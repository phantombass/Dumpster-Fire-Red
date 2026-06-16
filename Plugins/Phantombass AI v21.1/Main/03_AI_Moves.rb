class Battle::AI
	MOVE_FAIL_SCORE    = 0
	MOVE_USELESS_SCORE = 1   # Move predicted to do nothing or just be detrimental
	OFFENSIVE_MOVE_BASE_SCORE    = 1
	STATUS_MOVE_BASE_SCORE = 4

  def pbPredictMoveFailure
    # User is asleep and will not wake up
    # return true if @user.battler.asleep? && @user.statusCount > 1 && !@move.move.usableWhenAsleep?
    # User is awake and can't use moves that are only usable when asleep
    return true if !@user.battler.asleep? && @move.move.usableWhenAsleep?
    # NOTE: Truanting is not considered, because if it is, a Pokémon with Truant
    #       will want to switch due to terrible moves every other round (because
    #       all of its moves will fail), and this is disruptive and shouldn't be
    #       how such Pokémon behave.
    # Primal weather
    return true if @battle.pbWeather == :HeavyRain && @move.rough_type == :FIRE
    return true if @battle.pbWeather == :HarshSun && @move.rough_type == :WATER
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail?(@move.function_code, @move.move, @user, self, @battle)
    return false
  end

  def pbPredictMoveFailureAgainstTarget
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail_against_target?(@move.function_code, @move, @user, @target, self, @battle)
    # Immunity to priority moves because of Psychic Terrain
    return true if @battle.field.terrain == :Psychic && @target.battler.affectedByTerrain? &&
                   @target.opposes?(@user) && @move.rough_priority(@user) > 0
    # Immunity because of ability
    return true if @move.move.pbImmunityByAbility(@user.battler, @target.battler, false)
    # Immunity because of Dazzling/Queenly Majesty
    if @move.rough_priority(@user) > 0 && @target.opposes?(@user)
      each_same_side_battler(@target.side) do |b, i|
        return true if b.has_active_ability?([:DAZZLING, :QUEENLYMAJESTY])
      end
    end
    # Type immunity
    calc_type = @move.rough_type
    typeMod = @move.move.pbCalcTypeMod(calc_type, @user.battler, @target.battler)
    return true if @move.move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
    # Dark-type immunity to moves made faster by Prankster
    return true if Settings::MECHANICS_GENERATION >= 7 && @move.statusMove? &&
                   @user.has_active_ability?(:PRANKSTER) && @target.has_type?(:DARK) && @target.opposes?(@user)
    # Airborne-based immunity to Ground moves
    return true if @move.damagingMove? && calc_type == :GROUND &&
                   @target.battler.airborne? && !@move.move.hitsFlyingTargets?
    # Immunity to powder-based moves
    return true if @move.move.powderMove? && !@target.battler.affectedByPowder?
    # Substitute
    return true if @target.effects[PBEffects::Substitute] > 0 && @move.statusMove? &&
                   !@move.move.ignoresSubstitute?(@user.battler) && @user.index != @target.index
    return false
  end

  def pbGetMoveScores(log=true)
    choices = []
    @user.battler.eachMoveWithIndex do |orig_move, idxMove|
      base_score = orig_move.statusMove? ? STATUS_MOVE_BASE_SCORE : OFFENSIVE_MOVE_BASE_SCORE
      # Unchoosable moves aren't considered
      if !@battle.pbCanChooseMove?(@user.index, idxMove, false)
        if orig_move.pp == 0 && orig_move.total_pp > 0
          PBDebug.log_ai("#{@user.name} cannot use #{orig_move.name} (no PP left)") if log
          add_move_to_choices(choices, idxMove, 0)
        else
          PBDebug.log_ai("#{@user.name} cannot choose to use #{orig_move.name}") if log
          add_move_to_choices(choices, idxMove, 0)
        end
        next
      end
      # Set up move in class variables
      set_up_move_check(orig_move)
      # Predict whether the move will fail (generally)
      if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailure
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name}...") if log
        PBDebug.log_score_change(1, "move will fail") if log
        add_move_to_choices(choices, idxMove, MOVE_FAIL_SCORE)
        next
      end
      # Get the move's target type
      target_data = @move.pbTarget(@user.battler)
      if @move.function_code == "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" &&
         @move.rough_type == :GHOST && @user.has_active_ability?([:LIBERO, :PROTEAN])
        target_data = GameData::Target.get((Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe)
      end
      case target_data.num_targets
      when 0   # No targets, affects the user or a side or the whole field
        # Includes: BothSides, FoeSide, None, User, UserSide
        score = base_score
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name} (#{score})...") if log
        PBDebug.logonerr { score = pbGetMoveScore(nil,log) }
        add_move_to_choices(choices, idxMove, score)
      when 1   # One target to be chosen by the trainer
        # Includes: Foe, NearAlly, NearFoe, NearOther, Other, RandomNearFoe, UserOrNearAlly
        redirected_target = get_redirected_target(target_data)
        num_targets = 0
        @battle.allBattlers.each do |b|
          next if redirected_target && b.index != redirected_target
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          next if target_data.targets_foe && !@user.battler.opposes?(b)
          score = base_score
          PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name} (#{score}) against #{b.name} (#{b.index})...") if log
          PBDebug.logonerr { score = pbGetMoveScore([b],log) }
          add_move_to_choices(choices, idxMove, score, b.index)
          num_targets += 1
        end
        PBDebug.log("     no valid targets") if num_targets == 0 && log
      else   # Multiple targets at once
        # Includes: AllAllies, AllBattlers, AllFoes, AllNearFoes, AllNearOthers, UserAndAllies
        targets = []
        @battle.allBattlers.each do |b|
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          targets.push(b)
        end
        score = base_score
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name} (#{score})...") if log
        PBDebug.logonerr { score = pbGetMoveScore(targets,log) }
        add_move_to_choices(choices, idxMove, score)
      end
    end
    @battle.moldBreaker = false
    return choices
  end

	def pbChooseMove(choices)
    user_battler = @user.battler
    # If no moves can be chosen, auto-choose a move or Struggle
    if choices.length == 0
      @battle.pbAutoChooseMove(user_battler.index)
      PBDebug.log_ai("#{@user.name} will auto-use a move or Struggle")
      return
    end
    # Figure out useful information about the choices
    #max_score = 0
    #choices.each { |c| max_score = c[1] if max_score < c[1] }
    # Decide whether all choices are bad, and if so, try switching instead
    #if @trainer.high_skill? && @user.can_switch_lax?
    #  badMoves = false
    #  if max_score <= MOVE_USELESS_SCORE
    #    badMoves = true
    #  end
    #  if badMoves
    #    PBDebug.log_ai("#{@user.name} wants to switch due to terrible moves")
    #    if pbChooseToSwitchOut(true)
    #      @battle.pbUnregisterMegaEvolution(@user.index)
    #      return
    #    end
    #    PBDebug.log_ai("#{@user.name} won't switch after all")
    #  end
    #end
    last_move_score = 0
    last_move_index = -1
    next_move_index = 1
    choices.each do |c|
      if c[1] < last_move_score
        c[1] = 0
      else
        last_move_score = c[1]
      end
      if choices.length > 1
        if next_move_index == 1 && c[1] < choices[next_move_index][1]
          c[1] = 0
        end
        if last_move_index >= 0
          if c[1] > choices[last_move_index][1]
            choices[last_move_index][1] = 0
          end
          if next_move_index < choices.length
            if choices[last_move_index][1] < choices[next_move_index][1]
              choices[last_move_index][1] = 0
            end
          else
            if choices[0][1] > c[1]
              c[1] = 0
            end
            if choices[0][1] < c[1]
              choices[0][1] = 0
            end
          end
        end
      end
      over_one = choices.any? { |choice| choice[1] > 1 }
      if over_one && c[1] == 1
        c[1] = 0
      end
      last_move_index += 1
      next_move_index += 1
    end
    total_score = choices.sum { |c| c[1] }
    # Log the available choices
    if $INTERNAL
      PBDebug.log_ai("Move choices for #{@user.name}:")
      choices.each_with_index do |c, i|
        if total_score == 0
          c[1] = 1
          total_score = 1
        end
        chance = sprintf("%5.1f", (c[1] > 0) ? 100.0 * c[1] / total_score : 0)
        log_msg = "   * #{chance}% to use #{user_battler.moves[c[0]].name}"
        log_msg += " (target #{c[2]})" if c[2] >= 0
        log_msg += ": score #{c[1]}"
        PBDebug.log(log_msg)
      end
    end
    # Pick a move randomly from choices weighted by their scores
    randNum = pbAIRandom(total_score)
    choices.each do |c|
      randNum -= c[1]
      next if randNum >= 0
      @battle.pbRegisterMove(user_battler.index, c[0], false)
      @battle.pbRegisterTarget(user_battler.index, c[2]) if c[2] >= 0
      break
    end
    # Log the result
    if @battle.choices[user_battler.index][2]
      move_name = @battle.choices[user_battler.index][2].name
      if @battle.choices[user_battler.index][3] >= 0
        PBDebug.log("   => will use #{move_name} (target #{@battle.choices[user_battler.index][3]})")
      else
        PBDebug.log("   => will use #{move_name}")
      end
    end
  end

  def set_up_move_check_target(target)
    @target = (target) ? @battlers[target.index] : nil
    @target&.refresh_battler
    @user.calc_highest_damage(target)
    if @target && @move.function_code == "UseLastMoveUsedByTarget"
      if @target.battler.lastRegularMoveUsed &&
         GameData::Move.exists?(@target.battler.lastRegularMoveUsed) &&
         GameData::Move.get(@target.battler.lastRegularMoveUsed).has_flag?("CanMirrorMove")
        @battle.moldBreaker = @user.has_mold_breaker?
        mov = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@target.battler.lastRegularMoveUsed))
        @move.set_up(mov)
      end
    end
  end

  def pbGetMoveScore(targets = nil,log=true)
    # Get the base score for the move
    start_score = @move.move.statusMove? ? STATUS_MOVE_BASE_SCORE : OFFENSIVE_MOVE_BASE_SCORE
    score = start_score
    # Scores for each target in turn
    if targets
      # Reset the base score for the move (each target will add its own score)
      score = 0
      affected_targets = 0
      # Get a score for the move against each target in turn
      orig_move = @move.move   # In case move is Mirror Move and changes depending on the target
      targets.each do |target|
        set_up_move_check(orig_move)
        set_up_move_check_target(target)
        highest_move = @user.highest_damaging_move(target)
        if @user.index != target.index
          PBDebug.log("     #{@user.name}'s highest damaging move vs #{target.name}: #{highest_move.name}") if log
        end
        t_score = pbGetMoveScoreAgainstTarget(log,highest_move)
        next if t_score < 0
        score += t_score
        affected_targets += 1
      end
      # Set the default score if no targets were affected
      if affected_targets == 0
        score = (@trainer.has_skill_flag?("PredictMoveFailure")) ? MOVE_USELESS_SCORE : start_score
      end
      # Score based on how many targets were affected
      if affected_targets == 0 && @trainer.has_skill_flag?("PredictMoveFailure")
        if !@move.move.worksWithNoTargets?
          PBDebug.log_score_change(MOVE_FAIL_SCORE - start_score, "move will fail") if log
          return MOVE_FAIL_SCORE
        end
      else
        score /= affected_targets if affected_targets > 1   # Average the score against multiple targets
        # Bonus for affecting multiple targets
        if @trainer.has_skill_flag?("PreferMultiTargetMoves") && affected_targets > 1
          old_score = score
          score += affected_targets
          PBDebug.log_score_change(score - old_score, "affects multiple battlers") if log
        end
      end
    end
    # If we're here, the move either has no targets or at least one target will
    # be affected (or the move is usable even if no targets are affected, e.g.
    # Self-Destruct)
    if @trainer.has_skill_flag?("ScoreMoves")
      # Modify the score according to the move's effect
      old_score = score
      #score = Battle::AI::ScoreHandler.trigger_general(score, self, @user, @target, @move)
      @target = @battlers[@user.idxOpposingSide] if !@target
      score = Battle::AI::ScoreHandler.trigger_status_moves(score, self, @user, @target, @move, nil, log) if @move.move.statusMove?
      score = Battle::AI::ScoreHandler.trigger_move(@move, score, self, @user, @target, nil, log)
    end
    score = score.to_i
    score = 0 if score < 0
    return score
  end

  def pbGetMoveScoreAgainstTarget(log=true, max_move=nil)
    # Predict whether the move will fail against the target
    if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailureAgainstTarget
      PBDebug.log("     move will not affect #{@target.name}")
      return -1
    end
    # Score the move
    start_score = @move.move.statusMove? ? STATUS_MOVE_BASE_SCORE : OFFENSIVE_MOVE_BASE_SCORE
    score = start_score
    if @trainer.has_skill_flag?("ScoreMoves")
      # Modify the score according to the move's effect against the target
      old_score = score
      # Trigger move-specific score modifier code
      score = Battle::AI::ScoreHandler.trigger_general(score, self, @user, @target, @move, max_move,log)
      score = Battle::AI::ScoreHandler.trigger_damaging_moves(score, self, @user, @target, @move, max_move, log) if @move.move.damagingMove?
      score = Battle::AI::ScoreHandler.trigger_move(@move, score, self, @user, @target, max_move, log)
      score = Battle::AI::ScoreHandler.trigger_status_targeting_moves(score, self, @user, @target, @move, max_move, log) if @move.move.statusMove?
      score = Battle::AI::ScoreHandler.trigger_final(score, self, @user, @target, @move, max_move, log)
    end
    # Add the score against the target to the overall score
    target_data = @move.pbTarget(@user.battler)
    if target_data.targets_foe && !@target.opposes?(@user) && @target.index != @user.index
      if score == MOVE_USELESS_SCORE
        PBDebug.log("     move is useless against #{@target.name}") if log
        return -1
      end
      old_score = score
      score = ((3 + MOVE_BASE_SCORE) - score).to_i
      PBDebug.log_score_change(score - old_score, "score inverted (move targets ally but can target foe)") if log
    end
    return score
  end
