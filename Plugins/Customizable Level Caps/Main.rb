#New Level Cap System
module Settings
  LEVEL_CAP_IN_OPTIONS = 72 #This Switch will determine whether the Level Caps Option will appear in the Options Menu


  #This adds compatablilty with the Voltseon Pause Menu Plugin
  #Set to true if using the Voltseon Pause Menu
  #Also used to hide from Pause Menu if you wish to keep that off the UI
  VOLTSEON_PAUSE_MENU_USED = false
end

class PokemonSystem
  attr_accessor :level_caps
  attr_accessor :min_grinding
  alias initialize_caps initialize
  def initialize
    initialize_caps
    # @level_caps = 0 #Level caps set to on by default
    @min_grinding = 1
  end
end

# class Game_System
#   attr_accessor :level_cap
#   attr_accessor :egg_tutor
#   alias initialize_cap initialize
#   def initialize
#     initialize_cap
#     @level_cap          = 0
#   end
#   def level_cap
#     return @level_cap
#   end
# end

# #Define all your levels caps in this array. Every time you run Level_Cap.update, it will move to the next level cap in the array.
# LEVEL_CAP = [13,19,25,32,35,38,42,46,51,55,56,59,62,65,66,67,69,71,73,75,79,82,85,89,95,99]


# module Level_Cap
#   def self.initialize
#     $game_system.initialize
#   end
#   def self.update
#     $game_system.level_cap += 1
#     $game_system.level_cap = LEVEL_CAP.size-1 if $game_system.level_cap >= LEVEL_CAP.size
#     pbMessage(_INTL("Level Cap increased to \\r#{Level_Scaling.level_cap}!"))
#   end
# end

class Level_Cap
  attr_reader :cap_list
  attr_accessor :index

  def initialize
    @cap_list = [14,21,28,32]
    @index = 0
  end

  def start_new_game
    @index = 0
  end

  def setup
    @cap_list = [14,21,28,32]
  end

  def cap
    return @cap_list[@index] || @cap_list.last
  end

  def correct(cap)
    @cap_list.each_with_index do |c,i|
      next unless c == cap
      @index = i
      break
    end
    pbMessage(_INTL("Level Cap corrected to \\r#{cap}!"))
    pbMessage(_INTL("All overleveled Pokémon have been brought back to the Level Cap."))
  end

  def update
    @index += 1
    pbMessage(_INTL("Level Cap increased to \\r#{cap}!"))
  end

  def reset
    @index = 0
  end
end

SaveData.register(:level_caps) do
  load_in_bootup
  ensure_class :Level_Cap
  save_value { $level_caps }
  load_value { |value| $level_caps = value }
  new_game_value { Level_Cap.new }
end

module NavNums
  Dispose = 900 #Edit this to whatever switch you would like, it's not needed unless you're using the DexNav plugin
end

