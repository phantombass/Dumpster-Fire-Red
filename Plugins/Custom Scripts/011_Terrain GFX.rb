GameData::Environment.register({
  :id          => :Electric,
  :name        => _INTL("electric"),
  :battle_base => "electric"
})

GameData::Environment.register({
  :id          => :Grassy,
  :name        => _INTL("grassy"),
  :battle_base => "grassy"
})

GameData::Environment.register({
  :id          => :Misty,
  :name        => _INTL("misty"),
  :battle_base => "misty"
})

GameData::Environment.register({
  :id          => :Psychic,
  :name        => _INTL("psychic"),
  :battle_base => "psychic"
})

def pbSetTerrain(terrain)
  setBattleRule("terrain",terrain)
  setBattleRule("environment",terrain)
  name = GameData::Environment.get(terrain).name
  $PokemonGlobal.nextBattleBack = name
end

class Battle::Scene
  def pbCreateBackdropSprites
    case @battle.time
    when 1 then time = "eve"
    when 2 then time = "night"
    end
    # Put everything together into backdrop, bases and message bar filenames
    change = pbChangeTerrain(@battle.field.terrain)
    if @battle.field.terrain != :None
      @battle.backdrop = change[0]
      @battle.backdropBase = change[1]
    else
      if $PokemonGlobal.surfing
        bg = "water"
        back = "water"
      elsif pbGetEnvironment == :None
        bg = "interior"
        back = "interior"
      else
        bg = GameData::Environment.get(pbGetEnvironment).battle_base
        back = pbGetEnvironment == :Cave ? "cave1" : "field"
      end
      @battle.backdrop = back
      @battle.backdropBase = bg
    end
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s", baseFilename, @battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if time
      trialName = sprintf("%s_%s", backdropFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s", baseFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s", messageFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_message"))
        messageFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/" + baseFilename + "_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s", baseFilename, time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
          baseFilename = trialName
        end
      end
    end
    # Finalise filenames
    battleBG   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    playerBase = "Graphics/Battlebacks/" + baseFilename + "_base0"
    enemyBase  = "Graphics/Battlebacks/" + baseFilename + "_base1"
    messageBG  = "Graphics/Battlebacks/" + messageFilename + "_message"
    # Apply graphics
    bg = pbAddSprite("battle_bg", 0, 0, battleBG, @viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2", -Graphics.width, 0, battleBG, @viewport)
    bg.z      = 0
    bg.mirror = true
    2.times do |side|
      baseX, baseY = Battle::Scene.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}", baseX, baseY,
                         (side == 0) ? playerBase : enemyBase, @viewport)
      base.z = 1
      if base.bitmap
        base.ox = base.bitmap.width / 2
        base.oy = (side == 0) ? base.bitmap.height : base.bitmap.height / 2
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg", 0, Graphics.height - 96, messageBG, @viewport)
    cmdBarBG.z = 180
  end
  def pbChangeTerrain(terrain)
    name = GameData::Environment.get(terrain).name
    name = "cave" if terrain == :None
    back = name
    base = name
    return [back,base]
  end
end

class Battle
  def pbStartWeatherAbility(new_weather, battler, ignore_primal = false)
    return if !ignore_primal && [:HarshSun, :HeavyRain, :StrongWinds].include?(@field.weather)
    return if @field.weather == new_weather
    pbShowAbilitySplash(battler)
    if !Scene::USE_ABILITY_SPLASH
      pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
    fixed_duration = false
    fixed_duration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY &&
                             ![:HarshSun, :HeavyRain, :StrongWinds].include?(new_weather)
    pbStartWeather(battler, new_weather, fixed_duration)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
  end
  def pbStartTerrain(user, newTerrain, fixedDuration = true)
    return if @field.terrain == newTerrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerTerrainExtender(user.item, newTerrain,
                                                            duration, user, self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    pbHideAbilitySplash(user) if user
    @scene.pbChangeTerrain(@field.terrain)
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
    end
    @scene.pbRefreshEverything
    # Check for abilities/items that trigger upon the terrain changing
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end
  def pbEOREndTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration > 0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
      case @field.terrain
      when :Electric
        pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
      end
      @field.terrain = :None
      allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
      # Start up the default terrain
      if @field.defaultTerrain != :None
        pbStartTerrain(nil, @field.defaultTerrain, false)
        @scene.pbChangeTerrain(@field.defaultTerrain)
        allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
        allBattlers.each { |battler| battler.pbItemTerrainStatBoostCheck }
      else
        @scene.pbChangeTerrain(:None)
      end
      @scene.pbRefreshEverything
      return if @field.terrain == :None
    end
    # Terrain continues
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric then pbDisplay(_INTL("An electric current is running across the battlefield."))
    when :Grassy   then pbDisplay(_INTL("Grass is covering the battlefield."))
    when :Misty    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
    when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
    end
  end
end