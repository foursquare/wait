## Description

The wait gem executes a block until there's a result. Useful for blocking script execution until:
* an HTTP request was successful
* a port has opened
* an external process has started
* etc.

## Installation

Add to your `Gemfile`:

```ruby
gem 'wait', :git => 'git@github.com:foursquare/wait.git'
```

## Examples

```ruby
wait = Wait.new
# => #<Wait>
wait.until { Time.now.sec.even? }
# Rescued exception while waiting: Wait::NoResultError: result was false
# Attempt 1/5 failed, delaying for 1s
# => true
```

If you wish to handle an exception by attempting the block again, pass one or an array of exceptions with the `:rescue` option.

```ruby
wait = Wait.new(:rescue => RuntimeError)
# => #<Wait>
wait.until do |attempt|
  case attempt
  when 1 then nil
  when 2 then raise RuntimeError
  when 3 then 'foo'
  end
end
# Rescued exception while waiting: Wait::NoResultError: result was nil
# Attempt 1/5 failed, delaying for 1s
# Rescued exception while waiting: RuntimeError: RuntimeError
# Attempt 2/5 failed, delaying for 2s
# => "foo"
```

## Options

<dl>
  <dt>:attempts</dt>
  <dd>Number of times to attempt the block. Default is <code>5</code>.</dd>
  <dt>:timeout</dt>
  <dd>Seconds until the block times out. Default is <code>15</code>.</dd>
  <dt>:delay</dt>
  <dd>Initial (grows exponentially) delay (in seconds) to wait in between attempts. Default is <code>1</code>.</dd>
  <dt>:rescue</dt>
  <dd>One or an array of exceptions to rescue. Default is <code>nil</code>.</dd>
  <dt>:debug</dt>
  <dd>If <code>true</code>, logs debugging output. Default is <code>false</code>.</dd>
</dl>

## Documentation

RDoc-generated documentation available [here](http://foursquare.github.com/wait/).
