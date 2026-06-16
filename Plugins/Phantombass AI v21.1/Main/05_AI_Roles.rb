module GameData
  class Role
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id           = hash[:id]
      @id_number    = hash[:id_number]    || -1
      @real_name    = hash[:name]         || "Unnamed"
    end

    # @return [String] the translated name of this Role
    def name
      return _INTL(@real_name)
    end
  end
  class Trainer
    def to_trainer
        # Determine trainer's name
        trainer_data = PB_Trainers.get(@trainer_type,self.name,@version)
        tr_name = self.name
        Settings::RIVAL_NAMES.each do |rival|
          next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
          tr_name = $game_variables[rival[1]]
          break
        end
        # Create trainer object
        trainer = NPCTrainer.new(tr_name, @trainer_type, @version)
        trainer.id        = $player.make_foreign_ID
        trainer.items     = @items.clone
        trainer.lose_text = trainer_data[:lose_text]
        @pokemon = trainer_data[:pokemon]
        # Create each Pokémon owned by the trainer
        @pokemon.each do |pkmn_data|
          species = GameData::Species.get(pkmn_data[:species]).species
          pkmn = Pokemon.new(species, pkmn_data[:level], trainer, false)
          trainer.party.push(pkmn)
          # Set Pokémon's properties if defined
          if pkmn_data[:form]
            pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
            pkmn.form_simple = pkmn_data[:form]
          end
          pkmn.item = pkmn_data[:item]
          if pkmn_data[:moves] && pkmn_data[:moves].length > 0
            pkmn.forget_all_moves
            pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
          else
            pkmn.reset_moves
          end
          pkmn.ability_index = pkmn_data[:ability_index] || 0
          pkmn.ability = pkmn_data[:ability]
          pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
          pkmn.shiny = (pkmn_data[:shininess]) ? true : false
          pkmn.super_shiny = (pkmn_data[:super_shininess]) ? true : false
          if !pkmn_data[:roles]
              pkmn.roles = pkmn.assign_roles
              PBDebug.log("Roles for #{pkmn.species.name}: #{pkmn.roles}")
          else
            for i in pkmn_data[:roles]
              pkmn.add_role(i)
            end
          end
          if pkmn_data[:nature]
            pkmn.nature = pkmn_data[:nature]
          else   # Make the nature random but consistent for the same species used by the same trainer type
            pkmn.nature = pkmn.generate_beneficial_nature
            PB_Data.log_misc("=====> Nature for #{pkmn.name}: #{pkmn.nature.name}")
          end
          GameData::Stat.each_main do |s|
            if pkmn_data[:iv]
              pkmn.iv[s.id] = pkmn_data[:iv][s.id]
            else
              pkmn.iv[s.id] = 31
            end
            if pkmn_data[:ev]
              pkmn.ev[s.id] = pkmn_data[:ev][s.id]
            else
              pkmn.ev[s.id] = 0
            end
          end
          pkmn.happiness = pkmn_data[:happiness] if pkmn_data[:happiness]
          if !nil_or_empty?(pkmn_data[:real_name])
            pkmn.name = pbGetMessageFromHash(MessageTypes::POKEMON_NICKNAMES, pkmn_data[:real_name])
          end
          if pkmn_data[:shadowness]
            pkmn.makeShadow
            pkmn.shiny = false
          end
          pkmn.poke_ball = pkmn_data[:poke_ball] if pkmn_data[:poke_ball]
          pkmn.calc_stats
        end
        return trainer
      end
    end
end

