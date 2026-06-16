def pbRefresh
end

def useHMCatalogue
  pbFadeOutIn {
    scene = HM_Scene.new
    screen = HMScreen.new(scene)
    screen.pbStartScreen
    @scene.pbRefresh
  }
end

def give_hm_catalogue
  pbReceiveItem(:HMCATALOGUE)
  HM_Catalogue.new
  HM_Catalogue.setup
end

module HMCatalogue
  Obtained = 200
  Cut = 201
  RockSmash = 202
  Strength = 203
  Flash = 204
  Surf = 205
  Fly = 206
  Dive = 207
  RockClimb = 208
  Waterfall = 209
end

class HM_Catalogue
  attr_accessor :obtained
  attr_accessor :cut
  attr_accessor :rock_smash
  attr_accessor :strength
  attr_accessor :flash
  attr_accessor :surf
  attr_accessor :fly
  attr_accessor :dive
  attr_accessor :rock_climb
  attr_accessor :waterfall

  def initialize
    @obtained = false
    @cut = false
    @rock_smash = false
    @strength = false
    @flash = false
    @surf = false
    @fly = false
    @dive = false
    @rock_climb = false
    @waterfall = false
    $game_switches[HMCatalogue::Cut] = @cut
    $game_switches[HMCatalogue::RockSmash] = @rock_smash
    $game_switches[HMCatalogue::Strength] = @strength
    $game_switches[HMCatalogue::Flash] = @flash
    $game_switches[HMCatalogue::Surf] = @surf
    $game_switches[HMCatalogue::Fly] = @fly
    $game_switches[HMCatalogue::Dive] = @dive
    $game_switches[HMCatalogue::RockClimb] = @rock_climb
    $game_switches[HMCatalogue::Waterfall] = @waterfall
  end
  
  def self.clear
    @obtained = false
    @cut = false
    @rock_smash = false
    @strength = false
    @flash = false
    @surf = false
    @fly = false
    @dive = false
    @rock_climb = false
    @waterfall = false
  end

  def self.setup
    @obtained = true
    $game_switches[HMCatalogue::RockSmash] = true if $player.badge_count >= 1
    @cut = $game_switches[HMCatalogue::Cut]
    @rock_smash = $game_switches[HMCatalogue::RockSmash]
    @strength = $game_switches[HMCatalogue::Strength]
    @flash = $game_switches[HMCatalogue::Flash]
    @surf = $game_switches[HMCatalogue::Surf]
    @fly = $game_switches[HMCatalogue::Fly]
    @dive = $game_switches[HMCatalogue::Dive]
    @rock_climb = $game_switches[HMCatalogue::RockClimb]
    @waterfall = $game_switches[HMCatalogue::Waterfall]
  end

  def self.obtained?
    return @obtained
  end

  def self.cut
    return @cut
  end

  def self.rock_smash
    return @rock_smash
  end

  def self.strength
    return @strength
  end

  def self.flash
    return @flash
  end

  def self.surf
    return @surf
  end

  def self.fly
    return @fly
  end

  def self.dive
    return @dive
  end

  def self.rock_climb
    return @rock_climb
  end

  def self.waterfall
    return @waterfall
  end

  def self.cut=(value)
    @cut = value
    $game_switches[HMCatalogue::Cut] = value
    return @cut
  end

  def self.rock_smash=(value)
    @rock_smash = value
    $game_switches[HMCatalogue::RockSmash] = value
    return @rock_smash
  end

  def self.strength=(value)
    @strength = value
    $game_switches[HMCatalogue::Strength] = value
    return @strength
  end

  def self.flash=(value)
    @flash = value
    $game_switches[HMCatalogue::Flash] = value
    return @flash
  end

  def self.surf=(value)
    @surf = value
    $game_switches[HMCatalogue::Surf] = value
    return @surf
  end

  def self.fly=(value)
    @fly = value
    $game_switches[HMCatalogue::Fly] = value
    return @fly
  end

  def self.dive=(value)
    @dive = value
    $game_switches[HMCatalogue::Dive] = value
    return @dive
  end

  def self.rock_climb=(value)
    @rock_climb = value
    $game_switches[HMCatalogue::RockClimb] = value
    return @rock_climb
  end

  def self.waterfall=(value)
    @waterfall = value
    $game_switches[HMCatalogue::Waterfall] = value
    return @waterfall
  end