end

class Battle::AI::AIMove
  def category;                      return @move.category;           end
  def rough_type
    return @move.pbCalcType(@ai.user.battler)# if @ai.trainer.medium_skill?
    return @move.type
  end
  def base_power
    ret = @move.power
    ret = 60 if ret == 1
    return ret if !@ai.trainer.medium_skill?
    return Battle::AI::Handlers.get_base_power(function_code,
       ret, @move, @ai.user, @ai.target, @ai, @ai.battle)
  end
  def self.setup_move?(move)
      list = [:SWORDSDANCE,:WORKUP,:NASTYPLOT,:GROWTH,:HOWL,:BULKUP,:CALMMIND,:TAILGLOW,:AGILITY,:ROCKPOLISH,:AUTOTOMIZE,
      :SHELLSMASH,:SHIFTGEAR,:QUIVERDANCE,:VICTORYDANCE,:CLANGOROUSSOUL,:CHARGE,:COIL,:HONECLAWS,:IRONDEFENSE,:COSMICPOWER,:AMNESIA,:DRAGONDANCE,
      :FILLETAWAY,:BELLYDRUM,:CURSE,:TIDYUP,:DEFENSECURL,:RAPIDSPIN]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.defense_setup_move?(move)
      list = [:BULKUP,:CALMMIND,:QUIVERDANCE,:VICTORYDANCE,:CLANGOROUSSOUL,:CHARGE,:COIL,:IRONDEFENSE,:COSMICPOWER,:AMNESIA,:CURSE,:DEFENSECURL]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.offense_setup_move?(move)
      list = [:SWORDSDANCE,:WORKUP,:NASTYPLOT,:GROWTH,:HOWL,:BULKUP,:CALMMIND,:TAILGLOW,:SHELLSMASH,:SHIFTGEAR,:QUIVERDANCE,:VICTORYDANCE,
      :CLANGOROUSSOUL,:CHARGE,:COIL,:HONECLAWS,:IRONDEFENSE,:COSMICPOWER,:AMNESIA,:DRAGONDANCE,:CURSE,:TIDYUP]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.speed_setup_move?(move)
      list = [:AGILITY,:ROCKPOLISH,:AUTOTOMIZE,:SHELLSMASH,:SHIFTGEAR,:QUIVERDANCE,:VICTORYDANCE,:CLANGOROUSSOUL,:DRAGONDANCE,:FILLETAWAY,:TIDYUP,:RAPIDSPIN]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.hazard_move?(move)
      list = [:STEALTHROCK,:SPIKES,:TOXICSPIKES,:STICKYWEB,:STONEAXE,:CEASELESSEDGE]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.hazard_removal_move?(move)
      list = [:RAPIDSPIN,:MORTALSPIN,:DEFOG,:TIDYUP]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.screen_removal_move?(move)
      list = [:BRICKBREAK,:PSYCHICFANGS,:DEFOG,:GILLGASH,:RAGINGBULL]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.status_condition_move?(move)
      list = [:WILLOWISP,:DEEPFREEZE,:SPORE,:SING,:SLEEPPOWDER,:YAWN,:HYPNOSIS,:DARKVOID,:POISONGAS,:TOXIC,:POISONPOWDER,:TOXICTHREAD,:GLARE,:THUNDERWAVE,:STUNSPORE]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end

    def self.weather_terrain_move?(move)
      list = [:RAINDANCE,:SUNNYDAY,:SNOWSCAPE,:HAIL,:SANDSTORM,:CHILLYRECEPTION,:ELECTRICTERRAIN,:MISTYTERRAIN,:PSYCHICTERRAIN,:GRASSYTERRAIN]
      m = move.is_a?(Symbol) ? move : move.id
      return list.include?(m)
    end
    def power;          return GameData::Move.get(id).power;         end
