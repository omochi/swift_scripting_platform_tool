module SwiftScriptingPlatformTool
  class AppArgsParser
    def parse_main(args)
      args = [].concat args
      while true
        if args.length == 0
          return ["empty"]
        end
        arg = args.shift

        case arg
        when "-v", "--version"
          return ["version"]
        when "-h", "--help"
          return ["help"]
        when "init"
          return ["init", args]
        when "sync"
          return ["sync", args]
        else
          return ["invalid"]
        end
      end
    end
  end
end