end

class HM_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("HM Catalogue"),2,-18,256,64,@viewport)
    @sprites["header"].baseColor   = Color.new(248,248,248)
    @sprites["header"].shadowColor = Color.new(0,0,0)
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(@commands,
       14,92,324,224,@viewport)
    @sprites["commands"].baseColor   = Color.new(248,248,248)
    @sprites["commands"].shadowColor = Color.new(0,0,0)
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end


  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands,newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class HMScreen

  def initialize(scene)
    @scene = scene
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
  end

  def pbStartScreen
    commands = []
    cmdCut    = -1
    cmdRockSmash   = -1
    cmdStrength    = -1
    cmdFlash    = -1
    cmdSurf    = -1
    cmdFly    = -1
    cmdDive   = -1
    cmdRockClimb    = -1
    cmdWaterfall    = -1
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @viewport3 = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport3.z = 999999
    @sprites = {}
    commands[cmdFly = commands.length]   = _INTL("Fly") if HM_Catalogue.fly == true
    commands[cmdCut = commands.length]   = _INTL("Cut") if HM_Catalogue.cut == true
    commands[cmdRockSmash = commands.length]   = _INTL("Rock Smash") if HM_Catalogue.rock_smash == true
    commands[cmdStrength = commands.length]   = _INTL("Strength") if HM_Catalogue.strength == true
    commands[cmdFlash = commands.length]   = _INTL("Flash") if HM_Catalogue.flash == true
    commands[cmdSurf = commands.length]   = _INTL("Surf") if HM_Catalogue.surf == true
    commands[cmdDive = commands.length]   = _INTL("Dive") if HM_Catalogue.dive == true
    commands[cmdRockClimb = commands.length]   = _INTL("Rock Climb") if HM_Catalogue.rock_climb == true
    commands[cmdWaterfall = commands.length]   = _INTL("Waterfall") if HM_Catalogue.waterfall == true
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
        if cmd<0
        pbPlayCloseMenuSE
          break
        elsif cmdCut>=0 && cmd==cmdCut
          pbPlayDecisionSE
          dispose
          if !canUseMoveCut?
          else
            useMoveCut
            break
          end
        elsif cmdRockSmash>=0 && cmd==cmdRockSmash
          pbPlayDecisionSE
          dispose
          if !canUseMoveRockSmash?
          else
            useMoveRockSmash
            break
          end
        elsif cmdStrength>=0 && cmd==cmdStrength
          pbPlayDecisionSE
          dispose
          if !canUseMoveStrength?
          else
            useMoveStrength
            break
          end
        elsif cmdFlash>=0 && cmd==cmdFlash
          pbPlayDecisionSE
          dispose
          if !canUseMoveFlash?
          else
            useMoveFlash
            break
          end
        elsif cmdSurf>=0 && cmd==cmdSurf
          pbPlayDecisionSE
          dispose
          if !canUseMoveSurf?
          else
            useMoveSurf
            break
          end
        elsif cmdFly>=0 && cmd==cmdFly
          pbPlayDecisionSE
          dispose
          if !canUseMoveFly?
            pbMessage(_INTL("You cannot use that here."))
          else
            ret = nil
              pbFadeOutIn{
              scene = PokemonRegionMap_Scene.new(-1,false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartFlyScreen
              next 0 if !ret
            if ret
              $game_temp.fly_destination = ret
              $game_temp.in_menu = false
              useMoveFly
              dispose
              @scene.pbEndScene
            end
          }
          break
          end
        elsif cmdDive>=0 && cmd==cmdDive
          pbPlayDecisionSE
          dispose
          if !canUseMoveDive?
          else
            useMoveDive
            break
          end
        elsif cmdRockClimb>=0 && cmd==cmdRockClimb
          pbPlayDecisionSE
          dispose
          if !canUseMoveRockClimb?
          else
            useMoveRockClimb
            break
          end
        elsif cmdWaterfall>=0 && cmd==cmdWaterfall
          pbPlayDecisionSE
          dispose
          if !canUseMoveWaterfall?
          else
            useMoveWaterfall
            break
          end
        else# Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end

def pbCut
  if HM_Catalogue.cut != true
    pbMessage(_INTL("This tree looks like it can be cut down."))
    return false
  end
  pbMessage(_INTL("This tree looks like it can be cut down!\1"))
  if pbConfirmMessage(_INTL("Would you like to cut it?"))
    pbMessage(_INTL("{1} used Cut!",$player.name))
    return true
  end
  return false
end

def pbDive
  return false if $game_player.pbFacingEvent
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  return false if !map_metadata || !map_metadata.dive_map_id
  if HM_Catalogue.dive != true
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    pbMessage(_INTL("{1} used Dive!",$player.name))
    pbFadeOutIn {
       $game_temp.player_new_map_id    = map_metadata.dive_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = false
       $PokemonGlobal.diving  = true
       pbUpdateVehicle
       $scene.transfer_player(false)
       $game_map.autoplay
       $game_map.refresh
    }
    return true
  end
  return false
end

def pbSurfacing
  return if !$PokemonGlobal.diving
  return false if $game_player.pbFacingEvent
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  if HM_Catalogue.dive != true
    pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    pbMessage(_INTL("{1} used Dive!",$player.name))
    pbFadeOutIn {
       $game_temp.player_new_map_id    = surface_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = true
       $PokemonGlobal.diving  = false
       pbUpdateVehicle
       $scene.transfer_player(false)
       surfbgm = GameData::Metadata.get.surf_BGM
       (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
       $game_map.refresh
    }
    return true
  end
  return false
end

def pbStrength
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength made it possible to move boulders around."))
    return false
  end
  if HM_Catalogue.strength != true
    pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
    return false
  end
  pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside.\1"))
  if pbConfirmMessage(_INTL("Would you like to use Strength?"))
    pbMessage(_INTL("{1} used Strength!",$player.name))
    pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",$player.name))
    $PokemonMap.strengthUsed = true
    return true
  end
  return false
end

def pbRockSmash
  if HM_Catalogue.rock_smash != true
    pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    return false
  end
  if pbConfirmMessage(_INTL("This rock appears to be breakable. Would you like to use Rock Smash?"))
    pbMessage(_INTL("{1} used Rock Smash!",$player.name))
    return true
  end
  return false
end

def pbSurf
  return false if $game_player.pbFacingEvent
  return false if $game_player.has_follower?
  if HM_Catalogue.surf != true
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    pbMessage(_INTL("{1} used Surf!",$player.name))
    pbCancelVehicles
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing
    return true
  end
  return false
end

def pbWaterfall
  if HM_Catalogue.waterfall != true
    pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    pbMessage(_INTL("{1} used Waterfall!",$player.name))
    pbAscendWaterfall
    return true
  end
  return false
end

def canUseMoveCut?
  showmsg = true
   return false if HM_Catalogue.cut != true
   facingEvent = $game_player.pbFacingEvent
   if !facingEvent || !facingEvent.name[/cuttree/i]
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
end

def useMoveCut
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used Cut!",$player.name))
  end
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    pbSmashEvent(facingEvent)
  end
  return true
end

def canUseMoveDive?
   showmsg = true
   return false if HM_Catalogue.dive != true
   if $PokemonGlobal.diving
     surface_map_id = nil
     GameData::MapMetadata.each do |map_data|
       next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
       surface_map_id = map_data.id
       break
     end
     if !surface_map_id ||
        !$MapFactory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
   else
     if !GameData::MapMetadata.exists?($game_map.map_id) ||
        !GameData::MapMetadata.get($game_map.map_id).dive_map_id
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     if !$game_player.terrain_tag.can_dive
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
   end
   return true
end
def useMoveDive
  wasdiving = $PokemonGlobal.diving
  if $PokemonGlobal.diving
    dive_map_id = nil
    GameData::MapMetadata.each do |map_data|
      next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
      dive_map_id = map_data.id
      break
    end
  else
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    dive_map_id = map_metadata.dive_map_id if map_metadata
  end
  return false if !dive_map_id
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used Dive!",$player.name))
  end
  pbFadeOutIn {
    $game_temp.player_new_map_id    = dive_map_id
    $game_temp.player_new_x         = $game_player.x
    $game_temp.player_new_y         = $game_player.y
    $game_temp.player_new_direction = $game_player.direction
    $PokemonGlobal.surfing = wasdiving
    $PokemonGlobal.diving  = !wasdiving
    pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  }
  return true
end

def canUseMoveFlash?
   showmsg = true
   if !GameData::MapMetadata.exists?($game_map.map_id) ||
      !GameData::MapMetadata.get($game_map.map_id).dark_map
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   if $PokemonGlobal.flashUsed
     pbMessage(_INTL("Flash is already being used.")) if showmsg
     return false
   end
   return true
end
def useMoveFlash
  darkness = $PokemonTemp.darknessSprite
  return false if !darkness || darkness.disposed?
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used Flash!",$player.name))
  end
  $PokemonGlobal.flashUsed = true
  radiusDiff = 8*20/Graphics.frame_rate
  while darkness.radius<darkness.radiusMax
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += radiusDiff
    darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
  end
  return true
end

def canUseMoveFly?
  showmsg = true
  if $game_player.has_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if !GameData::MapMetadata.exists?($game_map.map_id) ||
     !GameData::MapMetadata.get($game_map.map_id).outdoor_map
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end

def useMoveFly
  if !$game_temp.fly_destination
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  pbMessage(_INTL("{1} used Fly!",$player.name))
  pbFadeOutIn {
    flying_to_league = ($game_temp.fly_destination[0] == 217)
    if !$game_switches[179] && flying_to_league
      $game_temp.fly_destination[1] = 17
      $game_temp.fly_destination[2] = 61
    end
    $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
    $game_temp.player_new_x         = $game_temp.fly_destination[1]
    $game_temp.player_new_y         = $game_temp.fly_destination[2]
    $CanToggle = true
    $game_temp.player_new_direction = 2
    $game_temp.fly_destination = nil
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  return true
end

def canUseMoveRockSmash?
  showmsg = true
  return false if HM_Catalogue.rock_smash != true
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/smashrock/i]
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end
def useMoveRockSmash
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used Rock Smash!",$player.name))
  end
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    pbSmashEvent(facingEvent)
    pbRockSmashRandomEncounter
    pbRockSmashRandomItem
  end
  return true
end

def canUseMoveStrength?
   showmsg = true
   return false if HM_Catalogue.strength != true
   if $PokemonMap.strengthUsed
     pbMessage(_INTL("The Fulcrum is already being used.")) if showmsg
     return false
   end
   return true
end
def useMoveStrength
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used Strength!\1",$player.name))
  end
  pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",$player.name))
  $PokemonMap.strengthUsed = true
  return true
end
def canUseMoveSurf?
   showmsg = true
   return false if HM_Catalogue.surf != true
   if $PokemonGlobal.surfing
     pbMessage(_INTL("You're already surfing.")) if showmsg
     return false
   end
   if $game_player.pbHasDependentEvents?
     pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
     return false
   end
   if GameData::MapMetadata.exists?($game_map.map_id) &&
      GameData::MapMetadata.get($game_map.map_id).always_bicycle
     pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
     return false
   end
   if !$game_player.pbFacingTerrainTag.can_surf_freely ||
      !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
     pbMessage(_INTL("No surfing here!")) if showmsg
     return false
   end
   return true
end

def useMoveSurf
  $game_temp.in_menu = false
  pbCancelVehicles
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used Surf!",$player.name))
  end
  surfbgm = GameData::Metadata.get.surf_BGM
  pbCueBGM(surfbgm,0.5) if surfbgm
  pbStartSurfing
  return true
end

def canUseMoveWaterfall?
  showmsg = true
  if !$game_player.pbFacingTerrainTag.waterfall
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end
def useMoveWaterfall
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used Waterfall!",$player.name))
  end
  pbAscendWaterfall
  return true
end

def pbRockSmashRandomItem
  randItem = rand(100)+1
  return nil if randItem < 51
  if randItem < 76
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:HARDSTONE)
  elsif randItem < 86
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:NUGGET)
  elsif randItem < 96
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:BIGNUGGET)
  else
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:METALCOAT)
  end
