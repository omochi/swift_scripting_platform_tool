require_relative "ShellUtil"

module SwiftScriptingPlatformTool
  class SwiftScriptingApp
    def main(args)
      command, params = parse_args(args)
      case command
      when "empty"
        puts "error: no command args"
        puts ""
      when "error"
        puts "error: invalid arg [#{params}]"
        puts ""
      when "version"
        print_version
        return
      when "help"
      when "init"
        app = InitApp.new(self)
        app.main(params)
        return
      end

      print_help
    end

    def parse_args(args)
      i = 0
      while true
        if i >= args.length
          return ["empty"]
        end
        arg = args[i]
        if arg == "-v" || arg == "--version"
          return ["version"]
        end
        if arg == "-h" || arg == "--help"
          return ["help"]
        end
        if arg == "init"
          return ["init", args[(i+1) .. -1]]
        end
        return ["invalid", arg]
      end
    end

    def print_help
      puts "Usage: swift-scripting <command>"
      puts ""
      puts "Command list:"
      puts ""
      puts "    init        init SPM"
      puts ""
    end

    def print_version
      puts "swift-scripting #{SwiftScriptingPlatformTool::VERSION}"
    end
  end
end