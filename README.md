Autolog
=====

_Before you start: a similar tool is now available in Ruby 2.0 called [TracePoint][tracepoint] (originally a [separate project][tracepoint_github]). You could also just use [set_trace_func][set_trace_func] directly. [Tracer][tracer] might be a good option if you want to see each line as it executes. And, a tree-formatted output similar to the `taw` format below is provided also by [Unroller][unroller]._

AutoLog allows you to automatically log and do things with tracing events in Ruby easily. To start tracing, you can do:

    autolog

With a block:

    autolog do
      # ...
    end

With a block outputting method calls and c-calls:

    autolog :call, :c_call do
      # ...
    end

With a block specifying a different format/proc you can register:

    autolog format: :taw do
      # ...
    end

### Example Output

Default format just outputs literally what `set_trace_func` makes available, which isn't pretty:

    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/inheritance.rb.61 #<Binding:0x007fc50cf4c080> ActiveRecord::Inheritance::ClassMethods instantiate
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.160 #<Binding:0x007fc50dec48c8> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.160 #<Binding:0x007fc50dec40d0> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    return /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.166 #<Binding:0x007fc50dec3c20> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    return /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/model_schema.rb.166 #<Binding:0x007fc50dec39a0> ActiveRecord::ModelSchema::ClassMethods inheritance_column
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/activerecord-3.2.8/lib/active_record/inheritance.rb.132 #<Binding:0x007fc50dec3720> ActiveRecord::Inheritance::ClassMethods find_sti_class
    call /path/to/.rvm/gems/ruby-1.9.3-p194@my_rails_app/gems/mail-2.4.4/lib/mail/core_extensions/nil.rb.6 #<Binding:0x007fc50dec3388> NilClass blank?

taw's [format][taw_format] is more tree-like and easier to read:

    c-call Complex.new
     call <Complex#-605829048>.initialize
       c-call 11.0.kind_of?
       c-call 11.0.kind_of?
       c-call -5.0.kind_of?
       c-call -5.0.kind_of?
    c-call Complex.new
     call <Complex#-605832038>.initialize
       c-call 2.0.kind_of?
       c-call 2.0.kind_of?
       c-call 13.5.kind_of?
       c-call 13.5.kind_of?

Or, you can use your own format.

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

#### Use the taw format

Use [Tomasz Wegrzanowski's (taw's) format][taw_format]:

    autolog format: :taw do
      # ...
    end

Do a pull request if you have another format or hack you'd like to share!

#### Overriding the default

You can either just override the default, while still letting Autolog filter by event type before it calls your proc:

    Autolog.procedure = lambda {|event, file, line, id, binding, classname| puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"}

#### Register proc and then use :using or :format to use a registered proc

`:using` and `:format` are equivalent.

Register a proc that autolog will filter automatically by event type, per documentation:

    Autolog.filtered_proc :simple, lambda {|event, file, line, id, binding, classname|
      puts "#{classname}.#{id}"
    }

or register a proc that autolog will just send into set_trace_func (which means effectively you'd just be using autolog for its ability to have a block and unset set_trace_func at the end of the block, but you also have access to last args from autolog so you can use user-provided args):

    Autolog.unfiltered_proc :all_calls_counter, lambda {|event, file, line, id, binding, classname|
      $counts ||= {}
      if Autolog.last_args[0] == event
        $counts[event.to_sym] = $counts[event.to_sym] ? $counts[event.to_sym] + 1 : 1
      end
    }

And then the :format and :using options are synonymous. For ease of reading code, using `format` to specify something that is just formatting the output differently or `using` for more involved procs:

    autolog :calls, using: :simple do
      # ...
    end

or

    autolog 'call', using: :all_calls_counter do
      # ...
    end

#### Single-context-safe variables available for usage in custom procs

These variables are "safe" as long as more than one autolog context is not being used at the same time. Multiple thread, etc. could be used within the context of the autolog block, etc. but if you have two different autolog calls executing at once sharing the same module class attributes, that would be a problem.

`Autolog.level` is just a variable that you can use to increment to find place in the call stack:

    Autolog.level += 1

It is initialized to 0 on gem load and at the end of each autolog block or when Autolog.off is called.

`Autolog.last_args` contains the last set of args and options sent into autolog.

### Warning

Enabling some of these like lines or trace will significantly slow down execution and may generate a lot of output.

### Contributing

It's as easy as [forking][fork], making your changes, and [submitting a pull request][pull].

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[taw_format]: http://t-a-w.blogspot.com/2007/04/settracefunc-smoke-and-mirrors.html
[fork]: https://help.github.com/articles/fork-a-repo
[pull]: https://help.github.com/articles/using-pull-requests
[tracer]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tracer/rdoc/index.html
[tracepoint]: http://www.ruby-doc.org/core-2.0.0/TracePoint.html
[tracepoint_github]: https://github.com/rubyunworks/tracepoint
[set_trace_func]: http://apidock.com/ruby/Kernel/set_trace_func
[unroller]: https://github.com/TylerRick/unroller
[lic]: http://github.com/garysweaver/autolog/blob/master/LICENSE
