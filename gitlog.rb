require 'time'

logs = `git rev-list --all --pretty | grep '^\\s'`.split("\n")
dates = `git rev-list --all --pretty | grep '^Date'`.split("\n")

logs = logs.map(&:strip)
dates = dates.map do |d|
  t = Time.parse(d.sub(/^Date:\s+/, '')) - 3600*6 # Start from 6 in the morning
  t.strftime('%Y-%m-%d')
end

data = dates.zip(logs).reverse
puts data.map{|d| d.join("\t\t")}.join("\n")
