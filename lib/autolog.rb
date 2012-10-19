require 'autolog/version'
require 'autolog/methods'

module Autolog
  class << self
    # called procedure instead of proc because set_trace_func proc was calling the proc attribute. Fun!
    attr_accessor :procedure
    attr_accessor :flush

    # log all specified events
    def events(*args)
      args.flatten!
      args.collect!{|e|e.to_s.gsub('_','-')}
      puts "events method received #{args.inspect}"

      # What's up with the Exception hiding?
      # Ruby bug 7180: can use up 100% cpu in 1.9.3p194 if let anything be raised. We'll silently rescue and ignore issues. Otherwise, it produces a deluge of output.
      if args.size == 1
        eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname) if event == #{args[0].inspect}; rescue SystemExit, Interrupt; raise; rescue Exception; end}"
      elsif args.size > 1
        eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname) if #{args.inspect}.include?(event); rescue SystemExit, Interrupt; raise; rescue Exception; end}"
      else
        set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname); rescue SystemExit, Interrupt; raise; rescue Exception; end}
      end

      if block_given?
        begin
          yield
        ensure
          off
        end
      end
    end
    alias_method :event, :events

    def trace(*args)
      if block_given?
        events args, &Proc.new
      else
        events args
      end
    end

    # log c-call events only
    def c_calls(*args)
      if block_given?
        events ['c-call', args].flatten, &Proc.new
      else
        events ['c-call', args].flatten
      end
    end

    # log c-return events only
    def c_returns(*args)
      if block_given?
        events ['c-return', args].flatten, &Proc.new
      else
        events ['c-return', args].flatten
      end
    end

    # log c-call and c-return events only
    def c_calls_and_returns(*args)
      if block_given?
        events ['c-call', 'c-return', args].flatten, &Proc.new
      else
        events ['c-call', 'c-return', args].flatten
      end
    end

    # log class events only
    def class_starts(*args)
      if block_given?
        events ['class', args].flatten, &Proc.new
      else
        events ['class', args].flatten
      end
    end

    # log end events only
    def class_ends(*args)
      if block_given?
        events ['end', args].flatten, &Proc.new
      else
        events ['end', args].flatten
      end
    end

    # log class and end events only
    def classes(*args)
      if block_given?
        events ['class', 'end', args].flatten, &Proc.new
      else
        events ['class', 'end', args].flatten
      end
    end

    # log call events only
    def method_calls(*args)
      if block_given?
        events ['call', args].flatten, &Proc.new
      else
        events ['call', args].flatten
      end
    end

    # log return events only
    def method_returns(*args)
      if block_given?
        events ['return', args].flatten, &Proc.new
      else
        events ['return', args].flatten
      end
    end

    # log call and return events only
    def methods(*args)
      if block_given?
        events ['call', 'return'], &Proc.new
      else
        events ['call', 'return', args].flatten
      end
    end

    # log raise events only
    def raises(*args)
      if block_given?
        events ['raise', args].flatten, &Proc.new
      else
        events ['raise', args].flatten
      end
    end

    # log line events only
    def lines(*args)
      if block_given?
        events ['line', args].flatten, &Proc.new
      else
        events ['line', args].flatten
      end
    end

    # turn logging off
    def off(*args)
      # accepts *args to make implementation of autolog in methods easier, but ignores them
      set_trace_func nil
    end
  end
end

Autolog.procedure = lambda {|event, file, line, id, binding, classname| begin; puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"; rescue SystemExit, Interrupt; raise; rescue Exception; end}

class Object
  # make autolog a method on every object except main (?)
  class << self
    extend Autolog::Methods
  end
end

# make autolog a method in main
TOPLEVEL_BINDING.eval('include Autolog::Methods')