class Pokemon
  attr_accessor :roles

  alias role_init initialize
  def initialize(*args)
    role_init(*args)
    @roles = []
  end

  def roles
    @roles = [] if @roles.nil?
    @roles.push(:NONE) if (@roles == [] || @roles == nil)
    return @roles
  end

  def add_role(value)
    return if value && !GameData::Role.exists?(value)
    @roles.push(:NONE) if !value
    @roles.push(GameData::Role.get(value).id)
  end

  def has_role?(role)
    x = []
    for i in @roles
      x.push(i)
      if role.is_a?(Array)
        if role.include?(i)
          return true
        end
      end
    end
    return x.include?(role) && !role.is_a?(Array)
  end

  def generate_beneficial_nature
    baseStats = species_data.base_stats
    if @roles.include?(:PHYSICALBREAKER)
      if baseStats[:ATTACK] >= 100 &&  baseStats[:SPEED] > baseStats[:ATTACK]
        return :JOLLY
      else
        return :ADAMANT
      end
    elsif @roles.include?(:SPECIALBREAKER)
      if baseStats[:SPECIAL_ATTACK] >= 100 &&  baseStats[:SPEED] > baseStats[:SPECIAL_ATTACK]
        return :TIMID
      else
        return :MODEST
      end
    elsif @roles.include?(:SETUPSWEEPER)
      if baseStats[:ATTACK] > baseStats[:SPECIAL_ATTACK] && baseStats[:ATTACK] > baseStats[:SPEED]
        return :ADAMANT
      elsif baseStats[:ATTACK] < baseStats[:SPECIAL_ATTACK] && baseStats[:SPECIAL_ATTACK] > baseStats[:SPEED]
        return :MODEST
      else
        return (baseStats[:ATTACK] > baseStats[:SPECIAL_ATTACK]) ? :JOLLY : :TIMID
      end
    elsif @roles.include?([:DEFENSIVEPIVOT,:TANK,:TOXICSTALLER,:PHAZER,:SCREENS,:TRICKROOMSETTER])
      return (baseStats[:DEFENSE] > baseStats[:SPECIAL_DEFENSE] ? :RELAXED : :SASSY)
    elsif @roles.include?(:PHYSICALWALL)
      if baseStats[:ATTACK] > baseStats[:SPECIAL_ATTACK]
        return :IMPISH
      else
        return :BOLD
      end
    elsif @roles.include?(:SPECIALWALL)
      if baseStats[:ATTACK] > baseStats[:SPECIAL_ATTACK]
        return :CAREFUL
      else
        return :CALM
      end
    end
    phys = 0
    spec = 0
    @moves.each do |move|
      phys += 1 if move.category == 0
      spec += 1 if move.category == 1
    end
    if phys > spec
      return :ADAMANT
    else
      return :MODEST
    end
  end

  def assign_roles
    roles = []
    physical_moves = 0
    special_moves = 0
    status_moves = 0
    @moves.each do |move|
      physical_moves += 1 if move.category == 0
      special_moves += 1 if move.category == 1
      status_moves += 1 if move.category == 2
    end
    roles.push(:PHYSICALBREAKER) if physical_moves > 2
    roles.push(:SPECIALBREAKER) if special_moves > 2
    roles.push(:REVENGEKILLER) if item_id == :CHOICESCARF
    for move in @moves
      m = GameData::Move.get(move.id).id
      roles.push(:SETUPSWEEPER) if Battle::AI::AIMove.setup_move?(m)
      roles.push(:WEATHERTERRAIN) if Battle::AI::AIMove.weather_terrain_move?(m)
      roles.push(:CLERIC) if [:WISH,:HEALBELL,:AROMATHERAPY].include?(m)
      roles.push(:OFFENSIVEPIVOT) if [:UTURN,:VOLTSWITCH,:FLIPTURN].include?(m)
      roles.push(:DEFENSIVEPIVOT) if [:PARTINGSHOT,:CHILLYRECEPTION,:TELEPORT,:SHEDTAIL].include?(m)
      roles.push(:SPEEDCONTROL) if [:ICYWIND,:THUNDERWAVE,:GLARE,:BULLDOZE,:DOLDRUMS,:ROCKTOMB,:POUNCE,:NUZZLE,:ELECTROWEB,:LOWSWEEP,:TAILWIND].include?(m)
      roles.push(:STALLBREAKER) if m == :TAUNT
      roles.push(:REDIRECTION) if [:FOLLOWME,:ALLYSWITCH,:RAGEPOWDER].include?(m)
      roles.push(:SUPPORT) if [:HELPINGHAND,:WIDEGUARD,:MATBLOCK,:POLLENPUFF,:AFTERYOU,:INSTRUCT].include?(m)
      roles.push(:HAZARDREMOVAL) if [:RAPIDSPIN,:MORTALSPIN,:TIDYUP,:DEFOG].include?(m)
      roles.push(:SCREENS) if [:LIGHTSCREEN,:REFLECT,:AURORAVEIL].include?(m)
      roles.push(:TOXICSTALLER) if m == :TOXIC
      roles.push(:LEAD) if [:STEALTHROCK,:SPIKES,:TOXICSPIKES,:STICKYWEB,:STONEAXE,:CEASELESSEDGE].include?(m)
      roles.push(:TRICKROOMSETTER) if m == :TRICKROOM
      roles.push(:TANK) if [:RECOVER,:ROOST,:MOONLIGHT,:MORNINGSUN,:SHOREUP,:PACKIN,:SOFTBOILED,:SYNTHESIS,:HEALORDER].include?(m) && !roles.include?(:SETUPSWEEPER)
      roles.push(:PHAZER) if [:ROAR,:DRAGONTAIL,:WHIRLWIND,:HAZE,:FREEZYFROST].include?(m)
      roles.push(:STATUSABSORBER) if m == :FACADE
      roles.push(:CRIT) if m == :FOCUSENERGY
    end
    case @ability
    when :DRIZZLE,:DROUGHT,:SNOWWARNING,:SANDSTREAM,:SANDSPIT,:ELECTRICSURGE,:PSYCHICSURGE,:GRASSYSURGE,:MISTYSURGE,:SEEDSOWER,:HADRONENGINE,:ORICHALCUMPULSE
      roles.push(:WEATHERTERRAIN)
    when :SWIFTSWIM,:DRYSKIN,:HYDRATION,:RAINDISH,:SOLARPOWER,:CHLOROPHYLL,:PROTOSYNTHESIS,:SLUSHRUSH,:ICEBODY,:ICEFACE,:SANDRUSH,:SANDVEIL,
      :SANDFORCE,:SNOWCLOAK,:FLOWERGIFT,:FORECAST,:SURGESURFER,:MEADOWRUSH,:BRAINBLAST,:HARVEST,:STEAMPOWERED
      roles.push(:WEATHERTERRAINABUSER)
    when :DEFIANT,:COMPETITIVE,:SOULHEART,:MOXIE,:ASONEICE,:ASONEGHOST,:GRIMNEIGH,:CHILLINGNEIGH,:LIONSPRIDE,:BEASTBOOST,:DOWNLOAD,:CONTRARY
      roles.push(:SETUPSWEEPER)
      roles.push(:SPECIALBREAKER) if [:COMPETITIVE,:SOULHEART,:ASONEGHOST,:GRIMNEIGH,:LIONSPRIDE].include?(@ability)
      roles.push(:PHYSICALBREAKER) if [:DEFIANT,:MOXIE,:ASONEICE,:CHILLINGNEIGH].include?(@ability)
    when :GUTS,:SHEDSKIN,:HOPEFULTOLL,:FAIRYBUBBLE,:PURIFYINGSALT
      roles.push(:STATUSABSORBER)
    end
    if (self.species == :SWAMPERT && self.item == :SWAMPERTITE) || (self.species == :TOXTRICITY && self.item == :TOXTRICITITE) ||
      (self.species == :ABOMASNOW && self.item == :ABOMASITE)
      roles.push(:WEATHERTERRAINABUSER) unless roles.include?(:WEATHERTERRAINABUSER)
    end
    if (self.species == :CHARIZARD && self.item == :CHARIZARDITEY) || (self.species == :RILLABOOM && self.item == :RILLABOOMITE)
      roles.push(:WEATHERTERRAIN) unless roles.include?(:WEATHERTERRAIN)
    end
    roles.push(:NONE) if roles == []
    roles = roles.uniq
    return roles
  end
