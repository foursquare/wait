## Description

Executes a block until there's a result. Useful for blocking script execution until:
* an HTTP request is successful
* a port has opened
* an external process has started
* etc.

## Examples

```ruby
wait = Wait.new(:debug => true)
wait.until { rand(2).zero? }
# => Rescued exception while waiting: Wait::NoResultError: result was false
# => Attempt 1/5 failed, delaying for 1s
# => Rescued exception while waiting: Wait::NoResultError: result was false
# => Attempt 2/5 failed, delaying for 2s
# => true
```

By default, all exceptions are rescued (the `Exception` class). However, the exception from the last attempt made is always raised.

```ruby
wait = Wait.new(:debug => true, :attempts => 3)
wait.until do |attempt|
  (attempt == 3) ? raise('raised!') : raise('rescued!')
end
# => Rescued exception while waiting: RuntimeError: rescued!
# => Attempt 1/3 failed, delaying for 1s
# => Rescued exception while waiting: RuntimeError: rescued!
# => Attempt 2/3 failed, delaying for 2s
# => Rescued exception while waiting: RuntimeError: raised!
# => RuntimeError: raised!
```

## Options

* __*:attempts*__ Number of times to attempt the block. Default is `5`.
* __*:timeout*__ Seconds the block is permitted to execute. Default is `15`.
* __*:delay*__ Initial (grows exponentially) number of seconds to wait in between attempts. Default is `1`.
* __*:rescue*__ One or an array of exceptions to rescue. Default is `Exception` (all exceptions).
* __*:debug*__ If `true`, logs debugging output. Default is `false`.

## Documentation

RDoc-formatted documentation available [here](http://foo.com).