end

def canUseMoveRockClimb?
  showmsg = true
  return false if !HM_Catalogue.rock_climb
   if !$game_player.pbFacingTerrainTag.rock_climb
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
end

def useMoveRockClimb
  event = $game_player if !event
   if !pbHiddenMoveAnimation(nil)
     pbMessage(_INTL("{1} used Rock Climb!",$player.name))
   end
   if event.direction==8
      pbRockClimbUp
    elsif event.direction==2
      pbRockClimbDown
    elsif event.direction==6
      pbRockClimbRight
    elsif event.direction==4
      pbRockClimbLeft
    end
   return true
end

def pbRockClimbUp(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 8   # can't ascend if not facing up
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  event.move_speed += 2
  loop do
    event.move_up
    if !$game_player.pbFacingTerrainTag.rock_climb
      event.move_up
      break
    end
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def pbRockClimbDown(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 2    # Can't descend if not facing down
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  event.move_speed += 2
  loop do
    event.move_down
    if !$game_player.pbFacingTerrainTag.rock_climb
      event.move_down
      break
    end
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def pbRockClimbRight(event=nil)
  event = $game_player if !event
  PBDebug.log("[Rock Climb] Event set to #{event}")
  return if !event
  return if event.direction != 6   # can't ascend if not facing up
  oldthrough   = event.through
  PBDebug.log("[Rock Climb] Old through set to #{oldthrough}")
  oldmovespeed = event.move_speed
  PBDebug.log("[Rock Climb] Old move speed set to #{oldmovespeed}")
  PBDebug.log("[Rock Climb] Checking if facing rock climb terrain tag: #{$game_player.pbFacingTerrainTag.rock_climb}")
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  PBDebug.log("[Rock Climb] Through set to #{event.through}")
  event.move_speed += 2
  PBDebug.log("[Rock Climb] Move speed set to #{event.move_speed}")
  move = 0
  loop do
    if move == 0
      event.move_right
      PBDebug.log("[Rock Climb] Event moves right")
    else
      if $game_player.pbFacingTerrainTagUpperRight.rock_climb
        event.move_upper_right
        PBDebug.log("[Rock Climb] Event moves upper right")
        if !$game_player.pbFacingTerrainTagUpperRight.rock_climb
          event.move_upper_right
          PBDebug.log("[Rock Climb] Event moves upper right last time")
          break
        end
      elsif $game_player.pbFacingTerrainTagLowerRight.rock_climb
        event.move_lower_right
        PBDebug.log("[Rock Climb] Event moves lower right")
        if !$game_player.pbFacingTerrainTagLowerRight.rock_climb
          event.move_lower_right
          PBDebug.log("[Rock Climb] Event moves lower right last time")
          break
        end
      end
    end
    move += 1
    PBDebug.log("[Rock Climb] move var = #{move}")
    break if move > 10
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
  PBDebug.log("[Rock Climb] End")
end

def pbRockClimbLeft(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 4    # Can't descend if not facing down
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  event.move_speed += 2
  move = 0
  moves = [true]
  loop do
    if move == 0
      event.move_left
    else
      if $game_player.pbFacingTerrainTagUpperLeft.rock_climb
        event.move_upper_left
        moves.push($game_player.pbFacingTerrainTagUpperLeft.rock_climb)
        if !$game_player.pbFacingTerrainTagUpperLeft.rock_climb
          event.move_upper_left
          break
        end
      elsif $game_player.pbFacingTerrainTagLowerLeft.rock_climb
        event.move_lower_left
        moves.push($game_player.pbFacingTerrainTagLowerLeft.rock_climb)
        if !$game_player.pbFacingTerrainTagLowerLeft.rock_climb
          event.move_lower_left
          break
        end
      end
    end
    move += 1
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def pbRockClimb
  event = $game_player if !event
  if !HM_Catalogue.rock_climb
    pbMessage(_INTL("These rocks look climbable."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large rock wall. Would you like to climb it?"))
    if HM_Catalogue.rock_climb
      pbMessage(_INTL("{1} used Rock Climb!",$player.name))
      pbHiddenMoveAnimation(nil)
    end
    if event.direction==8
      pbRockClimbUp
    elsif event.direction==2
      pbRockClimbDown
    elsif event.direction==6
      pbRockClimbRight
    elsif event.direction==4
      pbRockClimbLeft
    end
    return true
  end
  return false
end

EventHandlers.add(:on_player_interact, :rock_climb,
  proc {
    if $game_player.pbFacingTerrainTag.rock_climb
      pbRockClimb
    end
  }
)


module GameData
  class TerrainTag
    attr_reader :rock_climb
    alias oldinitialize initialize
    def initialize(hash)
      oldinitialize(hash)
      @rock_climb        = hash[:rock_climb]         || false
    end
  end
end

GameData::TerrainTag.register({
  :id                     => :RockClimb,
  :id_number              => 19,
  :rock_climb             => true
})

ItemHandlers::UseInField.add(:HMCATALOGUE,proc{|item|
  useHMCatalogue
})

ItemHandlers::UseFromBag.add(:HMCATALOGUE,proc{|item|
  next 2
})

class PokemonLoadScreen
  def pbStartLoadScreen
      commands = []
      cmd_continue     = -1
      cmd_new_game     = -1
      cmd_options      = -1
      cmd_language     = -1
      cmd_mystery_gift = -1
      cmd_debug        = -1
      cmd_quit         = -1
      show_continue = !@save_data.empty?
      if show_continue
        commands[cmd_continue = commands.length] = _INTL("Continue")
        if @save_data[:player].mystery_gift_unlocked
          commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
        end
      end
      commands[cmd_new_game = commands.length]  = _INTL("New Game")
      commands[cmd_options = commands.length]   = _INTL("Options")
      commands[cmd_language = commands.length]  = _INTL("Language") if Settings::LANGUAGES.length >= 2
      commands[cmd_debug = commands.length]     = _INTL("Debug") if $DEBUG
      commands[cmd_quit = commands.length]      = _INTL("Quit Game")
      map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
      @scene.pbStartScene(commands, show_continue, @save_data[:player], @save_data[:stats], map_id)
      @scene.pbSetParty(@save_data[:player]) if show_continue
      @scene.pbStartScene2
      loop do
        command = @scene.pbChoose(commands)
        pbPlayDecisionSE if command != cmd_quit
        case command
        when cmd_continue
          @scene.pbEndScene
          Game.load(@save_data)
          write_version
          HM_Catalogue.setup
          return
        when cmd_new_game
          @scene.pbEndScene
          Game.start_new
          write_version
          return
        when cmd_mystery_gift
          pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
        when cmd_options
          pbFadeOutIn do
            scene = PokemonOption_Scene.new
            screen = PokemonOptionScreen.new(scene)
            screen.pbStartScreen(true)
          end
        when cmd_language
          @scene.pbEndScene
          $PokemonSystem.language = pbChooseLanguage
          MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
          if show_continue
            @save_data[:pokemon_system] = $PokemonSystem
            File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(@save_data, file) }
          end
          $scene = pbCallTitle
          return
        when cmd_debug
          pbFadeOutIn { pbDebugMenu(false) }
        when cmd_quit
          pbPlayCloseMenuSE
          @scene.pbEndScene
          $scene = nil
          return
        else
          pbPlayBuzzerSE
        end
      end
    end
  end