end

class Battle::Battler
  attr_accessor :roles

  alias init_role pbInitBlank
  def pbInitBlank
    init_role
    @roles = []
  end

  alias pbInitRole pbInitPokemon
  def pbInitPokemon(pkmn, idxParty)
    pbInitRole(pkmn, idxParty)
    @roles = pkmn.roles
  end

  def roles
    @roles.push(:NONE) if (@roles == [] || @roles == nil)
    return @roles
  end

  def has_role?(role)
    x = []
    for i in @roles
      x.push(i)
      if role.is_a?(Array)
        if role.include?(i)
          return true
        end
      end
    end
    return x.include?(role) && !role.is_a?(Array)
  end

  def role=(value)
    new_role = GameData::Role.try_get(value)
    @roles.push(new_role) ? new_role.id : nil
  end
end

GameData::Role.register({
  :id           => :PHYSICALWALL,
  :id_number    => 0,
  :name         => _INTL("Physical Wall")
})

GameData::Role.register({
  :id           => :SPECIALWALL,
  :id_number    => 1,
  :name         => _INTL("Special Wall")
})

GameData::Role.register({
  :id           => :STALLBREAKER,
  :id_number    => 2,
  :name         => _INTL("Stallbreaker")
})

GameData::Role.register({
  :id           => :PHYSICALBREAKER,
  :id_number    => 3,
  :name         => _INTL("Physical Breaker")
})

