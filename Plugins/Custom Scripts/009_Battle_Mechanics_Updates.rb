#===========================#
# MEGA SOL / PIERCING DRILL #
#===========================#

class Battle::Battler
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
    if user.hasActiveAbility?(:HECKYEAH) && target.hasActiveAbility?(:STURDY)
      @battle.pbDisplay(_INTL("{1}'s {2} blocked {3}'s {4} from doing anything!",target.pbThis,target.abilityName,user.pbThis,user.abilityName)) if show_message
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
    battler.pbRaiseStatStageByAbility(:ACCURACY, 6, battler)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:WINDPOWER,
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
  OnTargetFlinch                         = AbilityHandlerHash.new
   def self.triggerOnHazardsSet(ability, battler, battle)
    return trigger(OnHazardsSet, ability, battler, battle)
  end
  def self.triggerOnTargetFlinch(ability, battler, battle)
    return trigger(OnTargetFlinch, ability, battler, battle)
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
    exempt = [:PARAS,:SUNKERN,:PARASECT,:SUNFLORA].include?(target.pokemon.species)
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

class Battle::Move::FixedDamage40 < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return 40
  end
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if moveType == :DRAGON && defType == :FAIRY
    return super
  end
end

class Battle::Battler
  def pbTryUseMove(choice, move, specialUsage, skipAccuracyCheck)
    # Check whether it's possible for self to use the given move
    # NOTE: Encore has already changed the move being used, no need to have a
    #       check for it here.
    if !pbCanChooseMove?(move, false, true, specialUsage)
      @lastMoveFailed = true
      return false
    end
    # Check whether it's possible for self to do anything at all
    if @effects[PBEffects::SkyDrop] >= 0   # Intentionally no message here
      PBDebug.log("[Move failed] #{pbThis} can't use #{move.name} because of being Sky Dropped")
      return false
    end
    if @effects[PBEffects::HyperBeam] > 0   # Intentionally before Truant
      PBDebug.log("[Move failed] #{pbThis} is recharging after using #{move.name}")
      @battle.pbDisplay(_INTL("{1} must recharge!", pbThis))
      @effects[PBEffects::Truant] = !@effects[PBEffects::Truant] if hasActiveAbility?(:TRUANT)
      return false
    end
    if choice[1] == -2   # Battle Palace
      PBDebug.log("[Move failed] #{pbThis} can't act in the Battle Palace somehow")
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!", pbThis))
      return false
    end
    # Skip checking all applied effects that could make self fail doing something
    return true if skipAccuracyCheck
    # Check status problems and continue their effects/cure them
    case @status
    when :SLEEP
      self.statusCount -= 1
      if @statusCount <= 0
        pbCureStatus
      else
        pbContinueStatus
        if !move.usableWhenAsleep?   # Snore/Sleep Talk
          PBDebug.log("[Move failed] #{pbThis} is asleep")
          @lastMoveFailed = true
          return false
        end
      end
    when :FROZEN
      if !move.thawsUser?
        if @battle.pbRandom(100) < 20
          pbCureStatus
        else
          pbContinueStatus
          PBDebug.log("[Move failed] #{pbThis} is frozen")
          @lastMoveFailed = true
          return false
        end
      end
    end
    # Obedience check
    return false if !pbObedienceCheck?(choice)
    # Truant
    if hasActiveAbility?(:TRUANT)
      @effects[PBEffects::Truant] = !@effects[PBEffects::Truant]
      if !@effects[PBEffects::Truant]   # True means loafing, but was just inverted
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is loafing around!", pbThis))
        @lastMoveFailed = true
        @battle.pbHideAbilitySplash(self)
        PBDebug.log("[Move failed] #{pbThis} can't act because of #{abilityName}")
        return false
      end
    end
    # Flinching
    if @effects[PBEffects::Flinch]
      @battle.pbDisplay(_INTL("{1} flinched and couldn't move!", pbThis))
      PBDebug.log("[Move failed] #{pbThis} flinched")
      if abilityActive?
        Battle::AbilityEffects.triggerOnFlinch(self.ability, self, @battle)
      end
      @battle.battlers.each do |b|
        next if self.idxOwnSide == b.idxOwnSide
        Battle::AbilityEffects.triggerOnTargetFlinch(b.ability,b,@battle) if b.abilityActive?
      end
      @lastMoveFailed = true
      return false
    end
    # Confusion
    if @effects[PBEffects::Confusion] > 0
      @effects[PBEffects::Confusion] -= 1
      if @effects[PBEffects::Confusion] <= 0
        pbCureConfusion
        @battle.pbDisplay(_INTL("{1} snapped out of its confusion.", pbThis))
      else
        @battle.pbCommonAnimation("Confusion", self)
        @battle.pbDisplay(_INTL("{1} is confused!", pbThis))
        threshold = (Settings::MECHANICS_GENERATION >= 7) ? 33 : 50   # % chance
        if @battle.pbRandom(100) < threshold
          pbConfusionDamage(_INTL("It hurt itself in its confusion!"))
          PBDebug.log("[Move failed] #{pbThis} hurt itself in its confusion")
          @lastMoveFailed = true
          return false
        end
      end
    end
    # Paralysis
    if @status == :PARALYSIS && @battle.pbRandom(100) < 25
      pbContinueStatus
      PBDebug.log("[Move failed] #{pbThis} is paralyzed")
      @lastMoveFailed = true
      return false
    end
    # Infatuation
    if @effects[PBEffects::Attract] >= 0
      @battle.pbCommonAnimation("Attract", self)
      @battle.pbDisplay(_INTL("{1} is in love with {2}!", pbThis,
                              @battle.battlers[@effects[PBEffects::Attract]].pbThis(true)))
      if @battle.pbRandom(100) < 50
        @battle.pbDisplay(_INTL("{1} is immobilized by love!", pbThis))
        PBDebug.log("[Move failed] #{pbThis} is immobilized by love")
        @lastMoveFailed = true
        return false
      end
    end
    return true
  end

  def pbProcessMoveHit(move, user, targets, hitNum, skipAccuracyCheck)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    heal_turn = hitNum.odd?
    move.pbInitialEffect(user, targets, hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond] > 0
    # Accuracy check (accuracy/evasion calc)
    if hitNum == 0 || move.successCheckPerHit?
      targets.each do |b|
        b.damageState.missed = false
        next if b.damageState.unaffected
        if pbSuccessCheckPerHit(move, user, b, skipAccuracyCheck)
          numTargets += 1
        else
          b.damageState.missed     = true
          b.damageState.unaffected = true
        end
      end
      # If failed against all targets
      if targets.length > 0 && numTargets == 0 && !move.worksWithNoTargets?
        targets.each do |b|
          next if !b.damageState.missed || b.damageState.magicCoat
          pbMissMessage(move, user, b)
          if user.itemActive?
            Battle::ItemEffects.triggerOnMissingTarget(user.item, user, b, move, hitNum, @battle)
          end
          break if move.pbRepeatHit?   # Dragon Darts only shows one failure message
        end
        move.pbCrashDamage(user)
        user.pbItemHPHealCheck
        pbCancelMoves
        return false
      end
    end
    # If we get here, this hit will happen and do something
    all_targets = targets
    targets = move.pbDesignateTargetsForHit(targets, hitNum)   # For Dragon Darts
    targets.each { |b| b.damageState.resetPerHit }
    #---------------------------------------------------------------------------
    # Calculate damage to deal
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # Check whether Substitute/Disguise will absorb the damage
        move.pbCheckDamageAbsorption(user, b)
        # Calculate the damage against b
        # pbCalcDamage shows the "eat berry" animation for SE-weakening
        # berries, although the message about it comes after the additional
        # effect below
        move.pbCalcDamage(user, b, targets.length)   # Stored in damageState.calcDamage
        # Lessen damage dealt because of False Swipe/Endure/etc.
        move.pbReduceDamage(user, b)   # Stored in damageState.hpLost
      end
    end
    # Show move animation (for this hit)
    move.pbShowAnimation(move.id, user, targets, hitNum)
    # Type-boosting Gem consume animation/message
    if user.effects[PBEffects::GemConsumed] && hitNum == 0
      # NOTE: The consume animation and message for Gems are shown now, but the
      #       actual removal of the item happens in def pbEffectsAfterMove.
      @battle.pbCommonAnimation("UseItem", user)
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
                              GameData::Item.get(user.effects[PBEffects::GemConsumed]).name, move.name))
    end
    # Messages about missed target(s) (relevant for multi-target moves only)
    if !move.pbRepeatHit?
      targets.each do |b|
        next if !b.damageState.missed
        pbMissMessage(move, user, b)
        if user.itemActive?
          Battle::ItemEffects.triggerOnMissingTarget(user.item, user, b, move, hitNum, @battle)
        end
      end
    end
    # Deal the damage (to all allies first simultaneously, then all foes
    # simultaneously)
    healed = false
    if move.pbDamagingMove?
      # This just changes the HP amounts and does nothing else
      targets.each do  |b|
        if heal_turn && b.hasActiveAbility?(:PARRYBLOW)
          move.pbHealHPDamage(b) if !b.damageState.unaffected
          healed = true
        else
          move.pbInflictHPDamage(b) if !b.damageState.unaffected
        end
      end
      # Animate the hit flashing and HP bar changes
      move.pbAnimateHitAndHPLost(user, targets) unless healed
    end
    return true if healed
    # Self-Destruct/Explosion's damaging and fainting of user
    move.pbSelfKO(user) if hitNum == 0
    user.pbFaint if user.fainted?
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # NOTE: This method is also used for the OHKO special message.
        move.pbHitEffectivenessMessages(user, b, targets.length)
        # Record data about the hit for various effects' purposes
        move.pbRecordDamageLost(user, b)
      end
      # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
      # and Incinerate's berry destruction
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectWhenDealingDamage(user, b)
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move, user, b)
      end
      # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEndureKOMessage(b)
      end
      # HP-healing held items (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each do |b|
        next if move.preventsBattlerConsumingHealingBerry?(b, targets)
        b.pbItemHPHealCheck
      end
      # Animate battlers fainting (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbFaint if b&.fainted? }
    end
    @battle.pbJudgeCheckpoint(user, move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user, b)
    end
    move.pbEffectGeneral(user)
    targets.each do |b|
      next if !b&.fainted?
      b.pbFaint
      if user.pokemon.isSpecies?(:BISHARP) && b.isSpecies?(:BISHARP) && b.item == :LEADERSCREST
        user.pokemon.evolution_counter += 1
      end
    end
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage == 0
        chance = move.pbAdditionalEffectChance(user, b)
        next if chance <= 0
        move.pbAdditionalEffect(user, b) if @battle.pbRandom(100) < chance
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage == 0 || b.damageState.substitute
      chance = move.pbFlinchChance(user, b)
      next if chance <= 0
      if @battle.pbRandom(100) < chance
        PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
        b.pbFlinch(user)
      end
    end
    # Message for and consuming of type-weakening berries
    # NOTE: The "consume held item" animation for type-weakening berries occurs
    #       during pbCalcDamage above (before the move's animation), but the
    #       message about it only shows here.
    targets.each do |b|
      next if b.damageState.unaffected
      next if !b.damageState.berryWeakened
      b.damageState.berryWeakened = false   # Weakening only applies for one hit
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!", b.itemName, b.pbThis(true)))
      b.pbConsumeItem
    end
    # Steam Engine (goes here because it should be after stat changes caused by
    # the move)
    if [:FIRE, :WATER].include?(move.calcType)
      targets.each do |b|
        next if b.damageState.unaffected
        next if b.damageState.calcDamage == 0 || b.damageState.substitute
        next if !b.hasActiveAbility?(:STEAMENGINE)
        b.pbRaiseStatStageByAbility(:SPEED, 6, b) if b.pbCanRaiseStatStage?(:SPEED, b)
      end
    end
    # Fainting
    targets.each { |b| b.pbFaint if b&.fainted? }
    user.pbFaint if user.fainted?
    # Dragon Darts' second half of attack
    if move.pbRepeatHit? && hitNum == 0 &&
       targets.any? { |b| !b.fainted? && !b.damageState.unaffected }
      pbProcessMoveHit(move, user, all_targets, 1, skipAccuracyCheck)
    end
    return true
  end
