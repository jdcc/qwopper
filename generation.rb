require "./keylist.rb"
require "./utils.rb"
include Utils

class Generation
	GENERATION_SIZE = 40
	BINS_TO_DROP_LOWER = 20
	BINS_TO_DROP_UPPER = 150
	CONSISTENCY_TESTS = 4
	NO_TO_TEST_FOR_CONSISTENCY = 4
	SCORE_MULTIPLIER = 50

	attr_reader :generation_members

	def initialize(keylists = [])
		@generation_members = keylists

		if @generation_members.length < GENERATION_SIZE then
			self.build
		end
	end

	def build	
		until @generation_members.length == GENERATION_SIZE do
			@generation_members << KeyList.new
		end
	end

	def test
		@generation_members.each_with_index do |member, index|
			member.test
			Utils::log "#{index+1}/#{GENERATION_SIZE} - Distance: #{member.distance} - Time: #{member.time}"
		end

		self.sort!
		puts "Testing top #{NO_TO_TEST_FOR_CONSISTENCY} for consistency..."
		NO_TO_TEST_FOR_CONSISTENCY.times do |i|
			member = @generation_members[-i-1].dup
			Utils::log "Testing keylist with distance of #{member.distance}..."
			distances = [member.distance]
			CONSISTENCY_TESTS.times do
				distance, time = member.test
				distances << distance
				Utils::log "Distance: #{distance.to_s}"
			end
			@generation_members[-i-1].score = (SCORE_MULTIPLIER * member.distance / Utils::stddev(distances)).round
			Utils::log "Score: #{@generation_members[-i-1].score}"
		end
	end

	def sort!
		@generation_members.sort_by! { |member| member.distance }
		@generation_members.sort_by! { |member| member.score }
	end

	def get_best
		self.sort!
		return @generation_members.last
	end

	def breed
		best_member = self.get_best
		prng = Random.new
		new_keylists = []
		GENERATION_SIZE.times do
			#remove all the unused bins, plus some random amount capped at 100 bins, to use as a basis for the next generation
			new_length = best_member.time - prng.rand(BINS_TO_DROP_LOWER..[BINS_TO_DROP_UPPER, best_member.time - 1].min)
			base_keylist = best_member.keylist[0, new_length]
			new_keylists << KeyList.new(base_keylist)
		end
		return self.class.new(new_keylists)
	end
end	
