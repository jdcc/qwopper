require "./generation.rb"
require "./utils.rb"
include Utils

class QWOP 
	NO_GENERATIONS = 25

	def start
		g = Generation.new
		Utils::log "Testing #{NO_GENERATIONS} generations..."
		NO_GENERATIONS.times do |i|
			Utils::log "Testing generation #{(i+1).to_s}..."
			g.test
			Utils::log 'Best Candidate: ' + g.get_best.distance.to_s
			g = g.breed
		end
	end
end

`echo > test.log`
qwop = QWOP.new
qwop.start
