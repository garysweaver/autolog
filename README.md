Autolog
=====

Automatically log tracing events in Ruby more easily.

To trace Ruby, you can just define `set_trace_func`, e.g.

    set_trace_func proc { |event, file, line, id, binding, classname|
      printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
    }
    t = Test.new
    t.test

        line prog.rb:11               false
      c-call prog.rb:11        new    Class
      c-call prog.rb:11 initialize   Object
    c-return prog.rb:11 initialize   Object
    c-return prog.rb:11        new    Class
        line prog.rb:12               false
        call prog.rb:2        test     Test
        line prog.rb:3        test     Test
        line prog.rb:4        test     Test
      return prog.rb:4        test     Test

But, why not use fewer keystrokes to output debug information? And what about just logging certain sets of events? How about:

    Autolog.events :raise, :c_call

Also, check out the Ruby stdlib's [Tracer][tracer], which does similar if you are just looking for a simple trace or need the other options or added speed that it may provide. Autolog is really just meant to be a shortcut for Kernel's set_trace_func, which is a lot more flexible in some ways, since it lets you hook into/log other types of events specifically.

### Installation

In your Gemfile, add:

    gem 'autolog'

Then:

    bundle install

### Usage

In the main object/IRB, or in any object, call autolog with parameters, e.g.:

    autolog :methods
    autolog :c_calls
    autolog :c_returns
    autolog :c_calls_and_returns
    autolog :class_starts
    autolog :class_ends
    autolog :classes
    autolog :method_calls
    autolog :method_returns
    autolog :methods
    autolog :lines
    autolog :raises
    autolog :trace
    autolog :event :c_return
    autolog :events 'raise', 'c-call'
    autolog :events :raise, :c_call
    autolog :off

Or call it on Autolog if that is easier:

    Autolog.c_calls
    Autolog.c_returns
    Autolog.c_calls_and_returns
    Autolog.class_starts
    Autolog.class_ends
    Autolog.classes
    Autolog.method_calls
    Autolog.method_returns
    Autolog.methods
    Autolog.lines
    Autolog.raises
    Autolog.trace
    Autolog.event :c_return
    Autolog.events 'raise', 'c-call'
    Autolog.events :raise, :c_call
    Autolog.off

### Blocks

    autolog do
      puts "this is something"
      puts "this is something 2"
    end

or

    autolog :methods do
      # ...
    end

or

    autolog :lines do
      # ...
    end

or

    autolog :events, :line, :c_call do
      # ...
    end

or

    Autolog.methods do
      # ...
    end

or

    Autolog.events :line, :c_call do
      # ...
    end

### What you can trace

* `Autolog.c_calls` - logs 'c-call'
* `Autolog.c_returns` - logs 'c-return'
* `Autolog.c_calls_and_returns` - logs 'c-call' and 'c-return'
* `Autolog.class_starts` - logs 'class'
* `Autolog.class_ends` - logs 'end'
* `Autolog.classes` - logs 'class' and 'end'
* `Autolog.method_calls` - logs 'call'
* `Autolog.method_returns` - logs 'return'
* `Autolog.methods` - logs 'call' and 'return'
* `Autolog.lines` - logs 'line' (logs every Ruby line executed in this context, similar to a hook into Ruby's caller stack that logs/prints/puts all lines)
* `Autolog.raises` - logs 'raise'
* `Autolog.events` or `Autolog.event` - logs one or more provided events, converting each to string and substituting '_' with '-', of the supported events in [set_trace_func][set_trace_func]. Calling with no arguments or empty array will log all events.
* `Autolog.trace` - logs all events
* `Autolog.off` - turns off tracing (calls `set_trace_func nil`)

### Changing the format, Using another logger, collecting stats, etc.

Keep the ease of Autolog and its minimal controls while doing nuts things with it:

    Autolog.proc = lambda {|event, file, line, id, binding, classname| puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"}

### Warning

Enabling some of these like lines or trace will significantly slow down execution and may generate a lot of output.

### Contributing

It's as easy as [forking][fork], making your changes, and [submitting a pull request][pull].

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[fork]: https://help.github.com/articles/fork-a-repo
[pull]: https://help.github.com/articles/using-pull-requests
[tracer]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tracer/rdoc/index.html
[set_trace_func]: http://apidock.com/ruby/Kernel/set_trace_func
[lic]: http://github.com/garysweaver/autolog/blob/master/LICENSE