# class PokemonLoadScreen
#   def pbStartLoadScreen
#     $intro = true
#     commands = []
#     cmd_continue     = -1
#     cmd_new_game     = -1
#     cmd_options      = -1
#     cmd_language     = -1
#     cmd_mystery_gift = -1
#     cmd_debug        = -1
#     cmd_update       = -1
#     cmd_quit         = -1
#     show_continue = !@save_data.empty?
#     if show_continue
#       commands[cmd_continue = commands.length] = _INTL("Continue")
#       if @save_data[:player].mystery_gift_unlocked
#         commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
#       end
#     end
#     if !$MOBILE
#       update = Ancient_Platinum.need_update? ? "Update Available!" : "Current version: v#{read_version}"
#     else
#       update = "Current version: v#{Settings::GAME_VERSION}"
#     end
#     commands[cmd_new_game = commands.length]  = _INTL("New Game")
#     commands[cmd_options = commands.length]   = _INTL("Options")
#     commands[cmd_update = commands.length]    =  _INTL("{1}",update)
#     commands[cmd_language = commands.length]  = _INTL("Language") if Settings::LANGUAGES.length >= 2
#     commands[cmd_debug = commands.length]     = _INTL("Debug") if $DEBUG
#     commands[cmd_quit = commands.length]      = _INTL("Quit Game")
#     map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
#     @scene.pbStartScene(commands, show_continue, @save_data[:player], @save_data[:stats], map_id)
#     @scene.pbSetParty(@save_data[:player]) if show_continue
#     @scene.pbStartScene2
#     loop do
#       command = @scene.pbChoose(commands)
#       pbPlayDecisionSE if command != cmd_quit
#       case command
#       when cmd_continue
#         @scene.pbEndScene
#         Game.load(@save_data)
#         $game_switches[Settings::DISABLE_EVS] = true
#         time = pbGetTimeNow
#         HM_Catalogue.setup
#         Badges.setup
#         decide_league unless $game_variables[E4Vars::League] == 0
#         $player.pokedex.set_all_seen
#         $intro = false
#         return
#       when cmd_new_game
#         @scene.pbEndScene
#         Level_Cap.initialize
#         Game.start_new
#         Badges.setup
#         $player.pokedex.set_all_seen
#         return
#       when cmd_update
#        if Ancient_Platinum.need_update?
#          link = "https://raw.githubusercontent.com/phantombass/Pokemon-Ancient-Platinum/final_beta/version"
#          new_vers = Downloader.toString(link)
#          pbMessage(_INTL("New Update Available!\nCurrent version: #{read_version}\nNew version: #{new_vers}"))
#          if pbConfirmMessage(_INTL("Would you like to download the patch?"))
#            Ancient_Platinum.update
#            return
#          else
#            pbMessage(_INTL("Be sure to download as soon as you can."))
#          end
#        end
#       when cmd_mystery_gift
#         pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
#       when cmd_options
#         pbFadeOutIn do
#           scene = PokemonOption_Scene.new
#           screen = PokemonOptionScreen.new(scene)
#           screen.pbStartScreen(true)
#         end
#       when cmd_language
#         @scene.pbEndScene
#         $PokemonSystem.language = pbChooseLanguage
#         pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
#         if show_continue
#           @save_data[:pokemon_system] = $PokemonSystem
#           File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(@save_data, file) }
#         end
#         $scene = pbCallTitle
#         return
#       when cmd_debug
#         pbFadeOutIn { pbDebugMenu(false) }
#       when cmd_quit
#         pbPlayCloseMenuSE
#         @scene.pbEndScene
#         $scene = nil
#         return
#       else
#         pbPlayBuzzerSE
#       end
#     end
#   end
# end

# class PokemonPauseMenu_Scene
#   alias pbStartSceneCap pbStartScene
#   def pbStartScene
#     if !Settings::VOLTSEON_PAUSE_MENU_USED
#       if $game_switches[NavNums::Dispose] == false
#         cap = $level_caps.cap
#         @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
#         @viewport.z = 99999
#         @sprites = {}
#         @sprites["cmdwindow"] = Window_CommandPokemon.new([])
#         @sprites["cmdwindow"].visible = false
#         @sprites["cmdwindow"].viewport = @viewport
#         @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
#         @sprites["infowindow"].visible = false
#         @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
#         @sprites["helpwindow"].visible = false
#         @sprites["levelcapwindow"] = Window_UnformattedTextPokemon.newWithSize("Level Cap: #{cap}",0,64,208,64,@viewport)
#         @sprites["levelcapwindow"].visible = false
#         @infostate = false
#         @helpstate = false
#         $close_dexnav = 0
#         $sprites = @sprites
#         pbSEPlay("GUI menu open")
#       else
#         $viewport1.dispose
#         $currentDexSearch = nil
#         $close_dexnav = 1
#         $game_switches[NavNums::Dispose] = false
#         pbSEPlay("GUI menu close")
#         return
#       end
#     else
#       pbStartSceneCap
#     end
#   end
#   alias pbShowCommandsCap pbShowCommands
#   def pbShowCommands(commands)
#     if !Settings::VOLTSEON_PAUSE_MENU_USED
#       if $game_switches[NavNums::Dispose] == false && $close_dexnav < 1
#         ret = -1
#         cmdwindow = @sprites["cmdwindow"]
#         cmdwindow.commands = commands
#         cmdwindow.index    = $menu_index == 0 ? 0 : $game_temp.menu_last_choice
#         cmdwindow.resizeToFit(commands)
#         cmdwindow.x        = Graphics.width - cmdwindow.width
#         cmdwindow.y        = 0
#         cmdwindow.visible  = true
#         loop do
#           cmdwindow.update
#           Graphics.update
#           Input.update
#           pbUpdateSceneMap
#           if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
#             ret = -1
#             break
#           elsif Input.trigger?(Input::USE)
#             ret = cmdwindow.index
#             $menu_index = ret
#             $game_temp.menu_last_choice = ret
#             break
#           end
#         end
#       else
#         ret = -1
#       end
#       $close_dexnav -= 1
#       return ret
#     else
#       pbShowCommandsCap(commands)
#     end
#   end
#   def pbShowLevelCap
#     @sprites["levelcapwindow"].visible = true if !Settings::VOLTSEON_PAUSE_MENU_USED
#   end
#   def pbHideLevelCap
#     @sprites["levelcapwindow"].visible = false if !Settings::VOLTSEON_PAUSE_MENU_USED
#   end
# end

