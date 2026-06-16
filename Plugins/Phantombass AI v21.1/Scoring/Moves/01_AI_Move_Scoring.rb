class Battle::AI

  def score_setup_move(ai,user,target,move,score,log)
    ai.each_foe_battler(user.side) do |b|
      if user.set_up_max?(move) || user.either_target_can_fast_2hko?(b) || user.target_has_killing_move?(b) || user.has_killing_move?(b) || (ai.knowledge_flags.has_key?(:haze_flag) && ai.knowledge_flags[:haze_flag].include?(b))
        score -= 15
        PBDebug.log("     - 15 to discourage use") if log
        return score
      end
      if !user.either_target_can_2hko?(b) && !user.has_killing_move?(b)
        add = 9
        score += add
        PBDebug.log("     + #{add} to encourage setup") if log
      end
    end
    return score
  end

  def score_speed_setup_move(ai,user,target,move,score,log)
    if user.set_up_max?(move) || user.either_target_can_fast_2hko?(target) || user.target_has_killing_move?(target) || user.has_killing_move?(target) || (ai.knowledge_flags.has_key?(:haze_flag) && ai.knowledge_flags[:haze_flag].include?(target))
      score -= 15
      PBDebug.log("     - 15 to discourage use") if log
      return score
    end
    if !user.either_target_can_2hko?(target) && !user.has_killing_move?(target) && target.pbSpeed > user.pbSpeed
      add = 9
      score += add
      PBDebug.log("     + #{add} to encourage setup") if log
    end
    return score
  end

  def score_speed_control_move(ai,user,target,move,score,log)
    if user.has_killing_move?(target) || user.either_target_can_fast_2hko?(target) || user.target_has_killing_move?(target)
      if user.user_highest_damaging_move(target) != move
        score -= 15
        PBDebug.log("     - 15 to discourage use") if log
      end
    elsif target.pbSpeed > user.pbSpeed
      score += 4
      PBDebug.log("     + 4 to make equal to highest damaging move") if log
    end
  end

  class ScoreHandler
    @@GeneralCode = []
    @@MoveCode = {}
    @@StatusCode = []
    @@StatusTargetCode = []
    @@DamagingCode = []
    @@FinalCode = []

    def self.add_status(&code)
      @@StatusCode << code
    end

    def self.add_status_targeting(&code)
      @@StatusTargetCode << code
    end

    def self.add_final(&code)
      @@FinalCode << code
    end

    def self.add_damaging(&code)
      @@DamagingCode << code
    end

    def self.add(*moves, &code)
      if moves.size == 0
        @@GeneralCode << code
      else
        moves.each do |move|
          if move.is_a?(Symbol) # Specific move
            id = getConst(Battle::Move, move)
            raise "Invalid move #{move}" if id.nil? || id == 0
            @@MoveCode[id] = code
          elsif move.is_a?(String) # Function code
            @@MoveCode[move] = code
          end
        end
      end
    end

    def self.trigger(list, score, ai, user, target, move, max_move, log)
      return score if list.nil?
      list.each do |code|
        next if code.nil?
        newscore = code.call(score, ai, user, target, move, max_move, log)
        score = newscore if newscore.is_a?(Numeric)
      end
      return score
    end

    def self.trigger_general(score, ai, user, target, move, max_move=nil, log)
      return self.trigger(@@GeneralCode, score, ai, user, target, move, max_move, log)
    end

    def self.trigger_status_moves(score, ai, user, target, move, max_move=nil, log)
      return self.trigger(@@StatusCode, score, ai, user, target, move, max_move, log)
    end

    def self.trigger_status_targeting_moves(score, ai, user, target, move, max_move=nil, log)
      return self.trigger(@@StatusTargetCode, score, ai, user, target, move, max_move, log)
    end

    def self.trigger_damaging_moves(score, ai, user, target, move, max_move=nil, log)
      return self.trigger(@@DamagingCode, score, ai, user, target, move, max_move, log)
    end

    def self.trigger_final(score, ai, user, target, move, max_move, log)
      return self.trigger(@@FinalCode, score, ai, user, target, move, max_move, log)
    end

    def self.trigger_move(move, score, ai, user, target, max_move=nil, log)
      id = move.id
      id = move.function_code if !@@MoveCode[id]
      return self.trigger(@@MoveCode[id], score, ai, user, target, move, max_move, log)
    end
  end
end

