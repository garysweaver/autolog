module Autolog
  module Methods
    def autolog(*args)
      if args.size > 1 && !args[0].is_a?(Hash) && args[0].to_sym == :off
        Autolog.off
      elsif block_given?
        Autolog.events *args, &Proc.new
      else
        Autolog.events *args
      end
    end
  end
end
