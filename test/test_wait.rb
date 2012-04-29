require 'test/unit'
require 'wait'

class WaitTest < Test::Unit::TestCase

  MILLISECOND = 0.001

  # Test that the result of the block is the result of Wait.for.
  def test_result
    options = {:delay => MILLISECOND, :silent => true}
    result = Wait.for(options) { 'foo' }
    assert_equal 'foo', result
  end

  # Test that Wait::Error is raised when all attempts fail.
  def test_exception
    options = {:delay => MILLISECOND, :silent => true}
    assert_raise Wait::Error do
      Wait.for(options) { nil }
    end
  end

  # Test that a delays are inserted between each attempt and they grow
  # exponentially.
  def test_delays
    t = Array.new(5)
    t[0] = Time.now
    delay = 0.1

    options = {:attempts => 4, :delay => delay, :silent => true}
    result = Wait.for(options) do |attempt|
      case attempt
      when 1
        t[1] = Time.now
        nil
      when 2
        t[2] = Time.now
        nil
      when 3
        t[3] = Time.now
        nil
      when 4
        t[4] = Time.now
      end
    end

    assert_equal 0,          (t[1] - t[0]).round(1)
    assert_equal delay,      (t[2] - t[1]).round(1)
    assert_equal delay *= 2, (t[3] - t[2]).round(1)
    assert_equal delay *= 2, (t[4] - t[3]).round(1)
  end

  # Test that a nil result is rescued.
  def test_rescuing_nil_result
    options = {:attempts => 2, :delay => MILLISECOND, :silent => true}
    result = Wait.for(options) do |attempt|
      case attempt
      when 1 then nil
      when 2 then 'foo'
      end
    end
    assert_equal 'foo', result
  end

  # Test that a false result is rescued.
  def test_rescuing_false_result
    options = {:attempts => 2, :delay => MILLISECOND, :silent => true}
    result = Wait.for(options) do |attempt|
      case attempt
      when 1 then false
      when 2 then 'foo'
      end
    end
    assert_equal 'foo', result
  end

  # Test that an exception is rescued.
  def test_rescuing_exception
    options = {:attempts => 2, :delay => MILLISECOND, :silent => true}
    result = Wait.for(options) do |attempt|
      case attempt
      when 1 then raise Exception
      when 2 then 'foo'
      end
    end
    assert_equal 'foo', result
  end

  # Test that a timeout is rescued.
  def test_rescuing_timeout
    options = {:attempts => 2, :delay => MILLISECOND, :timeout => 1, :silent => true}
    result = Wait.for(options) do |attempt|
      case attempt
      when 1 then sleep
      when 2 then 'foo'
      end
    end
    assert_equal 'foo', result
  end

  # Test the rescue option: don't rescue any exceptions.
  def test_options_not_rescuing_any_exceptions
    options = {
      :rescue   => [],
      :attempts => 2,
      :delay    => MILLISECOND,
      :silent   => true
    }
    assert_raise RuntimeError do
      result = Wait.for(options) do |attempt|
        case attempt
        # This nil tests that Wait::Error is rescued. Not doing so would
        # alter the core behavior of Wait.for.
        when 1 then nil
        when 2 then raise RuntimeError
        end
      end
    end
  end

  # Test the rescue option: only rescue a particular exception.
  def test_options_rescuing_particular_exception
    options = {
      :rescue   => [ArgumentError],
      :attempts => 3,
      :delay    => MILLISECOND,
      :silent   => true
    }
    assert_raise RuntimeError do
      result = Wait.for(options) do |attempt|
        case attempt
        # This nil tests that Wait::Error is rescued. Not doing so would
        # alter the core behavior of Wait.for.
        when 1 then nil
        when 2 then raise ArgumentError
        when 3 then raise RuntimeError
        end
      end
    end
  end

  # Test a few combinations of invalid number of attempts. Validation is
  # performed here to prevent accidentally causing an infinite loop.
  def test_invalid_number_of_attempts
    assert_raise ArgumentError do
      Wait.for(:attempts => 0) { nil }
    end

    assert_raise ArgumentError do
      Wait.for(:attempts => 1.1) { nil }
    end

    assert_raise ArgumentError do
      Wait.for(:attempts => '1') { nil }
    end
  end

end