###########################################################
#                     STATUS MOVES                        #
###########################################################


# Encourage using offense boosting setup moves if neither of us can kill.
Battle::AI::ScoreHandler.add do |score, ai, user, target, move, max_move, log|
  next if !Battle::AI::AIMove.offense_setup_move?(move)
  next ai.score_setup_move(ai,user,target,move,score,log)
end

# Encourage using defense boosting setup moves if neither of us can kill.
Battle::AI::ScoreHandler.add do |score, ai, user, target, move, max_move, log|
  next if !Battle::AI::AIMove.defense_setup_move?(move)
  next ai.score_setup_move(ai,user,target,move,score,log)
end

# Encourage using speed boosting setup moves if neither of us can kill.
Battle::AI::ScoreHandler.add do |score, ai, user, target, move, max_move, log|
  next if !Battle::AI::AIMove.speed_setup_move?(move)
  next ai.score_speed_setup_move(ai,user,target,move,score,log)
end

# Status-inducing move handling.
Battle::AI::ScoreHandler.add_status_targeting do |score, ai, user, target, move, max_move, log|
  next if !Battle::AI::AIMove.status_condition_move?(move)
  if ai.battle.field.terrain == :Misty || target.has_active_ability?(:HOPEFULTOLL)
    score -= 15
    PBDebug.log("     - 15 to prevent use") if log
    next score
  end
  ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
  can_status = true
  case move.id
  when :WILLOWISP
    flag = :burn
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:WATERVEIL,:WATERBUBBLE,:GUTS,:COMATOSE,:FAIRYBUBBLE,:FLAREBOOST,:MARVELSCALE,:WELLBAKEDBODY,:STEAMENGINE,:FLASHFIRE,:QUICKFEET]
    can_status = target.can_burn?(user,move)
  when :DEEPFREEZE
    flag = :frostbite
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:MAGMAARMOR,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_freeze?(user,move)
  when :THUNDERWAVE,:GLARE,:STUNSPORE
    flag = :paralysis
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:LIMBER,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_paralyze?(user,move)
  when :POISONGAS,:TOXIC,:POISONPOWDER,:TOXICTHREAD
    flag = :poison
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:IMMUNITY,:TOXICBOOST,:POISONHEAL,:GUTS,:QUICKFEET,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:PASTELVEIL,:QUICKFEET]
    can_status = target.can_poison?(user,move)
  when :SPORE,:SING,:SLEEPPOWDER,:YAWN,:HYPNOSIS,:DARKVOID
    flag = :sleep
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:INSOMNIA,:SWEETVEIL,:VITALSPIRIT,:FAIRYBUBBLE,:GUTS,:COMATOSE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_sleep?(user,move)
  else
    next score
  end
  prankster = user.has_active_ability?(:PRANKSTER) && target.pbHasType?(:DARK)
  if (target.has_active_ability?(ability_list) || !can_status || prankster)
    score -= 10
    PBDebug.log("     - 10 for not being able to status") if log
  end
  if user.has_move?([:HEX,:INFERNALPARADE,:BARBBARRAGE]) && can_status
      score += 2
      PBDebug.log("     + 2 to set up for Hex-style spam") if log
    end
  if !can_status
    score -= 10
    PBDebug.log("     - 10 for not being able to be statused") if log
  end
  if flag == :paralysis
    if user.has_role?(:SPEEDCONTROL)
      score += 1
      PBDebug.log("     + 1 for being a Speed Control Role") if log
    end
  end
  if flag == :poison
    if user.has_role?(:TOXICSTALLER)
      score += 2
      PBDebug.log("     + 2 for being a Toxic Staller") if log
    end
  end
  next score
end

# Reflect
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless move.id == :REFLECT
  if user.target_has_screen_removal?(target)
    score -= 3
    PBDebug.log("     - 3 because target can remove screens directly after we set them up.") if log
    next score
  end
  if user.pbOwnSide.effects[PBEffects::Reflect] > 0
    score -= 3
    PBDebug.log("     - 3 for reflect is already active") if log
  else
    enemies = ai.battle.pbParty(target.index).select { |proj| proj && !proj.fainted? }.size
    targets = ai.battle.pbParty(target.index).select { |proj| proj && !proj.fainted? }
    phys_targets = []
    targets.each do |tar|
      tar_battler = ai.pbMakeFakeBattler(tar)
      phys_targets.push(tar) if tar_battler.moves.select {|mov| mov && mov.physicalMove?}.size >= 2
    end
    physenemies = phys_targets.size
    add = enemies + physenemies
    score += add
    PBDebug.log("     + #{add} based on enemy and physical enemy count") if log
  end
  next score
