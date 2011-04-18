require "./generation.rb"

class QWOP 
	NO_GENERATIONS = 25
	CONSISTENCY_TESTS = 5

	def start
		g = Generation.new
		NO_GENERATIONS.times do |i|
			puts 'Generation ' + i.to_s + ':'
			`echo "#{'Generation ' + i.to_s + ':'}" >> test.log`
			g.test
			best = g.get_best
			puts 'Best Distance: ' + best.distance.to_s
			`echo "#{'Best Distance: ' + best.distance.to_s}" >> test.log`
			CONSISTENCY_TESTS.times do 
				distance, time = best.test
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
