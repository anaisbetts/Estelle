$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'library'
require 'pathname'
require 'test/unit'

$logging_level = Logger::DEBUG

DummyTaggerPath = File.join(File.dirname(__FILE__), '..', 'lib', 'taggers')
#DummyTaggerPath = File.join(File.dirname(__FILE__), 'taggers')
class TestLibrary < Test::Unit::TestCase
	def setup
		@file_list = []
		Pathname.new( (s = File.join(File.dirname(__FILE__), 'files') )).each_entry do |x| 
			@file_list << File.join(s, x.cleanpath) if x.extname == '.mp3'
		end
		puts "File count: #{@file_list.size}"
	end

	def test_load 
		library = MusicLibrary.new
		library.load_taggers DummyTaggerPath
		library.load @file_list
	end
end
