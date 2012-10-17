require 'autolog/version'

module Autolog
  class << self
    # called procedure instead of proc because set_trace_func proc was calling the proc attribute. Fun!
    attr_accessor :procedure

    # log all specified events
    def events(*args)
      args.flatten!
      args.collect!{|e|e.to_s.gsub('_','-')}

      # What's up with the Exception hiding?
      # Ruby bug 7180: can use up 100% cpu in 1.9.3p194 if let anything be raised. We'll silently rescue and ignore issues. Otherwise, it produces a deluge of output.
      if args.size == 1
        eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname) if event == #{args[0].inspect}; rescue SystemExit, Interrupt; raise; rescue Exception; end}"
      elsif args.size > 1
        eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname) if #{args.inspect}.include?(event); rescue SystemExit, Interrupt; raise; rescue Exception; end}"
      else
        set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.procedure.call(event, file, line, id, binding, classname); rescue SystemExit, Interrupt; raise; rescue Exception; end}
      end
    end
    alias_method :event, :events

    def trace
      events
    end

    # log c-call events only
    def c_calls
      events 'c-call'
    end

    # log c-return events only
    def c_returns
      events 'c-return'
    end

    # log c-call and c-return events only
    def c_calls_and_returns
      events 'c-call', 'c-return'
    end

    # log class events only
    def class_starts
      events 'class'
    end

    # log end events only
    def class_ends
      events 'end'
    end

    # log class and end events only
    def classes
      events 'class', 'end'
    end

    # log call events only
    def method_calls
      events 'call'
    end

    # log return events only
    def method_returns
      events 'return'
    end

    # log call and return events only
    def methods
      events 'call', 'return'
    end

    # log raise events only
    def raises
      events 'raise'
    end

    # log line events only
    def lines
      events 'line'
    end

    def off
      set_trace_func nil
    end
  end
end

Autolog.procedure = lambda {|event, file, line, id, binding, classname| puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"}
