module Dialogue
	Speakers = 103
	Speaker_Index = 104
	Event_ID = 51
	DATA = {}

	def self.data
		return DATA
	end

	def self.register(id,hash)
		if !DATA.has_key?(id)
			DATA[id] = hash
		else
			DATA[id].merge!(hash)
		end
	end

	def self.get_data(id)
		return DATA[id]
	end

	def self.disp(msg,event_id)
		case msg
		when "..."
			pbCallBub(2,event_id) if event_id
			pbMessage(_INTL("\\ts[20]....."))
		else
			pbCallBub(2,event_id) if event_id
			pbMessage(_INTL(msg))
		end
	end

	def self.show_options(msg,options,id,var=34)
		data = self.get_data(id)
		gender = data[:gender] == :male ? "\\b" : "\\r"
		txt = gender + msg + "\\ch[#{var},#{options.length+1},#{options}]"
		pbCallBub(2,self.get_event)
		pbMessage(_INTL(txt))
	end

	def self.get_character(parameter = 0,event_id = get_event)
    case parameter
    when -1   # player
      return $game_player
    when 0    # this event
      events = $game_map.events
      return (events) ? events[event_id] : nil
    else      # specific event
      events = $game_map.events
      return (events) ? events[parameter] : nil
    end
  end

	def self.set_self_switch
		$game_self_switches[[$game_map.map_id, Dialogue.get_event, "A"]] = true
		self.clear_event
	end

	def self.set_event(event_id)
		$game_variables[Dialogue::Event_ID] = event_id
	end

	def self.get_event
		return $game_variables[Dialogue::Event_ID]
	end

	def self.clear_event
		$game_variables[Dialogue::Event_ID] = 0
	end

	def self.change_speakers(id)
		$game_variables[Dialogue::Speaker_Index] = 0
		$game_variables[Dialogue::Speakers] = id
	end

	def self.reset_speakers
		$game_variables[Dialogue::Speakers] = 0
		$game_variables[Dialogue::Speaker_Index] = 0
	end

	def self.random_dialogue(id,event_id=get_event)
		case id
		when :Cheryl
			gender = :female
			dialogue = [
				"I don't usually come this way. So I'm glad you were willing to come with me.",
				"It's kinda scary here, huh?",
				"I heard there's this spooky mansion somewhere up ahead. I'm not a big fan of scary things.",
				"I'll make sure your team stays nice and healthy. Don't worry about anything.",
				"You're really talented. I bet you'll do really great in the Gym Challenge."
			]
		when :Mira
			gender = :female
			dialogue = [
				"I don't usually come this way. So I'm glad you were willing to come with me.",
				"It's kinda dark here, huh?",
				"I heard there's a dragon somewhere up ahead.",
				"I'll make sure your team stays nice and healthy. Don't worry about anything.",
				"You're really talented. I bet you'll do really great in the Gym Challenge."
			]
		when :Riley
			gender = :male
			dialogue = [
				"I don't usually come this way. So I'm glad you were willing to come with me",
				"You much of an explorer?",
				"I patrol here a bit to help Byron out.",
				"I'll make sure your team stays nice and healthy. Don't worry about anything.",
				"You're really talented. I bet you'll do really great in the Gym Challenge."
			]
		end
		return gender == :male ? self.disp("\\b" + dialogue.sample,event_id) : self.disp("\\r" + dialogue.sample,event_id)
	end

	def self.call(id,dialogue=:default)
	    data = self.get_data(id)
	    idx = 0
	    data[dialogue].each do |msg|
	    	message = ""
	    	if data.has_key?(:name)
	    		n = data[:name].is_a?(String) ? data[:name] : $game_variables[data[:name]]
	    		message = (idx == 0 && dialogue != :first_meet) ? (n + ": ") : ""
	    	elsif data.has_key?(:speakers)
	    		if $game_variables[Dialogue::Speakers] == 0
	    			data[:speakers].keys.each do |k|
	    				$game_variables[Dialogue::Speakers] = k
	    				break
	    			end
	    		end
	    		speaker = data[:speakers][$game_variables[Dialogue::Speakers]]
	    		gender = speaker[:gender]
	    		ms = gender == :male ? "\\b" : "\\r"
	    		message = ($game_variables[Dialogue::Speaker_Index] == 0) ? (speaker[:name] + ": " + ms) : (ms)
	    	end
	    	if !data.has_key?(:speakers)
		    	if data.has_key?(:gender)
		    		message += data[:gender] == :male ? "\\b" : "\\r"
		    	else
		    		message = "" 
		    	end
		    end
	    	if msg.is_a?(String)
	    		message += msg
	    		(msg == "...") ? self.disp(msg,self.get_event) : self.disp(message,self.get_event)
	    		$game_variables[Dialogue::Speaker_Index] += 1
	    	else
	    		msg.call
	    		$game_variables[Dialogue::Speaker_Index] = 0
	    	end
	    	idx += 1
	    end
	    self.reset_speakers
	end
end

def pbNoticePlayer(event, always_show_exclaim = false)
	$in_battle = true
  Dialogue.set_event(@event_id)
  if always_show_exclaim || !pbFacingEachOther(event, $game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player, event)
  pbMoveTowardPlayer(event)
end