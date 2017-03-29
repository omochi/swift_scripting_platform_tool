require "pathname"
require "json"
require "fileutils"

require_relative "Config"
require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "CommandLineHelper"
require_relative "PackageTree"

module SwiftScriptingPlatformTool
  class SwiftScriptingApp

    attr_reader :tree
    def initialize
      @tree = nil
    end

    def print_error(error)
      print "error: #{error}\n\n"
    end

    def print_version
      puts "swift-scripting #{SwiftScriptingPlatformTool::VERSION}"
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
          print_version
          return
        when "-h", "--help"
          print_help
          return
        when "init"
          main_init(args)
          return
        when "add"
          main_add(args)
          return
        when "sync"
          main_sync(args)
          return
        else
          error = "invalid args"
          break
        end
      end

      print_error(error)
      print_help
    end

    def init_tree
      @tree = PackageTree.new(Pathname("."))
      tree.scan
    end

    def check_tree
      if ! tree.spm_inited
        print_error("spm is not inited here")
        return false
      end

      if tree.targets.count {|x| x.main_swift } >= 2
        print_error("multiple target does not supported")
        return false
      end

      return true
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

    def main_init(args)
      error = nil

      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          print_init_help
          return
        else
          error = "invalid args"
          break
        end
      end

      if error
        print_error(error)
        print_init_help
        return
      end

      init_tree
      
      tree.init_spm_if_need
      tree.add_scripting_lib_if_need

      main_sync([])
    end

    def print_add_help
      lines = [
        "Usage: swift-scripting add <script-name>",
        "",
      ]
      puts lines.map {|x| x + "\n" }.join
    end

    def main_add(args)
      error = nil

      args = [].concat args
      script_name = nil
      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          print_add_help
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
        print_error(error)
        print_add_help
        return
      end

      init_tree
      if ! check_tree
        return
      end

      tree.targets[0].add_script_swift(script_name)
      main_sync([])
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

    def main_sync(args)
      error = nil

      while true
        if args.length == 0
          break
        end
        arg = args.shift

        case arg
        when "-h", "--help"
          print_sync_help
          return
        else
          error = "invalid args"
          break
        end
      end

      if error
        print_error(error)
        print_sync_help
        return
      end

      init_tree
      if ! check_tree
        return
      end
      tree.sync_targets
    end
  end
end