# class PokemonPauseMenu
#   def pbShowLevelCap
#     @scene.pbShowLevelCap if !Settings::VOLTSEON_PAUSE_MENU_USED
#   end

#   def pbHideLevelCap
#     @scene.pbHideLevelCap if !Settings::VOLTSEON_PAUSE_MENU_USED
#   end
#   alias pbStartPokemonMenuCap pbStartPokemonMenu
#   def pbStartPokemonMenu
#     if !Settings::VOLTSEON_PAUSE_MENU_USED
#       if !$player
#         if $DEBUG
#           pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
#           pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
#         end
#         return
#       end
#       @scene.pbStartScene
#       # Show extra info window if relevant
#       pbShowInfo
#       pbShowLevelCap
#       # Get all commands
#       command_list = []
#       commands = []
#       MenuHandlers.each_available(:pause_menu) do |option, hash, name|
#         command_list.push(name)
#         commands.push(hash)
#       end
#       # Main loop
#       end_scene = false
#       loop do
#         if !$currentDexSearch
#           choice = @scene.pbShowCommands(command_list)
#         else
#           choice = -1
#         end
#         if choice < 0
#           pbPlayCloseMenuSE if !$currentDexSearch
#           end_scene = true
#           break
#         end
#         break if commands[choice]["effect"].call(@scene)
#       end
#       if $close_dexnav != 0
#         @scene.pbEndScene if end_scene
#       end
#     else
#       pbStartPokemonMenuCap
#     end
#   end
# end

class Battle
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    level_cap = $level_caps.cap
    level_cap_gap = growth_rate.exp_values[level_cap] - pkmn.exp
    # Main Exp calculation
    exp = 0
    a = level * defeatedBattler.pokemon.base_exp
    if expShare.length > 0 && (isPartic || hasExpShare)
      if numPartic == 0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a / (2 * numPartic) if isPartic
        exp += a / (2 * expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a / 2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a / 2
    end
    return if exp <= 0
    # Pokémon gain more Exp from trainer battles
    exp = (exp * 1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = ((2 * level) + 10.0) / (pkmn.level + level + 10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
      if pkmn.level >= level_cap
        exp /= 250
      end
      if exp >= level_cap_gap
        exp = level_cap_gap + 1
      end
    else
      if a <= level_cap_gap
        exp = a
      else
        exp /= 7
      end
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp * 1.7).floor
      else
        exp = (exp * 1.5).floor
      end
    end
    # Exp. Charm increases Exp gained
    # exp = exp * 3 / 2 if $bag.has?(:EXPCHARM)
    # Modify Exp gain based on pkmn's held item
    i = Battle::ItemEffects.triggerExpGainModifier(pkmn.item, pkmn, exp)
    if i < 0
      i = Battle::ItemEffects.triggerExpGainModifier(@initialItems[0][idxParty], pkmn, exp)
    end
    exp = i if i >= 0
    # Boost Exp gained with high affection
    if Settings::AFFECTION_EFFECTS && @internalBattle && pkmn.affection_level >= 4 && !pkmn.mega?
      exp = exp * 6 / 5
      isOutsider = true   # To show the "boosted Exp" message
    end
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    return if expGained <= 0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!", pkmn.name, expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, expGained))
      end
    end
    curLevel = pkmn.level
    oldlevel = curLevel
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel < curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
                  pkmn.name, debugInfo)
    end
    # Give Exp
    if pkmn.shadowPokemon?
      if pkmn.heartStage <= 3
        pkmn.exp += expGained
        $stats.total_exp_gained += expGained
      end
      return
    end
    $stats.total_exp_gained += expGained
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel > newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler&.pbUpdate(false)
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp", battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler&.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler&.pbUpdate(false)
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel))
      @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                       oldSpAtk, oldSpDef, oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty, m[1]) if m[0] == curLevel }
      return if pkmn.level==oldlevel
      battler = pbFindBattler(idxParty)
      newSpecies = pkmn.check_evolution_on_level_up
      return if newSpecies.nil?
      previousBGM = $game_system.getPlayingBGM
      # Evolution
      pbFadeOutInWithMusic { evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newSpecies)
        evo.pbEvolution
        evo.pbEndScreen }
      if battler
        @scene.pbChangePokemon(@battlers[battler.index],@battlers[battler.index].pokemon)
        battler.pbInitPokemon(pkmn,battler.pokemonIndex)
        battler.name = battler.name
        battler.pbUpdate(false)
        @scene.pbRefreshOne(battler.index)
      end
      pbBGMPlay(previousBGM)
    end
  end
  def pbGainEVsOne(idxParty, defeatedBattler)
     if $no_evs == false
      pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
      evYield = defeatedBattler.pokemon.evYield
      # Num of effort points pkmn already has
      evTotal = 0
      GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
      # Modify EV yield based on pkmn's held item
      if !Battle::ItemEffects.triggerEVGainModifier(pkmn.item, pkmn, evYield)
        Battle::ItemEffects.triggerEVGainModifier(@initialItems[0][idxParty], pkmn, evYield)
      end
      # Double EV gain because of Pokérus
      if pkmn.pokerusStage >= 1   # Infected or cured
        evYield.each_key { |stat| evYield[stat] *= 2 }
      end
      # Gain EVs for each stat in turn
      if pkmn.shadowPokemon? && pkmn.heartStage <= 3 && pkmn.saved_ev
        pkmn.saved_ev.each_value { |e| evTotal += e }
        GameData::Stat.each_main do |s|
          evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id] - pkmn.saved_ev[s.id])
          evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
          pkmn.saved_ev[s.id] += evGain
          evTotal += evGain
        end
      else
        GameData::Stat.each_main do |s|
          evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id])
          evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
          pkmn.ev[s.id] += evGain
          evTotal += evGain
        end
      end
    end
  end
