require 'timeout'

# Executes a block until there's a result.
#
#   Wait.for { rand(2).zero? }
#   => Rescued exception while waiting: Wait::Error: result was false
#   => Attempt 1/5 failed, delaying for 0.5s
#   => Rescued exception while waiting: Wait::Error: result was false
#   => Attempt 2/5 failed, delaying for 1.0s
#   => true
#
# By default, all exceptions are rescued.
#
#   Wait.for do
#     if rand(2).zero?
#       true
#     else
#       raise Exception
#     end
#   end
#   => Rescued exception while waiting: Exception: Exception
#   => Attempt 1/5 failed, delaying for 0.5s
#   => true
#
# The attempt counter is passed to the block if special conditionals are
# needed.
#
#   Wait.for(:attempts => 3) { |attempt| puts Time.now if attempt == 3 }
#   => Rescued exception while waiting: Wait::Error: result was nil
#   => Attempt 1/3 failed, delaying for 0.5s
#   => Rescued exception while waiting: Wait::Error: result was nil
#   => Attempt 2/3 failed, delaying for 1.0s
#   => Sun Apr 29 10:03:17 -0400 2012
#   => Rescued exception while waiting: Wait::Error: result was nil
#   => Wait::Error: 3/3 attempts failed
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
# [:exceptions]
#   Array of exceptions to rescue. Default is +Exception+ (all exceptions).
# [:silent]
#   If +true+, silences output. Default is +false+.
#
# == Returns
#
# The result of the block if:
# * the result is not +nil+ or +false+
# * the block doesn't raise an exception
# * the block doesn't time out

class Wait

  def self.for(options = {})
    attempts    = options[:attempts] || 5
    timeout     = options[:timeout]  || 15
    delay       = options[:delay]    || 1
    exceptions  = options[:rescue]   || Exception
    silent      = options[:silent]   || false

    # Prevent accidentally causing an infinite loop.
    unless attempts.is_a?(Fixnum) && attempts > 0
      raise ArgumentError, 'invalid number of attempts'
    end

    # Initialize the attempt counter.
    attempt = 0

    begin
      attempt += 1
      result = Timeout.timeout(timeout) { yield attempt }
      result ? result : raise(Wait::Error, "result was #{result.inspect}")
    rescue Wait::Error, *exceptions => exception
      unless silent
        puts "Rescued exception while waiting: #{exception.class.name}: #{exception.message}"
        puts exception.backtrace.join("\n")
      end

      if attempt == attempts
        raise Wait::Error, "#{attempt}/#{attempts} attempts failed"
      else
        puts "Attempt #{attempt}/#{attempts} failed, delaying for #{delay}s" unless silent
        sleep delay
        delay *= 2
        retry
      end
    end
  end #for

  class Error < StandardError; end

end #Wait
