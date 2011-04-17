require "./generation.rb"

class QWOP 
	def start
		g = Generation.new
		50.times do |i|
			puts 'Generation ' + i.to_s + ':'
			`echo "#{'Generation ' + i.to_s + ':'}" >> test.log`
			g.test
			best = g.get_best
			puts 'Best Distance: ' + best[:distance].to_s
			`echo "#{'Best Distance: ' + best[:distance].to_s}" >> test.log`
			5.times do 
				distance, time = best[:keylist].test
				puts distance
				`echo "#{distance}" >> test.log`
			end
			g = g.breed
		end
	end
end

`echo > test.log`
qwop = QWOP.new
qwop.start
