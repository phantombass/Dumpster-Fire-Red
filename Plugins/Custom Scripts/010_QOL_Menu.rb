class UI::QOLVisuals < UI::BaseVisuals
  def initialize
    @info_text_visible = false
#    @help_text_visible = false
    super
  end

  def initialize_background; end
  def initialize_overlay; end

  def initialize_sprites
    # Pause menu
    @sprites[:commands] = Window_CommandPokemon.new([])
    @sprites[:commands].visible = false
    @sprites[:commands].viewport = @viewport
#    @sprites[:help_text] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
#    @sprites[:help_text].visible = false
  end

  #-----------------------------------------------------------------------------

  # commands is [[command IDs], [command names]].
  def set_commands(commands)
    @commands = commands
    cmd_window = @sprites[:commands]
    cmd_window.commands = @commands[1]
    cmd_window.index    = $game_temp.menu_last_choice
    cmd_window.resizeToFit(@commands[1])
    cmd_window.x        = Graphics.width - cmd_window.width
    cmd_window.y        = 0
    cmd_window.visible  = true
  end

  #-----------------------------------------------------------------------------

  def show_menu
    @sprites[:commands].visible = true
#    @sprites[:help_text].visible = @help_text_visible
  end

  def hide_menu
    @sprites[:commands].visible = false
#    @sprites[:help_text].visible = false
  end

  # Used in Safari Zone and Bug-Catching Contest to show extra information.
  def show_info(text);  end

  # Unused.
#  def show_help(text)
#    @sprites[:help_text].resizeToFit(text, Graphics.height)
#    @sprites[:help_text].text    = text
#    @sprites[:help_text].visible = true
#    pbBottomLeft(@sprites[:help_text])
#    @help_text_visible = true
#  end

  #-----------------------------------------------------------------------------

  def update_visuals
    pbUpdateSceneMap
    super
  end

  def update_input
    if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
      return :quit
    end
    if Input.trigger?(Input::USE)
      idx = @sprites[:commands].index
      $game_temp.menu_last_choice = idx
      return @commands[0][idx]
    end
    return nil
  end
end

#===============================================================================
# Party menu text colors.
#===============================================================================
class Window_CommandPokemon
  #-----------------------------------------------------------------------------
  # Stores the text colors for each color symbol. The first color in each array
  # corresponds to the base color, and the second color is for the shadow.
  #-----------------------------------------------------------------------------
  TEXT_COLOR_KEY = {
    :Red    => [Color.new(232,  32,  16), Color.new(248, 168, 184)],
    :Blue   => [Color.new(  0,  80, 160), Color.new(128, 192, 240)],
    :Green  => [Color.new( 96, 176,  72), Color.new(174, 208, 144)],
    :Orange => [Color.new(236,  88,   0), Color.new(255, 170,  51)],
    :Purple => [Color.new(149,  33, 246), Color.new(255, 161, 326)],
    :Gray   => [Color.new(184, 184, 184), Color.new( 96,  96,  96)]
  }

  #-----------------------------------------------------------------------------
  # Sets the text color for each menu option.
  #-----------------------------------------------------------------------------
  def drawItem(index, _count, rect)
    pbSetSystemFont(self.contents) if @starting
    rect = drawCursor(index, rect)
    if @commands[index].is_a?(Array)
      base   = TEXT_COLOR_KEY[@commands[index][1]][0]
      shadow = TEXT_COLOR_KEY[@commands[index][1]][1]
    else
      base   = self.baseColor
      shadow = self.shadowColor
    end
    pbDrawShadowText(self.contents, rect.x, rect.y + (self.contents.text_offset_y || 0),
                     rect.width, rect.height, @commands[index], base, shadow)
  end
end

class UI::QOLMenu < UI::BaseScreen
  def initialize
    raise _INTL("Tried to open the pause menu when $player was not defined.") if !$player
    initialize_commands
    super
  end

  def initialize_commands
    @commands ||= [[], []]
    @commands[0].clear
    @commands[1].clear
    @commands_hashes ||= {}
    @commands_hashes.clear
    MenuHandlers.each_available(:qol_menu) do |option, hash, name|
      @commands[0].push(option)
      @commands[1].push(name)
      @commands_hashes[option] = hash
    end
  end

  def initialize_visuals
    @visuals = UI::QOLVisuals.new
    @visuals.set_commands(@commands)
    show_info
  end

  def hide_menu
    @visuals.hide_menu
  end

  def show_menu
    @visuals.show_menu
  end

  def show_info; end

  def start_screen
    pbSEPlay("GUI menu open")
  end

  def end_screen
    return if @disposed
    pbPlayCloseMenuSE
    $qol_menu = false
    silent_end_screen
  end

  #-----------------------------------------------------------------------------

  def refresh
    initialize_commands
    @visuals.set_commands(@commands)
    super
  end

  def perform_action(command)
    if @commands_hashes[command]["effect"].call(self)
      # NOTE: Calling end_screen will have been done in the "effect" proc, so
      #       there's no need to do anything special here to mark that this
      #       screen has already been closed/disposed of.
      $qol_menu = false
      return :quit
    end
    return nil
  end