end

# Light Screen
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless move.id == :LIGHTSCREEN
  if user.target_has_screen_removal?(target)
    score -= 3
    PBDebug.log("     - 3 because target can remove screens directly after we set them up.") if log
    next score
  end
  if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
    score -= 3
    PBDebug.log("     - 3 for light screen is already active") if log
  else
    enemies = ai.battle.pbParty(target.index).select { |proj| proj && !proj.fainted? }.size
    targets = ai.battle.pbParty(target.index).select { |proj| proj && !proj.fainted? }
    phys_targets = []
    targets.each do |tar|
      tar_battler = ai.pbMakeFakeBattler(tar)
      phys_targets.push(tar) if tar_battler.moves.select {|mov| mov && mov.specialMove?}.size >= 2
    end
    specenemies = phys_targets.size
    add = enemies + specenemies
    score += add
    PBDebug.log("     + #{add} based on enemy and special enemy count") if log
  end
  next score
end

# Aurora Veil
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless move.id == :AURORAVEIL
  if user.target_has_screen_removal?(target)
    score -= 3
    PBDebug.log("     - 3 because target can remove screens directly after we set them up.") if log
    next score
  end
  if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    score -= 3
    PBDebug.log("     - 3 for Aurora Veil is already active") if log
  elsif user.effectiveWeather != :Hail
    score -= 3
    PBDebug.log("     - 3 for Aurora Veil will fail without Hail active") if log
  else
    enemies = ai.battle.pbParty(target.index).select { |proj| proj && !proj.fainted? }.size
    add = enemies
    score += add
    PBDebug.log("     + #{add} based on enemy count") if log
  end
  next score
end

#Follow Me/Rage Powder
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:FOLLOWME,:RAGEPOWDER].include?(move.id)
  next if ai.battle.singleBattle?
  enemy = []
  allies = []
  ai.each_ally(user.index) do |ally|
    allies.push(ally)
  end
  if allies.length > 0
    ai.each_foe_battler(1) do |opp|
      next if opp.fainted?
      next if opp.nil?
      enemy.push(opp)
    end
    mon = allies[0]
    if enemy.any? {|e| e.has_killing_move?(mon) && !e.has_killing_move?(user)}
      score += 5
      PBDebug.log("     + 5 for redirecting an attack away from partner")
    end
  end
  next score
end

# Helping Hand
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless move.id == :HELPINGHAND
  next if ai.battle.singleBattle?
  if ai.battle.choices[0][0] == :SwitchOut && user.index.even?
    score -= 9
    PBDebug.log("     - 9 to prevent use since player is switching") if log
    next score
  end
  ai.each_same_side_battler(user.side) do |ally, i|
    killer = ally.helping_hand_kill?(target)
    if killer
      score += 9
      PBDebug.log("     + 9 to give the boost ally needs to kill the target") if log
    end
  end
  next score
end

# Status Switch Initiative Moves
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:PARTINGSHOT,:CHILLYRECEPTION,:TELEPORT].include?(move.id)
  next if [:DEATHGRIP].include?(target.ability_id)
  mov = user.target_highest_damaging_move(target)
  best = Battle::AI::FakeMove.new(ai,mov)
  immune = ai.battle.pbParty(user.index).any? { |pkmn| ai.pokemon_can_absorb_move?(pkmn,move,move.type) }
  if (best.rough_damage(target,user) >= user.hp && user.pbSpeed > target.pbSpeed && move.id != :TELEPORT) || (best.rough_damage(target,user) >= user.hp/2)
    add = immune ? 9 : 4
    score += add
    PBDebug.log("     + #{add} for switch initiative against a bad matchup") if log
  end
  next score
end

