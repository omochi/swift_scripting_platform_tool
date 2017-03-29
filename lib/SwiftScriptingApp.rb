require "pathname"
require "json"

require_relative "Config"
require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "SpmTargetsReader"
require_relative "MainSwiftUpdater"

module SwiftScriptingPlatformTool
  class SwiftScriptingApp

    attr_reader :package_swift_path

    def initialize
      @package_swift_path = Pathname("Package.swift")
      @package_json = nil
    end

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
        main_init(params)
        return
      when "sync"
        main_sync(params)
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
        if arg == "sync"
          return ["sync", args[(i+1) .. -1]]
        end
        return ["invalid", arg]
      end
    end

    def print_help
      lines = [
        "Usage: swift-scripting <command>",
        "",
        "Command list:",
        "",
        "    init        init SPM project",
        "    add         add script",
        "    sync        update dispatch code in main.swift",
        "                based on existing Script class files",
        ""
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def print_version
      puts "swift-scripting #{SwiftScriptingPlatformTool::VERSION}"
    end

    def main_init
      init_spm
      load_package
      add_swift_scripting_platform_dependency
      
      main_sync([])
    end

    def main_sync(args)
      targets = (SpmTargetsReader.new).read

      for target in targets
        updater = MainSwiftUpdater.new
        updater.sync(target)
      end
    end

    def init_spm
      if Pathname("Package.swift").exist?
        return
      end

      ShellUtil.exec(["swift", "package", "init", "--type", "executable"])
    end

    def load_package
      json_str = ShellUtil.exec_capture(["swift", "package", "dump-package"])
      @package_json = JSON.parse(json_str)
    end

    def has_swift_scripting_platform_dependency
      deps = package_json["dependencies"]
      if ! deps
        return false
      end
      config = Config.shared.swift_scripting_platform
      if deps.any? {|x| 
        url_path_str = URI.parse(x["url"]).path
        name = Pathname(url_path_str).basename(".*").to_s
        config[:name] == name
      }
        return true
      end
      return false
    end

    def add_swift_scripting_platform_dependency
      if has_swift_scripting_platform_dependency
        return
      end

      path = package_swift_path
      lines = SwiftUtil.read(path)
      config = Config.shared.swift_scripting_platform
      lines.concat [
        "package.dependencies.append(.Package(url: \"#{config[:url]}\",",
        "                                     versions: #{config[:version]}))",
      ]
      SwiftUtil.write(path, lines)
    end

  private
    attr_reader :package_json
  end
end