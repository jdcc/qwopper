require './utils.rb'
include Utils

class KeyList
	LIST_LENGTH = 10000
	PROB_LOWER_BOUND = 0.01
	PROB_UPPER_BOUND = 0.02

	FELL_DIST_IMAGE = '133x25+643+432'
	TIME_BETWEEN_BINS = 0.01

	attr_reader :keylist

	def initialize(keylist = [])
		@keylist = keylist
		@keys = {'q'=>true,'w'=>true,'o'=>true,'p'=>true} #true == key is up
		if @keylist.length < LIST_LENGTH then
			self.build
		end
	end

	def build
		prng = Random.new
		odds = prng.rand(PROB_LOWER_BOUND..PROB_UPPER_BOUND)
		until @keylist.length == LIST_LENGTH do
		       	bin_array = []
			@keys.each do |key, state|
				if rand < odds then 
					bin_array << key + (state ? 'd' : 'u') 
					@keys[key] = !state
				end
			end
			@keylist << bin_array
		end
	end

	def test
		Utils.prepare_applet
		browser_window_id = `xdotool search --name "#{Utils::WINDOW_NAME}"`.strip
		@keylist.each_with_index do |keys, time|
			keys.each do |key|
				command = (key[1] == 'u' ? 'keyup' : 'keydown')
				`xdotool #{command + ' --window ' + browser_window_id + ' --delay 0 ' + key[0]}`
			end
			pixel_color = `./grabpixel "#{Utils::WINDOW_NAME}" #{Utils::FELL_PIXEL}`.strip
			if pixel_color == Utils::FELL_PIXEL_COLOR then
				distance = `xdotool search -name "#{Utils::WINDOW_NAME}" windowactivate \
					&& xwd -name "#{Utils::WINDOW_NAME}" -out "Distance.xwd" \
					&& convert Distance.xwd -negate -crop '#{FELL_DIST_IMAGE}' Distance#{time}.pnm \
					&& rm -f Distance.xwd && gocr -u "1" -C "--0-9.metrs " Distance#{time}.pnm`.gsub!(' ','').to_f
				`rm Distance#{time}.pnm`
				return distance, time
			end
			sleep(TIME_BETWEEN_BINS)
		end
	end
end