# Healing Moves
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:RECOVER,:ROOST,:SOFTBOILED,:SLACKOFF,:SHOREUP,:MORNINGSUN,:MOONLIGHT,:SYNTHESIS].include?(move.id)
  factor = (user.hp/user.totalhp).floor
  factor *= 100
  if factor >= 75
    score -= 20
    PBDebug.log("     - 20 to not use pointlessly") if log
    next score
  end
  threshold = 55.0
  heal_factor = 50.0
  healing_weather = {
    :Sandstorm => [:SHOREUP],
    :Sun => [:SYNTHESIS,:MOONLIGHT,:MORNINGSUN],
    :HarshSun => [:SYNTHESIS,:MOONLIGHT,:MORNINGSUN]
  }
  weather = ai.battle.pbWeather
  if healing_weather.has_key?(weather) && healing_weather[weather].include?(move.id)
    heal_factor = (2/3)*100
  end
  if [:Rain,:HeavyRain].include?(weather) && healing_weather[:Sun].include?(move.id)
    heal_factor = 25.0
  end
  dmg = (user.target_highest_move_damage(target)/user.totalhp)*100
  if factor >= threshold
    score -= 5
    PBDebug.log("     - 5 because lost HP is not significant") if log
  else
    if dmg >= heal_factor
      score -= 5
      PBDebug.log("     - 5 because we will not gain any HP in this exchange") if log
    else
      if (factor - dmg + heal_factor) >= threshold
        score += 5
        PBDebug.log("     + 5 to get us into a range of HP to be prioritize attacking") if log
      else
        score += 3
        PBDebug.log("     + 3 because we will heal more than the damage taken") if log
      end
    end
  end
  if user.effects[PBEffects::Toxic] > 0
    score -= 10
    PBDebug.log("     - 10 because Toxic will always outdamage healing")
  end
  next score
end

# Tailwind
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless move.id == :TAILWIND
  if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
    score -= 9
    PBDebug.log("     - 9 because it will fail") if log
    next score
  end
  if ai.battle.singleBattle?
    if user.pbSpeed > target.pbSpeed
      score -= 5
      PBDebug.log("     - 5 because we already outspeed") if log
    end
  else
    speeds = 0
    amount = 0
    ai.each_same_side_battler(user.side) do |ally, i|
      next if ally.fainted?
      amount += 1
      speeds += 1 if ally.pbSpeed > target.pbSpeed
    end
    if speeds == amount
      score -= 5
      PBDebug.log("     - 5 because both we and our ally already outspeed") if log
    else
      add = (amount-speeds)*2
      score += add
      PBDebug.log("     + #{add} to allow #{amount-speeds} battlers to outspeed opponents") if log
    end
  end
  next score
end

# Speed Control Moves
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:BULLDOZE,:DRUMBEATING,:LOWSWEEP,:ROCKTOMB,:ELECTROWEB,:ICYWIND,:MUDSHOT,:SCARYFACE,:STRINGSHOT,:COTTONSPORE,:POUNCE].include?(move.id)
  score = ai.score_speed_control_move(ai,user,target,move,score,log)
  next score
end

# Protect, Detect, King's Shield, Burning Bulwark, Silk Trap, Spiky Shield, Obstruct
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:PROTECT,:DETECT,:KINGSSHIELD,:BURNINGBULWARK,:SILKTRAP,:SPIKYSHIELD,:OBSTRUCT].include?(move.id)
  if user.effects[PBEffects::ProtectRate] > 1
    rate = 5*user.effects[PBEffects::ProtectRate]
    score -= rate
    PBDebug.log("     - #{rate} to prevent Protect failure") if log
  end
  if user.has_active_ability?(:SPEEDBOOST)
    if user.pbSpeed < target.pbSpeed
      score += 5
      PBDebug.log("     + 5 to try to outspeed target with Speed Boost") if log
    end
  end
  if user.has_active_ability?([:GUTS,:FLAREBOOST,:MARVELSCALE]) && user.status == :NONE && user.item == :FLAMEORB
    score += 5
    PBDebug.log("     + 5 to activate Guts/Flare Boost/Marvel Scale") if log
  end
  if user.has_active_ability?([:GUTS,:TOXICBOOST,:POISONHEAL]) && user.status == :NONE && user.item == :TOXICORB
    score += 5
    PBDebug.log("     + 5 to activate Guts/Toxic Boost/Poison Heal") if log
  end
  if ai.battle.pbSideSize(user.index) == 2 && user.either_target_can_2hko?(target)
    score += 4
    PBDebug.log("     + 4 to avoid a strong hit") if log
  end
  if user.has_passive_healing?
    score += 3
    PBDebug.log(     "+ 3 to get passive recovery") if log
  end
  next score
end