end

Battle::AbilityEffects::OnTargetFlinch.add(:MASOCHIST,
  proc { |ability, battler, battle|
    battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
  }
)

class Battle::Move::HitFourTimesOneTimeIfIce < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets)
    if targets.any? { |target| target.pbHasType?(:ICE) || target.pbHasType?(:GHOST)  }
      return 1
    else
      return 4
    end
  end
  def pbFixedDamage(user, target)
    return 1 if target.pbHasType?(:ICE)
    return 1 if target.pbHasType?(:GHOST)
    return (target.totalhp/4).floor
  end
end

class Battle::Move::HitTwiceAsManyAsHeads < Battle::Move
  def multiHitMove?;            return true; end
  def numHeads(user)
    if [:DODUO,:GIRAFARIG,:FARIGIRAF,:TANDEMAUS,:WEEZING,:CHERUBI,:DRAKLOAK,:DOUBLADE,:KLINK,:KLANG,:VANILLUXE,:SLOWBRO,:SLOWKING,:BINACLE,:METANG].include?(user.pokemon.species)
      heads = 2
    elsif [:DODRIO,:HYDREIGON,:DUGTRIO,:WUGTRIO,:EXEGGUTOR,:MAGNETON,:COMBEE,:DRAGAPULT,:KLINKLANG,:MAGNEZONE].include?(user.pokemon.species)
      heads = 3
    elsif user.pokemon.species == :MAUSHOLD
      if user.pokemon.form == 1
        heads = 3
      else
        heads = 4
      end
    elsif user.pokemon.species == :METAGROSS
      heads = (user.pokemon.form == 1) ? 8 : 4
    elsif [:HYDRAPPLE,:FALINKS].include?(user.pokemon.species)
      heads = 5
    elsif user.pokemon.species == :EXEGGCUTE
      heads = 6
    end
    return heads
  end
  def pbNumHits(user, targets)
    heads = numHeads(user)
    return heads * 2
  end
  def pbBaseDamage(baseDmg, user, target)
    heads = numHeads(user)
    return baseDmg if heads == 1
    baseDmg = (baseDmg*heads)/(heads+1)
    return baseDmg
  end
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if moveType == :NORMAL
    return super
  end
  def preventsBattlerConsumingHealingBerry?(battler, targets)
    return targets.any? { |b| b.index == battler.index } &&
           battler.item&.is_berry? && Battle::ItemEffects::HPHeal[battler.item] && @type == :FLYING
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || !target.item.is_berry? || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    return unless @type == :FLYING
    item = target.item
    itemName = target.itemName
    user.setBelched
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
    user.pbHeldItemTriggerCheck(item.id, false)
    user.pbSymbiosis
  end
