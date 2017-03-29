module SwiftScriptingPlatformTool
  class CommandLineHelper

    def print_help
      lines = [
        "Usage: swift-scripting <command>",
        "",
        "Command list:",
        "",
        "    init        init SPM project",
        "    add         add script",
        "    sync        update main.swift and entry point scripts",
        "                based on existing script class files",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def parse_main(args)
      args = [].concat args
      while true
        if args.length == 0
          return ["error", "no command args"]
        end
        arg = args.shift

        case arg
        when "-v", "--version"
          return ["version"]
        when "-h", "--help"
          return ["help"]
        when "init"
          return ["init", args]
        when "add"
          return ["add", args]
        when "sync"
          return ["sync", args]
        else
          return ["error", "invalid args"]
        end
      end
    end

    def print_init_help
      lines = [
        "Usage: swift-scripting init",
        "",
        "no help",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def parse_init(args)
      args = [].concat args
      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          return ["help"]
        else
          return ["error", "invalid args"]
        end
      end
      return ["ok"]
    end

    def print_sync_help
      lines = [
        "Usage: swift-scripting sync",
        "",
        "no help",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def parse_sync(args)
      args = [].concat args
      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          return ["help"]
        else
          return ["error", "invalid args"]
        end
      end
      return ["ok"]
    end

    def print_add_help
      lines = [
        "Usage: swift-scripting add <script-name>",
        "",
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def parse_add(args)
      args = [].concat args
      script_name = nil
      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          return ["help"]
        else
          if script_name
            return ["error", "invalid args"]
          else
            script_name = arg
          end
        end
      end
      if ! script_name
        return ["error", "script name not specified"]
      end
      return ["ok"]
    end

  end
end