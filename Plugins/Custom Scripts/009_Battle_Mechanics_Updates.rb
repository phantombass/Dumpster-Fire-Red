#===========================#
# MEGA SOL / PIERCING DRILL #
#===========================#

class Battler
  def effectiveWeather
    ret = @battle.pbWeather
    ret = :None if [:Sun, :Rain, :HarshSun, :HeavyRain].include?(ret) && hasActiveItem?(:UTILITYUMBRELLA)
    ret = :Sun if hasActiveAbility?(:MEGASOL)
    return ret
  end
  def pbSuccessCheckAgainstTarget(move, user, target, targets)
    show_message = move.pbShowFailMessages?(targets)
    typeMod = move.pbCalcTypeMod(move.calcType, user, target)
    target.damageState.typeMod = typeMod
    # Two-turn attacks can't fail here in the charging turn
    return true if user.effects[PBEffects::TwoTurnAttack]
    # Semi-invulnerable target
    if !pbSuccessCheckSemiInvulnerable(move, user, target)
      PBDebug.log("[Move failed] Target is semi-invulnerable")
      target.damageState.invulnerable = true
      return true   # Succeeds here but fails in def pbSuccessCheckPerHit
    end
    # Move-specific failures
    if move.pbFailsAgainstTarget?(user, target, show_message)
      PBDebug.log(sprintf("[Move failed] In function code %s's def pbFailsAgainstTarget?", move.function_code))
      return false
    end
    # Immunity to priority moves because of Psychic Terrain
    if @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user) &&
       @battle.choices[user.index][4] > 0   # Move priority saved from pbCalculatePriority
      @battle.pbDisplay(_INTL("{1} surrounds itself with psychic terrain!", target.pbThis)) if show_message
      return false
    end
    # Crafty Shield
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && user.index != target.index &&
       move.statusMove? && !move.pbTarget(user).targets_all
      if show_message
        @battle.pbCommonAnimation("CraftyShield", target)
        @battle.pbDisplay(_INTL("Crafty Shield protected {1}!", target.pbThis(true)))
      end
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    if !(user.hasActiveAbility?([:UNSEENFIST,:PIERCINGDRILL]) && move.pbContactMove?(user))
      # Wide Guard
      if target.pbOwnSide.effects[PBEffects::WideGuard] && user.index != target.index &&
         move.pbTarget(user).num_targets > 1 &&
         (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?)
        if show_message
          @battle.pbCommonAnimation("WideGuard", target)
          @battle.pbDisplay(_INTL("Wide Guard protected {1}!", target.pbThis(true)))
        end
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
      if move.canProtectAgainst?
        # Quick Guard
        if target.pbOwnSide.effects[PBEffects::QuickGuard] &&
           @battle.choices[user.index][4] > 0   # Move priority saved from pbCalculatePriority
          if show_message
            @battle.pbCommonAnimation("QuickGuard", target)
            @battle.pbDisplay(_INTL("Quick Guard protected {1}!", target.pbThis(true)))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          return false
        end
        # Protect
        if target.effects[PBEffects::Protect]
          if show_message
            @battle.pbCommonAnimation("Protect", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          return false
        end
        # Mat Block
        if target.pbOwnSide.effects[PBEffects::MatBlock] && move.damagingMove?
          # NOTE: Confirmed no common animation for this effect.
          @battle.pbDisplay(_INTL("{1} was blocked by the kicked-up mat!", move.name)) if show_message
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          return false
        end
        # King's Shield
        if target.effects[PBEffects::KingsShield] && move.damagingMove?
          if show_message
            @battle.pbCommonAnimation("KingsShield", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? &&
             user.pbCanLowerStatStage?(:ATTACK, target)
            user.pbLowerStatStage(:ATTACK, (Settings::MECHANICS_GENERATION >= 8) ? 1 : 2, target)
          end
          return false
        end
        # Obstruct
        if target.effects[PBEffects::Obstruct] && move.damagingMove?
          if show_message
            @battle.pbCommonAnimation("Obstruct", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? &&
             user.pbCanLowerStatStage?(:DEFENSE, target)
            user.pbLowerStatStage(:DEFENSE, 2, target)
          end
          return false
        end
        # Silk Trap
        if target.effects[PBEffects::SilkTrap] && move.damagingMove?
          if show_message
            @battle.pbCommonAnimation("SilkTrap", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? &&
             user.pbCanLowerStatStage?(:SPEED, target)
            user.pbLowerStatStage(:SPEED, 1, target)
          end
          return false
        end
        # Spiky Shield
        if target.effects[PBEffects::SpikyShield]
          if show_message
            @battle.pbCommonAnimation("SpikyShield", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? && user.takesIndirectDamage?
            @battle.scene.pbDamageAnimation(user)
            user.pbReduceHP(user.totalhp / 8, false)
            @battle.pbDisplay(_INTL("{1} was hurt!", user.pbThis))
            user.pbItemHPHealCheck
          end
          return false
        end
        # Baneful Bunker
        if target.effects[PBEffects::BanefulBunker]
          if show_message
            @battle.pbCommonAnimation("BanefulBunker", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? &&
             user.pbCanPoison?(target, false)
            user.pbPoison(target)
          end
          return false
        end
        # Burning Bulwark
        if target.effects[PBEffects::BurningBulwark]
          if show_message
            @battle.pbCommonAnimation("BurningBulwark", target)
            @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
          end
          target.damageState.protected = true
          @battle.successStates[user.index].protected = true
          if move.pbContactMove?(user) && user.affectedByContactEffect? &&
             user.pbCanBurn?(target, false)
            user.pbBurn(target)
          end
          return false
        end
      end
    end
    # Magic Coat/Magic Bounce
    if move.statusMove? && move.canMagicCoat? && !target.semiInvulnerable? && target.opposes?(user)
      if target.effects[PBEffects::MagicCoat]
        target.damageState.magicCoat = true
        target.effects[PBEffects::MagicCoat] = false
        return false
      end
      if target.hasActiveAbility?(:MAGICBOUNCE) && !target.beingMoldBroken? &&
         !target.effects[PBEffects::MagicBounce]
        target.damageState.magicBounce = true
        target.effects[PBEffects::MagicBounce] = true
        return false
      end
    end
    # Immunity because of ability (intentionally before type immunity check)
    return false if move.pbImmunityByAbility(user, target, show_message)
    # Type immunity
    if move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
      PBDebug.log("[Target immune] #{target.pbThis}'s type immunity")
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return false
    end
    # Dark-type immunity to moves made faster by Prankster
    if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::Prankster] &&
       target.pbHasType?(:DARK) && target.opposes?(user)
      PBDebug.log("[Target immune] #{target.pbThis} is Dark-type and immune to Prankster-boosted moves")
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return false
    end
    # Airborne-based immunity to Ground moves
    if move.damagingMove? && move.calcType == :GROUND &&
       target.airborne? && !move.hitsFlyingTargets?
      if target.hasActiveAbility?(:LEVITATE) && !target.beingMoldBroken?
        if show_message
          @battle.pbShowAbilitySplash(target)
          if Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} avoided the attack with {2}!", target.pbThis, target.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
        end
        return false
      end
      if target.hasActiveItem?(:AIRBALLOON)
        @battle.pbDisplay(_INTL("{1}'s {2} makes Ground moves miss!", target.pbThis, target.itemName)) if show_message
        return false
      end
      if target.effects[PBEffects::MagnetRise] > 0
        @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!", target.pbThis)) if show_message
        return false
      end
      if target.effects[PBEffects::Telekinesis] > 0
        @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!", target.pbThis)) if show_message
        return false
      end
    end
    # Immunity to powder-based moves
    if move.powderMove?
      if target.pbHasType?(:GRASS) && Settings::MORE_TYPE_EFFECTS
        PBDebug.log("[Target immune] #{target.pbThis} is Grass-type and immune to powder-based moves")
        @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
        return false
      end
      if Settings::MECHANICS_GENERATION >= 6
        if target.hasActiveAbility?(:OVERCOAT) && !target.beingMoldBroken?
          if show_message
            @battle.pbShowAbilitySplash(target)
            if Battle::Scene::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
            else
              @battle.pbDisplay(_INTL("It doesn't affect {1} because of its {2}.", target.pbThis(true), target.abilityName))
            end
            @battle.pbHideAbilitySplash(target)
          end
          return false
        end
        if target.hasActiveItem?(:SAFETYGOGGLES)
          PBDebug.log("[Item triggered] #{target.pbThis} has Safety Goggles and is immune to powder-based moves")
          @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
          return false
        end
      end
    end
    # Substitute
    if target.effects[PBEffects::Substitute] > 0 && move.statusMove? &&
       !move.ignoresSubstitute?(user) && user.index != target.index
      PBDebug.log("[Target immune] #{target.pbThis} is protected by its Substitute")
      @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis(true))) if show_message
      return false
    end
    return true
  end
end

#============================#
# SPICY SPRAY IMPLEMENTATION #
#============================#

Battle::AbilityEffects::OnBeingHit.add(:SPICYSPRAY,
  proc { |ability, user, target, move, battle|
    next if !move.pbDamagingMove?
    next if user.burned?
    next unless user.pbCanBurn?(target, Battle::Scene::USE_ABILITY_SPLASH)
    if user.pbCanBurn?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!", target.pbThis, target.abilityName, user.pbThis(true))
      end
      user.pbBurn(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

#==========================================================================================
# Poisons the target and decreases its Speed by 2 stages. (Toxic Thread, Champions Update)
#==========================================================================================
class Battle::Move::PoisonTargetLowerTargetSpeed1 < Battle::Move
  attr_reader :statDown

  def initialize(battle, move)
    super
    @statDown = [:SPEED, 2]
  end

  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.pbCanPoison?(user, false, self) &&
       !target.pbCanLowerStatStage?(@statDown[0], user, self)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    if target.pbCanLowerStatStage?(@statDown[0], user, self)
      target.pbLowerStatStage(@statDown[0], @statDown[1], user)
    end
  end
end

#==========================================
# Add Dragonize
#==========================================

Battle::AbilityEffects::ModifyMoveBaseType.add(:DRAGONIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:DRAGON)
    move.powerBoost = true
    next :DRAGON
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:AERILATE, :DRAGONIZE)

#====================================
# CUSTOM BATTLE EFFECTS
#====================================
Battle::AbilityEffects::OnSwitchIn.add(:FOREWARN,
  proc { |ability, battler, battle, switch_in|
    highestPower = 0
    forewarnMoves = []
    battle.allOtherSideBattlers(battler.index).each do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
        power = 150 if ["PowerHigherWithUserHP"].include?(m.function_code)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["CounterPhysicalDamage",
                        "CounterSpecialDamage",
                        "CounterDamagePlusHalf"].include?(m.function_code)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["FixedDamage20",
                       "FixedDamage40",
                       "FixedDamageUserLevel",
                       "LowerTargetHPToUserHP",
                       "FixedDamageUserLevelRandom",
                       "PowerHigherWithUserHappiness",
                       "PowerLowerWithUserHappiness",
                       "PowerHigherWithUserHP",
                       "PowerHigherWithTargetFasterThanUser",
                       "TypeAndPowerDependOnUserBerry",
                       "PowerHigherWithLessPP",
                       "PowerLowerWithUserHP",
                       "PowerHigherWithTargetWeight"].include?(m.function_code)
        power = 80 if Settings::MECHANICS_GENERATION <= 5 && m.function_code == "TypeDependsOnUserIVs"
        next if power < highestPower
        forewarnMoves = [] if power > highestPower
        forewarnMoves.push(m.name)
        highestPower = power
        $category = m.category
      end
    end
    if forewarnMoves.length > 0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis, forewarnMoveName))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis, forewarnMoveName))
      end
      stat = $category == 1 ? :SPECIAL_DEFENSE : :DEFENSE
      battler.pbRaiseStatStageByAbility(stat, 1, battler)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DOWNLOAD,
  proc { |ability, battler, battle, switch_in|
    oDef = oSpDef = 0
    battle.allOtherSideBattlers(battler.index).each do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef < oSpDef) ? :ATTACK : :SPECIAL_ATTACK
    mod = battler.hasActiveItem?(:UPGRADE) ? 2 : 1
    battler.pbRaiseStatStageByAbility(stat, mod, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:KEENEYE,
  proc { |ability, battler, battle, switch_in|
    next if battler.effects[PBEffects::FocusEnergy] >= 2
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbAnimation(GameData::Move.get(:FOCUSENERGY).id,battler,battler)
    battler.effects[PBEffects::FocusEnergy] = 2
    battle.pbDisplay(_INTL("{1} is getting pumped!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ILLUMINATE,
  proc { |ability, battler, battle, switch_in|
    next if battler.statStageAtMax?(:ACCURACY)
    battler.pbRaiseStatStageByAbility(:ACCURACY, 1, battler)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:WINDRIDER,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if user.index == target.index
    next false if !move.windMove?
    if show_message
      battle.pbShowAbilitySplash(target)
      user.effects[PBEffects::Charge] = 2
      battle.pbDisplay(_INTL("The strong winds charged {1} with power!", user.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:STEAMENGINE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if type == :WATER
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:WATERCOMPACTION,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if type == :WATER
  }
)

Battle::AbilityEffects::CriticalCalcFromTarget.copy(:BATTLEARMOR, :MAGMAARMOR, :PILLARPLANT)

#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
#===============================================================================

module Battle::AbilityEffects
  OnHazardsSet                        = AbilityHandlerHash.new
   def self.triggerOnHazardsSet(ability, battler, battle)
    return trigger(OnHazardsSet, ability, battler, battle)
  end
end

class Battle::Move::AddStealthRocksToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::StealthRock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StealthRock] = true
    @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
                            user.pbOpposingTeam(true)))
    @battle.battlers.each do |battler|
      next if user.idxOwnSide == battler.idxOwnSide
      Battle::AbilityEffects.triggerOnHazardsSet(battler.ability, battler, @battle) if battler.abilityActive?
    end
  end
end

Battle::AbilityEffects::OnHazardsSet.add(:PILLARPLANT,
  proc { |ability, battler, battle|
    battler.pbRaiseStatStageByAbility(:DEFENSE, 6, battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 6, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PILLARPLANT,
  proc { |ability, user, target, move, battle|
    if user.pbOwnSide.effects[PBEffects::StealthRock]
      user.pbRaiseStatStageByAbility(:DEFENSE, 6, user)
      user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 6, user)
    end
  }
)

class Battle::Move::SwitchOutTargetDragonTail < Battle::Move::FixedDamageMove
  def pbEffectAgainstTarget(user, target)
    if target.wild? && target.allAllies.length == 0 && @battle.canRun &&
       target.level <= user.level &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      @battle.decision = 3   # Escaped from battle
    end
  end

  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if moveType == :DRAGON && defType == :FAIRY
    return super
  end

  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if b.wild?
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)   # Random
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end

  def pbFixedDamage(user, target)
    exempt = [:PARAS,:SUNKERN].include?(target.pokemon.species)
    return ((target.totalhp*1.0) / 16.0).floor if exempt
    return ((target.totalhp*7.0) / 8.0).round
  end
end

Battle::AbilityEffects::MoveImmunity.add(:BLINDINGSPEED,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if user.index == target.index
    next false if [:COUNTER,:MIRRORCOAT,:METALBURST,:COMEUPPANCE].include?(move.id)
    if show_message
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} is moving too fast!", user.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

class Battle::Move::HealUserByHalfOfDamageDoneAbsorb < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg = 255 if target.pokemon.species == :ONIX
    return baseDmg
  end
end

Battle::ItemEffects::EndOfRoundHealing.add(:MOMSLEFTOVERS,
  proc { |item, battler, battle|
    next if !battler.canHeal?
    battle.pbCommonAnimation("UseItem", battler)
    battler.pbRecoverHP(battler.totalhp / 2)
    battle.pbDisplay(_INTL("{1} restored a lot of HP using its {2}!",
       battler.pbThis, battler.itemName))
  }
)

Battle::ItemEffects::HPHeal.add(:RAGECANDYBAR2,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    amt = 40
    battle.pbCommonAnimation("UseItem", battler) if !forced
    battler.pbRecoverHP(amt)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)