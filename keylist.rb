require './utils.rb'
include Utils

class KeyList
	LIST_LENGTH = 10
	PROB_LOWER_BOUND = 0.1
	PROB_UPPER_BOUND = 0.2

	FELL_PIXEL_X = 580
	FELL_PIXEL_Y = 410
	FELL_PIXEL_COLOR = '237 237 237'
	FELL_DIST_IMAGE = '133x25+643+432'
	TIME_BETWEEN_BINS = 0.01

	attr_reader :keylist

	def initialize(keylist = [])
		@keys = {'q'=>true,'w'=>true,'o'=>true,'p'=>true} #true == key is up
		@keylist = keylist
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
		browser_window_id = `xdotool search --name "QWOP - Google Chrome"`.strip
		@keylist.each_with_index do |keys, time|
			keys.each do |key|
				command = (key[1] == 'u' ? 'keyup' : 'keydown')
				`xdotool #{command + ' --window ' + browserWindowId + ' --delay 0 ' + key[0]}`
			end
			pixel_color = `./grabpixel "QWOP - Google Chrome" #{FELL_PIXEL_X FELL_PIXEL_Y}`.strip
			if  pixel_color == FELL_PIXEL_COLOR then
				distance = `xdotool search -name "QWOP - Google Chrome" windowactivate \
					&& xwd -name "QWOP - Google Chrome" -out "Distance.xwd" \
					&& convert Distance.xwd -negate -crop '#{FELL_DIST_IMAGE}' Distance#{time}.pnm \
					&& rm -f Distance.xwd && gocr -u "1" -C "--0-9.metrs " Distance#{time}.pnm`.gsub!(' ','').to_f
				return distance, time
			end
			sleep(TIME_BETWEEN_BINS)
		end
	end
end
