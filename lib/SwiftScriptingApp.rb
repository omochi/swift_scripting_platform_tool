require "pathname"
require "json"
require "fileutils"

require_relative "Config"
require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "AppArgsParser"
require_relative "PackageSwiftCode"
require_relative "SpmTargetsReader"
require_relative "MainSwiftUpdater"
require_relative "EntryPointScript"

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
        "    sync        update main.swift and entry point scripts",
        "                based on existing script class files",
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
      package_code.load
      package_code.add_scripting_lib_if_need
      
      main_sync([])
    end

    def main_sync(args)
      package_code = PackageSwiftCode.new
      if ! package_code.is_spm_inited
        puts "error: SPM is not inited here"
        return
      end

      targets = (SpmTargetsReader.new).read

      if targets.length >= 2
        puts "error: multiple targets does not supported"
        return
      end

      updaters = targets.map {|target|
        updater = MainSwiftUpdater.new
        updater.sync(target)
        updater
      }

      scripts = EntryPointScript.scan_scripts
      for script in scripts
        script.delete
      end

      for updater in updaters
        for code_entry in updater.main_code.entries
          script = EntryPointScript.new(updater.target[:name])
          code = script.render

          path = Pathname(code_entry[:script_name])
          path.binwrite(code)
          FileUtils.chmod("+x", path)
        end
      end
      
    end
  end
end