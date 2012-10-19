module Autolog
  module Methods
    def autolog(*args)
      args.flatten!
      if args.size > 0
        if Autolog.respond_to?(args[0])
          if block_given?
            Autolog.send(args.delete_at(0), args, &Proc.new)
          else
            Autolog.send(args.delete_at(0), args)
          end
        elsif block_given?
          Autolog.events args, &Proc.new
        else
          Autolog.events args
        end
      elsif block_given?
        Autolog.events &Proc.new
      else
        Autolog.events
      end
    end
  end
end
