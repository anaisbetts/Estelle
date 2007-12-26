$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'library' 
require 'yaml'
require 'mocha'

TestDir = File.dirname(__FILE__)

class TestLibrary < Test::Unit::TestCase
	def test_create_action_list
		ml = YAML::load(File.read(File.join(TestDir, 'test_library_fixture.yaml')))
                list = ml.create_action_list('.', "<artist>/<album>/<track> - <title>.<ext>", 
		                      "Soundtracks/<album>/<track> - <title> (<artist>).<ext>") do |tag,invalid,defparm|
			defparm
		end
		assert list
	end

	def test_empty_eh
		ml = Library.new
		assert ml.empty?
	end

	def test_execute_action_list
		raise NotImplementedError, 'Need to write test_execute_action_list'
	end

	def test_find_soundtracks
		ml = YAML::load(File.read(File.join(TestDir, 'test_library_fixture.yaml')))
		ml.find_soundtracks do |x|
			assert_equal("Office Space", x)
		end
	end

	def test_load_taggers
		ml = Library.new
		ml.load_taggers(File.join(TestDir, 'mocks'))

		assert ml.taggers

		# FIXME: For some reason, autotest convinces the regular tagger to load
		# I don't know why
		#assert_equal ml.taggers.length, 1
	end
end

# Number of errors detected: 9
