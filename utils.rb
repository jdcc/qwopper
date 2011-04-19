module Utils
	MOUSE_BUTTON = 1;
	WINDOW_NAME = 'QWOP - Google Chrome'
	BROWSER_COMMAND = 'google-chrome'
	URL = 'http://www.foddy.net/Athletics.html'
	APPLET_LOCATION = '720 450'
	FELL_PIXEL = '580 410'
	FELL_PIXEL_COLOR = '237 237 237'
	JAW_PIXEL = '700 375'
	JAW_PIXEL_RED_VALUE = 82

	def prepare_applet
		if `xdotool search -name "#{WINDOW_NAME}"`.strip == '' then
			`#{BROWSER_COMMAND} "#{URL}"`
			sleep 5
			`xdotool mousemove #{APPLET_LOCATION} click #{MOUSE_BUTTON}`
			sleep 1
		else
			`xdotool search -name "#{WINDOW_NAME}" windowactivate`
		end

		pixel_color = `./grabpixel "#{WINDOW_NAME}" #{FELL_PIXEL}`.strip
		if  pixel_color == FELL_PIXEL_COLOR then
			`xdotool key q w o p`
			`xdotool key --delay 0 space`
		end
		red, green, blue = 0
		count = 0
		until red.to_i == JAW_PIXEL_RED_VALUE do
			head_pixel = `./grabpixel "#{WINDOW_NAME}" #{JAW_PIXEL}`
			red, green, blue = head_pixel.split(' ')
			count += 1
			if count == 30 then
				$stderr.puts 'I Quit.'
				`xdotool keydown o`
				sleep(2)
				`xdotool key o space`
				count = 0
			end
		end
	end

	def variance (population)
		n = 0
		mean = 0.0
		s = 0.0
		population.each { |x|
			n = n + 1
			delta = x - mean
			mean = mean + (delta / n)
			s = s + delta * (x - mean)
		}
		return s / n
	end

	def stddev (population)
		return Math.sqrt (variance(population))
	end
	
	def log (message)
		puts message
		`echo "#{message}" >> test.log`
	end
end
