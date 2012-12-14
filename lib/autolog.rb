require 'autolog/version'
require 'autolog/methods'

module Autolog
  class << self
    # called procedure instead of proc because set_trace_func proc was calling the proc attribute. Fun!
    attr_accessor :last_args
    attr_accessor :level
    attr_accessor :procedure
    attr_accessor :filtered_procs
    attr_accessor :unfiltered_procs

    def filtered_proc(name, procedure)
      filtered_procs[name.to_sym] = procedure
    end

    def unfiltered_proc(name, procedure)
      unfiltered_procs[name.to_sym] = procedure
    end

    # log all specified events
    def events(*args)
      args = convert_args(*args)

      Autolog.last_args = args.dup # to allow access by custom procs later in set_trace_func. only "single-context-safe"

      using = nil
      if args.size > 0 && args.last.is_a?(Hash)
        options = args.pop
        using = options[:using] ? options[:using].to_s.to_sym : options[:format] ? options[:format].to_s.to_sym : nil
      end

      if unfiltered_procs[using]
        # What's up with the Exception hiding in the body of the procs?
        # Ruby bug 7180: can use up 100% cpu in 1.9.3p194 if let anything be raised. We'll silently rescue and ignore issues. Otherwise, it produces a deluge of output.
        eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; Autolog.unfiltered_procs[#{using.inspect}].call(event, file, line, id, binding, classname); rescue SystemExit, Interrupt; raise; rescue Exception; end}"
      else
        if using && !filtered_procs.has_key?(using)
          raise "Unregistered format/using: #{using.inspect}"
        end

        proc_string = using ? "Autolog.filtered_procs[#{using.inspect}]" : 'Autolog.procedure'
        
        if args.size > 0
          # What's up with the Exception hiding in the body of the procs?
          # Ruby bug 7180: can use up 100% cpu in 1.9.3p194 if let anything be raised. We'll silently rescue and ignore issues. Otherwise, it produces a deluge of output.
          if args.size == 1
            eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; #{proc_string}.call(event, file, line, id, binding, classname) if event == #{args[0].inspect}; rescue SystemExit, Interrupt; raise; rescue Exception; end}"
          elsif args.size > 1
            eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; #{proc_string}.call(event, file, line, id, binding, classname) if #{args.inspect}.include?(event); rescue SystemExit, Interrupt; raise; rescue Exception; end}"
          end
        else
          eval "set_trace_func proc {|event, file, line, id, binding, classname| begin; #{proc_string}.call(event, file, line, id, binding, classname); rescue SystemExit, Interrupt; raise; rescue Exception; end}"
        end
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

    def convert_args(*args)
      result = []
      args.each do |a|
        case a
        when :trace
        when :c_calls; result << 'c-call'
        when :c_return; result << 'c-return'
        when :c_calls_and_returns; result << 'c-call' << 'c-return'
        when :class_starts; result << 'class'
        when :class_ends; result << 'end'
        when :classes; result << 'class' << 'end'
        when :method_calls; result << 'call'
        when :method_returns; result << 'return'
        when :methods; result << 'call' << 'return'
        when :raises; result << 'raise'
        when :lines; result << 'line'
        else
          a = a.to_s.gsub('_','-') if a.is_a?(Symbol)
          result << a
        end
      end
      result
    end

    [:trace, :c_calls, :c_returns, :c_calls_and_returns, :class_starts, :class_ends, :classes, :method_calls, :method_returns, :methods, :raises, :lines].each {|m|
      eval "def #{m}(*args); if block_given?; events #{m.inspect}, *args, &Proc.new; else; events #{m.inspect}, *args; end; end"
    }

    # turn logging off
    def off(*args)
      set_trace_func nil
      Autolog.level = 0
    end
  end
end

Autolog.filtered_procs = {}
Autolog.unfiltered_procs = {}

Autolog.filtered_proc :default, lambda {|event, file, line, id, binding, classname|
  puts "#{event} #{file}.#{line} #{binding} #{classname} #{id}"
}

# Tomasz Wegrzanowski (taw)'s format, modified a little: http://t-a-w.blogspot.com/2007/04/settracefunc-smoke-and-mirrors.html
Autolog.unfiltered_proc :taw, lambda { |event, file, line, id, binding, classname|
  if event == "line"
    # Ignore
  elsif %w[return c-return end].include?(event)
    Autolog.level -= 2
  else
    obj = eval("self", binding)
    if event == "class"
      STDERR.printf "%*s%s %s\n", Autolog.level, "", event, obj
    else
      obj = "<#{obj.class}##{obj.object_id}>" if id == :initialize
      STDERR.printf "%*s%s %s.%s\n", Autolog.level, "", event, obj, id
    end
    Autolog.level += 2 if %w[call c-call class].include?(event)
  end
}

Autolog.procedure = Autolog.filtered_procs[:default]
Autolog.level = 0

class Object
  # make autolog a method on every object except main (?)
  class << self
    extend Autolog::Methods
  end
end

# make autolog a method in main
TOPLEVEL_BINDING.eval('include Autolog::Methods')
