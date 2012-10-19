Autolog
=====

Automatically log tracing events in Ruby more easily.

To trace Ruby, you can just define `set_trace_func`. But, why not use fewer keystrokes to output debug information? And what about just logging certain sets of events? How about just:

    autolog

Or a block:

    autolog do
      # ...
    end

Or a block outputting method calls and c-calls:

    autolog :call, :c_call do
      # ...
    end

### Example Output

    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/inheritance.rb.61 #<Binding:0x007fc50cf4c080> ActiveRecord::Inheritance::ClassMethods instantiate
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.160 #<Binding:0x007fc50dec48c8> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.160 #<Binding:0x007fc50dec40d0> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    return /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.166 #<Binding:0x007fc50dec3c20> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    return /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.166 #<Binding:0x007fc50dec39a0> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/inheritance.rb.132 #<Binding:0x007fc50dec3720> ActiveRecord::Inheritance::ClassMethods find_sti_class
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/mail-2.4.4/lib/mail/core_extensions/nil.rb.6 #<Binding:0x007fc50dec3388> NilClass blank?

Note: You can change the format and behavior by setting `Autolog.procedure`.

### See also

* [set_trace_func][set_trace_func]
* [Tracer][tracer] (part of Ruby stdlib)
* [Tracepoint][tracepoint]

### Installation

In your Gemfile, add:

    gem 'autolog'

Then:

    bundle install

### Usage

In the main object/IRB, or in any object, call autolog with parameters, e.g.:

    # "convenience methods" to have readable names
    autolog
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
    # log individual events using their usual names from http://apidock.com/ruby/Kernel/set_trace_func
    autolog :raise, :c_call 
    autolog 'raise', 'c-call'
    # note: autolog :event, ... and autolog :events, ... also works
    autolog :off

Or call it on Autolog if that is easier:

    # "convenience methods" to have readable names
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
    # log individual events using their usual names from http://apidock.com/ruby/Kernel/set_trace_func
    Autolog.event :c_return
    Autolog.events 'raise', 'c-call'
    Autolog.events :raise, :c_call
    Autolog.off

### Blocks

Blocks are nice, because they do an `ensure` to make sure that `autolog :off` happens.

For example, this will still stop tracing in the end of the block:

    autolog do
      raise Exception.new
    end

But, this won't:

    autolog
    raise Exception.new
    autolog :off

Although this would:

    begin
      autolog
      raise Exception.new
    ensure
      autolog :off
    end
      
More examples:

    autolog :methods do
      # ...
    end


    autolog :lines do
      # ...
    end


    autolog :events, :line, :c_call do
      # ...
    end


    Autolog.methods do
      # ...
    end


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

    Autolog.procedure = lambda {|event, file, line, id, binding, classname| puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"}

### Warning

Enabling some of these like lines or trace will significantly slow down execution and may generate a lot of output.

### Contributing

It's as easy as [forking][fork], making your changes, and [submitting a pull request][pull].

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[fork]: https://help.github.com/articles/fork-a-repo
[pull]: https://help.github.com/articles/using-pull-requests
[tracer]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tracer/rdoc/index.html
[tracepoint]: https://github.com/rubyworks/tracepoint
[set_trace_func]: http://apidock.com/ruby/Kernel/set_trace_func
[lic]: http://github.com/garysweaver/autolog/blob/master/LICENSE
