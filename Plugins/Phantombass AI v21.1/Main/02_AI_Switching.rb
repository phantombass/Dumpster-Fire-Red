class Battle::AI
	def pbChooseToSwitchOut(terrible_moves = false)
    return false if !@battle.canSwitch   # Battle rule
    return false # due to the puzzle nature of this, we will not be having hard switches
    PBDebug.log_ai("#{@user.name} will not switch out, even though normally it would want to")
    return false if @user.wild?
    return false if !@battle.pbCanSwitchOut?(@user.index)
    # Don't switch if all foes are unable to do anything, e.g. resting after
    # Hyper Beam, will Truant (i.e. free turn)
    if @trainer.high_skill?
      foe_can_act = false
      each_foe_battler(@user.side) do |b, i|
        next if !b.can_attack?
        foe_can_act = true
        break
      end
      return false if !foe_can_act
    end
    # Various calculations to decide whether to switch
    if terrible_moves
      PBDebug.log_ai("#{@user.name} is being forced to switch out")
    else
      return false if !@trainer.has_skill_flag?("ConsiderSwitching")
      reserves = get_non_active_party_pokemon(@user.index)
      return false if reserves.empty?
      #should_switch = Battle::AI::Handlers.should_switch?(@user, reserves, self, @battle)
      #if should_switch && @trainer.medium_skill?
      #  should_switch = false if Battle::AI::Handlers.should_not_switch?(@user, reserves, self, @battle)
      #end
      switch_scores = []
      start_scores = pbGetMoveScores(false)
      start_scores.each {|s| switch_scores.push(s[1])}
      should_switch = ai_should_switch?(switch_scores)
    end
    # Want to switch; find the best replacement Pokémon
    if should_switch
      idxParty = choose_best_replacement_pokemon(@user.index, terrible_moves)
      if idxParty < 0   # No good replacement Pokémon found
        PBDebug.log("   => no good replacement Pokémon, will not switch after all")
        return false
      end
      # Prefer using Baton Pass instead of switching
      baton_pass = -1
      @user.battler.eachMoveWithIndex do |m, i|
        next if m.function_code != "SwitchOutUserPassOnEffects"   # Baton Pass
        next if !@battle.pbCanChooseMove?(@user.index, i, false)
        baton_pass = i
        break
      end
      if baton_pass >= 0 && @battle.pbRegisterMove(@user.index, baton_pass, false)
        PBDebug.log("   => will use Baton Pass to switch out")
        return true
      elsif @battle.pbRegisterSwitch(@user.index, idxParty)
        PBDebug.log("   => will switch with #{@battle.pbParty(@user.index)[idxParty].name}")
        return true
      end
    end
    return false
  end

  def ai_should_switch?(scores)
      if @battle.pbSideSize(0) == 2
        return false
      end
      $switch_flags = {}
      score = 0
      party = @battle.pbParty(@user.index)
      scores = scores.sort
      highest_move_score = scores[-1]
      self_party = []
      party.each do |mon|
        next if mon.fainted?
        self_party.push(mon) if mon.owner.id == @user.pokemon.owner.id
      end
      return false if self_party.length == 1
      return false if self_party.length <= 2 && @battle.pbSideSize(0) == 2
      @battlers.each do |target|
        next if target.nil?
        next if target == @user
        next if target.side == @user.side
        score = Battle::AI::SwitchHandler.trigger_out(score,self,@user,target)
      end
      PBDebug.log_ai("Switch out Score (#{score}) vs Highest Moves Score (#{highest_move_score})")
      if score > highest_move_score
        switch = true
      else
        switch = false
      end
      $switch_flags[:score] = score
      nope = switch ? "" : "not "
      PBDebug.log_ai("The AI will #{nope}try to switch.")
      return switch
    end

  def choose_best_replacement_pokemon(idxBattler, terrible_moves = false)
    # Get all possible replacement Pokémon
    party = @battle.pbParty(idxBattler)
    switch_scores = []
    start_scores = pbGetMoveScores(false)
    start_scores.each {|s| switch_scores.push(s[1])}
    switch_scores = switch_scores.sort
    highest_move_score = switch_scores[-1]
    idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    reserves = []
    party.each_with_index do |_pkmn, i|
      next if _pkmn.fainted?
      next if !@battle.pbCanSwitchIn?(idxBattler, i)
      if !terrible_moves   # Not terrible_moves means choosing an action for the round
        ally_will_switch_with_i = false
        @battle.allSameSideBattlers(idxBattler).each do |b|
          next if @battle.choices[b.index][0] != :SwitchOut || @battle.choices[b.index][1] != i
          ally_will_switch_with_i = true
          break
        end
        next if ally_will_switch_with_i
      end
      # Ignore ace if possible
      if @trainer.has_skill_flag?("ReserveLastPokemon") && i == idxPartyEnd - 1
        next if !terrible_moves || reserves.length > 0
      end
      reserves.push([i, 0])
      break if @trainer.has_skill_flag?("UsePokemonInOrder") && reserves.length > 0
    end
    return -1 if reserves.length == 0
    # Rate each possible replacement Pokémon
    reserves.each_with_index do |reserve, i|
      reserves[i][1] = rate_replacement_pokemon(idxBattler, party[reserve[0]], reserve[1])
    end
    reserves.sort! { |a, b| 
      ret = (b[1] <=> a[1])
      ret = (a[0] <=> b[0]) if b[1] == a[1]
      next ret
    }   # Sort from highest to lowest rated
    # Don't bother choosing to switch if all replacements are poorly rated
    PBDebug.log_ai("Highest move score (#{highest_move_score}) vs Switch In Score (#{reserves[0][1]})") unless @battle.battlers[idxBattler].fainted?
    if !terrible_moves
      return -1 if reserves[0][1] < highest_move_score   # If best replacement rated at < highest move score, don't switch
    end
    # Return the party index of the best rated replacement Pokémon
    return reserves[0][0]
  end

  def rate_replacement_pokemon(idxBattler, pkmn, score)
    pkmn_types = pkmn.types
    entry_hazard_damage = calculate_entry_hazard_damage(pkmn, idxBattler & 1)
    # if entry_hazard_damage >= pkmn.hp
    #   score -= 10   # pkmn will just faint
    #   PBDebug.log("     [#{pkmn.name}] - 10 because we will die from hazards on entry")
    # elsif entry_hazard_damage > 0
    #   calc = (5 * entry_hazard_damage / pkmn.hp).floor
    #   score -= calc
    #   PBDebug.log("     [#{pkmn.name}] - #{calc} because we will take #{entry_hazard_damage} damage from hazards on entry")
    # end
    # if !pkmn.hasItem?(:HEAVYDUTYBOOTS) && !pokemon_airborne?(pkmn)
    #   # Toxic Spikes
    #   if @user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    #     score -= 5 if pokemon_can_be_poisoned?(pkmn)
    #     PBDebug.log("     [#{pkmn.name}] - 5 because we will be poisoned on entry")
    #   end
    #   # Sticky Web
    #   if @user.pbOwnSide.effects[PBEffects::StickyWeb]
    #     score -= 5
    #     PBDebug.log("     [#{pkmn.name}] - 5 because we will have our Speed lowered on entry")
    #   end
    # end
    mon = pbMakeFakeBattler(pkmn)
    # Calc highest damage against all party members
    kill = {}
    kill2 = {}
    best_moves = {}
    list1 = []
    txt = "="*29
    txt += "=\n"
    @battle.battlers[idxBattler].allOpposing.each do |b|
      kill[b.index] = 0
      kill2[b.index] = 0
      pkmn.moves.each do |m|
        next if m.power == 0 || (m.pp == 0 && m.total_pp > 0)
        mov = Battle::AI::FakeMove.new(self,m)
        next if pokemon_can_absorb_move?(b.pokemon, m, mov.rough_type)
        dmg2 = mov.rough_damage(mon,b,true)
        list1.push([m,dmg2])
        txt += "     [#{pkmn.name}] using #{mov.name} vs #{b.pokemon.name} does a max of #{dmg2}/#{b.hp} damage\n"
        if dmg2 >= b.pokemon.hp
          kill[b.index] += 1
        elsif dmg2 >= b.pokemon.hp/2
          kill2[b.index] += 1      
        end
      end
      list1.sort! do |a,b|
          ret = (b[1] <=> a[1])
          next ret
        end
      if list1.length > 0
        movs = list1[0][0]
        damage = list1[0][1]
        moves = list1.select {|move| move[1] == damage}
        final = []
        moves.each {|m| final.push(m[0])}
        best_moves[pkmn] = [final[0],moves[0][1]]
      else
        best_moves[pkmn] = [pkmn.moves[0],1]
      end
    end
    each_foe_battler(@user.side) do |b, i|
      list = []
      b.moves.each do |mo|
        mv = Battle::AI::FakeMove.new(self,mo)
        if mo.statusMove?
          list.push(0)
          next
        end
        dm = mv.rough_damage(b,mon,true)
        list.push([mo,dm])
      end
       list.sort! do |a,b|
        ret = (b[1] <=> a[1])
        next ret
      end
      mov = list[0][0]
      damage = list[0][1]
      moves = list.select {|move| move[1] == damage}
      final = []
      moves.each {|m| final.push(m[0])}
      best_move = final[0].is_a?(Integer) ? b.moves[final[0]] : final[0]
      txt += "     #{b.name}'s best move: #{best_move.name} for #{damage}/#{pkmn.hp} damage\n"
      txt += "="*30
      PBDebug.log(txt)
      move = Battle::AI::FakeMove.new(self,best_move)
      dmg = move.rough_damage(b,mon,true)
      target_kill = dmg >= mon.hp
      target_2hko = dmg >= mon.hp/2 && !target_kill
      absorb_move = dmg == 0
      faster = mon.faster_than?(b)
      fast_kill = faster && kill[b.index] > 0
      slow_kill = !faster && kill[b.index] > 0
      fast_2hko = faster && kill2[b.index] > 0 && kill[b.index] == 0
      outdamage = best_moves[pkmn][1] > dmg
      fast_outdamage = faster && outdamage
      target_fast_kill = !faster && target_kill
      target_fast_2hko = target_2hko && !faster
      PBDebug.log("     #{b.name} speed (#{b.pbSpeed}) vs #{mon.name} speed: #{mon.pbSpeed}")
      calc_info = {
        :fast_kill => fast_kill,
        :slow_kill => (slow_kill && !target_fast_kill),
        :fast_2hko => (fast_2hko && !target_kill),
        :fast_outdamage => fast_outdamage,
        :outdamage => (outdamage && !faster),
        :target_fast_kill => target_fast_kill,
        :target_fast_2hko => (target_fast_2hko && !slow_kill),
        :target_slow_kill => (target_kill && faster),
        :faster => faster
      }
      flags = {}
      txt = "Flags assigned to #{mon.name}:\n"
      calc_info.keys.each do|key|
        if calc_info[key] == true
          flags[mon] = key.to_sym
          txt += "==========> #{key}: #{calc_info[key]}\n"
          break
        end
      end
      PBDebug.log_ai("=====> "+txt)
      # Calc
      case flags[mon]
      when :fast_kill
        score += 12
        PBDebug.log_switch_score_change(pkmn,12,"for fast kill")
      when :fast_2hko
        score += 6
        PBDebug.log_switch_score_change(pkmn,6,"for fast 2HKO")
      when :slow_kill
        score += 9
        PBDebug.log_switch_score_change(pkmn,9,"for slow kill")
      when :fast_outdamage
        score += 5
        PBDebug.log_switch_score_change(pkmn,5,"for fast outdamage")
      when :outdamage
        score += 3
        PBDebug.log_switch_score_change(pkmn,3,"for outdamage")
      when :target_fast_kill
        if @user.fainted?
          score -= 9
          PBDebug.log_switch_score_change(pkmn,-9,"for target fast kill")
        else
          score -= 20
          PBDebug.log_switch_score_change(pkmn,-20,"for us being killed on switch in")
        end
      when :target_slow_kill
        if @user.fainted?
          score -= 7
          PBDebug.log_switch_score_change(pkmn,-7,"for target slow kill")
        else
          score -= 20
          PBDebug.log_switch_score_change(pkmn,-20,"for us being killed on switch in")
        end
      when :target_fast_2hko
        if @user.fainted?
          score -= 5
          PBDebug.log_switch_score_change(pkmn,-5,"for target having fast 2HKO and us having no kill")
        else
          score -= 20
          PBDebug.log_switch_score_change(pkmn,-20,"for us being killed on switch in")
        end
      end 
    end
    # Prefer if pkmn has lower HP and its position will be healed by Wish
    position = @battle.positions[idxBattler]
    if position.effects[PBEffects::Wish] > 0
      amt = position.effects[PBEffects::WishAmount]
      if pkmn.totalhp - pkmn.hp > amt * 2 / 3
        score += 6
        PBDebug.log_switch_score_change(pkmn,6,"to catch a Wish")
      end
    end
    # Prefer if user is about to faint from Perish Song
    if @user.effects[PBEffects::PerishSong] == 1
      score += 6 
      PBDebug.log_switch_score_change(pkmn,6,"to dodge Perish Song")
    end
    if pkmn.hp < (pkmn.totalhp/2).floor
      score -= 20
      PBDebug.log_switch_score_change(pkmn,-20,"to avoid dying on switch in")
    end
    PBDebug.log("     [#{pkmn.name}] final Switch score: #{score}")
    return score
  end
end

module PBDebug
  def self.log_switch_score_change(pkmn, amt, msg)
    return if amt == 0
    if $DEBUG && $INTERNAL
      sign = (amt > 0) ? "+" : "-"
      amt_text = sprintf("%3d", amt.abs)
      msg = "     [#{pkmn.name}] #{sign}#{amt_text}: #{msg}"
      echoln msg.gsub("%", "%%")
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end
end