GameData::Role.register({
  :id           => :SPECIALBREAKER,
  :id_number    => 4,
  :name         => _INTL("Special Breaker")
})

GameData::Role.register({
  :id           => :TANK,
  :id_number    => 5,
  :name         => _INTL("Tank")
})

GameData::Role.register({
  :id           => :LEAD,
  :id_number    => 5,
  :name         => _INTL("Lead")
})

GameData::Role.register({
  :id           => :CLERIC,
  :id_number    => 7,
  :name         => _INTL("Cleric")
})

GameData::Role.register({
  :id           => :REVENGEKILLER,
  :id_number    => 8,
  :name         => _INTL("Revenge Killer")
})

GameData::Role.register({
  :id           => :WINCON,
  :id_number    => 9,
  :name         => _INTL("Win Condition")
})

GameData::Role.register({
  :id           => :TOXICSTALLER,
  :id_number    => 10,
  :name         => _INTL("Toxic Staller")
})

GameData::Role.register({
  :id           => :SETUPSWEEPER,
  :id_number    => 11,
  :name         => _INTL("Setup Sweeper")
})

GameData::Role.register({
  :id           => :HAZARDREMOVAL,
  :id_number    => 12,
  :name         => _INTL("Hazard Removal")
})

GameData::Role.register({
  :id           => :DEFENSIVEPIVOT,
  :id_number    => 13,
  :name         => _INTL("Defensive Pivot")
})

GameData::Role.register({
  :id           => :SPEEDCONTROL,
  :id_number    => 14,
  :name         => _INTL("Speed Control")
})

GameData::Role.register({
  :id           => :SCREENS,
  :id_number    => 15,
  :name         => _INTL("Screens")
})

GameData::Role.register({
  :id           => :NONE,
  :id_number    => 16,
  :name         => _INTL("None")
})

GameData::Role.register({
  :id           => :TARGETALLY,
  :id_number    => 17,
  :name         => _INTL("Target Ally")
})

GameData::Role.register({
  :id           => :REDIRECTION,
  :id_number    => 18,
  :name         => _INTL("Redirection")
})

GameData::Role.register({
  :id           => :TRICKROOMSETTER,
  :id_number    => 19,
  :name         => _INTL("Trick Room Setter")
})

GameData::Role.register({
  :id           => :OFFENSIVEPIVOT,
  :id_number    => 20,
  :name         => _INTL("Offensive Pivot")
})

GameData::Role.register({
  :id           => :STATUSABSORBER,
  :id_number    => 21,
  :name         => _INTL("Status Absorber")
})

GameData::Role.register({
  :id           => :WEATHERTERRAIN,
  :id_number    => 22,
  :name         => _INTL("Weather/Terrain Setter")
})

GameData::Role.register({
  :id           => :TRAPPER,
  :id_number    => 23,
  :name         => _INTL("Trapper")
})

GameData::Role.register({
  :id           => :PHAZER,
  :id_number    => 24,
  :name         => _INTL("Phazer")
})

GameData::Role.register({
  :id           => :SUPPORT,
  :id_number    => 25,
  :name         => _INTL("Support")
})

GameData::Role.register({
  :id           => :WEATHERTERRAINABUSER,
  :id_number    => 26,
  :name         => _INTL("Weather/Terrain Abuser")
})

GameData::Role.register({
  :id           => :FEAR,
  :id_number    => 27,
  :name         => _INTL("FEAR")
})

GameData::Role.register({
  :id           => :CRIT,
  :id_number    => 28,
  :name         => _INTL("Crit")
})