require 'zone_ids'

class Guide

	def initialize(filename)
		@filename = filename.gsub(/\A.*\//, '')
		guide = File.read filename
		guide = guide.gsub(/--\[\[.*\]\]/m, "")
		raise "Cannot parse file '#{filename}'" unless guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "?([^"]+)"?, function\(\).*\[\[(.+)\]\]/m
		@name, @next_guide, @faction, @data = $1, $2, $3, $4

		zone_id = ZONE_IDS[@name.gsub(/ \(.*\)\Z/, '')]

		lines = @data.split(/[\n\r]+/)
		lines.reject! {|l| l == ""}
		@objectives = lines.map {|line| Objective.new(line, zone_id)}
	end

	def write
		filename = "../tg/#{@faction.downcase[0..0]}/#{@filename.gsub(/lua\Z/, "html")}"
		f = File.open(filename, "w")
		f << to_html
		f.close
	end

	def to_html
		%Q|---
layout: tg
title: TourGuide - #{@name}
is_guide: true
---

<h1>
	<img src="../extras/#{@faction.downcase}.gif" alt="#{@faction}">
	<span class="print_header"> #{@faction} - </span>
	#{@name}
</h1>

<ul class="objectives">
	#{@objectives.map {|o| o.to_html}.join("\n")}
</ul>
|
	end
end
