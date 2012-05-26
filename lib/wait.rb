require 'timeout'
require 'logger'

class Wait

  # Creates a new Wait instance.
  #
  # == Options
  #
  # [:attempts]
  #   Number of times to attempt the block. Default is 5.
  # [:timeout]
  #   Seconds the block is permitted to execute. Default is 15.
  # [:delay]
  #   Initial (grows exponentially) number of seconds to wait in between
  #   attempts. Default is 1.
  # [:rescue]
  #   One or an array of exceptions to rescue. Default is +Exception+ (all
  #   exceptions).
  # [:debug]
  #   If +true+, logs debugging output. Default is +false+.
  #
  def initialize(options = {})
    @attempts   = options[:attempts] || 5
    @timeout    = options[:timeout]  || 15
    @delay      = options[:delay]    || 1
    @exceptions = options[:rescue]   || Exception
    debug       = options[:debug]    || false

    # Prevent accidentally causing an infinite loop.
    unless @attempts.is_a?(Fixnum) && @attempts > 0
      raise ArgumentError, 'invalid number of attempts'
    end

    @logger = Logger.new(STDOUT)
    @logger.level = debug ? Logger::DEBUG : Logger::WARN
  end

  # == Description
  #
  # Executes a block until there's a result. Useful for blocking script
  # execution until:
  # * an HTTP request is successful
  # * a port has opened
  # * an external process has started
  # * etc.
  #
  # == Examples
  #
  #   wait = Wait.new(:debug => true)
  #   wait.until { rand(2).zero? }
  #   => Rescued exception while waiting: Wait::NoResultError: result was false
  #   => Attempt 1/5 failed, delaying for 1s
  #   => Rescued exception while waiting: Wait::NoResultError: result was false
  #   => Attempt 2/5 failed, delaying for 2s
  #   => true
  #
  # By default, all exceptions are rescued (the +Exception+ class). However,
  # the exception from the last attempt made is always raised.
  #
  #   wait = Wait.new(:debug => true, :attempts => 3)
  #   wait.until do |attempt|
  #     (attempt == 3) ? raise('raised!') : raise('rescued!')
  #   end
  #   => Rescued exception while waiting: RuntimeError: rescued!
  #   => Attempt 1/3 failed, delaying for 1s
  #   => Rescued exception while waiting: RuntimeError: rescued!
  #   => Attempt 2/3 failed, delaying for 2s
  #   => Rescued exception while waiting: RuntimeError: raised!
  #   => RuntimeError: raised!
  #
  # == Returns
  #
  # The result of the block if not +nil+ or +false+.
  #
  # == Raises
  #
  # The exception from the last attempt made.
  #
  def until(&block)
    # Initialize the attempt and delay counters.
    attempt = 0
    delay = @delay

    begin
      attempt += 1

      result = Timeout.timeout(@timeout, Wait::TimeoutError) do
        # Execute the block and pass the attempt counter to it.
        yield attempt
      end

      # If there's a result (neither +nil+ or +false+), return the result.
      if result
        result
      else
        raise Wait::NoResultError, "result was #{result.inspect}"
      end
    rescue Wait::TimeoutError, Wait::NoResultError, *@exceptions => exception
      @logger.debug 'Rescued exception while waiting: ' +
        "#{exception.class.name}: #{exception.message}"
      @logger.debug exception.backtrace.join("\n")

      # If we've run out of attempts, raise the exception from the last
      # attempt.
      if attempt == @attempts
        raise exception
      else
        @logger.debug "Attempt #{attempt}/#{@attempts} failed, delaying for #{delay}s"
        sleep delay
        delay *= 2
        retry
      end
    end
  end

  # Raised when a block doesn't return a result (+nil+ or +false+).
  class NoResultError < StandardError; end

  # Raised when a block times out.
  class TimeoutError < Timeout::Error; end

end #Wait
