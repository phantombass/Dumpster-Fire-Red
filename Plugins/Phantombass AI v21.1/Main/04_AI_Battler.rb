class Battle::AI::AIBattler
	attr_accessor :threat_scores,:threat_flags,:highest_damaging_move

	def initialize(ai, index)
   @ai = ai
   @index = index
   @side = (@ai.battle.opposes?(@index)) ? 1 : 0
   @threat_scores = [0,0,0,0]
   @highest_damaging_move = {}
   refresh_battler
  end

  def refresh_battler
		old_party_index = @party_index
		@battler = @ai.battle.battlers[@index]
		@party_index = battler.pokemonIndex
		@threat_flags = {}
	end

  def calc_highest_damage(target)
    @highest_damaging_move[target] = user_highest_damaging_move_non_explosive(target)
  end

  def highest_damaging_move(target)
    return @highest_damaging_move[target]
  end

  def log_threat_scores(target)
    @threat_scores[target.index] = assess_threats(target)
  end

	def threat_scores(target)
		return @threat_scores[target.index]
	end

  def threats
    return @threat_scores
  end

  def threat_flags
    return @threat_flags
  end

  def roles
    return battler.roles
  end

  def pbSpeed
    return rough_stat(:SPEED)
  end

  def pbEncoredMoveIndex
    return -1 if @effects[PBEffects::Encore] == 0 || !@effects[PBEffects::EncoreMove]
    ret = -1
    eachMoveWithIndex do |m, i|
      next if m.id != @effects[PBEffects::EncoreMove]
      ret = i
      break
    end
    return ret
  end

  def hasActiveAbility?(ability)
    return has_active_ability?(ability)
  end

  def has_role?(role)
    x = []
    for i in roles
      x.push(i)
      if role.is_a?(Array)
        if role.include?(i)
          return true
        end
      end
    end
    return x.include?(role) && !role.is_a?(Array)
  end

  def can_sleep?(inflictor, move, ignore_status = false)
    return battler.pbCanSleep?(inflictor, false, move, ignore_status)
  end

  def can_poison?(inflictor, move)
    return battler.pbCanPoison?(inflictor, false, move)
  end

  def can_burn?(inflictor, move)
    return battler.pbCanBurn?(inflictor, false, move)
  end

  def can_paralyze?(inflictor, move)
    return battler.pbCanParalyze?(inflictor, false, move)
  end

  def can_freeze?(inflictor, move)
    return battler.pbCanFreeze?(inflictor, false, move)
  end

  def has_move?(*ids)
    check_for_move { |m| return true if ids.include?(m.id) }
    return false
  end

	def assess_threats(target)
	  score = 0
      if @ai.battle.wildBattle?
        PBDebug.log_ai("Threat assessment skipped for being a wild battle")
        return score
      end
      score += Battle::AI::ThreatAssessment.threat_damage(self,target)
      score += target.set_up_score
      PBDebug.log("     Threat Score for #{target.name}: #{score}")
      return score
  	end

    def set_flags(target)
      str = ""
      str += "     Checking flags..."
      if !flags_set?(target)
        str += "\n     No flags found."
        str += "\n     Setting flags..."
        off_move = target.moves.length
        prio = 0
        for i in target.moves
          if ["ResetAllBattlersStatStages","UserStealTargetPositiveStatStages"].include?(i.function_code)
            @ai.add_knowledge(:haze_flag,target)
            str += "\n     #{target.name} has been assigned Haze flag"
          end
          if i.statusMove?
            off_move -= 1
          end
          if i.priority > 0
            prio += 1
          end
        end
        if target.battler.hasActiveAbility?(:UNAWARE)
          @ai.add_knowledge(:haze_flag,target)
          str += "\n     #{target.name} has been assigned Haze flag"
        end
        str += "\n     Offensive Move Count: #{off_move}"
        str += "\n     Priority Move Count: #{prio}"
        if off_move == 0
          @ai.add_knowledge(:no_attacking,target)
          str += "\n     #{target.name} has been assigned No Attacking Flag"
        end
        if off_move < target.moves.length - 2
          @ai.add_knowledge(:should_taunt,target)
          str += "\n     #{target.name} has been assigned Should Taunt flag"
        end
        if prio == 0
          @ai.add_knowledge(:no_priority,target)
          str += "\n     #{target.name} has been assigned No Priority flag"
        end
        if target.choice_locked?
          @ai.add_knowledge(:choice_locked,target)
        end
        @ai.add_knowledge(:flags_set,target)
       str += "\n     End flag assignment."
     else
      str += "     Flags found.\n     End flag search"
     end
     PBDebug.log(str)
    end

    def flags_set?(target)
      return @ai.knowledge_flags[:flags_set].include?(target)
    end

    def choice_locked?
      return true if effects[PBEffects::ChoiceBand] != nil
      return false
    end

  	def set_up_score
      stats = [:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
      boosts = []
      score = 0
      for stat in stats
        boosts.push(self.stages[stat]) if ((self.is_physical_attacker? && stat != :SPECIAL_ATTACK) || (self.is_special_attacker? && stat != :ATTACK))
      end
      for i in boosts
        score += i
      end
      #score += 1 if self.battler.effects[PBEffects::ParadoxStat]
      PBDebug.log("Set up score for #{self.name}: #{score}")
      return score
    end

    def set_up_max?(move)
      if Battle::AI::AIMove.offense_setup_move?(move)
        max = (@battler.stages[:ATTACK] == 6 || @battler.stages[:SPECIAL_ATTACK] == 6)
      elsif Battle::AI::AIMove.defense_setup_move?(move)
        max = (@battler.stages[:DEFENSE] == 6 || @battler.stages[:SPECIAL_DEFENSE] == 6)
      elsif Battle::AI::AIMove.speed_setup_move?(move)
        max = @battler.stages[:SPEED] == 6
      end
      return max
    end

    def is_physical_attacker?
      stats = [rough_stat(:ATTACK), rough_stat(:SPECIAL_ATTACK)]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      physcount = 0
      attackBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        physcount += 1 if move.physicalMove?
        if move.is_a?(Battle::Move::StatUpMove)
          for i in 0...move.statUp.size / 2
            attackBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if physcount == 0
      if rough_stat(:ATTACK) >= min
        # Has high attack stat
        # All physical moves would be a solid bet since we have a high attack stat.
        return true
      elsif rough_stat(:ATTACK) >= avg
        # Attack stat is not high, but still above average
        # If this Pokémon has any attack-boosting moves, or more than 1 physical move,
        # we consider this Pokémon capable of being a physical attacker.
        return true if physcount > 1
        return true if attackBoosters >= 1
        return true if self.has_role?(:PHYSICALBREAKER)
      end
      return false
    end

    # If this is true, this Pokémon will be treated as being a special attacker.
    # This means that the Pokémon will be more likely to try to use spatk-boosting and
    # spdef-lowering status moves, and will be even more likely to use strong special moves
    # if any of these status boosts are active.
    def is_special_attacker?
      stats = [rough_stat(:ATTACK), rough_stat(:SPECIAL_ATTACK)]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      speccount = 0
      spatkBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        speccount += 1 if move.specialMove?
        if move.is_a?(Battle::Move::StatUpMove)
          for i in 0...move.statUp.size / 2
            spatkBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :SPECIAL_ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if speccount == 0
      if rough_stat(:SPECIAL_ATTACK) >= min
        # Has high spatk stat
        # All special moves would be a solid bet since we have a high spatk stat.
        return true
      elsif rough_stat(:SPECIAL_ATTACK) >= avg
        # Spatk stat is not high, but still above average
        # If this Pokémon has any spatk-boosting moves, or more than 1 special move,
        # we consider this Pokémon capable of being a special attacker.
        return true if speccount > 1
        return true if spatkBoosters >= 1
        return true if self.has_role?(:SPECIALBREAKER)
      end
      return false
    end

	def has_killing_move?(target,switching=false)
    moves.each do |move|
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,switching) >= target.hp
    end
    return false
	end

  def has_killing_priority?(target,switching=false)
    moves.each do |move|
      next if move.priority < 1
      next if move.statusMove?
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,switching) >= target.hp
    end
  end

  def has_helping_hand_kill?(target)
    moves.each do |move|
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,false)*1.5 >= target.hp
    end
    return false
  end
  def has_passive_healing?
    return true if self.item == :LEFTOVERS
    return true if self.types.include?(:POISON) && self.item == :BLACKSLUDGE
    return true if self.has_active_ability?(:RESURGENCE)
    return false
  end
  def target_has_hazard_removal?(target)
    hazard = target.moves.select {|move| move && Battle::AI::AIMove.hazard_removal_move?(move.id)}.size
    return hazard > 0
  end
  def target_has_screen_removal?(target)
    hazard = target.moves.select {|move| move && Battle::AI::AIMove.screen_removal_move?(move.id)}.size
    ret = hazard > 0 && self.pbSpeed > target.pbSpeed
    return ret
  end
  def target_has_potential_magic_bounce?(target)
    return true if target.has_active_ability?(:MAGICBOUNCE)
    mons = {
      :pokemon => [:ABSOL,:EMPOLEON,:SABLEYE,:DIANCIE],
      :item => [:ABSOLITE,:EMPOLEONITE,:SABLENITE,:DIANCITE]
    }
    ret = false
    mons[:pokemon].each_with_index do |pkmn,idx|
      if target.pokemon.species == pkmn && target.item == mons[:item][idx]
        ret = true
      end
    end
    return ret
  end
  def either_target_can_kill?(target)
    if @ai.battle.pbSideSize(0) == 2
      dmg = 0
      @ai.battlers.each do |tar|
        next if target.idxOwnSide != tar.idxOwnSide
        dmg += 1 if target_has_killing_move?(tar)
      end
      return dmg > 0
    else
      return target_has_killing_move?(target)
    end
  end

	def either_target_can_2hko?(target)
      if @ai.battle.pbSideSize(0) == 2
        dmg = 0
        @ai.battlers.each do |tar|
          next if target.idxOwnSide != tar.idxOwnSide
          dmg += 1 if target_has_2hko?(tar)
        end
        return dmg > 0
      else
        return target_has_2hko?(target)
      end
    end

    def either_target_can_fast_2hko?(target)
      if @ai.battle.pbSideSize(0) == 2
        dmg = 0
        @ai.battlers.each do |tar|
          next if target.idxOwnSide != tar.idxOwnSide
          dmg += 1 if target_has_fast_2hko?(tar)
        end
        return dmg > 0
      else
        return target_has_fast_2hko?(target)
      end
    end

    def target_has_killing_move?(target,switching=false)
      return target.has_killing_move?(battler,switching)
    end

    def fast_kill?(target,switching=false)
      return has_killing_move?(target,switching) && (battler.pbSpeed > target.pbSpeed || has_killing_priority?(target,switching))
    end

    def fast_helping_hand?(target)
      return has_helping_hand_kill?(target) && battler.pbSpeed > target.pbSpeed
    end

    def slow_helping_hand?(target)
      return has_helping_hand_kill?(target) && !target_fast_kill?(target)
    end

    def helping_hand_kill?(target)
      return fast_helping_hand?(target) || slow_helping_hand?(target)
    end

    def slow_kill?(target,switching=false)
      return has_killing_move?(target,switching) && target.pbSpeed >= battler.pbSpeed
    end

    def target_fast_kill?(target,switching=false)
      return target_has_killing_move?(target,switching) && (target.pbSpeed >= battler.pbSpeed || target.has_killing_priority?(target,switching))
    end

    def target_slow_kill?(target)
      return target_has_killing_move?(target) && battler.pbSpeed > target.pbSpeed
    end

    def target_has_fast_2hko?(target)
      return true if target_fast_kill?(target)
      for move in target.moves
        next if move.statusMove?
        mov = Battle::AI::FakeMove.new(@ai,move)
        return true if mov.rough_damage(target,self) >= battler.hp/2 && (target.pbSpeed >= battler.pbSpeed || has_killing_priority?(battler))
      end
      return false
    end
    def target_has_2hko?(target)
      return true if target_fast_kill?(target)
      for move in target.moves
        next if move.statusMove?
        mov = Battle::AI::FakeMove.new(@ai,move)
        return true if mov.rough_damage(target,self) >= battler.hp/2
      end
      return false
    end

    def target_highest_move_damage(target)
      move_damage = []
      target.moves.each do |move|
        mov = Battle::AI::FakeMove.new(@ai,move)
        move.damagingMove? && move_damage.push(mov.rough_damage(target,battler))
      end
      return 0 if move_damage.length == 0
      move_damage = move_damage.sort
      return move_damage[-1]
    end
    def user_highest_move_damage(target)
      move_damage = []
      battler.moves.each do |move|
        mov = Battle::AI::FakeMove.new(@ai,move)
        move.damagingMove? && move_damage.push(mov.rough_damage(battler,target))
      end
      return 0 if move_damage.length == 0
      move_damage = move_damage.sort
      return move_damage[-1]
    end
    def target_highest_damaging_move(target)
      move_damage = []
      target.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(target,battler)
        move_damage.push([move,dmg])
      end
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def user_highest_damaging_move(target)
      move_damage = []
      battler.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(battler,target)
        move_damage.push([move,dmg])
      end
      return battler.moves[0] if move_damage.length == 0
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def user_highest_damaging_move_non_explosive(target)
      move_damage = []
      battler.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        next if [:SELFDESTRUCT,:EXPLOSION,:MISTYEXPLOSION].include?(move.id)
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(battler,target,true)
        move_damage.push([move,dmg])
      end
      return battler.moves[0] if move_damage.length == 0
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def effectiveness_of_type_against_battler(type, user = nil, move = nil)
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      return ret if !type
      return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
      # Get effectivenesses
      if type == :SHADOW
        if battler.shadowPokemon?
          ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
        else
          ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
        end
      else
        battler.pbTypes(true).each do |defend_type|
          mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
          #p "#{battler.name}: #{move.name} (#{type}) vs #{defend_type} = #{mult}"
          if move
            case move.function_code
            when "HitsTargetInSkyGroundsTarget"
              mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING
            when "FreezeTargetSuperEffectiveAgainstWater"
              mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER
            end
          end
          ret *= mult
        end
        ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
      end
      return ret
    end
