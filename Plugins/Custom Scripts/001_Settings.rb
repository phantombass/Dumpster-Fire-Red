module Settings

  GAME_VERSION = "0.1.1"
  POISON_ANIMATION_ID = 8
  TIME_SHADING = true
  POISON_IN_FIELD = true
  CAN_FLY_FROM_TOWN_MAP = false
  NUZLOCKE_SWITCH = 67
  NUZLOCKE_CHOSEN_SWITCH = 68
  FIXED_DURATION_WEATHER_FROM_ABILITY = false
  INFINITE_REPEL = 66
  GAUNTLET_SWITCH = 65
  FISHING_AUTO_HOOK          = true

  def self.game_credits
    return [
      _INTL("Pokémon Dumpster Fire Red by:"),
      "Phantombass",
      "",
      _INTL("Special thanks to:"),
      "My wife and kids",
      "My beta testers in the Discord",
      "",
      _INTL("Special No Thanks:"),
      "My cats",
      "",
      "Until the next one..."
    ]
  end
end

Graphics.frame_rate = 60

class ::Numeric
  def poke_round
    fact = self-self.to_i
    if fact > 0.5
      return self.round
    else
      return self.floor
    end
  end
end

def block_debug
  $DEBUG = false
  $INTERNAL = false
end

def write_version(path = "version")
  # block_debug
  $intro = true
  $in_battle = false
  File.open(path, "wb") { |f|
    version = Settings::GAME_VERSION
    f.write("#{version}")
  }
end

$DEBUG = true
$INTERNAL = true
$no_evs = true

class Player < Trainer
  class Pokedex
    def set_all_seen
      GameData::Species.each { |s| set_seen(s) }
    end
  end
end

module Game
  def self.set_up_system
    SaveData.initialize_bootup_values
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if !Settings::LANGUAGES.empty?
      $PokemonSystem.language = pbChooseLanguage if !SaveData.exists? && Settings::LANGUAGES.length >= 2
      MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
    end
    write_version
  end
  def self.start_new
    pbIntro
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    # $game_temp.begun_new_game = true
    # $game_system.initialize
    # HM_Catalogue.clear
    #Randomizer.start_new
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $player.has_running_shoes = true
    $game_switches[FAST_PICK_ITEM_SWITCH] = true
    $game_switches[FAST_PICK_BERRY_SWITCH] = false
    # $level_caps.start_new_game
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end
end

def pbTrainerPC
  return UI::PC.pbTrainerPC
end

def pbPokeCenterPC
  return UI::PC.pbPokeCenterPC
end

def pbIntro
  pbMessage(_INTL("Welcome to Pokémon Dumpster Fire Red, a non-profit fan game made by Phantombass."))
  pbMessage(_INTL("If you paid for this, contact the person who sent it to you for a refund immediately."))
  pbMessage(_INTL("The current version is #{Settings::GAME_VERSION}."))
  pbMessage(_INTL("This game is intended to be a combination of a Trashlocke and an Escape Room."))
  pbMessage(_INTL("There will be puzzles, shenanigans, and just an overall different experience from what I usually make."))
  pbMessage(_INTL("I hope you enjoy your journey!"))
  HM_Catalogue.clear
  $level_caps.start_new_game
end

def pbBerryPlant
  pbMessage(_INTL("This soil is all used up."))
end

