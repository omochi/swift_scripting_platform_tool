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
    attr_reader :helper
    def initialize
      @tree = nil
      @helper = CommandLineHelper.new
    end

    def print_version
      puts "swift-scripting #{SwiftScriptingPlatformTool::VERSION}"
    end

    def main(args)
      command, params = helper.parse_main(args)
      case command
      when "error"
        print "error: #{params}\n\n"
        helper.print_help
      when "help"
        helper.print_help
      when "version"
        print_version
      when "init"
        main_init(params)
      when "add"
        main_add(params)
      when "sync"
        main_sync(params)
      end
    end

    def main_init(args)
      command, params = helper.parse_init(args)
      case command
      when "error"
        print "error: #{params}\n\n"
        helper.print_init_help
        return
      when "help"
        helper.print_init_help
        return
      when "ok"
      end

      @tree = PackageTree.new(Pathname("."))
      tree.scan
      
      tree.init_spm_if_need
      tree.add_scripting_lib_if_need

      main_sync([])
    end

    def main_add(args)
      command, params = helper.parse_add(args)
      case command
      when "error"
        print "error: #{params}\n\n"
        helper.print_add_help
        return
      when "help"
        helper.print_add_help
        return
      when "ok"
      end

      # package_code = PackageSwiftCode.new
      # if ! package_code.is_spm_inited
      #   puts "error: SPM is not inited here"
      #   return
      # end

      # targets = (SpmTargetsReader.new).read
      # if targets.length >= 2
      #   puts "error: multiple targets does not supported"
      #   return
      # end

      # updaters = targets.map {|target|
      #   updater = MainSwiftUpdater.new
      #   updater.sync(target)
      #   updater
      # }
    end

    def main_sync(args)
      command, params = helper.parse_sync(args)
      case command
      when "error"
        print "error: #{params}\n\n"
        helper.print_sync_help
        return
      when "help"
        helper.print_sync_help
        return
      when "ok"
      end

      @tree = PackageTree.new(Pathname("."))
      tree.scan

      if ! tree.spm_inited
        puts "error: SPM is not inited here"
        return
      end

      tree.sync_targets
    end
  end
end