end

MenuHandlers.add(:qol_menu, :town_map, {
  "name"      => _INTL("Town Map"),
  "order"     => 10,
  "effect"    => proc { |menu|
    menu.hide_menu
    pbPlayDecisionSE
    pbShowMap
    $qol_menu = false
    menu.silent_end_screen
    next false
  }
})

MenuHandlers.add(:qol_menu, :repel_off, {
  "name"      => _INTL("Infinite Repel (Disabled)"),
  "order"     => 20,
  "condition" => proc { next $PokemonGlobal.repel == 0},
  "effect"    => proc { |menu|
    menu.hide_menu
    pbPlayDecisionSE
    pbInfiniteRepel
    $qol_menu = false
    menu.silent_end_screen
    next false
  }
})

MenuHandlers.add(:qol_menu, :repel_on, {
  "name"      => _INTL("Infinite Repel (Enabled)"),
  "order"     => 21,
  "condition" => proc { next $PokemonGlobal.repel > 0},
  "effect"    => proc { |menu|
    menu.hide_menu
    pbPlayDecisionSE
    pbInfiniteRepel
    $qol_menu = false
    menu.silent_end_screen
    next false
  }
})

=begin
MenuHandlers.add(:qol_menu, :repel, {
  "name"      => _INTL("Infinite Repel"),
  "color"     => :Green,
  "order"     => 21,
  #{}"condition" => proc { next $game_variables[Settings::INFINITE_REPEL] == 1},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbInfiniteRepel
    next false
  }
})
=end
MenuHandlers.add(:qol_menu, :heal, {
  "name"      => _INTL("Heal Party"),
  "order"     => 30,
  "condition" => proc { next $game_switches && $game_switches[67] && !$game_switches[Settings::GAUNTLET_SWITCH]},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    $player.heal_party
    pbMessage(_INTL("Your party was healed!"))
    $qol_menu = false
    menu.silent_end_screen
    next false
  }
})

def pbQOLMenu
  if $game_switches[Settings::QOL_SWITCH] && $in_battle != true
    $qol_menu = true
    UI::QOLMenu.new.main
  end
end
=begin
def pbQOLMenu
  if $game_switches[64]
    $viewport_mission.pbEndScene if !$viewport_mission.nil?
    $qol_toggle = false
    commands = []
    commands.push("Town Map") if $game_switches[65]
    if $game_switches[66]
      color = $game_variables[Settings::INFINITE_REPEL] == 1 ? "On" : "Off"
    end
    commands.push("Infinite Repel") if $game_switches[66]
    commands.push("Heal: #{pbGet(74)}") if $game_switches[67]
    commands.push("Cancel")
    cmd = commands.length
    var = 34
    case cmd
    when 2
      pbMessage(_INTL("Choose a function.\\ch[#{var},#{cmd},#{commands[0]},#{commands[1]}]"))
    when 3
      pbMessage(_INTL("Choose a function.\\ch[#{var},#{cmd},#{commands[0]},#{commands[1]}: #{color},#{commands[2]}]"))
    when 4
      pbMessage(_INTL("Choose a function.\\ch[#{var},#{cmd},#{commands[0]},#{commands[1]}: #{color},#{commands[2]},#{commands[3]}]"))
    end
    case $game_variables[var]
    when 0
      pbShowMap
      $qol_toggle = true
    when 1
      if $game_switches[66]
        pbInfiniteRepel
        $qol_toggle = true
      else
        $qol_toggle = true
      end
    when 2
      if $game_switches[67]
        if $game_variables[74] > 0
          $Trainer.heal_party
          pbMessage(_INTL("Your party was healed!"))
          $game_variables[74] -= 1
        else
          pbMessage(_INTL("You've run out of Heals!"))
          pbMessage(_INTL("Please recharge at the PMC!"))
        end
        pbPlayCloseMenuSE
        $qol_toggle = true
      else
        $qol_toggle = true
      end
    else
      pbPlayCloseMenuSE
      $qol_toggle = true
    end
  end
end
=end
def pbInfiniteRepel
  $game_variables[Settings::INFINITE_REPEL] += 1
  $game_variables[Settings::INFINITE_REPEL] = 0 if $game_variables[Settings::INFINITE_REPEL] >= REPEL_STAGES.size
  $PokemonGlobal.repel = REPEL_STAGES[$game_variables[Settings::INFINITE_REPEL]]
  $PokemonGlobal.repel == 0 ? pbMessage(_INTL("Infinite Repel Disabled.")) : pbMessage(_INTL("Infinite Repel Enabled."))
end

REPEL_STAGES = [0,1]

module Settings
  QOL_SWITCH = 64
end