def pbPickBerry(berry, qty = 1)
  berry_name = (qty > 1) ? GameData::Item.get(berry).portion_name_plural : GameData::Item.get(berry).portion_name
  case berry
  when :ORANBERRY,:PECHABERRY,:RAWSTBERRY,:ASPEARBERRY,:CHERIBERRY,:LUMBERRY,:CHESTOBERRY,:PERSIMBERRY
    qty = 1 + rand(2)
  when :SITRUSBERRY
    qty = 1
  else
    qty = 1
  end
  if qty > 1
    message = _INTL("There are {1} \\c[1]{2}\\c[0]!", qty, berry_name)
  else
    message = _INTL("There is 1 \\c[1]{1}\\c[0]!", berry_name)
  end
  pbMessage(message)
  if !$bag.can_add?(berry, qty)
    pbMessage(_INTL("Too bad...\nThe Bag is full..."))
    return false
  end
  $stats.berry_plants_picked += 1
  if qty >= GameData::BerryPlant.get(berry).maximum_yield
    $stats.max_yield_berry_plants += 1
  end
  $bag.add(berry, qty)
  if qty > 1
    pbMessage("\\me[Berry get]" + _INTL("You picked the {1} \\c[1]{2}\\c[0].", qty, berry_name) + "\\wtnp[30]")
  else
    pbMessage("\\me[Berry get]" + _INTL("You picked the \\c[1]{1}\\c[0].", berry_name) + "\\wtnp[30]")
  end
  pocket = GameData::Item.get(berry).pocket
  pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                  berry_name, pocket, GameData::BagPocket.get(pocket).name) + "\1")
  if Settings::NEW_BERRY_PLANTS
    pbMessage(_INTL("The soil is all used up."))
  else
    pbMessage(_INTL("The soil is all used up."))
  end
  this_event = pbMapInterpreter.get_self
  pbSetSelfSwitch(this_event.id, "A", true)
  return true
end

class Trainer
  def heal_party
    if Nuzlocke.active?
      pbEachPokemon { |poke,_box| poke.heal if !poke.fainted?}
    else
      pbEachPokemon { |poke,_box| poke.heal}
    end
  end
end

class Nuzlocke

  def initialize
    $game_switches[Settings::NUZLOCKE_SWITCH] = true
  end

  def self.active?
    return $game_switches[Settings::NUZLOCKE_SWITCH]
  end

  def self.cancel
    $game_switches[Settings::NUZLOCKE_SWITCH] = false
    $game_switches[Settings::NUZLOCKE_CHOSEN_SWITCH] = false
  end
end

def pbFindTM(move)
  itm = nil
  GameData::Item.each do |item|
    next unless item.is_machine?
    itm = item.id if item.move == move
  end
  if pbItemBall(itm)
    return true
  end
end

def pbGiveTM(move)
  itm = nil
  GameData::Item.each do |item|
    next unless item.is_machine?
    itm = item.id if item.move == move
  end
  if pbReceiveItem(itm)
    return true
  end
end

class Pokemon
  attr_accessor :unown_form
  attr_writer :evolution_counter

  alias unown_init initialize
  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    unown_init(species, level, owner = $player, withMoves = true, recheck_form = true)
    @unown_form       = @species == :UNOWN ? @form : nil
  end

  def evolution_counter
    @evolution_counter ||= 0
    return @evolution_counter
  end

  def unown_form
    return @unown_form
  end

  def alolan?
    pkmn = [:CUBONE,:EXEGGCUTE,:PIKACHU]
    return pkmn.include?(self.species) && $game_variables[7] != 2
  end

  def galarian?
    pkmn = [:KOFFING,:MIMEJR]
    return pkmn.include?(self.species)
  end

  def hisuian?
    pkmn = [:QUILAVA,:DARTRIX,:DEWOTT,:GOOMY,:RUFFLET,:PETILIL,:BERGMITE]
    return pkmn.include?(self.species)
  end

  def paldean?
    pkmn = [:URSARING]
  end

  def is_able_alternate_stone?
    return alolan? || galarian? || hisuian?
  end

  def grounded?
    return !hasType?(:FLYING) && !hasAbility?(:LEVITATE) && self.item != :AIRBALLOON
  end

  def hidden_move?;   return false;  end

  def check_evolution_on_use_item(item_used)
    return check_evolution_internal do |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_use_item(pkmn, parameter, item_used)
      if success && [:ALTERNATESTONE,:BLOODMOONSTONE,:SCROLLOFWATERS].include?(item_used)
        new_poke = pkmn.clone
        new_poke.species = new_species
        new_poke.form = 1
        new_species = new_poke.species
        new_species = GameData::Species.get_species_form(new_species,new_poke.form).id
      end
      next (success) ? new_species : nil
    end
  end