# Baton Pass - stat pass specific
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless [:BATONPASS].include?(move.id)
  next if [:DEATHGRIP].include?(target.ability_id)
  mov = user.target_highest_damaging_move(target)
  best = Battle::AI::FakeMove.new(ai,mov)
  immune = ai.battle.pbParty(user.index).any? { |pkmn| ai.pokemon_can_absorb_move?(pkmn,move,move.type) }
  if (best.rough_damage(target,user) >= user.hp && user.pbSpeed > target.pbSpeed) || (best.rough_damage(target,user) >= user.hp/2)
    add = immune ? 9 : 4
    score += add
    PBDebug.log("     + #{add} for switch initiative against a bad matchup") if log
  end
  if user.set_up_score >= 2
    score += user.set_up_score
    PBDebug.log("     + #{user.set_up_score} to encourage stat passing") if log
  end
  next score
end

# Hazard logic handling
Battle::AI::ScoreHandler.add_status do |score, ai, user, target, move, max_move, log|
  next unless Battle::AI::AIMove.hazard_move?(move.id)
  faster = user.pbSpeed > target.pbSpeed
  if !user.either_target_can_kill?(target)
    if user.target_has_hazard_removal?(target) || user.target_has_potential_magic_bounce?(target)
      old = score
      score -= (old - 1)
      PBDebug.log("     - #{old - 1} because target can remove hazards") if log
    else
      party_size = ai.battle.pbParty(target.index).select {|pkmn| pkmn && !pkmn.fainted?}.size
      if party_size == 1
        old = score
        score -= (old - 1)
        PBDebug.log("     - #{old - 1} because there's only one mon left in the party") if log
      else
        score += party_size
        PBDebug.log("     + #{party_size} to encourage hazards for each able opposing party member") if log
        if user.turnCount == 0
          score += 46
          PBDebug.log("     + 46 to incentivize hazards turn 1") if log
        end
      end
    end
  else
    old = score
    score -= (old - 1)
    PBDebug.log("     - #{old-1} because this will be pointless") if log
  end
  next score
end

# Encourage status moves as long as neither target can 2HKO
Battle::AI::ScoreHandler.add_status_targeting do |score, ai, user, target, move, max_move, log|
  next if [:PROTECT,:DETECT,:KINGSSHIELD,:BURNINGBULWARK,:SILKTRAP,:SPIKYSHIELD,:OBSTRUCT].include?(move.id)
  party = ai.battle.pbParty(user.index)
  count = party.select {|pkmn| pkmn && !pkmn.fainted?}.size
  faster = user.pbSpeed > target.pbSpeed
  if (!user.either_target_can_2hko?(target) && !faster) || (!user.target_has_killing_move?(target) && faster)
    score += 1
    PBDebug.log("     + 1 to make equal to highest damaging move") if log
  else
    old = score
    score -= (old - 1)
    PBDebug.log("     - #{old-1} because this will be pointless") if log
  end
  if target.has_move?(:TAUNT) && (target.pbSpeed > user.pbSpeed || target.has_active_ability?(:PRANKSTER) && !user.types.include?(:DARK))
    score -= 20
    PBDebug.log("     - 20 because target can Taunt us.") if log
  end
  next score
end

###########################################################
#                    DAMAGING MOVES                       #
###########################################################

# Fake Out, First Impression
Battle::AI::ScoreHandler.add_damaging do |score, ai, user, target, move, max_move, log|
  next unless [:FAKEOUT,:FIRSTIMPRESSION].include?(move.id)
  next if [:ARMORTAIL,:DAZZLING,:QUEENLYMAJESTY].include?(target.ability_id)
  next if move.id == :FAKEOUT && [:INNERFOCUS,:STEADFAST].include?(target.ability_id)
  next if ai.battle.field.terrain == :Psychic
  if user.turnCount == 0
    score += 18
    PBDebug.log("     + 18 for using turn 1") if log
  else
    score -= 30
    PBDebug.log("     - 30 to discourage use after turn 1") if log
  end
  next score
end