end

class Battle::Battler
  def faster_than?(target)
    this_speed = self.pbSpeed
    other_speed = target.pbSpeed
    return (this_speed > other_speed) ^ (@battle.field.effects[PBEffects::TrickRoom] > 0)
  end
  def has_active_ability?(ability, ignore_fainted = false)
    return hasActiveAbility?(ability, ignore_fainted)
  end
  def ability_active?
    return abilityActive?
  end
  def item_active?
    return itemActive?
  end

  def pbMoveTypeWeakeningBerryCalc(berry_type, move_type, mults)
    return if move_type != berry_type
    return if effectiveness_of_type_against_battler(move_type) < 2.0 && move_type != :NORMAL
    # PBDebug.log("     =====> Before Mult: #{mults[:final_damage_multipliers]}")
    mults[:final_damage_multiplier] /= 2
    if self.pokemon.ability == :RIPEN
      mults[:final_damage_multiplier] /= 2
    end
    # PBDebug.log("     =====> After Mult: #{mults[:final_damage_multipliers]}")
  end

  def has_active_item?(item)
    return hasActiveItem?(item)
  end
  def has_type?(type)
    return false if !type
    active_types = pbTypes(true)
    return active_types.include?(GameData::Type.get(type).id)
  end
  def effectiveness_of_type_against_battler(type, user = nil, move = nil)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !type
    return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
    # Get effectivenesses
    if type == :SHADOW
      if self.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      self.pbTypes(true).each do |defend_type|
        mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
        #p "#{battler.name}: #{move.name} (#{type}) vs #{defend_type} = #{mult}"
        if move
          case move.function_code
          when "HitsTargetInSkyGroundsTarget"
            mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING
          when "FreezeTargetSuperEffectiveAgainstWater"
            mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER
          end
        end
        ret *= mult
      end
      ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
    end
    return ret
  end
  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (self&.has_active_ability?(:SCRAPPY) || self.effects[PBEffects::Foresight]) &&
         defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if self.effects[PBEffects::MiracleEye] && defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if self.effectiveWeather == :StrongWinds && defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !self.airborne? && defend_type == :FLYING && type == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    if Effectiveness.ineffective_type?(type, defend_type)
      if self&.has_active_ability?(:MINDSEYE) && defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    return ret
  end
  def pbOwnSide
    return idxOwnSide == false ? @battle.sides[1] : @battle.sides[idxOwnSide]
  end
