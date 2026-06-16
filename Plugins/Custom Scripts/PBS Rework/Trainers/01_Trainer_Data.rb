def pbLoadTrainer_new(tr_type, tr_name, tr_version)
    # Determine trainer's name
    trainer_data = PB_Trainers.get(tr_type,tr_name,tr_version)
    Settings::RIVAL_NAMES.each do |rival|
      next if rival[0] != tr_type || !$game_variables[rival[1]].is_a?(String)
      tr_name = $game_variables[rival[1]]
      break
    end
    # Create trainer object
    trainer = NPCTrainer.new(tr_name, tr_type)
    trainer.id        = $player.make_foreign_ID
    trainer.items     = [:MEGARING]
    trainer.lose_text = trainer_data[:lose_text]
    pokemon = trainer_data[:pokemon]
    # Create each Pokémon owned by the trainer
    pokemon.each do |pkmn_data|
      species = GameData::Species.get(pkmn_data[:species]).species
      f = GameData::Species.get_species_form_data_from_species(pkmn_data[:species])
      pkmn = f.nil? ? Pokemon.new(species, pkmn_data[:level], trainer, false) : Pokemon.new(f, pkmn_data[:level], trainer, false)
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
        PBDebug.log("=====> Nature for #{pkmn.name}: #{pkmn.nature.name}")
      end
      GameData::Stat.each_main do |s|
        if pkmn_data[:iv]
          if pkmn_data[:iv].has_key?(s.id)
            pkmn.iv[s.id] = pkmn_data[:iv][s.id]
          else
            pkmn.iv[s.id] = 31
          end
        else
          pkmn.iv[s.id] = 31
        end
        if pkmn_data[:ev]
          pkmn.ev[s.id] = pkmn_data[:ev][s.id]
        else
          pkmn.ev[s.id] = 0
        end
      end
      pkmn.happiness = pkmn_data[:happiness] ? pkmn_data[:happiness] : 255
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

module PB_Trainers

  DATA = {}

  def self.get(trainer_type,trainer,version=:base)
    #return nil if $game_switches[RandTrainer::Switch]
    return DATA[trainer_type][trainer][version]
  end

  def self.max_level(trainer_type,trainer,version=:base)
    data = self.get(trainer_type,trainer,version)
    return data[:pokemon].map {|e| e[:level]}.max
  end

  def self.register(trainer_type,tr_name,hash)
    start_hash = {}
    start_hash[tr_name] = hash
    if !DATA.has_key?(trainer_type)
      DATA[trainer_type] = start_hash
    else
      if DATA[trainer_type].has_key?(tr_name)
        DATA[trainer_type][tr_name].merge!(hash)
      else
        DATA[trainer_type].merge!(start_hash)
      end
    end
  end

  def self.get_name(trainer_type,trainer)
    return trainer
  end

  def self.exists?(trainer_type,trainer,version=:base)
    return false if !DATA.has_key?(trainer_type)
    return false if !DATA[trainer_type].has_key?(trainer)
    return false if !DATA[trainer_type][trainer].has_key?(version)
    return true
  end

  def self.random_dialogue
    r = rand(5)
    case r
    when 0
      msg = "You're really good!"
    when 1
      msg = "Aw that's no fun!"
    when 2
      msg = "Looks like I need more practice."
    when 3
      msg = "Hmmph. No fun."
    when 4
      msg = "How'd you get so strong?"
    end
    return msg
  end

end

