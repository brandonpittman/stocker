require 'minitest_helper'

class TestStocker < MiniTest::Test

  include Stocker

  def setup
    @stocker = Generator.new
  end

  def test_that_it_has_a_version_number
    refute_nil Stocker::VERSION
  end

  def test_read_config
    setup
    assert_equal Hash, @stocker.read_file.class
  end

  def test_file
    setup
    assert_equal Pathname.new("/Users/brandonpittman/Dropbox/.stocker.yaml"), @stocker.file
  end

  def test_config_file_exist?
    setup
    assert @stocker.config_file_exist?
  end
end
