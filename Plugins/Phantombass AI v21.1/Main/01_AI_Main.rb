class Battle::AI
  attr_accessor :knowledge_flags
	# Choose an action.
  def create_ai_objects
    # Initialize AI trainers
    @trainers = [[], []]
    @battle.player.each_with_index do |trainer, i|
      @trainers[0][i] = AITrainer.new(self, 0, i, trainer)
    end
    if @battle.wildBattle?
      @trainers[1][0] = AITrainer.new(self, 1, 0, nil)
    else
      @battle.opponent.each_with_index do |trainer, i|
        @trainers[1][i] = AITrainer.new(self, 1, i, trainer)
      end
    end
    # Initialize AI battlers
    @battlers = []
    @battle.battlers.each_with_index do |battler, i|
      @battlers[i] = AIBattler.new(self, i) if battler
    end
    # Initialize AI move object
    @move = AIMove.new(self)
    @knowledge_flags = {}
    @knowledge_flags[:flags_set] = []
  end

  # Set some class variables for the Pokémon whose action is being chosen
  def set_up(idxBattler)
    # Find the AI trainer choosing the action
    opposes = @battle.opposes?(idxBattler)
    trainer_index = @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @trainer = @trainers[(opposes) ? 1 : 0][trainer_index]
    # Find the AI battler for which the action is being chosen
    @user = @battlers[idxBattler]
    @battlers.each { |b| b.refresh_battler if b }
  end

  def add_knowledge(flag,target)
    @knowledge_flags[flag] = [] if @knowledge_flags[flag].nil?
    @knowledge_flags[flag].push(target)
  end

  def pbMakeFakeBattler(pokemon,batonpass=false)
    return nil if pokemon.nil?
    pokemon = pokemon.clone
    battler = Battle::Battler.new(@battle,@index)
    return if battler.pokemon == pokemon
    battler.pbInitPokemon(pokemon,@index)
    battler.pbInitEffects(batonpass)
    return battler
  end

  def knowledge_flags
    return @knowledge_flags
  end

  def pbDefaultChooseEnemyCommand(idxBattler)
    set_up(idxBattler)
    ret = false
    PBDebug.logonerr { ret = pbChooseToSwitchOut }
    if ret
      PBDebug.log("")
      return
    end
    ret = false
    PBDebug.logonerr { ret = pbChooseToUseItem }
    if ret
      PBDebug.log("")
      return
    end
    if @battle.pbAutoFightMenu(idxBattler)
      PBDebug.log("")
      return
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
    @battlers.each_with_index do |b,i|
      next if [1,3,5].include?(i)
      @user.log_threat_scores(b)
      @user.set_flags(b)
    end
    choices = pbGetMoveScores
    pbChooseMove(choices)
    PBDebug.log("")
  end

  def pbChooseToUseItem
    return false
  end
  def pokemon_can_absorb_move?(pkmn, move, move_type)
      return false if pkmn.is_a?(Battle::AI::AIBattler) && !pkmn.ability_active?
      # Check pkmn's ability
      # Anything with a Battle::AbilityEffects::MoveImmunity handler
      case pkmn.ability_id
      when :BULLETPROOF
        move_data = GameData::Move.get(move.id)
        return move_data.has_flag?("Bomb")
      when :FLASHFIRE
        return move_type == :FIRE
      when :LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB
        return move_type == :ELECTRIC
      when :SAPSIPPER
        return move_type == :GRASS
      when :SOUNDPROOF
        move_data = GameData::Move.get(move.id)
        return move_data.has_flag?("Sound")
      when :STORMDRAIN, :WATERABSORB, :DRYSKIN
        return move_type == :WATER
      when :TELEPATHY
        # NOTE: The move is being used by a foe of pkmn.
        return false
      when :WONDERGUARD
        types = pkmn.types
        types = pkmn.pbTypes(true) if pkmn.is_a?(Battle::AI::AIBattler)
        return !Effectiveness.super_effective_type?(move_type, *types)
      when :EARTHEATER, :LEVITATE
        return move_type == :GROUND
      when :WELLBAKEDBODY
        return move_type == :FIRE
      when :WINDRIDER, :WINDPOWER
        move_data = GameData::Move.get(move.id)
        return move_data.has_flag?("Wind")
      end
      types = pkmn.types
      if Effectiveness.ineffective_type?(move_type, *types)
        return true
      end
      return false
    end
end

class Battle::AI::AITrainer
  attr_reader :side, :trainer_index
  attr_reader :skill

  def initialize(ai, side, index, trainer)
    @ai            = ai
    @side          = side
    @trainer_index = index
    @trainer       = trainer
    @skill         = 0
    @skill_flags   = []
    set_up_skill
    set_up_skill_flags
    sanitize_skill_flags
  end

  def set_up_skill
    if @trainer
      @skill = @trainer.skill_level
    elsif Settings::SMARTER_WILD_LEGENDARY_POKEMON
      # Give wild legendary/mythical Pokémon a higher skill
      wild_battler = @ai.battle.battlers[@side]
      sp_data = wild_battler.pokemon.species_data
      if sp_data.has_flag?("Legendary") ||
         sp_data.has_flag?("Mythical") ||
         sp_data.has_flag?("UltraBeast")
        @skill = 32   # Medium skill
      end
    end
  end

  def set_up_skill_flags
    if @trainer
      @trainer.flags.each { |flag| @skill_flags.push(flag) }
    end
    if @skill > 0
      @skill_flags.push("PredictMoveFailure")
      @skill_flags.push("ScoreMoves")
      @skill_flags.push("PreferMultiTargetMoves")
    end
    if medium_skill?
      @skill_flags.push("ConsiderSwitching")
      @skill_flags.push("HPAware")
    end
    if !medium_skill?
      @skill_flags.push("UsePokemonInOrder")
    end
  end
end