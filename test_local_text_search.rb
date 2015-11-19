require 'benchmark'

games = []
Game.pluck(:id, :name_slug).each{|g| games[g[0]] = g[1]}

found_games = games.size.times.select{|i| games[i] =~ /civ/}