end

# ItemHandlers::UseOnPokemonMaximum.add(:INFINITECANDY, proc { |item, pkmn|
#   if $PokemonSystem.level_caps == 1
#     next GameData::GrowthRate.max_level - pkmn.level
#   else
#     next $level_caps.cap - pkmn.level
#   end
# })

ItemHandlers::UsableOnPokemon.add(:INFINITECANDY, proc { |item, pkmn|
  next pkmn.level < $level_caps.cap
})

ItemHandlers::UseOnPokemon.add(:INFINITECANDY, proc { |item, qty, pkmn, scene|
  if pkmn.shadowPokemon? || pkmn.fainted?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if $PokemonSystem.level_caps == 1
    if pkmn.level >= GameData::GrowthRate.max_level
      new_species = pkmn.check_evolution_on_level_up
      if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
        scene.pbDisplay(_INTL("It won't have any effect."))
        next false
      end
      # Check for evolution
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(UI::Party)
      }
      next true
    end
  else
    if pkmn.level >= $level_caps.cap
      new_species = pkmn.check_evolution_on_level_up
      if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
        scene.pbDisplay(_INTL("It won't have any effect."))
        next false
      end
      # Check for evolution
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(UI::Party)
      }
      next true
    end
  end
  # Level up
  pbChangeLevel(pkmn, pkmn.level + qty, scene)
  scene.pbHardRefresh
  next true
})

MenuHandlers.add(:options_menu, :level_caps, {
  "name"        => _INTL("Level Caps"),
  "order"       => 90,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you will have hard level caps."),
  "condition"   => proc { next $game_switches && $game_switches[Settings::LEVEL_CAP_IN_OPTIONS] },
  "get_proc"    => proc { next $PokemonSystem.level_caps},
  "set_proc"    => proc { |value, _scene| $PokemonSystem.level_caps = value }
})

def pbGainExpFromExpCandy(pkmn, base_amt, qty, scene)
  if (pkmn.level >= GameData::GrowthRate.max_level && $PokemonSystem.level_caps == 1) || pkmn.shadowPokemon? || (pkmn.level >=$level_caps.cap && $PokemonSystem.level_caps == 0)
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  if qty > 1
    (qty - 1).times { pkmn.changeHappiness("vitamin") }
  end
  pbChangeExp(pkmn, pkmn.exp + (base_amt * qty), scene)
  scene.pbHardRefresh
  return true
end

def pbChangeExp(pkmn, new_exp, scene)
  growth_rate = pkmn.growth_rate
  level_cap =$level_caps.cap
  exp_change = $PokemonSystem.level_caps == 0 ? growth_rate.exp_values[level_cap] : growth_rate.maximum_exp
  new_exp = new_exp.clamp(0, exp_change)
  if pkmn.exp == new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  if pkmn.exp > new_exp   # Loses Exp
    difference = pkmn.exp - new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else   # Gains Exp
    difference = new_exp - pkmn.exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.changeHappiness("vitamin")
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\nAttack<r>+{2}\nDefense<r>+{3}\nSp. Atk<r>+{4}\nSp. Def<r>+{5}\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic do
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      end
    end
  end
end