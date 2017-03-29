module SwiftScriptingPlatformTool
  class RootCommand
    attr_reader :app
    def initialize(app)
      @app = app
    end

    def print_help
      lines = [
        "Usage: swift-scripting <command>",
        "",
        "Command list:",
        "",
        "    init        init SPM project",
        "    list        show script list",
        "    add         add script",
        "    sync        update main.swift and entry point scripts",
        "                based on existing script class files",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def main(args)
      error = nil

      while true
        if args.length == 0
          error = "no command args"
          break
        end
        arg = args.shift

        case arg
        when "-v", "--version"
          app.print_version
          return
        when "-h", "--help"
          print_help
          return
        when "init"
          app.main_init(args)
          return
        when "list"
          app.main_list(args)
          return
        when "add"
          app.main_add(args)
          return
        when "sync"
          app.main_sync(args)
          return
        else
          error = "invalid args"
          break
        end
      end

      app.print_error(error)
      puts
      print_help
    end
  end
end