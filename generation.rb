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
		GENERATION_SIZE.times do |i|
			base_keylist = best_member[:keylist].select do |time, keys|
				if time < (best_member[:time] - prng.rand(BINS_TO_DROP_LOWER..BINS_TO_DROP_UPPER)) then
					true
				end
			end
			new_keylists << KeyList.new(base_keylist)
			@generation_members[i] = {:keylist=>base_keylist, :distance=>0.0, :time=>0, :score=>0}
		end
		return self.class.new(new_keylists)
	end
end	
