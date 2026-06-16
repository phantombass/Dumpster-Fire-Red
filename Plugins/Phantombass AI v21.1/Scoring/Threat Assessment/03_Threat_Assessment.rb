class Battle::AI::ThreatAssessment
	def self.log(battler,score,msg)
	  if score >= 0
        echoln "[AI Threat Assessment: #{battler.pokemon.name}] +#{score}: " + msg
      else
        echoln "[AI Threat Assessment: #{battler.pokemon.name}] #{score}: " + msg
      end
	end
	def self.threat_damage(battler,target)
		score = 0
    faster = battler.pbSpeed > target.pbSpeed
    if battler.has_killing_move?(target) && faster
      score -= 3
      Battle::AI::ThreatAssessment.log(target,-3,"for us having fast kill")
      battler.threat_flags[:fast_kill] = true
    elsif battler.has_killing_move?(target) && !faster
      score -= 2
      Battle::AI::ThreatAssessment.log(target,-2,"for us having slow kill")
      battler.threat_flags[:slow_kill] = true
    end
    if battler.target_has_killing_move?(target) && !faster
      score += 5
      Battle::AI::ThreatAssessment.log(target,5,"for target having fast kill")
      battler.threat_flags[:target_fast_kill] = true
    elsif battler.target_has_2hko?(target) && !faster
      score += 3
      Battle::AI::ThreatAssessment.log(target,3,"for target having fast 2HKO")
      battler.threat_flags[:target_fast_2hko] = true
    elsif battler.target_has_killing_move?(target) && faster
      score += 2
      Battle::AI::ThreatAssessment.log(target,2,"for target having slow kill")
      battler.threat_flags[:target_slow_kill] = true
    end
    if !battler.has_killing_move?(target) && !battler.target_has_killing_move?(target)
      if battler.pbSpeed > target.pbSpeed
        score -= 1
        Battle::AI::ThreatAssessment.log(target,-1,"for us outspeeding")
        battler.threat_flags[:outspeed] = true
      else
        score += 1
        Battle::AI::ThreatAssessment.log(target,1,"for target outspeeding")
        battler.threat_flags[:outspeed] = false
      end
    end
    return score
	end
end