end

module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
      species = pkmn.species if !species
      species = GameData::Species.get_species_form(species,pkmn.form).id   # Just to be sure it's a symbol
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
      else
        ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
      end
      alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
      if ret && alter_bitmap_function
        new_ret = ret.copy
        ret.dispose
        new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
        ret = new_ret
      end
      return ret
    end
  end
end

class Battle::Scene
  def pbItemMenu(idxBattler, _firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $bag.last_viewed_pocket
    oldChoices    = $bag.last_pocket_selections.clone
    if @bagLastPocket
      $bag.last_viewed_pocket     = @bagLastPocket
      $bag.last_pocket_selections = @bagChoices
    else
      $bag.reset_last_selections
    end
    wasTargeting = false
    # Start Bag screen
    bag_screen = UI::Bag.new($bag, mode: :choose_item_in_battle)
    bag_screen.set_filter_proc(proc { |itm|
      use_type = GameData::Item.get(itm).battle_use
      next if use_type != 4
      next use_type && use_type > 0
    })
    bag_screen.show_and_hide do
      # Loop while in Bag screen
      loop do
        # Select an item
        item = bag_screen.choose_item_core
        break if !item
        # Choose a command for the selected item
        item = GameData::Item.get(item)
        itemName = item.name
        useType = item.battle_use
        cmdUse = -1
        commands = []
        commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
        commands[commands.length]          = _INTL("Cancel")
        command = bag_screen.show_menu(_INTL("{1} is selected.", itemName), commands)
        next unless cmdUse >= 0 && command == cmdUse   # Use
        # Use types:
        # 0 = not usable in battle
        # 1 = use on Pokémon (lots of items, Blue Flute)
        # 2 = use on Pokémon's move (Ethers)
        # 3 = use on battler (X items, Persim Berry, Red/Yellow Flutes)
        # 4 = use on opposing battler (Poké Balls)
        # 5 = use no target (Poké Doll, Guard Spec., Poké Flute, Launcher items)
        case useType
        when 1, 2, 3   # Use on Pokémon/Pokémon's move/battler
          # Auto-choose the Pokémon/battler whose action is being decided if they
          # are the only available Pokémon/battler to use the item on
          case useType
          when 1   # Use on Pokémon
            if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
              if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, bag_screen
                break
              else
                next
              end
            end
          when 3   # Use on battler
            if @battle.pbPlayerBattlerCount == 1
              if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, bag_screen
                break
              else
                next
              end
            end
          end
          # Fade out and hide Bag screen
          bag_sprites_status = pbFadeOutAndHide(bag_screen.sprites)
          # Get player's party
          party    = @battle.pbParty(idxBattler)
          partyPos = @battle.pbPartyOrder(idxBattler)
          partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
          modParty = @battle.pbPlayerDisplayParty(idxBattler)
          # Start party screen
          party_idx = -1
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, bag)
          ret = screen.pbChooseItemScreen(proc { |item|
            itm = GameData::Item.get(item)
            next false if !pbCanUseOnPokemon?(itm)
            next false if pokemon.hyper_mode && !GameData::Item.get(item)&.is_scent?
            if itm.is_machine?
              move = itm.move
              next false if pokemon.hasMove?(move) || !pokemon.compatible_with_move?(move)
            end
            next true
          })
          break if party_idx >= 0   # Item was used; close the Bag screen
          # Cancelled choosing a Pokémon; show the Bag screen again
          pbFadeInAndShow(bag_screen.sprites, bag_sprites_status)
        when 4   # Use on opposing battler (Poké Balls)
          idxTarget = -1
          if @battle.pbOpposingBattlerCount(idxBattler) == 1
            @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
            break if yield item.id, useType, idxTarget, -1, bag_screen
          else
            wasTargeting = true
            # Fade out and hide Bag screen
            bag_sprites_status = pbFadeOutAndHide(bag_screen.sprites)
            # Fade in and show the battle screen, choosing a target
            tempVisibleSprites = visibleSprites.clone
            tempVisibleSprites["commandWindow"] = false
            tempVisibleSprites["targetWindow"]  = true
            idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), tempVisibleSprites)
            if idxTarget >= 0
              break if yield item.id, useType, idxTarget, -1, self
            end
            # Target invalid/cancelled choosing a target; show the Bag screen again
            wasTargeting = false
            pbFadeOutAndHide(@sprites)
            pbFadeInAndShow(bag_screen.sprites, bag_sprites_status)
          end
        when 5   # Use with no target
          break if yield item.id, useType, idxBattler, -1, bag_screen
        end
      end
      next true
    end
    @bagLastPocket = $bag.last_viewed_pocket
    @bagChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = oldLastPocket
    $bag.last_pocket_selections = oldChoices
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end
end

