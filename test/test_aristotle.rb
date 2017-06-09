require 'minitest/autorun'
require 'aristotle'

class TestLogic < Aristotle::Logic
  action /Go to a bar/ do |_|
    false
  end
  action /Do something else/ do |_|
    false
  end
  action /Do a third thing/ do |_|
    false
  end
  action /Return (\d+)/ do |_, number|
    number.to_i
  end
  action /Return payload/ do |test_model|
    test_model.payload
  end
  condition /this won't match/ do |_|
    false
  end
  condition /this matches/ do |_|
    true
  end
  condition /nothing happens/ do |_|
    false
  end
  condition /all hell breaks loose/ do |_|
    false
  end
  condition /this is a ([a-z]+) condition/ do |test_model, string|
    test_model.payload = string
  end
end

class TestModel
  attr_accessor :payload

  def initialize(argument)
    @payload = argument
  end
end

class AristotleTest < Minitest::Test
  def test_aristotle
    test_model = TestModel.new('payload')
    test_logic = TestLogic.new(test_model)

    assert test_logic.is_a? Aristotle::Logic
    assert_nil test_logic.process('Nothing matches')

    begin
      test_logic.process('Things not defined')
      assert false, 'It should have thrown an exception here'
    rescue
      assert true, ''
    end

    assert_equal 2, test_logic.process('Return on second')
    assert_equal 1, test_logic.process('Return only the first')

    assert_equal 'payload', test_logic.process('Test payload')

    assert_equal 'regexp', test_logic.process('Test condition regexp')

    returned_command = test_logic.process('Test condition regexp', return_command: true)
    assert returned_command.is_a?(Aristotle::Command)
    assert_equal 'Return payload', returned_command.action
    assert_equal 'this is a regexp condition', returned_command.condition
  end
end
