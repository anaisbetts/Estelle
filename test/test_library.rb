$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'library' 
require 'yaml'

class TestMusicLibrary < Test::Unit::TestCase
	def test_create_action_list
		raise NotImplementedError, 'Need to write test_create_action_list'
	end

	def test_empty_eh
		ml = MusicLibrary.new
		assert ml.empty?
	end

	def test_execute_action_list
		raise NotImplementedError, 'Need to write test_execute_action_list'
	end

	def test_find_soundtracks
		raise NotImplementedError, 'Need to write test_find_soundtracks'
	end

	def test_is_soundtrack_equals
		raise NotImplementedError, 'Need to write test_is_soundtrack_equals'
	end

	def test_load_taggers
		raise NotImplementedError, 'Need to write test_load_taggers'
	end

	def test_size
		raise NotImplementedError, 'Need to write test_size'
	end
end

# Number of errors detected: 9
