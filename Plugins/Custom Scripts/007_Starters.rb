class Pokemon
  def three_random_ivs
    ret = []
    stats = []
    GameData::Stat.each_main {|stat| stats.push(stat.id)}
    loop do
    	stat = stats.sample
    	ret.push(stat) unless ret.include?(stat)
    	break if ret.length == 3
    end
    ret.each do |s|
      @iv[s] = 31
    end
  end

  def max_ivs
  	GameData::Stat.each_main {|stat| @iv[stat.id] = 31}
  end
end