class QWOP 
	def start
		g = Generation.new
		g.new
		50.times do |i|
			puts 'Generation ' + i.to_s + ':'
			`echo "#{'Generation ' + i.to_s + ':'}" >> test.log`
			g.test
			best = g.get_best
			puts 'Best Distance: ' + best[:distance].to_s
			k = KeyList.new
			5.times do 
				distance, time = k.test(best[:keylist])
				puts distance
				`echo "#{distance}" >> test.log`
			end
			g.new_generation(best)
		end
	end

	def prepare
		if `xdotool search -name "QWOP - Google Chrome"`.strip == '' then
			`google-chrome "http://www.foddy.net/Athletics.html"`
			sleep 5
			`xdotool mousemove 720 450 click 3`
			sleep 1
		else
			`xdotool search -name "QWOP - Google Chrome" windowactivate`
		end

		pixel_color = `./grabpixel "QWOP - Google Chrome" 580 410`.strip
		if  pixel_color == '237 237 237' then
			`xdotool key q w o p`
			`xdotool key --delay 0 space`
		end
		red, green, blue = 0
		count = 0
		until red.to_i == 82 do
			head_pixel = `./grabpixel "QWOP - Google Chrome" 700 375`
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

class KeyList < QWOP
	LISTLENGTH = 10000
	def generate(first_index = 0)
		prng = Random.new
		odds = prng.rand(0.1..0.2)
		#keypress list will be of form {1=>['qd', 'wd', 'ou']}
		keyList = {}
		keys = {'q'=>true,'w'=>true,'o'=>true,'p'=>true} #true == up
		i = first_index
		until i == LISTLENGTH do
		       	keyList[i] = []	
			keys.each do |key, state|
				if rand < odds then 
					keyList[i] << key + (state ? 'd' : 'u') 
					keys[key] = !state
				end
			end
			i += 1
		end
		return keyList
	end

	def test(keylist)
		prepare
		browserWindowId = `xdotool search --name "QWOP - Google Chrome"`.strip
		keylist.each do |time, keys|
			keys.each do |key|
				command = (key[1] == 'u' ? 'keyup' : 'keydown')
				`xdotool #{command + ' --window ' + browserWindowId + ' --delay 0 ' + key[0]}`
			end
			pixel_color = `./grabpixel "QWOP - Google Chrome" 580 410`.strip
			if  pixel_color == '237 237 237' then
				distance = `xdotool search -name "QWOP - Google Chrome" windowactivate \
					&& xwd -name "QWOP - Google Chrome" -out "Distance.xwd" \
					&& convert Distance.xwd -negate -crop '133x25+643+432' Distance#{time}.pnm \
					&& rm -f Distance.xwd && gocr -u "1" -C "--0-9.metrs " Distance#{time}.pnm`.gsub!(' ','').to_f
				return distance, time
			end
			sleep(0.01)
		end
	end
end

class Generation
	GENERATIONSIZE = 40
	LISTLENGTH = 10000

	def initialize
		@generation_members = []
	end

	def new	
		k = KeyList.new
		GENERATIONSIZE.times do |i|
			@generation_members[i] = {:keylist=>k.generate, :distance=>0.0, :time=>0, :score=>0}
		end
	end

	def test
		k = KeyList.new
		
		@generation_members.each_with_index do |member, index|
			distance, time = k.test(member[:keylist])
			member[:distance] = distance
			member[:time] = time
			puts index.to_s + '. Distance: ' + distance.to_s + ' Time: ' + time.to_s
			`echo "#{index.to_s + '. Distance: ' + distance.to_s + ' Time: ' + time.to_s}" >> test.log`

		end
	end

	def get_best
		@generation_members.sort_by!{ |member| member[:distance] }
		return @generation_members.last
	end

	def new_generation(best_member)
		initialize
		prng = Random.new
		GENERATIONSIZE.times do |i|
			base_keylist = best_member[:keylist].select do |time, keys|
				if time < (best_member[:time] - prng.rand(1..100)) then
					true
				end
			end
			k = KeyList.new
			base_keylist.merge!(k.generate(base_keylist.length))
			@generation_members[i] = {:keylist=>base_keylist, :distance=>0.0, :time=>0, :score=>0}
		end
	end
end	
q = QWOP.new
q.start
