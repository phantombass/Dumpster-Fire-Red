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
    @bgBitmap = AnimatedBitmap.new("Graphics/UI/Battle/2/ability_bar")
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
    return if !battler
    item = battler.pokemon.item_id if !item
    side = battler.index % 2
    pbHideAbilitySplash(battler) if @sprites["itemBar_#{side}"].visible
    @sprites["itemBar_#{side}"].item = item
    @sprites["itemBar_#{side}"].battler = battler
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
    return if !battler
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

class Battle
  def pbShowItemSplash(battler, item = nil, delay = false, logTrigger = true)
    item = battler.pokemon.item_id if !item
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{battler.itemName}") if logTrigger
    return if !Scene::USE_ABILITY_SPLASH
    @scene.pbShowItemSplash(battler,item)
    if delay
      timer_start = System.uptime
      until System.uptime - timer_start >= 1   # 1 second
        @scene.pbUpdate
      end
    end
  end

  def pbHideItemSplash(battler)
    return if !Scene::USE_ABILITY_SPLASH
    @scene.pbHideItemSplash(battler)
  end

  def pbCommonAnimation(name, user = nil, targets = nil)
    pbShowItemSplash(user, user.item) if ["EatBerry","UseItem"].include?(name)
    @scene.pbCommonAnimation(name, user, targets) if @showAnims
    pbHideItemSplash(user)
  end
end

Battle::ItemEffects::AfterMoveUseFromUser.add(:LIFEORB,
  proc { |item, user, targets, move, numHits, battle|
    next if !user.takesIndirectDamage?
    next if !move.pbDamagingMove? || numHits == 0
    hitBattler = false
    targets.each do |b|
      hitBattler = true if !b.damageState.unaffected && !b.damageState.substitute
      break if hitBattler
    end
    next if !hitBattler
    battle.pbShowItemSplash(user,item)
    PBDebug.log("[Item triggered] #{user.pbThis}'s #{user.itemName} (recoil)")
    user.pbReduceHP(user.totalhp / 10)
    battle.pbDisplay(_INTL("{1} lost some of its HP!", user.pbThis))
    pbHideItemSplash(user)
    user.pbItemHPHealCheck
    user.pbFaint if user.fainted?
  }
)

Battle::ItemEffects::AfterMoveUseFromUser.add(:SHELLBELL,
  proc { |item, user, targets, move, numHits, battle|
    next if !user.canHeal?
    totalDamage = 0
    targets.each { |b| totalDamage += b.damageState.totalHPLost }
    next if totalDamage <= 0
    battle.pbShowItemSplash(user,item)
    user.pbRecoverHP(totalDamage / 8)
    battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
       user.pbThis, user.itemName))
    pbHideItemSplash(user)
  }
)

Battle::ItemEffects::EndOfRoundEffect.add(:FLAMEORB,
  proc { |item, battler, battle|
    next if !battler.pbCanBurn?(battler, false)
    pbCommonAnimation("UseItem", battler)
    battler.pbBurn(nil, _INTL("{1} was burned by the {2}!", battler.pbThis, battler.itemName))
  }
)

Battle::ItemEffects::EndOfRoundEffect.add(:STICKYBARB,
  proc { |item, battler, battle|
    next if !battler.takesIndirectDamage?
    battle.pbShowItemSplash(user,item)
    battle.scene.pbDamageAnimation(battler)
    battler.pbTakeEffectDamage(battler.totalhp / 8, false) do |hp_lost|
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, battler.itemName))
    end
    pbHideItemSplash(user)
  }
)

Battle::ItemEffects::EndOfRoundEffect.add(:TOXICORB,
  proc { |item, battler, battle|
    next if !battler.pbCanPoison?(battler, false)
    pbCommonAnimation("UseItem", battler)
    battler.pbPoison(nil, _INTL("{1} was badly poisoned by the {2}!",
       battler.pbThis, battler.itemName), true)
  }
)

Battle::ItemEffects::OnSwitchIn.add(:AIRBALLOON,
  proc { |item, battler, battle|
    battle.pbShowItemSplash(battler,item)
    battle.pbDisplay(_INTL("{1} floats in the air with its {2}!",
       battler.pbThis, battler.itemName))
    pbHideItemSplash(battler)
  }
)