def export_all
	str = ""
	blacklist = [:PICHU,:MINIOR,:FLABEBE,:FLOETTE,:FLORGES,:PIKACHU,:TATSUGIRI,:SQUAWKABILLY,:UNOWN,:SHELLOS,:GASTRODON,:DEERLING,:SAWSBUCK,:VIVILLON,:ALCREMIE,
		:ROCKRUFF,:WISHIWASHI,:CRAMORANT,:SINISTEA,:POLTEAGEIST,:POLTCHAGEIST,:SINISTCHA,:MORPEKO,:DUDUNSPARCE,:GIMMIGHOUL]
  for i in 0...$player.party.length
    pokemon = $player.party[i]
    next if pokemon.egg?
    speciesname = GameData::Species.get(pokemon.species_data).name
    if pokemon.species_data == :NIDORANmA
    	speciesname = "Nidoran-M"
    elsif pokemon.species_data == :NIDORANfE
    	speciesname = "Nidoran-F"
    elsif pokemon.species_data == :FARFETCHD
    	speciesname = "Farfetch’d"
    elsif pokemon.species_data == :SIRFETCHD
    	speciesname = "Sirfetch’d"
    elsif pokemon.species_data == :JANGMOO
    	speciesname = "Jangmo-o"
    elsif pokemon.species_data == :HAKAMOO
    	speciesname = "Hakamo-o"
    elsif pokemon.species_data == :KOMMOO
    	speciesname = "Kommo-o"
    end
    if pokemon.species_data.form > 0 && !blacklist.include?(pokemon.species) && pokemon.species_data.form_name
    	speciesname += "-#{pokemon.species_data.form_name}"
    end
    if pokemon.item
    	str += "\n#{speciesname} @ #{GameData::Item.get(pokemon.item).name}"
    else
    	str += "\n#{speciesname}"
    end
    str += "\nLevel: #{pokemon.level}"
    str += "\n#{GameData::Nature.get(pokemon.nature).name} Nature"
    str += "\nAbility: #{GameData::Ability.get(pokemon.ability).name}"
    str += "\nIVs: #{pokemon.iv[:HP]} HP / #{pokemon.iv[:ATTACK]} Atk / #{pokemon.iv[:DEFENSE]} Def / #{pokemon.iv[:SPECIAL_ATTACK]} SpA / #{pokemon.iv[:SPECIAL_DEFENSE]} SpD / #{pokemon.iv[:SPEED]} Spe\n"
    pokemon.moves.each do |move| 
    	if move.name == "Hidden Power" && move.id != :HIDDENPOWER
    		str += "- #{move.name} #{GameData::Type.get(move.type).name}\n"
    	else
    		str += "- #{move.name}\n"
    	end
    end
  end
	box = $PokemonStorage.maxBoxes - 2
	box.times do |i|
	  $PokemonStorage.maxPokemon(i).times do |j|
	    if $PokemonStorage[i,j] != nil
	      pokemon2 = $PokemonStorage[i, j]
	      next if pokemon2.egg?
	      speciesname2 = GameData::Species.get(pokemon2.species_data).name
	      if pokemon2.species_data == :NIDORANmA
		    	speciesname2 = "Nidoran-M"
		    elsif pokemon2.species_data == :NIDORANfE
		    	speciesname2 = "Nidoran-F"
		    elsif pokemon2.species_data == :FARFETCHD
		    	speciesname2 = "Farfetch’d"
		    elsif pokemon2.species_data == :SIRFETCHD
		    	speciesname2 = "Sirfetch’d"
		    elsif pokemon2.species_data == :JANGMOO
		    	speciesname2 = "Jangmo-o"
		    elsif pokemon2.species_data == :HAKAMOO
		    	speciesname2 = "Hakamo-o"
		    elsif pokemon2.species_data == :KOMMOO
		    	speciesname2 = "Kommo-o"
		    end
	      if pokemon2.species_data.form > 0 && !blacklist.include?(pokemon2.species) && pokemon2.species_data.form_name
		    	speciesname2 += "-#{pokemon2.species_data.form_name}"
		    end
	      if pokemon2.item
	    	str += "\n#{speciesname2} @ #{GameData::Item.get(pokemon2.item).name}"
		  else
		  	str += "\n#{speciesname2}"
		  end
		  	str += "\nLevel: #{pokemon2.level}"
	      str += "\n#{GameData::Nature.get(pokemon2.nature).name} Nature"
	      str += "\nAbility: #{GameData::Ability.get(pokemon2.ability).name}"
	      str += "\nIVs: #{pokemon2.iv[:HP]} HP / #{pokemon2.iv[:ATTACK]} Atk / #{pokemon2.iv[:DEFENSE]} Def / #{pokemon2.iv[:SPECIAL_ATTACK]} SpA / #{pokemon2.iv[:SPECIAL_DEFENSE]} SpD / #{pokemon2.iv[:SPEED]} Spe\n"
	      pokemon2.moves.each do |move1| 
	      	if move1.name == "Hidden Power" && move1.id != :HIDDENPOWER
	      		str += "- #{move1.name} #{GameData::Type.get(move1.type).name}\n"
	      	else
	      		str += "- #{move1.name}\n"
	      	end
	      end
	    end
	  end
	end
	path = "export.txt"
	File.open(path, "wb") { |f|
	    f.write(str)
	  }
	  pbMessage(_INTL("Pokémon exported! Check export.txt for your copy paste!"))
end

def return_items
	party_items = []
  $player.party.each do |pkmn|
  	party_items.push(GameData::Item.get(pkmn.item).id) if pkmn.item
  	pkmn.item = nil
  end
  box_items = []
  $PokemonStorage.maxBoxes.times do |i|
    $PokemonStorage.maxPokemon(i).times do |j|
      if $PokemonStorage[i,j] != nil && $PokemonStorage[i,j].item != nil
        box_items.push(GameData::Item.get($PokemonStorage[i,j].item).id)
        $PokemonStorage[i,j].item = nil
      end
    end
  end
  party_items.each {|p_item| $bag.add(p_item)}
  box_items.each {|b_item| $bag.add(b_item)}
end

MenuHandlers.add(:pc_menu, :export, {
  "name"      => proc { next _INTL("Export...") },
  "order"     => 30,
  "effect"    => proc { |menu|
  	if pbConfirmMessage(_INTL("This will export all but the last 2 boxes as well as your party.\nContinue?"))
  		pbMessage(_INTL("Now exporting...\nPress C to finish..."))
    	export_all
    end
    next false
  }
})
=begin
MenuHandlers.add(:pc_menu, :cap, {
  "name"      => proc { next _INTL("Level all...") },
  "order"     => 31,
  "effect"    => proc { |menu|
  	if pbConfirmMessage(_INTL("This will level all able Pokémon to the Level Cap.\nContinue?"))
  		pbMessage(_INTL("Now leveling up...\nPress C to finish..."))
    	level_cap_all
    end
    next false
  }
})
=end
MenuHandlers.add(:pc_menu, :return_items, {
  "name"      => proc { next _INTL("Return Items...") },
  "order"     => 32,
  "effect"    => proc { |menu|
  	if pbConfirmMessage(_INTL("This will place all items held by all Pokémon back in your bag. This does not apply to items in Item Storage.\nContinue?"))
    	return_items
    end
    next false
  }
})