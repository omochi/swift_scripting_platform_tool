module SwiftScriptingPlatformTool
  class ListCommand
    attr_reader :app
    def initialize(app)
      @app = app
    end

    def print_help
      lines = [
        "Usage: swift-scripting list",
        "",
        "no help",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def main(args)
      error = nil

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
          error = "invalid args"
          break
        end
      end

      if error
        app.print_error(error)
        puts
        print_help
        return
      end

      yield
    end

  end
end