ItemHandlers::UseOnPokemon.add(:IVMAXSTONE,proc { |item, qty, pkmn, scene|
  stats = []
  choices = []
  GameData::Stat.each do |stat|
    next if [:EVASION,:ACCURACY].include?(stat.id)
    stats.push(stat.id)
    choices.push(stat.name)
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to max out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[stats[statChoice]] == 31
    scene.pbDisplay(_INTL("This stat is already maxed out!"))
    next false
  end
  stat = GameData::Stat.get(stats[statChoice]).id
  statDisp = GameData::Stat.get(stats[statChoice]).name
    pkmn.iv[stat] = 31
    pkmn.calc_stats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were maxed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UseOnPokemon.add(:IVMINSTONE,proc { |item, qty, pkmn, scene|
  stats = []
  choices = []
  GameData::Stat.each do |stat|
    next if [:EVASION,:ACCURACY].include?(stat.id)
    stats.push(stat.id)
    choices.push(stat.name)
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to zero out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[stats[statChoice]] == 0
    scene.pbDisplay(_INTL("This stat is already zeroed out!"))
    next false
  end
  stat = GameData::Stat.get(stats[statChoice]).id
  statDisp = GameData::Stat.get(stats[statChoice]).name
    pkmn.iv[stat] = 0
    pkmn.calc_stats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were zeroed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UsableOnPokemon.add(:ALTERNATESTONE, proc { |item, pkmn|
  next true if pkmn.check_evolution_on_use_item(item) && pkmn.is_able_alternate_stone?
  next false
})

ItemHandlers::UseOnPokemon.add(:ALTERNATESTONE,
  proc { |item, qty, pkmn, scene|
    if pkmn.shadowPokemon?
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    newspecies = pkmn.check_evolution_on_use_item(item)
    if newspecies
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonPartyScreen)
          scene.pbRefreshAnnotations(proc { |p| !p.check_evolution_on_use_item(item).nil? })
          scene.pbRefresh
        end
      }
      next true
    end
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  }
)

ItemHandlers::UsableOnPokemon.add(:BLOODMOONSTONE, proc { |item, pkmn|
  next true if pkmn.check_evolution_on_use_item(item) && pkmn.paldean?
  next false
})

ItemHandlers::UseOnPokemon.add(:BLOODMOONSTONE,
  proc { |item, qty, pkmn, scene|
    if pkmn.shadowPokemon?
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    newspecies = pkmn.check_evolution_on_use_item(item)
    if newspecies
      pkmn.form = 1
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonPartyScreen)
          scene.pbRefreshAnnotations(proc { |p| !p.check_evolution_on_use_item(item).nil? })
          scene.pbRefresh
        end
      }
      next true
    end
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  }
)