end

class Battle::AI::FakeMove
  attr_accessor :move
  def initialize(ai,move)
    @ai = ai
    @move = (move.is_a?(Battle::AI::AIMove) || move.is_a?(Pokemon::Move)) ? Battle::Move.from_pokemon_move(@ai.battle,Pokemon::Move.new(move.id)) : move
  end

  def id;                            return @move.id;                      end
  def name;                          return @move.name;                    end
  def physicalMove?(thisType = nil); return @move.physicalMove?(thisType); end
  def specialMove?(thisType = nil);  return @move.specialMove?(thisType);  end
  def damagingMove?;                 return @move.damagingMove?;           end
  def statusMove?;                   return @move.statusMove?;             end
  def function_code;                 return @move.function_code;           end
  def category;                      return @move.category;           end
  def power;                         return GameData::Move.get(id).power; end

  #-----------------------------------------------------------------------------

  def type; return @move.type; end

  def rough_type
    return @move.pbCalcType(@ai.user.battler)# if @ai.trainer.medium_skill?
    return @move.type
  end

  def rough_priority(user)
    if !user.is_a?(Battle::Battler)
      user = user.battler
    end
    ret = @move.pbPriority(user)
    if user.ability_active?
      ret = Battle::AbilityEffects.triggerPriorityChange(user.ability, user, @move, ret)
      user.effects[PBEffects::Prankster] = false   # Untrigger this
    end
    return ret
  end

  def pbTarget(user)
    return @move.pbTarget((user.is_a?(Battle::AI::AIBattler)) ? user.battler : user)
  end

  # Returns whether this move targets multiple battlers.
  def targets_multiple_battlers?
    user_battler = @ai.user.battler
    target_data = pbTarget(user_battler)
    return false if target_data.num_targets <= 1
    num_targets = 0
    case target_data.id
    when :AllAllies
      @ai.battle.allSameSideBattlers(user_battler).each { |b| num_targets += 1 if b.index != user_battler.index }
    when :UserAndAllies
      @ai.battle.allSameSideBattlers(user_battler).each { |_b| num_targets += 1 }
    when :AllNearFoes
      @ai.battle.allOtherSideBattlers(user_battler).each { |b| num_targets += 1 if b.near?(user_battler) }
    when :AllFoes
      @ai.battle.allOtherSideBattlers(user_battler).each { |_b| num_targets += 1 }
    when :AllNearOthers
      @ai.battle.allBattlers.each { |b| num_targets += 1 if b.near?(user_battler) }
    when :AllBattlers
      @ai.battle.allBattlers.each { |_b| num_targets += 1 }
    end
    return num_targets > 1
  end

  def base_power(user,target)
    ret = @move.power
    ret = 60 if ret == 1
    return Battle::AI::Handlers.get_base_power(function_code,
       ret, @move, user, target, @ai, @ai.battle)
  end

  # Full damage calculation.
  def rough_damage(user,target,calc_max=false)
    return 0 if @move.category == 2
    return 0 if @ai.pokemon_can_absorb_move?(target.pokemon, @move, @move.type)
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    # Get the user and target of this move
    if !user.is_a?(Battle::Battler)
      user = user.is_a?(Battle::AI::AIBattler) ? user : @ai.user
      user_battler = user.battler
    else
      user_battler = user
    end
    if !target.is_a?(Battle::Battler)
      target = target.is_a?(Battle::AI::AIBattler) ? target : @ai.target
      if user == target
        target = user.index == 0 ? @ai.battlers[user.index+1] : @ai.battlers[user.index-1]
      end
      target_battler = target.battler
    else
      target_battler = target
    end
    base_dmg = base_power(user,target)
    return base_dmg if @move.is_a?(Battle::Move::FixedDamageMove)
    if function_code == "DoublePowerIfTargetNotActed" && user_battler.faster_than?(target_battler)
      base_dmg *= 2
    end
    # if @move.multiHitMove? && calc_max == false
    #   base_dmg *= @move.pbNumHits(user_battler, [target_battler])
    # end
    #PBDebug.log_ai("Calcing #{user_battler.name}'s #{@move.name} vs #{target_battler.name}")
    # Get the move's type
    calc_type = rough_type
    calc_type = :WATER if user_battler.has_active_ability?(:LIQUIDVOICE) && @move.soundMove?
    # PBDebug.log_ai("#{user_battler.name}'s #{@move.name} calculated type: #{calc_type}")
    # Decide whether the move has 50% chance of higher of being a critical hit
    crit_stage = rough_critical_hit_stage(user,target)
    is_critical = crit_stage >= Battle::Move::CRITICAL_HIT_RATIOS.length || false
                  #Battle::Move::CRITICAL_HIT_RATIOS[crit_stage] <= 2
    ##### Calculate user's attack stat #####
    if ["CategoryDependsOnHigherDamagePoisonTarget",
        "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(function_code)
      @move.pbOnStartUse(user_battler, [target_battler])   # Calculate category
    end
    atk, atk_stage = @move.pbGetAttackStats(user_battler, target_battler)
    if !target.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker
      atk_stage = max_stage if is_critical && atk_stage < max_stage
      atk = (atk.to_f * stage_mul[atk_stage] / stage_div[atk_stage]).floor
    end
    ##### Calculate target's defense stat #####
    defense, def_stage = @move.pbGetDefenseStats(user_battler, target_battler)
    if !user.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker || ![:SELFDESTRUCT,:EXPLOSION].include?(@move.id)
      def_stage = max_stage if is_critical && def_stage > max_stage
      defense = (defense.to_f * stage_mul[def_stage] / stage_div[def_stage]).floor
    end
    ##### Calculate all multiplier effects #####
    multipliers = {
      :power_multiplier        => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Global abilities
    if @ai.trainer.medium_skill? &&
       ((@ai.battle.pbCheckGlobalAbility(:DARKAURA) && calc_type == :DARK) ||
        (@ai.battle.pbCheckGlobalAbility(:FAIRYAURA) && calc_type == :FAIRY))
      if @ai.battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:power_multiplier] *= 3 / 4.0
      else
        multipliers[:power_multiplier] *= 4 / 3.0
      end
    end
    if [:SELFDESTRUCT,:EXPLOSION].include?(@move.id)
      multipliers[:defense_multiplier] *= 0.75
    end
    if @ai.trainer.medium_skill?
      [:TABLETSOFRUIN, :SWORDOFRUIN, :VESSELOFRUIN, :BEADSOFRUIN].each_with_index do |ability, i|
        next if !@ai.battle.pbCheckGlobalAbility(ability)
        category = (i < 2) ? physicalMove?(calc_type) : specialMove?(calc_type)
        category = !category if i.odd? && @ai.battle.field.effects[PBEffects::WonderRoom] > 0
        if i.even? && !user.has_active_ability?(ability)
          multipliers[:attack_multiplier] *= 0.75 if category
        elsif i.odd? && !target.has_active_ability?(ability)
          multipliers[:defense_multiplier] *= 0.75 if category
        end
      end
    end
    # Ability effects that alter damage
    if user.ability_active?
      case user.ability_id
      when :AERILATE, :GALVANIZE, :PIXILATE, :REFRIGERATE, :ENTYMATE
        multipliers[:power_multiplier] *= 1.2 if type == :NORMAL   # NOTE: Not calc_type.
      when :ANALYTIC
        if rough_priority(user) <= 0
          user_faster = false
          @ai.each_battler do |b, i|
            user_faster = (i != user.index && user.faster_than?(b))
            break if user_faster
          end
          multipliers[:power_multiplier] *= 1.3 if !user_faster
        end
      when :NEUROFORCE
        if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 1.25
        end
      when :NORMALIZE
        multipliers[:power_multiplier] *= 1.2 if Settings::MECHANICS_GENERATION >= 7
      when :SNIPER
        multipliers[:final_damage_multiplier] *= 1.5 if is_critical
      when :STAKEOUT
        # NOTE: Can't predict whether the target will switch out this round.
      when :TINTEDLENS
        if Effectiveness.resistant_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 2
        end
      else
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
    if !@ai.battle.moldBreaker
      user_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
      if target.ability_active?
        case target.ability_id
        when :FILTER, :SOLIDROCK
          if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
            multipliers[:final_damage_multiplier] *= 0.75
          end
        else
          Battle::AbilityEffects.triggerDamageCalcFromTarget(
            target.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
          )
        end
      end
    end
    if target.ability_active?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
      )
    end
    if !@ai.battle.moldBreaker
      target_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
    # Item effects that alter damage
    if user.item_active?
      case user.item_id
      when :EXPERTBELT
        if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 1.2
        end
      when :LIFEORB
        multipliers[:final_damage_multiplier] *= 1.3
      else
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user.item, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
        user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
    end
    if target.item_active? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
      )
    end
    if target.item && target.item.is_berry? && calc_max
      # PBDebug.log("     =====> Item Check for #{target_battler.name}: #{target.item.name}")
      berry_type = pbCheckBerryType(target.item.id)
      target_battler.pbMoveTypeWeakeningBerryCalc(berry_type,calc_type,multipliers) if berry_type
    end
    # Parental Bond
    if user.has_active_ability?(:PARENTALBOND)
      multipliers[:power_multiplier] *= (Settings::MECHANICS_GENERATION >= 7) ? 1.25 : 1.5
    end
    # Me First - n/a because can't predict the move Me First will use
    # Helping Hand - n/a
    # Charge
    if @ai.trainer.medium_skill? &&
       user.effects[PBEffects::Charge] > 0 && calc_type == :ELECTRIC
      multipliers[:power_multiplier] *= 2
    end
    # Mud Sport and Water Sport
    if @ai.trainer.medium_skill?
      if calc_type == :ELECTRIC
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:power_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:power_multiplier] /= 3
        end
      elsif calc_type == :FIRE
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:power_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:power_multiplier] /= 3
        end
      end
    end
    # Terrain moves
    if @ai.trainer.medium_skill?
      terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
      case @ai.battle.field.terrain
      when :Electric
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :ELECTRIC && user_battler.affectedByTerrain?
        multipliers[:power_multiplier] *= 1.5 if function_code == "IncreasePowerInElectricTerrain" && user_battler.affectedByTerrain?
      when :Grassy
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :GRASS && user_battler.affectedByTerrain?
      when :Psychic
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :PSYCHIC && user_battler.affectedByTerrain?
      when :Misty
        multipliers[:power_multiplier] /= 2 if calc_type == :DRAGON && target_battler.affectedByTerrain?
      end
    end
    # Badge multipliers
    if @ai.trainer.high_skill? && @ai.battle.internalBattle && target_battler.pbOwnedByPlayer?
      # Don't need to check the Atk/Sp Atk-boosting badges because the AI
      # won't control the player's Pokémon.
      if physicalMove?(calc_type) && @ai.battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif specialMove?(calc_type) && @ai.battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end
    # Multi-targeting attacks
    if @ai.trainer.high_skill? && targets_multiple_battlers?
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    if @ai.trainer.medium_skill?
      case user_battler.effectiveWeather
      when :Sun, :HarshSun
        case calc_type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER
          if function_code == "IncreasePowerInSunWeather" # Added for Hydro Steam
            multipliers[:final_damage_multiplier] *= 1.5
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        end
      when :Rain, :HeavyRain
        case calc_type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.has_type?(:ROCK) && specialMove?(calc_type) &&
           function_code != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      #-------------------------------------------------------------------------
      # Added for Gen 9 Snow
      #-------------------------------------------------------------------------
      when :Hail
        if Settings::HAIL_WEATHER_TYPE > 0 && target.pbHasType?(:ICE) &&
            (physicalMove?(calc_type) || function_code == "UseTargetDefenseInsteadOfTargetSpDef")
          multipliers[:defense_multiplier] *= 1.5
        end
      #-------------------------------------------------------------------------
      end
    end
    # Critical hits
    if is_critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    random = 85 + rand(16)
    # random = 92 if $game_switches[Settings::NO_ROLLS]
    random = 100 if calc_max
    multipliers[:final_damage_multiplier] *= random / 100.0
    # STAB
    if calc_type && user.has_type?(calc_type)
      if user.has_active_ability?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    typemod = target.effectiveness_of_type_against_battler(calc_type, user, @move)
    multipliers[:final_damage_multiplier] *= typemod
    # Burn
    if @ai.trainer.high_skill? && user.status == :BURN && physicalMove?(calc_type) &&
       @move.damageReducedByBurn? && !user.has_active_ability?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    #---------------------------------------------------------------------------
    # Added for Drowsy
    #---------------------------------------------------------------------------
    if @ai.trainer.high_skill? && target.status == :DROWSY
      multipliers[:final_damage_multiplier] *= 4 / 3.0
    end
    #---------------------------------------------------------------------------
    # Added for Frostbite
    #---------------------------------------------------------------------------
    if @ai.trainer.high_skill? && move.specialMove?(type) && user.status == :FROSTBITE
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if @ai.trainer.medium_skill? && !@move.ignoresReflect? && !is_critical &&
       !user.has_active_ability?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?(calc_type)
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?(calc_type)
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if @ai.trainer.medium_skill? && target.effects[PBEffects::Minimize] && @move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    #---------------------------------------------------------------------------
    # Added for Glaive Rush
    #---------------------------------------------------------------------------
    if @ai.trainer.high_skill? && target.effects[PBEffects::GlaiveRush] > 0
      multipliers[:final_damage_multiplier] *= 2
    end
    #---------------------------------------------------------------------------
    # NOTE: No need to check pbBaseDamageMultiplier, as it's already accounted
    #       for in an AI's MoveBasePower handler or can't be checked now anyway.
    # NOTE: No need to check pbModifyDamage, as it's already accounted for in an
    #       AI's MoveBasePower handler.
    ##### Main damage calculation #####
    base_dmg = [(base_dmg * multipliers[:power_multiplier]).round, 1].max
    atk      = [(atk      * multipliers[:attack_multiplier]).round, 1].max
    defense  = [(defense  * multipliers[:defense_multiplier]).round, 1].max
    damage   = (((((2.0 * user.level / 5) + 2).floor * base_dmg * atk / defense).floor / 50)+2).floor
    damage   = [(damage * multipliers[:final_damage_multiplier]).poke_round, 1].max
    ret = damage.floor
    ret = target.hp - 1 if @move.nonLethal?(user_battler, target_battler) && ret >= target.hp
    ret = target.hp - 1 if target.hp == target.totalhp && target.has_active_ability?([:STURDY]) && !@ai.battle.moldBreaker && ret >= target.hp
    return ret
  end
  # Full critical hit chance calculation (returns the determined critical hit
  # stage).
  def rough_critical_hit_stage(user,target)
    user_battler = user.is_a?(Battle::Battler) ? user : user.battler
    target_battler = target.is_a?(Battle::Battler) ? target : target.battler
    return -1 if target_battler.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    crit_stage = 0
    # Ability effects that alter critical hit rate
    if user.ability_active?
      crit_stage = Battle::AbilityEffects.triggerCriticalCalcFromUser(user_battler.ability,
         user_battler, target_battler, @move, crit_stage)
      return -1 if crit_stage < 0
    end
    if !@ai.battle.moldBreaker && target.ability_active?
      crit_stage = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target_battler.ability,
         user_battler, target_battler, @move, crit_stage)
      return -1 if crit_stage < 0
    end
    # Item effects that alter critical hit rate
    if user.item_active?
      crit_stage = Battle::ItemEffects.triggerCriticalCalcFromUser(user_battler.item,
         user_battler, target_battler, @move, crit_stage)
      return -1 if crit_stage < 0
    end
    if target.item_active?
      crit_stage = Battle::ItemEffects.triggerCriticalCalcFromTarget(user_battler.item,
         user_battler, target_battler, @move, crit_stage)
      return -1 if crit_stage < 0
    end
    # Other effects
    case @move.pbCritialOverride(user_battler, target_battler)
    when 1  then return 99
    when -1 then return -1
    end
    return 99 if crit_stage > 50   # Merciless
    return 99 if user_battler.effects[PBEffects::LaserFocus] > 0
    crit_stage += 1 if @move.highCriticalRate?
    crit_stage += user_battler.effects[PBEffects::FocusEnergy]
    crit_stage += 1 if user_battler.inHyperMode? && @move.type == :SHADOW
    crit_stage = [crit_stage, Battle::Move::CRITICAL_HIT_RATIOS.length - 1].min
    return crit_stage
  end
end