end

#===============================================================================
#
#===============================================================================
class Battle::AI::FakeBattler
  attr_reader :index, :side, :party_index
  attr_reader :battler

  def initialize(ai, pokemon, index)
    @ai = ai
    @pokemon = pokemon
    @battler.pokemon = @pokemon
    @index = index
    refresh_battler
  end

  def refresh_battler
    party = @ai.battle.pbParty(@index)
    party.each_with_index do |pkmn,idx|
      @party_index = idx if @pokemon == pkmn
    end
  end

  def pokemon;     return @pokemon;     end
  def level;       return battler.level;       end
  def hp;          return battler.hp;          end
  def totalhp;     return battler.totalhp;     end
  def fainted?;    return battler.fainted?;    end
  def status;      return battler.status;      end
  def statusCount; return battler.statusCount; end
  def gender;      return battler.gender;      end
  def turnCount;   return battler.turnCount;   end
  def effects;     return battler.effects;     end
  def stages;      return battler.stages;      end
  def statStageAtMax?(stat); return battler.statStageAtMax?(stat); end
  def statStageAtMin?(stat); return battler.statStageAtMin?(stat); end
  def moves;       return battler.moves;       end

  def wild?
    return @ai.battle.wildBattle? && opposes?
  end

  def name
    return sprintf("%s (%d)", battler.name, @index)
  end

  def opposes?(other = nil)
    return @side == 1 if other.nil?
    return other.side != @side
  end

  def idxOwnSide;      return battler.idxOwnSide;      end
  def pbOwnSide;       return battler.pbOwnSide;       end
  def idxOpposingSide; return battler.idxOpposingSide; end
  def pbOpposingSide;  return battler.pbOpposingSide;  end

  #-----------------------------------------------------------------------------

  # Returns how much damage this battler will take at the end of this round.
  def rough_end_of_round_damage
    ret = 0
    # Weather
    weather = battler.effectiveWeather
    if @ai.battle.field.weatherDuration == 1
      weather = @ai.battle.field.defaultWeather
      weather = :None if @ai.battle.allBattlers.any? { |b| b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK]) }
      weather = :None if [:Sun, :Rain, :HarshSun, :HeavyRain].include?(weather) && has_active_item?(:UTILITYUMBRELLA)
    end
    case weather
    when :Sandstorm
      ret += [self.totalhp / 16, 1].max if battler.takesSandstormDamage?
    when :Hail
      ret += [self.totalhp / 16, 1].max if battler.takesHailDamage?
    when :ShadowSky
      ret += [self.totalhp / 16, 1].max if battler.takesShadowSkyDamage?
    end
    case ability_id
    when :DRYSKIN
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
      ret -= [self.totalhp / 8, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :ICEBODY
      ret -= [self.totalhp / 16, 1].max if weather == :Hail && battler.canHeal?
    when :RAINDISH
      ret -= [self.totalhp / 16, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :SOLARPOWER
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
    end
    # Future Sight/Doom Desire
    # NOTE: Not worth estimating the damage from this.
    # Wish
    if @ai.battle.positions[@index].effects[PBEffects::Wish] == 1 && battler.canHeal?
      ret -= @ai.battle.positions[@index].effects[PBEffects::WishAmount]
    end
    # Sea of Fire
    if @ai.battle.sides[@side].effects[PBEffects::SeaOfFire] > 1 &&
       battler.takesIndirectDamage? && !has_type?(:FIRE)
      ret += [self.totalhp / 8, 1].max
    end
    # Grassy Terrain (healing)
    if @ai.battle.field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      ret -= [self.totalhp / 16, 1].max
    end
    # Leftovers/Black Sludge
    if has_active_item?(:BLACKSLUDGE)
      if has_type?(:POISON)
        ret -= [self.totalhp / 16, 1].max if battler.canHeal?
      else
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
      end
    elsif has_active_item?(:LEFTOVERS)
      ret -= [self.totalhp / 16, 1].max if battler.canHeal?
    end
    # Aqua Ring
    if self.effects[PBEffects::AquaRing] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Ingrain
    if self.effects[PBEffects::Ingrain] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Leech Seed
    if self.effects[PBEffects::LeechSeed] >= 0
      if battler.takesIndirectDamage?
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
      end
    else
      @ai.each_battler do |b, i|
        next if i == @index || b.effects[PBEffects::LeechSeed] != @index
        amt = [[b.totalhp / 8, b.hp].min, 1].max
        amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
        ret -= [amt, 1].max
      end
    end
    # Hyper Mode (Shadow Pokémon)
    if battler.inHyperMode?
      ret += [self.totalhp / 24, 1].max
    end
    # Poison/burn/Nightmare
    if self.status == :POISON
      if has_active_ability?(:POISONHEAL)
        ret -= [self.totalhp / 8, 1].max if battler.canHeal?
      elsif battler.takesIndirectDamage?
        mult = 2
        mult = [self.effects[PBEffects::Toxic] + 1, 16].min if self.statusCount > 0   # Toxic
        ret += [mult * self.totalhp / 16, 1].max
      end
    elsif self.status == :BURN
      if battler.takesIndirectDamage?
        amt = (Settings::MECHANICS_GENERATION >= 7) ? self.totalhp / 16 : self.totalhp / 8
        amt = (amt / 2.0).round if has_active_ability?(:HEATPROOF)
        ret += [amt, 1].max
      end
    elsif battler.asleep? && self.statusCount > 1 && self.effects[PBEffects::Nightmare]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Curse
    if self.effects[PBEffects::Curse]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Trapping damage
    if self.effects[PBEffects::Trapping] > 1 && battler.takesIndirectDamage?
      amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 8 : self.totalhp / 16
      if @ai.battlers[self.effects[PBEffects::TrappingUser]].has_active_item?(:BINDINGBAND)
        amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 6 : self.totalhp / 8
      end
      ret += [amt, 1].max
    end
    # Perish Song
    return 999_999 if self.effects[PBEffects::PerishSong] == 1
    # Bad Dreams
    if battler.asleep? && self.statusCount > 1 && battler.takesIndirectDamage?
      @ai.each_battler do |b, i|
        next if i == @index || !b.battler.near?(battler) || !b.has_active_ability?(:BADDREAMS)
        ret += [self.totalhp / 8, 1].max
      end
    end
    # Sticky Barb
    if has_active_item?(:STICKYBARB) && battler.takesIndirectDamage?
      ret += [self.totalhp / 8, 1].max
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def base_stat(stat)
    ret = 0
    case stat
    when :ATTACK          then ret = battler.attack
    when :DEFENSE         then ret = battler.defense
    when :SPECIAL_ATTACK  then ret = battler.spatk
    when :SPECIAL_DEFENSE then ret = battler.spdef
    when :SPEED           then ret = battler.speed
    end
    return ret
  end

  def rough_stat(stat)
    return battler.pbSpeed if stat == :SPEED
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
      stage_div = Battle::Battler::ACC_EVA_STAGE_DIVISORS
    end
    stage = battler.stages[stat] + Battle::Battler::STAT_STAGE_MAXIMUM
    value = base_stat(stat)
    return (value.to_f * stage_mul[stage] / stage_div[stage]).floor
  end

  def faster_than?(other)
    return false if other.nil?
    this_speed  = rough_stat(:SPEED)
    other_speed = other.rough_stat(:SPEED)
    return (this_speed > other_speed) ^ (@ai.battle.field.effects[PBEffects::TrickRoom] > 0)
  end

  #-----------------------------------------------------------------------------

  def types; return battler.types; end
  def pbTypes(withExtraType = false); return battler.pbTypes(withExtraType); end

  def has_type?(type)
    return false if !type
    active_types = pbTypes(true)
    return active_types.include?(GameData::Type.get(type).id)
  end
  alias pbHasType? has_type?

  def effectiveness_of_type_against_battler(type, user = nil, move = nil)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !type
    return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
    # Get effectivenesses
    if type == :SHADOW
      if battler.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      battler.pbTypes(true).each do |defend_type|
        mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
        if move
          case move.function_code
          when "HitsTargetInSkyGroundsTarget"
            mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING
          when "FreezeTargetSuperEffectiveAgainstWater"
            mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER
          end
        end
        ret *= mult
      end
      ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def ability_id; return battler.ability_id; end
  def ability;    return battler.ability;    end

  def ability_active?
    return battler.abilityActive?
  end

  def has_active_ability?(ability, ignore_fainted = false)
    return battler.hasActiveAbility?(ability, ignore_fainted)
  end

  def has_mold_breaker?
    return battler.hasMoldBreaker?
  end

  #-----------------------------------------------------------------------------

  def item_id; return battler.item_id; end
  def item;    return battler.item;    end

  def item_active?
    return battler.itemActive?
  end

  def has_active_item?(item)
    return battler.hasActiveItem?(item)
  end

  #-----------------------------------------------------------------------------

  def check_for_move
    ret = false
    battler.eachMove do |move|
      next if move.pp == 0 && move.total_pp > 0
      next unless yield move
      ret = true
      break
    end
    return ret
  end

  def has_damaging_move_of_type?(*types)
    check_for_move do |m|
      return true if m.damagingMove? && types.include?(m.pbCalcType(battler))
    end
    return false
  end

  def has_move_with_function?(*functions)
    check_for_move { |m| return true if functions.include?(m.function_code) }
    return false
  end

  #-----------------------------------------------------------------------------

  def can_attack?
    return false if self.effects[PBEffects::HyperBeam] > 0
    return false if status == :SLEEP && statusCount > 1
    return false if status == :FROZEN   # Only 20% chance of unthawing; assune it won't
    return false if self.effects[PBEffects::Truant] && has_active_ability?(:TRUANT)
    return false if self.effects[PBEffects::Flinch]
    # NOTE: Confusion/infatuation/paralysis have higher chances of allowing the
    #       attack, so the battler is treated as able to attack in those cases.
    return true
  end

  def can_switch_lax?
    return false if wild?
    @ai.battle.eachInTeamFromBattlerIndex(@index) do |pkmn, i|
      return true if @ai.battle.pbCanSwitchIn?(@index, i)
    end
    return false
  end

  # NOTE: This specifically means "is not currently trapped but can become
  #       trapped by an effect". Similar to def pbCanSwitchOut? but this returns
  #       false if any certain switching OR certain trapping applies.
  def can_become_trapped?
    return false if fainted?
    # Ability/item effects that allow switching no matter what
    if ability_active? && Battle::AbilityEffects.triggerCertainSwitching(ability, battler, @ai.battle)
      return false
    end
    if item_active? && Battle::ItemEffects.triggerCertainSwitching(item, battler, @ai.battle)
      return false
    end
    # Other certain switching effects
    return false if Settings::MORE_TYPE_EFFECTS && has_type?(:GHOST)
    # Other certain trapping effects
    return false if battler.trappedInBattle?
    # Trapping abilities/items
    @ai.each_foe_battler(side) do |b, i|
      if b.ability_active? &&
         Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b.battler, @ai.battle)
        return false
      end
      if b.item_active? &&
         Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b.battler, @ai.battle)
        return false
      end
    end
    return true
  end

  #-----------------------------------------------------------------------------

  def wants_status_problem?(new_status)
    return true if new_status == :NONE
    if ability_active?
      case ability_id
      when :GUTS
        return true if ![:SLEEP, :FROZEN].include?(new_status) &&
                       @ai.stat_raise_worthwhile?(self, :ATTACK, true)
      when :MARVELSCALE
        return true if @ai.stat_raise_worthwhile?(self, :DEFENSE, true)
      when :QUICKFEET
        return true if ![:SLEEP, :FROZEN].include?(new_status) &&
                       @ai.stat_raise_worthwhile?(self, :SPEED, true)
      when :FLAREBOOST
        return true if new_status == :BURN && @ai.stat_raise_worthwhile?(self, :SPECIAL_ATTACK, true)
      when :TOXICBOOST
        return true if new_status == :POISON && @ai.stat_raise_worthwhile?(self, :ATTACK, true)
      when :POISONHEAL
        return true if new_status == :POISON
      when :MAGICGUARD   # Want a harmless status problem to prevent getting a harmful one
        return true if new_status == :POISON ||
                       (new_status == :BURN && !@ai.stat_raise_worthwhile?(self, :ATTACK, true))
      end
    end
    return true if new_status == :SLEEP && check_for_move { |m| m.usableWhenAsleep? }
    if has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed")
      return true if [:POISON, :BURN, :PARALYSIS].include?(new_status)
    end
    return false
  end

  #-----------------------------------------------------------------------------

  # Returns a value indicating how beneficial the given ability will be to this
  # battler if it has it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  # NOTE: This method assumes the ability isn't being negated. The calculations
  #       that call this method separately check for it being negated, because
  #       they need to do something special in that case.
  def wants_ability?(ability = :NONE)
    ability = ability.id if !ability.is_a?(Symbol) && ability.respond_to?("id")
    # Get the base ability rating
    ret = 0
    Battle::AI::BASE_ABILITY_RATINGS.each_pair do |val, abilities|
      next if !abilities.include?(ability)
      ret = val
      break
    end
    # Modify the rating based on ability-specific contexts
    if @ai.trainer.medium_skill?
      ret = Battle::AI::Handlers.modify_ability_ranking(ability, ret, self, @ai)
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns a value indicating how beneficial the given item will be to this
  # battler if it is holding it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean this battler benefits, negative values mean this battler suffers.
  # NOTE: This method assumes the item isn't being negated. The calculations
  #       that call this method separately check for it being negated, because
  #       they need to do something special in that case.
  def wants_item?(item)
    item = :NONE if !item
    item = item.id if !item.is_a?(Symbol) && item.respond_to?("id")
    # Get the base item rating
    ret = 0
    Battle::AI::BASE_ITEM_RATINGS.each_pair do |val, items|
      next if !items.include?(item)
      ret = val
      break
    end
    # Modify the rating based on item-specific contexts
    if @ai.trainer.medium_skill?
      ret = Battle::AI::Handlers.modify_item_ranking(item, ret, self, @ai)
    end
    # Prefer if this battler knows Fling and it will do a lot of damage/have an
    # additional (negative) effect when flung
    if item != :NONE && has_move_with_function?("ThrowUserItemAtTarget")
      GameData::Item.get(item).flags.each do |flag|
        next if !flag[/^Fling_(\d+)$/i]
        amt = $~[1].to_i
        ret += 1 if amt >= 80
        ret += 1 if amt >= 100
        break
      end
      if [:FLAMEORB, :KINGSROCK, :LIGHTBALL, :POISONBARB, :RAZORFANG, :TOXICORB].include?(item)
        ret += 1
      end
    end
    # Don't prefer if this battler knows Acrobatics
    if has_move_with_function?("DoublePowerIfUserHasNoItem")
      ret += (item == :NONE) ? 1 : -1
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Items can be consumed by Stuff Cheeks, Teatime, Bug Bite/Pluck and Fling.
  def get_score_change_for_consuming_item(item, try_preserving_item = false)
    ret = 0
    case item
    when :ORANBERRY, :BERRYJUICE, :ENIGMABERRY, :SITRUSBERRY
      # Healing
      ret += (hp > totalhp * 0.75) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY
      # Healing with confusion
      fraction_to_heal = 8   # Gens 6 and lower
      if Settings::MECHANICS_GENERATION == 7
        fraction_to_heal = 2
      elsif Settings::MECHANICS_GENERATION >= 8
        fraction_to_heal = 3
      end
      ret += (hp > totalhp * (1 - (1.0 / fraction_to_heal))) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
      if @ai.trainer.high_skill?
        flavor_stat = {
          :AGUAVBERRY  => :SPECIAL_DEFENSE,
          :FIGYBERRY   => :ATTACK,
          :IAPAPABERRY => :DEFENSE,
          :MAGOBERRY   => :SPEED,
          :WIKIBERRY   => :SPECIAL_ATTACK
        }[item]
        if @battler.nature.stat_changes.any? { |val| val[0] == flavor_stat && val[1] < 0 }
          ret -= 3 if @battler.pbCanConfuseSelf?(false)
        end
      end
    when :ASPEARBERRY, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY
      # Status cure
      cured_status = {
        :ASPEAR      => :FROZEN,
        :CHERIBERRY  => :PARALYSIS,
        :CHESTOBERRY => :SLEEP,
        :PECHABERRY  => :POISON,
        :RAWSTBERRY  => :BURN
      }[item]
      ret += (cured_status && status == cured_status) ? 6 : -6
    when :PERSIMBERRY
      # Confusion cure
      ret += (self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :LUMBERRY
      # Any status/confusion cure
      ret += (status != :NONE || self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :MENTALHERB
      # Cure mental effects
      if self.effects[PBEffects::Attract] >= 0 ||
         self.effects[PBEffects::Taunt] > 1 ||
         self.effects[PBEffects::Encore] > 1 ||
         self.effects[PBEffects::Torment] ||
         self.effects[PBEffects::Disable] > 1 ||
         self.effects[PBEffects::HealBlock] > 1
        ret += 6
      else
        ret -= 6
      end
    when :APICOTBERRY, :GANLONBERRY, :LIECHIBERRY, :PETAYABERRY, :SALACBERRY,
         :KEEBERRY, :MARANGABERRY
      # Stat raise
      stat = {
        :APICOTBERRY  => :SPECIAL_DEFENSE,
        :GANLONBERRY  => :DEFENSE,
        :LIECHIBERRY  => :ATTACK,
        :PETAYABERRY  => :SPECIAL_ATTACK,
        :SALACBERRY   => :SPEED,
        :KEEBERRY     => :DEFENSE,
        :MARANGABERRY => :SPECIAL_DEFENSE
      }[item]
      ret += (stat && @ai.stat_raise_worthwhile?(self, stat)) ? 8 : -8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :STARFBERRY
      # Random stat raise
      ret += 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :WHITEHERB
      # Resets lowered stats
      ret += (battler.hasLoweredStatStages?) ? 8 : -8
    when :MICLEBERRY
      # Raises accuracy of next move
      ret += (@ai.stat_raise_worthwhile?(self, :ACCURACY, true)) ? 6 : -6
    when :LANSATBERRY
      # Focus energy
      ret += (self.effects[PBEffects::FocusEnergy] < 2) ? 6 : -6
    when :LEPPABERRY
      # Restore PP
      ret += 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    end
    ret = 0 if ret < 0 && !try_preserving_item
    return ret
  end

  #-----------------------------------------------------------------------------

  private

  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user&.has_active_ability?(:SCRAPPY) || self.effects[PBEffects::Foresight]) &&
         defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if self.effects[PBEffects::MiracleEye] && defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if battler.effectiveWeather == :StrongWinds && defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !battler.airborne? && defend_type == :FLYING && type == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end

    def choice_locked?
      return true if effects[PBEffects::ChoiceBand] != nil
      return false
    end

    def set_up_score
      stats = [:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
      boosts = []
      score = 0
      for stat in stats
        boosts.push(self.stages[stat]) if ((self.is_physical_attacker? && stat != :SPECIAL_ATTACK) || (self.is_special_attacker? && stat != :ATTACK))
      end
      for i in boosts
        score += i
      end
      #score += 1 if self.battler.effects[PBEffects::ParadoxStat]
      PBDebug.log("Set up score for #{self.name}: #{score}")
      return score
    end

    def set_up_max?(move)
      if Battle::AI::AIMove.offense_setup_move?(move)
        max = (@battler.stages[:ATTACK] == 6 || @battler.stages[:SPECIAL_ATTACK] == 6)
      elsif Battle::AI::AIMove.defense_setup_move?(move)
        max = (@battler.stages[:DEFENSE] == 6 || @battler.stages[:SPECIAL_DEFENSE] == 6)
      elsif Battle::AI::AIMove.speed_setup_move?(move)
        max = @battler.stages[:SPEED] == 6
      end
      return max
    end

    def is_physical_attacker?
      stats = [rough_stat(:ATTACK), rough_stat(:SPECIAL_ATTACK)]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      physcount = 0
      attackBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        physcount += 1 if move.physicalMove?
        if move.is_a?(Battle::Move::StatUpMove)
          for i in 0...move.statUp.size / 2
            attackBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if physcount == 0
      if rough_stat(:ATTACK) >= min
        # Has high attack stat
        # All physical moves would be a solid bet since we have a high attack stat.
        return true
      elsif rough_stat(:ATTACK) >= avg
        # Attack stat is not high, but still above average
        # If this Pokémon has any attack-boosting moves, or more than 1 physical move,
        # we consider this Pokémon capable of being a physical attacker.
        return true if physcount > 1
        return true if attackBoosters >= 1
        return true if self.has_role?(:PHYSICALBREAKER)
      end
      return false
    end

    # If this is true, this Pokémon will be treated as being a special attacker.
    # This means that the Pokémon will be more likely to try to use spatk-boosting and
    # spdef-lowering status moves, and will be even more likely to use strong special moves
    # if any of these status boosts are active.
    def is_special_attacker?
      stats = [rough_stat(:ATTACK), rough_stat(:SPECIAL_ATTACK)]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      speccount = 0
      spatkBoosters = 0
      self.moves.each do |move|
        next if move.pp == 0
        speccount += 1 if move.specialMove?
        if move.is_a?(Battle::Move::StatUpMove)
          for i in 0...move.statUp.size / 2
            spatkBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :SPECIAL_ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if speccount == 0
      if rough_stat(:SPECIAL_ATTACK) >= min
        # Has high spatk stat
        # All special moves would be a solid bet since we have a high spatk stat.
        return true
      elsif rough_stat(:SPECIAL_ATTACK) >= avg
        # Spatk stat is not high, but still above average
        # If this Pokémon has any spatk-boosting moves, or more than 1 special move,
        # we consider this Pokémon capable of being a special attacker.
        return true if speccount > 1
        return true if spatkBoosters >= 1
        return true if self.has_role?(:SPECIALBREAKER)
      end
      return false
    end

  def has_killing_move?(target,switching=false)
    moves.each do |move|
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,switching) >= target.hp
    end
    return false
  end

  def has_killing_priority?(target,switching=false)
    moves.each do |move|
      next if move.priority < 1
      next if move.statusMove?
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,switching) >= target.hp
    end
  end

  def has_helping_hand_kill?(target)
    moves.each do |move|
      mov = Battle::AI::FakeMove.new(@ai,move)
      return true if mov.rough_damage(self,target,false)*1.5 >= target.hp
    end
    return false
  end
  def has_passive_healing?
    return true if self.item == :LEFTOVERS
    return true if self.types.include?(:POISON) && self.item == :BLACKSLUDGE
    return true if self.has_active_ability?(:RESURGENCE)
    return false
  end
  def target_has_hazard_removal?(target)
    hazard = target.moves.select {|move| move && Battle::AI::AIMove.hazard_removal_move?(move.id)}.size
    return hazard > 0
  end
  def target_has_screen_removal?(target)
    hazard = target.moves.select {|move| move && Battle::AI::AIMove.screen_removal_move?(move.id)}.size
    ret = hazard > 0 && self.pbSpeed > target.pbSpeed
    return ret
  end
  def target_has_potential_magic_bounce?(target)
    return true if target.has_active_ability?(:MAGICBOUNCE)
    mons = {
      :pokemon => [:ABSOL,:EMPOLEON,:SABLEYE,:DIANCIE],
      :item => [:ABSOLITE,:EMPOLEONITE,:SABLENITE,:DIANCITE]
    }
    ret = false
    mons[:pokemon].each_with_index do |pkmn,idx|
      if target.pokemon.species == pkmn && target.item == mons[:item][idx]
        ret = true
      end
    end
    return ret
  end
  def either_target_can_kill?(target)
    if @ai.battle.pbSideSize(0) == 2
      dmg = 0
      @ai.battlers.each do |tar|
        next if target.idxOwnSide != tar.idxOwnSide
        dmg += 1 if target_has_killing_move?(tar)
      end
      return dmg > 0
    else
      return target_has_killing_move?(target)
    end
  end

  def either_target_can_2hko?(target)
      if @ai.battle.pbSideSize(0) == 2
        dmg = 0
        @ai.battlers.each do |tar|
          next if target.idxOwnSide != tar.idxOwnSide
          dmg += 1 if target_has_2hko?(tar)
        end
        return dmg > 0
      else
        return target_has_2hko?(target)
      end
    end

    def either_target_can_fast_2hko?(target)
      if @ai.battle.pbSideSize(0) == 2
        dmg = 0
        @ai.battlers.each do |tar|
          next if target.idxOwnSide != tar.idxOwnSide
          dmg += 1 if target_has_fast_2hko?(tar)
        end
        return dmg > 0
      else
        return target_has_fast_2hko?(target)
      end
    end

    def target_has_killing_move?(target,switching=false)
      return target.has_killing_move?(battler,switching)
    end

    def fast_kill?(target,switching=false)
      return has_killing_move?(target,switching) && (battler.pbSpeed > target.pbSpeed || has_killing_priority?(target,switching))
    end

    def fast_helping_hand?(target)
      return has_helping_hand_kill?(target) && battler.pbSpeed > target.pbSpeed
    end

    def slow_helping_hand?(target)
      return has_helping_hand_kill?(target) && !target_fast_kill?(target)
    end

    def helping_hand_kill?(target)
      return fast_helping_hand?(target) || slow_helping_hand?(target)
    end

    def slow_kill?(target,switching=false)
      return has_killing_move?(target,switching) && target.pbSpeed >= battler.pbSpeed
    end

    def target_fast_kill?(target,switching=false)
      return target_has_killing_move?(target,switching) && (target.pbSpeed >= battler.pbSpeed || target.has_killing_priority?(target,switching))
    end

    def target_slow_kill?(target)
      return target_has_killing_move?(target) && battler.pbSpeed > target.pbSpeed
    end

    def target_has_fast_2hko?(target)
      return true if target_fast_kill?(target)
      for move in target.moves
        next if move.statusMove?
        mov = Battle::AI::FakeMove.new(@ai,move)
        return true if mov.rough_damage(target,self) >= battler.hp/2 && (target.pbSpeed >= battler.pbSpeed || has_killing_priority?(battler))
      end
      return false
    end
    def target_has_2hko?(target)
      return true if target_fast_kill?(target)
      for move in target.moves
        next if move.statusMove?
        mov = Battle::AI::FakeMove.new(@ai,move)
        return true if mov.rough_damage(target,self) >= battler.hp/2
      end
      return false
    end

    def target_highest_move_damage(target)
      move_damage = []
      target.moves.each do |move|
        mov = Battle::AI::FakeMove.new(@ai,move)
        move.damagingMove? && move_damage.push(mov.rough_damage(target,battler))
      end
      move_damage = move_damage.sort
      return move_damage[-1]
    end
    def user_highest_move_damage(target)
      move_damage = []
      battler.moves.each do |move|
        mov = Battle::AI::FakeMove.new(@ai,move)
        move.damagingMove? && move_damage.push(mov.rough_damage(battler,target))
      end
      move_damage = move_damage.sort
      return move_damage[-1]
    end
    def target_highest_damaging_move(target)
      move_damage = []
      target.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(target,battler)
        move_damage.push([move,dmg])
      end
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def user_highest_damaging_move(target)
      move_damage = []
      battler.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(battler,target)
        move_damage.push([move,dmg])
      end
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def user_highest_damaging_move_non_explosive(target)
      move_damage = []
      battler.moves.each do |move|
        next if move.statusMove?
        next if move.pp == 0
        next if [:SELFDESTRUCT,:EXPLOSION,:MISTYEXPLOSION].include?(move.id)
        mov = Battle::AI::FakeMove.new(@ai,move)
        dmg = mov.rough_damage(battler,target)
        move_damage.push([move,dmg])
      end
      move_damage.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = move_damage[0][0]
      damage = move_damage[0][1]
      moves = move_damage.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      return final[0]
    end
    def effectiveness_of_type_against_battler(type, user = nil, move = nil)
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      return ret if !type
      return ret if type == :GROUND && has_type?(:FLYING) && has_active_item?(:IRONBALL)
      # Get effectivenesses
      if type == :SHADOW
        if battler.shadowPokemon?
          ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
        else
          ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
        end
      else
        battler.pbTypes(true).each do |defend_type|
          mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
          #p "#{battler.name}: #{move.name} (#{type}) vs #{defend_type} = #{mult}"
          if move
            case move.function_code
            when "HitsTargetInSkyGroundsTarget"
              mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING
            when "FreezeTargetSuperEffectiveAgainstWater"
              mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER
            end
          end
          ret *= mult
        end
        ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE
      end
      return ret
    end
end