ItemHandlers::UseFromBag.add(:OLDROD, proc { |item, bag_screen|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if $game_player.pbFacingTerrainTag.can_fish && ($PokemonGlobal.surfing || notCliff) && $PokemonGlobal.bridge == 0
    next 2
  end
  pbMessage(_INTL("Can't use that here."))
  next 0
})

ItemHandlers::UseFromBag.copy(:OLDROD, :SUPERROD)

GameData::Evolution.register({
  :id            => :AlternateItem,
  :parameter     => :Item,
  :use_item_proc => proc { |pkmn, parameter, item|
    next item == parameter
  }
})

MenuHandlers.add(:pause_menu, :pc_functions, {
  "name"      => _INTL("PC Functions"),
  "order"     => 46,
  "effect"    => proc { |menu|
    $menu_index = 0
    $last_menu_index = $game_temp.menu_last_choice
    pbPlayDecisionSE
    command_list = []
    commands = []
    MenuHandlers.each_available(:pc_functions, menu) do |option, hash, name|
      command_list.push(name)
      commands.push(hash)
    end
    command_list.push(_INTL("Cancel"))
    choice = menu.pbShowCommands("Choose a function",command_list)
    if choice < 0 || choice >= commands.length
      $menu_index = $last_menu_index
      menu.pbRefresh
      next false
    end
    commands[choice]["effect"].call(menu)
}
})

MenuHandlers.add(:pc_functions, :box_link, {
  "name"      => _INTL("PC Box Link"),
  "order"     => 10,
  "condition" => proc { next $player.party_count > 0 && !$game_switches[Settings::GAUNTLET_SWITCH]},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
      pbFadeOutIn do
        UI::PokemonStorage.new($PokemonStorage, mode: :organize).main
      end
  }
})

# MenuHandlers.add(:pc_functions, :export, {
#   "name"      => proc { next _INTL("Export...") },
#   "order"     => 20,
#   "effect"    => proc { |menu|
#     if pbConfirmMessage(_INTL("This will export all but the last 2 boxes as well as your party.\nContinue?"))
#       pbMessage(_INTL("Now exporting...\nPress C to finish..."))
#       export_all
#     end
#     next false
#   }
# })

MenuHandlers.add(:pc_functions, :return_items, {
  "name"      => proc { next _INTL("Return Items...") },
  "order"     => 40,
  "effect"    => proc { |menu|
    if pbConfirmMessage(_INTL("This will place all items held by all Pokémon back in your bag. This does not apply to items in Item Storage.\nContinue?"))
      return_items
    end
    next false
  }
})

def pbStaticEncounter(pkmn,level)
  pokemon = Pokemon.new(pkmn,level)
  pokemon.three_random_ivs
  pokemon.calc_stats
  return WildBattle.start(pokemon)
end

def pbCheckBerryType(berry)
  berries = {
    :CHILANBERRY => :NORMAL,
    :COBABERRY => :FLYING,
    :CHOPLEBERRY => :FIGHTING,
    :CHARTIBERRY => :ROCK,
    :SHUCABERRY => :GROUND,
    :TANGABERRY => :BUG,
    :KEBIABERRY => :POISON,
    :BABIRIBERRY => :STEEL,
    :KASIBBERRY => :GHOST,
    :RINDOBERRY => :GRASS,
    :OCCABERRY => :FIRE,
    :PASSHOBERRY => :WATER,
    :WACANBERRY => :ELECTRIC,
    :YACHEBERRY => :ICE,
    :PAYAPABERRY => :PSYCHIC,
    :HABANBERRY => :DRAGON,
    :COLBURBERRY => :DARK,
    :ROSELIBERRY => :FAIRY
  }
  # PBDebug.log("     =====> Berry type: #{berries[berry]}")
  return nil if !berries.has_key?(berry)
  return berries[berry]
end