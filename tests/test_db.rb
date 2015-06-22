require 'kiwi/database/simple_db'
require 'test/unit'
require 'socket'

# This test case covers get, set and delete methods
class TestDatabase < Test::Unit::TestCase
  def setup
    @db = Kiwi::Database::SimpleDatabase.new
  end

  def test_set_and_get
    key = 'test_var'
    value = 'value'
    @db.set(key, value)
    assert_equal(@db.get(key), value)
  end

  def test_delete
    key = 'test_var'
    value = 'value'
    assert_raise KeyError do
      @db.set(key, value)
      @db.del(key)
      @db.get(key)
    end
  end
end