# Sucker Punch, Thunderclap
Battle::AI::ScoreHandler.add_damaging do |score, ai, user, target, move, max_move, log|
  next unless [:SUCKERPUNCH,:THUNDERCLAP].include?(move.id)
  next if [:ARMORTAIL,:DAZZLING,:QUEENLYMAJESTY].include?(target.ability_id)
  next if ai.battle.field.terrain == :Psychic
  count = 0
  target.moves.each {|m| count += 1 if m.statusMove?}
  if count == target.moves.length
    score -= 12
    PBDebug.log("     - 12 because it will fail") if log
    next score
  end
  start = [2,-1,-3,-4]
  add = start[count]
  score += add
  mod = add >= 0 ? "+" : "-"
  PBDebug.log("     #{mod} #{add.abs} for factoring in #{count} Status Moves from #{target.name}") if log
  prio = target.moves.any? {|m| m.damagingMove? && m.priority > 0}
  if user.target_has_killing_move?(target) && target.pbSpeed > user.pbSpeed && !prio
    math = (add>0) ? 3 : (5-add)
    score += math
    PBDebug.log("     + #{math} to match highest damaging move") if log
  else
    PBDebug.log("     no added score due to target having faster priority or being slower with no priority") if log
  end
  next score
end

# Self-Destruct, Explosion
Battle::AI::ScoreHandler.add_damaging do |score, ai, user, target, move, max_move, log|
  next unless [:SELFDESTRUCT,:EXPLOSION,:MISTYEXPLOSION].include?(move.id)
  if [:DAMP].include?(target.ability_id)
    old = score - 1
    score -= old
    PBDebug.log("     - #{old} because the target has Damp") if log
    next score
  end
  test_move = user.user_highest_damaging_move_non_explosive(target)
  mov = Battle::AI::FakeMove.new(ai,test_move)
  if mov.rough_damage(user,target) >= target.hp
    old = score - 1
    score -= old
    score -= 20
    PBDebug.log("     set to - 19 because we have a move that kills other than this") if log
  else
    party = ai.battle.pbParty(user.index)
    count = party.select {|pkmn| pkmn && !pkmn.fainted?}.size
    if count == 1
      score -= 5
      PBDebug.log("     - 5 to set one lower than other moves that can kill if we are last mon") if log
    else
      factor = user.hp == 0 ? 0 : (user.totalhp/user.hp).floor
      if factor > 1
        score += factor
        PBDebug.log("     + #{factor} to incentivize exploding the lower HP we are") if log
      end
    end
  end
  next score
end

# Damaging Switch Initiative Moves
Battle::AI::ScoreHandler.add_damaging do |score, ai, user, target, move, max_move, log|
  next unless [:UTURN,:VOLTSWITCH,:MAGMATREK,:FLIPTURN].include?(move.id)
  next if [:DEATHGRIP].include?(target.ability_id)
  able_party = ai.battle.pbParty(user.index).select {|mon| mon && !mon.fainted?}.size
  next if able_party == 1
  best = user.target_highest_damaging_move(target)
  best_move = Battle::AI::FakeMove.new(ai,best)
  test_move = Battle::AI::FakeMove.new(ai,max_move)
  if test_move != move && test_move.rough_damage(user,target) >= target.hp
    score -= 9
    PBDebug.log("     - 9 to prevent switching when we have a kill with another move")
    next score
  end
  immune = ai.battle.pbParty(user.index).any? { |pkmn| ai.pokemon_can_absorb_move?(pkmn,move,move.type) }
  if (best_move.rough_damage(target,user) >= user.hp/2 && user.pbSpeed <= target.pbSpeed) || (best_move.rough_damage(target,user) >= user.hp && user.pbSpeed > target.pbSpeed)
    add = immune ? 9 : 4
    score += add
    PBDebug.log("     + #{add} for switch initiative against a bad matchup") if log
  end
  next score
end

# Pursuit
Battle::AI::ScoreHandler.add_damaging do |score, ai, user, target, move, max_move, log|
  next unless [:PURSUIT].include?(move.id)
  mov = Battle::AI::FakeMove.new(ai,move)
  has_pursuit_kill = mov.rough_damage(user,target) >= target.hp
  pursuit_kills_if_switching = mov.rough_damage(user,target)*2 >= target.hp
  if has_pursuit_kill
    score += 5
    PBDebug.log("     + 5 because we see kill with Pursuit, regardless of whether they switch") if log
  elsif pursuit_kills_if_switching
    score += 2
    PBDebug.log("     + 2 because we see kill with Pursuit, but only if target switches") if log
  end
  next score
end

###########################################################
#                  FINAL CONSIDERATIONS                   #
###########################################################

# Discount Status Moves if Taunted
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  if move.statusMove? && user.effects[PBEffects::Taunt] > 0
      score -= 20
      PBDebug.log("     - 20 to prevent failing") if log
  end
  next score
