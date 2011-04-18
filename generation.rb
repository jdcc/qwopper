require "./keylist.rb"

class Generation
	GENERATION_SIZE = 40
	BINS_TO_DROP_LOWER = 1
	BINS_TO_DROP_UPPER = 100

	attr_reader :generation_members

	def initialize(keylists = [])
		@generation_members = []
		keylists.each do |keylist|
			@generation_members << { :keylist => keylist, :distance => 0.0, :time => 0, :score => 0 }
		end

		if @generation_members.length < GENERATION_SIZE then
			self.build
		end
	end

	def build	
		until @generation_members.length == GENERATION_SIZE do
			keylist = KeyList.new
			@generation_members << { :keylist => keylist, :distance => 0.0, :time => 0, :score => 0 }
		end
	end

	def test
		@generation_members.each_with_index do |member, index|
			member[:distance], member[:time] = member[:keylist].test
			puts "#{index}. Distance: #{member[:distance]} - Time: #{member[:time]}"
			`echo "#{"#{index}. Distance: #{member[:distance]} - Time: #{member[:time]}"}" >> test.log`
		end
	end

	def get_best
		@generation_members.sort_by! { |member| member[:distance] }
		return @generation_members.last
	end

	def breed
		best_member = self.get_best
		prng = Random.new
		new_keylists = []
		GENERATION_SIZE.times do
			#remove all the unused keypresses, plus some random amount capped at 30%, to use as a basis for the next generation
			new_length = [best_member[:time] - prng.rand(BINS_TO_DROP_LOWER..BINS_TO_DROP_UPPER), (best_member[:time] * 0.3).round].min
			base_keylist = best_member[:keylist].keylist[0, new_length]
			new_keylists << KeyList.new(base_keylist)
		end
		return self.class.new(new_keylists)
	end
end	