end

class Battle::Move
  def pbHealHPDamage(target)
    if target.damageState.substitute
    elsif target.damageState.hpLost > 0
      target.pbRecoverHP(target.damageState.hpLost)
    end
  end
end

Battle::AbilityEffects::MoveImmunity.copy(:WONDERGUARD,:POWEROFALCHEMY)

Battle::AbilityEffects::ChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability, battler, fainted, battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler, true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battler.ability = :POWEROFALCHEMY
    battle.pbDisplay(_INTL("{1}'s {2} was added!", fainted.pbThis, fainted.abilityName))
    $ability_received = fainted.ability
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:POWEROFALCHEMY,
  proc { |ability, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 2 if move.physicalMove? && $ability_received == :HUGEPOWER
  }
)

Battle::AbilityEffects::OnBeingHit.add(:BATTERY,
  proc { |ability, user, target, move, battle|
    next if target.fainted?
    if target.effects[PBEffects::Charge] > 0
      next if target.hp == target.totalhp
      battle.pbShowAbilitySplash(target)
      target.pbRecoverHP((target.totalhp/4).round)
      battle.pbDisplay(_INTL("Because it is already charged up, being hit by {1} recovered some of {2}'s HP!", move.name, target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    else
      battle.pbShowAbilitySplash(target)
      target.effects[PBEffects::Charge] = 2
      battle.pbDisplay(_INTL("Being hit by {1} charged {2} with power!", move.name, target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
  }
)

Battle::ItemEffects::AfterMoveUseFromTarget.add(:EJECTBERRY,
  proc { |item, battler, user, move, switched_battlers, battle|
    next if !switched_battlers.empty?
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
    battle.pbCommonAnimation("EatBerry", battler)
    battle.pbDisplay(_INTL("{1} is switched out with the {2}!", battler.pbThis, battler.itemName))
    battler.pbConsumeItem(true, false)
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next if newPkmn < 0
    battle.pbRecallAndReplace(battler.index, newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    switched_battlers.push(battler.index)
    battle.moldBreaker = false if battler.index == user.index
    battle.pbOnBattlerEnteringBattle(battler.index)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic, Settings::FIXED_DURATION_WEATHER_FROM_ABILITY)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MISTYSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Misty, Settings::FIXED_DURATION_WEATHER_FROM_ABILITY)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:GRASSYSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grassy, Settings::FIXED_DURATION_WEATHER_FROM_ABILITY)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric, Settings::FIXED_DURATION_WEATHER_FROM_ABILITY)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)