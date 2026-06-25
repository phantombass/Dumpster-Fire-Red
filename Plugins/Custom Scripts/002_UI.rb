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