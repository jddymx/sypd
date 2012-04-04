require 'zone_ids'

class Objective

	attr_accessor :title, :notes, :qid, :obj_type, :use_item, :loot_item, :classes, :races

	TAG_REGEXES = [/\|(O|NODEBUG|T)\|/, /\|(N|R|C|Z|SZ|Q|QO|PRE)\|[^|]+\|/, /\|(QID|U|L)\|\d+\|/, /\|L\|\d+ \d+\|/]
	TYPES = {"A" => "Accept", "C" => "Complete", "T" => "Turnin", "F" => "Fly", "B" => "Buy", "R" => "Run", "h" => "Set Hearth", "N" => "Note", "H" => "Hearth", "K" => "Kill", "U" => "Use", "f" => "Flightpoint",
		"b" => "Boat", "P" => "Pet"}

	def initialize(line, zone_id)
		@zone_id = zone_id

		tag_stripped = line.clone
		TAG_REGEXES.each {|re| tag_stripped.gsub!(re, "")}
		raise "Bad tag? '#{line}'" if tag_stripped =~ /\|/

		raise "Bad char '#{line}'" if line =~ /[“”’]/

		raise "Cannot parse '#{line}'" unless line =~ /\A(.) ([^|]+)\|?/
		type, @title = $1, $2.strip
		raise "Cannot find type '#{type}'" unless TYPES[type]
		@obj_type = TYPES[type]

		@qid = $1 if line =~ /\|QID\|(\d+)\|/
		@use_item = $1 if line =~ /\|U\|(\d+)\|/
		@loot_item = $1 if line =~ /\|L\|(\d+)\s?\d*\|/
		@notes = $1 if line =~ /\|N\|([^|]+)\|/
		@classes = $1 if line =~ /\|C\|([^|]+)\|/
		@races = $1 if line =~ /\|R\|([^|]+)\|/
		@zone_id = ZONE_IDS[$1] if line =~ /\|Z\|([^|]+)\|/

		super()
	end

	def title_link
		return "<a href='http://www.wowhead.com/?item=#{loot_item}' target='_blank'> #{title} </a>" if obj_type == "Buy" && !loot_item.nil?
		return "<a href='http://www.wowhead.com/?quest=#{qid}' target='_blank'> #{title} </a>" unless qid.nil?
		title
	end

	def note_block
		vals = [notes]
		vals << "<i> #{classes} only </i>" unless classes.nil?
		vals << "<i> #{races} only </i>" unless races.nil?
		vals.compact!
		vals.empty? ? "" : "<p> #{vals.join(" <br> ")} </p>"
	end

	def map_link
		return "" if notes.nil? || !(notes =~ /\(([\d.]+),\s?([\d.]+)\)/)
		y = "<a href='http://www.wowhead.com/?maps=#{@zone_id || '3483'}:"
		notes.scan(/\(([\d.]+),\s?([\d.]+)\)/) {|a,b| y += "#{(a.to_f*10).to_i}#{(b.to_f*10).to_i}"}
		y + "' target='_blank'><img src='http://static.wowhead.com/images/icons/large/ability_spy.jpg' alt='Map'></a>"
	end

	def use_item_link
		use_item.nil? ? "" : "<a href='http://www.wowhead.com/?item=#{use_item}' target='_blank'>Use item</a>"
	end

	def to_html
		%Q|
		<li class="#{obj_type.downcase.gsub(" ", "")}">
			<img class="icon" src="../extras/#{obj_type.downcase.gsub(" ", "")}.png" alt="#{obj_type}">
			<div class="quest_detail">
				#{map_link}
				#{use_item_link}
				<h3> #{title_link} </h3>
				#{note_block}
			</div>
		</li>|
	end
end