class TrainerBattle
  def self.generate_foes(*args)
    trainer_array = []
    foe_items     = []
    pokemon_array = []
    party_starts  = []
    trainer_type = nil
    trainer_name = nil
    vers = !args[2] ? :base : args[2]
    trainer_check = PB_Trainers.exists?(args[0],args[1],vers)
    trainer_check_2 = (args[2] && args[2].is_a?(NPCTrainer)) ? PB_Trainers.exists?(args[2].trainer_type,args[2].name) : true
    if args[2] && args[2].is_a?(NPCTrainer)
      trainer_check = trainer_check_2
    end
    if args.is_a?(Array) && trainer_check && trainer_check_2
      args[2] = :base if !args[2]
      args.each_with_index do |arg, i|
        case arg
        when NPCTrainer
          raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
          trainer_array.push(arg)
          foe_items.push(arg.items)
          party_starts.push(pokemon_array.length)
          arg.party.each { |pkmn| pokemon_array.push(pkmn) }
        when Array   # [trainer type, trainer name, version number, speech (optional)]
          raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
          if arg[2].is_a?(Symbol)
            trainer = pbLoadTrainer_new(arg[0],arg[1],arg[2])
          else
            trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
            pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
            trainer = pbLoadTrainer(arg[0], arg[1], arg[2]) if !trainer   # Try again
            raise _INTL("Trainer for data '{1}' is not defined.", arg) if !trainer
          end
          EventHandlers.trigger(:on_trainer_load, trainer)
          trainer_array.push(trainer)
          foe_items.push(trainer.items)
          party_starts.push(pokemon_array.length)
          trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
        else
          if trainer_name   # Expecting version number
            if !arg.is_a?(Symbol)
              raise _INTL("Expected a trainer version but {1} is not a valid value.", arg)
            end
            trainer = pbLoadTrainer_new(trainer_type, trainer_name, arg)
            raise _INTL("Trainer for data '{1}, {2}, {3}' is not defined.", trainer_type, trainer_name, arg) if !trainer
            EventHandlers.trigger(:on_trainer_load, trainer)
            trainer_array.push(trainer)
            foe_items.push(trainer.items)
            party_starts.push(pokemon_array.length)
            trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
            trainer_type = nil
            trainer_name = nil
          elsif trainer_type   # Expecting trainer name
            if !arg.is_a?(String) || arg.strip.empty?
              raise _INTL("Expected a trainer name but '{1}' is not a valid name.", arg)
            end
            if args[i + 1].is_a?(Symbol)   # Version number is next
              trainer_name = arg.strip
            else
              trainer = pbLoadTrainer_new(trainer_type, arg,:base)
              raise _INTL("Trainer for data '{1}, {2}' is not defined.", trainer_type, arg) if !trainer
              EventHandlers.trigger(:on_trainer_load, trainer)
              trainer_array.push(trainer)
              foe_items.push(trainer.items)
              party_starts.push(pokemon_array.length)
              trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
              trainer_type = nil
            end
          else   # Expecting trainer type
            if !GameData::TrainerType.exists?(arg)
              raise _INTL("Trainer type {1} does not exist.", arg)
            end
            trainer_type = arg
          end
        end
      end
    else
      args.each_with_index do |arg, i|
        case arg
        when NPCTrainer
          raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
          trainer_array.push(arg)
          foe_items.push(arg.items)
          party_starts.push(pokemon_array.length)
          arg.party.each { |pkmn| pokemon_array.push(pkmn) }
        when Array   # [trainer type, trainer name, version number, speech (optional)]
          raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
          if arg[2].is_a?(Symbol)
            trainer = pbLoadTrainer_new(arg[0],arg[1],arg[2])
          else
            trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
            pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
            trainer = pbLoadTrainer(arg[0], arg[1], arg[2]) if !trainer   # Try again
            raise _INTL("Trainer for data '{1}' is not defined.", arg) if !trainer
          end
          EventHandlers.trigger(:on_trainer_load, trainer)
          trainer.lose_text = arg[3] if arg[3] && !arg[3].empty?
          trainer_array.push(trainer)
          foe_items.push(trainer.items)
          party_starts.push(pokemon_array.length)
          trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
        else
          if trainer_name   # Expecting version number
            if !arg.is_a?(Integer) || arg < 0
              raise _INTL("Expected a trainer version number (0 or higher) but {1} is not a number or not a valid value.", arg)
            end
            trainer = pbLoadTrainer(trainer_type, trainer_name, arg)
            pbMissingTrainer(trainer_type, trainer_name, arg) if !trainer
            trainer = pbLoadTrainer(trainer_type, trainer_name, arg) if !trainer   # Try again
            raise _INTL("Trainer for data '{1}, {2}, {3}' is not defined.", trainer_type, trainer_name, arg) if !trainer
            EventHandlers.trigger(:on_trainer_load, trainer)
            trainer_array.push(trainer)
            foe_items.push(trainer.items)
            party_starts.push(pokemon_array.length)
            trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
            trainer_type = nil
            trainer_name = nil
          elsif trainer_type   # Expecting trainer name
            if !arg.is_a?(String) || arg.strip.empty?
              raise _INTL("Expected a trainer name but '{1}' is not a valid name.", arg)
            end
            if args[i + 1].is_a?(Integer)   # Version number is next
              trainer_name = arg.strip
            else
              trainer = pbLoadTrainer(trainer_type, arg)
              pbMissingTrainer(trainer_type, arg, 0) if !trainer
              trainer = pbLoadTrainer(trainer_type, arg) if !trainer   # Try again
              raise _INTL("Trainer for data '{1}, {2}' is not defined.", trainer_type, arg) if !trainer
              EventHandlers.trigger(:on_trainer_load, trainer)
              trainer_array.push(trainer)
              foe_items.push(trainer.items)
              party_starts.push(pokemon_array.length)
              trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
              trainer_type = nil
            end
          else   # Expecting trainer type
            if !GameData::TrainerType.exists?(arg)
              raise _INTL("Trainer type {1} does not exist.", arg)
            end
            trainer_type = arg
          end
        end
      end
    end
    raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
    return trainer_array, foe_items, pokemon_array, party_starts
  end
end

module GameData
  class Species
    def self.get_species_form_data_from_species(species)
      return nil if !species
      validate species => [Symbol, self, String]
      species_base = species.species if species.is_a?(self)
      species_form = (DATA[species].nil?) ? species_base : species
      return (DATA.has_key?(species_form)) ? DATA[species_form] : nil
    end
  end
end