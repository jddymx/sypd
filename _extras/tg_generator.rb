#! /c/ruby/bin/ruby

require 'xmlsimple'

require "GuideList"
require "Guide"
require "Objective"

if File.exist?("tourguide")
	`cd tourguide && git pull origin master`
else
	`git clone git://github.com/tekkub/tourguide.git`
end

`rm -rf ../tg/a`
`rm -rf ../tg/h`
Dir.mkdir "../tg/a"
Dir.mkdir "../tg/h"

xml = XmlSimple.xml_in File.read("tourguide/TourGuide_Alliance/Guides.xml")
ally_files = xml["Script"].map{|v| v["file"]}
GuideList.new("Alliance", ally_files).write

xml = XmlSimple.xml_in File.read("tourguide/TourGuide_Horde/Guides.xml")
horde_files = xml["Script"].map{|v| v["file"]}
GuideList.new("Horde", horde_files).write

ally_files.each {|f| Guide.new("tourguide/TourGuide_Alliance/#{f}").write}
horde_files.each {|f| Guide.new("tourguide/TourGuide_Horde/#{f}").write}

