module SwiftScriptingPlatformTool
  class RemoveCommand
    attr_reader :app
    def initialize(app)
      @app = app
    end
    def print_help
      lines = [
        "Usage: swift-scripting remove <script-name>",
        "",
      ]
      puts lines.map {|x| x + "\n" }.join
    end
    def main(args)
      error = nil

      script_name = nil
      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          print_help
          return
        else
          if script_name
            error = "invalid args"
            break
          else
            script_name = arg
          end
        end
      end

      if ! script_name
        error = "script name not specified"
      end
      if error
        app.print_error(error)
        puts
        print_help
        return
      end

      yield(script_name)
    end
  end
end