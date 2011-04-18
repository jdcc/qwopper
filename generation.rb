require "./keylist.rb"

class Generation
	GENERATION_SIZE = 40
	BINS_TO_DROP_LOWER = 1
	BINS_TO_DROP_UPPER = 100
	MIN_PERCENT_RETAINED = 0.7

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
			puts "#{index}. Distance: #{member.distance} - Time: #{member.time}"
			`echo "#{"#{index}. Distance: #{member.distance} - Time: #{member.time}"}" >> test.log`
		end
	end

	def get_best
		@generation_members.sort_by! { |member| member.distance }
		return @generation_members.last
	end

	def breed
		best_member = self.get_best
		prng = Random.new
		new_keylists = []
		GENERATION_SIZE.times do
			#remove all the unused keypresses, plus some random amount capped at 30%, to use as a basis for the next generation
			new_length = [best_member.time - prng.rand(BINS_TO_DROP_LOWER..BINS_TO_DROP_UPPER), (best_member.time * MIN_PERCENT_RETAINED).round].max
			base_keylist = best_member.keylist[0, new_length]
			new_keylists << KeyList.new(base_keylist)
		end
		return self.class.new(new_keylists)
	end
end	
