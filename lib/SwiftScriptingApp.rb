require "pathname"
require "json"

require_relative "Config"
require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "AppArgsParser"
require_relative "PackageSwiftCode"
require_relative "SpmTargetsReader"
require_relative "MainSwiftUpdater"

module SwiftScriptingPlatformTool
  class SwiftScriptingApp

    attr_reader :arg_parser
    def initialize
      @arg_parser = AppArgsParser.new
    end

    def main(args)
      command, params = arg_parser.parse_main(args)
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

    def main_init(args)
      package_code = PackageSwiftCode.new
      package_code.init_spm_if_need
      package_code.add_scripting_lib_if_need
      
      main_sync([])
    end

    def main_sync(args)
      targets = (SpmTargetsReader.new).read

      for target in targets
        updater = MainSwiftUpdater.new
        updater.sync(target)
      end
    end
  end
end