end

# Properly choose moves if Tormented
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  if move == user.battler.lastRegularMoveUsed && user.effects[PBEffects::Torment]
      score -= 20
      PBDebug.log("     - 20 to prevent failing") if log
  end
  next score
end

# Properly choose moves if Encored
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  if user.effects[PBEffects::Encore] > 0
    encore_move = user.effects[PBEffects::EncoreMove]
    if move.id == encore_move
      score += 30
      PBDebug.log("     + 30 to guarantee use of this move") if log
    else
      score -= 20
      PBDebug.log("     - 20 to prevent failing") if log
    end
  end
  next score
end

# De-incentivizing moves that hit the ally if it will 2HKO
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  next if ai.battle.singleBattle?
  target_data = move.pbTarget(user.battler)
  next if target_data != :AllNearOthers
  mov = Battle::AI::FakeMove.new(ai,move)
  ai.each_same_side_battler(user.side) do |ally, i|
    dmg = target_data == :AllNearOthers ? mov.rough_damage(user,ally) : -1
    PBDebug.log("     Predicted damage to #{ally.name}: #{dmg}") if log
    next if dmg <= -1
    if dmg >= ally.hp/2
      score -= 6
      PBDebug.log("     - 6 to avoid 2HKOing our ally") if log
    end
  end
  next score
end

# Properly choose a priority move if target is faster and has no priority move
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  next if target.has_active_ability?([:ARMORTAIL,:DAZZLING,:QUEENLYMAJESTY])
  next if ai.battle.field.terrain == :Psychic
  next if move.move.priority < 1
  prio = target.moves.any? { |mov| mov.damagingMove? && mov.priority > 0  }
  no_prio = !prio && target.faster_than?(user)
  slower_prio = user.faster_than?(target)
  condition = prio ? slower_prio : no_prio
  if move.move.damagingMove? && target.has_killing_move?(user) && condition
    score += 9
    PBDebug.log("     + 9 to get a last ditch hit off.") if log
  end
  next score
end

# Add threat score to determine targeting
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  next if ai.battle.singleBattle?
  targets = ai.battlers.select {|tar| tar.idxOwnSide != user.idxOwnSide }
  threats = targets.select {|t| user.threat_scores(t) < 0}.size
  next if threats == targets.length
  score += user.threat_scores(target)
  PBDebug.log("     + #{user.threat_scores(target)} to factor in threat scoring.") if log
  next score
end

# Adding score based on the ability to outspeed and KO
Battle::AI::ScoreHandler.add_final do |score, ai, user, target, move, max_move, log|
  next score if [:FAKEOUT,:FIRSTIMPRESSION].include?(move.id) && ai.battle.turnCount == 0
  if move.statusMove? && (user.has_killing_move?(target) || Battle::AI::AIMove.setup_move?(move.id) && user.either_target_can_2hko?(target))
    old_score = score
    score -= old_score-1
    PBDebug.log("     - #{(old_score-1)} because we see kill or target sees 2HKO") if log
    next score
  end
  mov = Battle::AI::FakeMove.new(ai,move)
  party = ai.battle.pbParty(user.index)
  count = party.select {|pkmn| pkmn && !pkmn.fainted?}.size
  if [:SELFDESTRUCT,:EXPLOSION,:MISTYEXPLOSION].include?(move.id) && count == 1
    PBDebug.log("     skipping remaining scoring for #{move.name} because we are last mon") if log
    next score
  end
  faster = user.pbSpeed > target.pbSpeed
  if user.has_killing_move?(target) && faster && mov.rough_damage(user,target) >= target.hp
    score += 20
    PBDebug.log("      + 20 for fast kill") if log
  elsif user.has_killing_move?(target) && !faster && mov.rough_damage(user,target) >= target.hp
    score += 17
    PBDebug.log("      + 17 for slow kill") if log
  elsif user.target_has_killing_move?(target) && !faster && user.has_killing_move?(target) && mov.rough_damage(user,target) >= target.hp
    score += 5
    PBDebug.log("      + 5 for having a kill even if we are killed first") if log
  else
    mv = max_move
    if mv.id == move.id
      score += 4
      PBDebug.log("     + 4 to prioritize highest damaging move") if log
    end
  end
  if score < 1
    score = 1
    PBDebug.log("     set score to 1 if lower than 1 to prevent not using a move") if log
  end
  next score
end