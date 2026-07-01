# Poison party Pokémon
EventHandlers.add(:on_player_step_taken_can_transfer, :poison_party,
  proc { |handled|
    # handled is an array: [nil]. If [true], a transfer has happened because of
    # this event, so don't do anything that might cause another one
    next if handled[0]
    next if !Settings::POISON_IN_FIELD || $PokemonGlobal.stepcount % 4 != 0
    flashed = false
    $player.able_party.each do |pkmn|
      next if pkmn.status != :POISON || pkmn.hasAbility?(:IMMUNITY)
      if !flashed
        $scene.spriteset.addUserAnimation(Settings::POISON_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
        flashed = true
      end
      pkmn.hp -= 1 if pkmn.hp > 1 || Settings::POISON_FAINT_IN_FIELD
      if pkmn.hp == 1 && !Settings::POISON_FAINT_IN_FIELD
        pkmn.status = :NONE
        pbMessage(_INTL("{1} survived the poisoning.\nThe poison faded away!", pkmn.name))
        next
      elsif pkmn.hp == 0
        pkmn.changeHappiness("faint")
        pkmn.status = :NONE
        pbMessage(_INTL("{1} fainted...", pkmn.name))
      end
      if $player.able_pokemon_count == 0
        handled[0] = true
        pbCheckAllFainted
      end
    end
  }
)

class PokemonPokedexInfo_Scene
  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_area"))
    overlay = @sprites["overlay"].bitmap
    pbSetSmallFont(overlay)
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    # Set the text
    textpos = []
    species_data = GameData::Species.get_species_form(@species, @form)
    pkmn = Pokemon.new(species_data,1)
    moves = pkmn.getMoveList
    textpos.push([_INTL("Level"), 26, 56, 0, base, shadow])
    textpos.push([_INTL("Move"), 172, 56, 1, base, shadow])
    idx = 1
    xdx = 0
    for move_data in moves
      x1 = 26 + (240*xdx)
      x2 = 86 + (240*xdx)
      y = 56 + (16*idx)
      level = move_data[0]
      move = GameData::Move.get(move_data[1]).name
      textpos.push([_INTL("{1}",level), x1, y, 0, base, shadow])
      textpos.push([_INTL("{1}",move), x2, y, 0, base, shadow])
      idx += 1
      if idx > 18
        textpos.push([_INTL("Level"), 266, 56, 0, base, shadow])
        textpos.push([_INTL("Move"), 412, 56, 1, base, shadow])
        xdx += 1
        idx = 1
      end
    end
    pbDrawTextPositions(overlay, textpos)
  end
end

MenuHandlers.add(:bag_screen_interact, :use, {
  "name"      => proc { |screen|
    #next ItemHandlers.getUseText(screen.item.id) if ItemHandlers.hasUseText(screen.item.id)
    next _INTL("Give") unless $pocket == :Berries
    next _INTL("Use")
  },
  "order"     => 30,
  "condition" => proc { |screen|
    next $player.pokemon_party.length > 0 && screen.item.can_hold? unless screen.item.pocket == :Berries
    next ItemHandlers.hasOutHandler(screen.item.id) || (screen.item.is_machine? && $player.party.length > 0)
  }
})

MenuHandlers.add(:bag_screen_interact, :give, {
  "name"      => proc {|screen|
    next _INTL("Give") if $pocket == :Berries
    next _INTL("Use")
  },
  "order"     => 20,
  "condition" => proc { |screen| 
    next $player.pokemon_party.length > 0 && screen.item.can_hold? if screen.item.pocket == :Berries
    next ItemHandlers.hasOutHandler(screen.item.id) || (screen.item.is_machine? && $player.party.length > 0)
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :use, {
  :returns_value => ($pocket ? $pocket != :Berries : true),
  :effect        => proc { |screen|
    if $pocket == :Berries
      item = screen.item.id
      ret = pbUseItem(screen.bag, item, screen)
      # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
      if ret == 2
        screen.result = item
        screen.end_screen
        next :quit
      end
      screen.refresh
      next nil
    else
      if $player.pokemon_count == 0
        screen.show_message(_INTL("There is no Pokémon."))
      elsif screen.item.is_important?
        screen.show_message(_INTL("The {1} can't be held.", screen.item.portion_name))
      else
        pbFadeOutInWithUpdate(screen.sprites) do
          party_screen = UI::Party.new($player.party, mode: :choose_pokemon)
          party_screen.choose_pokemon do |pkmn, party_index|
            pbGiveItemToPokemon(screen.item.id, party_screen.pokemon, party_screen, party_index) if party_index >= 0
            next true
          end
          screen.refresh
        end
      end
    end
  }
})

UIActionHandlers.add(UI::Bag::SCREEN_ID, :give, {
  :returns_value => ($pocket ? $pocket == :Berries : false),
  :effect => proc { |screen|
    if $pocket == :Berries
      if $player.pokemon_count == 0
        screen.show_message(_INTL("There is no Pokémon."))
      elsif screen.item.is_important?
        screen.show_message(_INTL("The {1} can't be held.", screen.item.portion_name))
      else
        pbFadeOutInWithUpdate(screen.sprites) do
          party_screen = UI::Party.new($player.party, mode: :choose_pokemon)
          party_screen.choose_pokemon do |pkmn, party_index|
            pbGiveItemToPokemon(screen.item.id, party_screen.pokemon, party_screen, party_index) if party_index >= 0
            next true
          end
          screen.refresh
        end
      end
    else
      item = screen.item.id
      ret = pbUseItem(screen.bag, item, screen)
      # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
      if ret == 2
        screen.result = item
        screen.end_screen
        next :quit
      end
      screen.refresh
      next nil
    end
  }
})

class Battle::Scene::Animation::AbilitySplashAppear < Battle::Scene::Animation
  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar.setVisible(0, true)
    bar.setSE(0, "Battle ability")
    bar.z = @sprites["pokemon_#{@side}"].z+1
    dir = (@side == 0) ? 1 : -1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
  end
end

class Battle::Scene::Animation::AbilitySplashDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, side)
    @side = side
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    dir = (@side == 0) ? -1 : 1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
    bar.setVisible(8, false)
  end
end

#===============================================================================
# Splash bar to announce a triggered item
#===============================================================================
class Battle::Scene::ItemSplashBar < Sprite
  attr_reader :battler

  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)

  def initialize(side, viewport = nil)
    super(viewport)
    @side    = side
    @battler = nil
    # Create sprite wrapper that displays background graphic
    @bgBitmap = AnimatedBitmap.new("Graphics/UI/Battle/ability_bar")
    @bgSprite = Sprite.new(viewport)
    @bgSprite.bitmap = @bgBitmap.bitmap
    @bgSprite.src_rect.y      = (side == 0) ? 0 : @bgBitmap.height / 2
    @bgSprite.src_rect.height = @bgBitmap.height / 2
    # Create bitmap that displays the text
    @contents = Bitmap.new(@bgBitmap.width, @bgBitmap.height / 2)
    @item = nil
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    # Position the bar
    self.x       = (side == 0) ? -Graphics.width / 2 : Graphics.width
    self.y       = (side == 0) ? 180 : 80
    self.z       = 120
    self.visible = false
  end

  def dispose
    @bgSprite.dispose
    @bgBitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    @bgSprite.x = value
  end

  def y=(value)
    super
    @bgSprite.y = value
  end

  def z=(value)
    super
    @bgSprite.z = value - 1
  end

  def opacity=(value)
    super
    @bgSprite.opacity = value
  end

  def visible=(value)
    super
    @bgSprite.visible = value
  end

  def color=(value)
    super
    @bgSprite.color = value
  end

  def item=(value)
    @item = value
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def refresh
    self.bitmap.clear
    return if !@battler
    textPos = []
    textX = (@side == 0) ? 10 : self.bitmap.width - 8
    align = (@side == 0) ? :left : :right
    # Draw Pokémon's name
    textPos.push([_INTL("{1}'s", @battler.name), textX, 8, align,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, :outline])
    # Draw Pokémon's item name
    textPos.push([GameData::Item.get(@item).name, textX, 38, align,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, :outline])
    pbDrawTextPositions(self.bitmap, textPos)
  end

  def update
    super
    @bgSprite.update
  end
end

class Battle::Scene
  def pbInitSprites
    @sprites = {}
    # The background image and each side's base graphic
    pbCreateBackdropSprites
    # Create message box graphic
    messageBox = pbAddSprite("messageBox", 0, Graphics.height - 96,
                             "Graphics/UI/Battle/overlay_message", @viewport)
    messageBox.z = 10195
    # Create message window (displays the message)
    msgWindow = Window_AdvancedTextPokemon.newWithSize(
      "", 16, Graphics.height - 96 + 2, Graphics.width - 32, 96, @viewport
    )
    msgWindow.z              = 10200
    msgWindow.opacity        = 0
    msgWindow.baseColor      = MESSAGE_BASE_COLOR
    msgWindow.shadowColor    = MESSAGE_SHADOW_COLOR
    msgWindow.letterbyletter = true
    @sprites["messageWindow"] = msgWindow
    # Create command window
    @sprites["commandWindow"] = CommandMenu.new(@viewport, 10200)
    # Create fight window
    @sprites["fightWindow"] = FightMenu.new(@viewport, 10200)
    # Create targeting window
    @sprites["targetWindow"] = TargetMenu.new(@viewport, 10200, @battle.sideSizes)
    pbShowWindow(MESSAGE_BOX)
    # The party lineup graphics (bar and balls) for both sides
    2.times do |side|
      partyBar = pbAddSprite("partyBar_#{side}", 0, 0,
                             "Graphics/UI/Battle/overlay_lineup", @viewport)
      partyBar.z       = 10120
      partyBar.mirror  = true if side == 0   # Player's lineup bar only
      partyBar.visible = false
      NUM_BALLS.times do |i|
        ball = pbAddSprite("partyBall_#{side}_#{i}", 0, 0, nil, @viewport)
        ball.z       = 10121
        ball.visible = false
      end
      # Ability and Item splash bars
      if USE_ABILITY_SPLASH
        @sprites["abilityBar_#{side}"] = AbilitySplashBar.new(side, @viewport)
        @sprites["itemBar_#{side}"] = ItemSplashBar.new(side, @viewport)
      end
    end
    # Player's and partner trainer's back sprite
    @battle.player.each_with_index do |p, i|
      pbCreateTrainerBackSprite(i, p.trainer_type, @battle.player.length)
    end
    # Opposing trainer(s) sprites
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |p, i|
        pbCreateTrainerFrontSprite(i, p.trainer_type, @battle.opponent.length)
      end
    end
    # Data boxes and Pokémon sprites
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"] = PokemonDataBox.new(b, @battle.pbSideSize(i), @viewport)
      pbCreatePokemonSprite(i)
    end
    # Wild battle, so set up the Pokémon sprite(s) accordingly
    if @battle.wildBattle?
      @battle.pbParty(1).each_with_index do |pkmn, i|
        index = (i * 2) + 1
        pbChangePokemon(index, pkmn)
        pkmnSprite = @sprites["pokemon_#{index}"]
        pkmnSprite.tone    = Tone.new(-80, -80, -80)
        pkmnSprite.visible = true
      end
    end
  end

  def pbShowItemSplash(battler,item)
    return if !USE_ABILITY_SPLASH
    item = battler.pokemon.item_id if !item
    side = battler.index % 2
    pbHideAbilitySplash(battler) if @sprites["itemBar_#{side}"].visible
    @sprites["itemBar_#{side}"].battler = battler
    @sprites["itemBar_#{side}"].item = item
    abilitySplashAnim = Animation::ItemSplashAppear.new(@sprites, @viewport, side)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end

  def pbHideItemSplash(battler)
    return if !USE_ABILITY_SPLASH
    side = battler.index % 2
    return if !@sprites["itemBar_#{side}"].visible
    abilitySplashAnim = Animation::ItemSplashDisappear.new(@sprites, @viewport, side)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end
end

class Battle::Scene::Animation::ItemSplashAppear < Battle::Scene::Animation
  def initialize(sprites, viewport, side)
    @side = side
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["itemBar_#{@side}"]
    bar = addSprite(@sprites["itemBar_#{@side}"])
    bar.setVisible(0, true)
    bar.setSE(0, "Battle ability")
    bar.z = @sprites["pokemon_#{@side}"].z+1
    dir = (@side == 0) ? 1 : -1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
  end
end

class Battle::Scene::Animation::ItemSplashDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, side)
    @side = side
    super(sprites, viewport)
  end

  def createProcesses
    return if !@sprites["itemBar_#{@side}"]
    bar = addSprite(@sprites["itemBar_#{@side}"])
    dir = (@side == 0) ? -1 : 1
    bar.moveDelta(0, 8, dir * Graphics.width / 2, 0)
    bar.setVisible(8, false)
  end
end