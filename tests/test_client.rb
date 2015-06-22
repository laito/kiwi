require 'kiwi/client/client'
require 'test/unit'
require 'socket'

# This test case covers get, set and delete methods
class TestClient < Test::Unit::TestCase
  def setup
    @thread = Thread.new { system('cd bin && ruby kiwi config.yml') }
    @client = Kiwi::Client::TCPClient.new('127.0.0.1', '1771')
  end

  def teardown
    @client.shutdown_server
  end

  def test_key_not_found
    5.times do |i|
      # Make sure we delete that key first
      key = "test_var_random_#{i}"
      @client.del(key)
      reply = @client.get(key)
      assert_true(reply.include? 'Key not found')
    end
  end

  def test_set_and_get
    5.times do |i|
      key = "test_var_#{i}"
      value = "value_#{i}"
      @client.set(key, value)
      reply = @client.get(key)
      assert_true(reply.include? value)
    end
  end

  def test_delete
    5.times do |i|
      key = "test_del_var_#{i}"
      value = "value_#{i}"
      @client.set(key, value)
      @client.del(key)
      reply = @client.get(key)
      assert_true(reply.include? 'Key not found')
    end
  end
end
