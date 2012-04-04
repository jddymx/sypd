
class GuideList

	def initialize(faction, filelist)
		@faction = faction
		@filelist = filelist.map do |filename|
			guide = File.read "tourguide/TourGuide_#{faction}/#{filename}"
			raise "Cannot parse file '#{filename}'" unless guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "?([^"]+)"?, function\(\).*\[\[(.+)\]\]/m
			[filename, $1]
		end

	end

	def write
		filename = "../_includes/#{@faction.downcase}.html"
		f = File.open(filename, "w")
		f << self.to_html
		f.close
	end

	def to_html
		links = @filelist.map {|f,name| "<li> <a href='/tg/#{@faction.downcase[0..0]}/#{f.gsub(/lua\Z/, "html")}'> #{name} </a> </li>"}
		%Q|
<img src="/tg/extras/#{@faction.downcase}.gif" alt="#{@faction}" style="float: left;">
<img src="/tg/extras/#{@faction.downcase}.gif" alt="#{@faction}" style="float: right;">
<h4> #{@faction} </h4>
<ul>
	#{links.join("\n\t")}
</ul>
|
	end

end
