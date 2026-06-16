Dialogue.register(:Nurse_Joy,{
	:gender => :female,
	:default => [
		"Hello, and welcome to the Pokémon Center.",
		"We restore your tired Pokémon to full health!",
		proc {
			Dialogue.show_options("Would you like me to heal your Pokémon?","Yes,No",:Nurse_Joy)
			case pbGet(34)
			when 0
				Dialogue.call(:Nurse_Joy,:heal)
			else
				Dialogue.call(:Nurse_Joy,:dont_heal)
			end
		}
	],
	:heal => [
		"OK, I'll take your Pokémon for a few seconds.",
		proc {
			$stats.poke_center_count += 1
			event = $game_map.events[Dialogue.get_event]
			event.turn_up if event
			pbMEPlay("Pkmn healing")
			$player.heal_party
			pbWait(4)
			event.turn_down if event
			if pbPokerus?
				Dialogue.call(:Nurse_Joy,:pokerus)
			else
				Dialogue.call(:Nurse_Joy,:end)
			end
		}
	],
	:blackout => [
		"First, you should restore your Pokémon to full health.",
		proc {
			$stats.poke_center_count += 1
			event = $game_map.events[Dialogue.get_event]
			event.turn_up if event
			pbMEPlay("Pkmn healing")
			$player.heal_party
			pbWait(4)
			event.turn_down if event
		},
		"We've restored your Pokémon back to full health.",
		"We hope you excel!",
		proc {
			$game_switches[1] = false
			$game_map.refresh
		}
	],
	:pokerus => [
		"Your Pokémon may be infected with Pokérus.",
		"Little is known about Pokérus except that they are microscopic life-forms that attach to Pokémon.",
		"While infected, Pokémon are said to grow exceptionally well."
	],
	:end => [
		"Thank you for waiting.",
		"We've restored your Pokémon back to full health.",
		"We hope to see you again!"
	]
})