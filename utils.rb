module Utils
	MOUSE_BUTTON = 1;
	WINDOW_NAME = 'QWOP - Google Chrome'
	BROWSER_COMMAND = 'google-chrome'
	URL = 'http://www.foddy.net/Athletics.html'
	APPLET_LOCATION = '720 450'

	def prepare_applet
		if `xdotool search -name "#{WINDOW_NAME}"`.strip == '' then
			`#{BROWSER_COMMAND} "#{URL}"`
			sleep 5
			`xdotool mousemove #{APPLET_LOCATION} click #{MOUSE_BUTTON}`
			sleep 1
		else
			`xdotool search -name "#{WINDOW_NAME}" windowactivate`
		end

		pixel_color = `./grabpixel "#{WINDOW_NAME}" 580 410`.strip
		if  pixel_color == '237 237 237' then
			`xdotool key q w o p`
			`xdotool key --delay 0 space`
		end
		red, green, blue = 0
		count = 0
		until red.to_i == 82 do
			head_pixel = `./grabpixel "#{WINDOW_NAME}" 700 375`
			red, green, blue = head_pixel.split(' ')
			count += 1
			if count == 30 then
				`xdotool keydown o`
				sleep(2)
				`xdotool key o space`
				count = 0
			end
		end
	end
end
