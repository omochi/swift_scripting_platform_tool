require "pathname"
require "json"
require "fileutils"

require_relative "Config"
require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "PackageTree"

require_relative "RootCommand"
require_relative "InitCommand"
require_relative "ListCommand"
require_relative "AddCommand"
require_relative "SyncCommand"

module SwiftScriptingPlatformTool
  class SwiftScriptingApp

    attr_reader :tree
    def initialize
      @tree = nil
    end

    def print_error(error)
      puts "error: #{error}"
    end

    def print_version
      puts "swift-scripting #{SwiftScriptingPlatformTool::VERSION}"
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

    def main(args)
      RootCommand.new(self).main(args)
    end

    def main_init(args)
      InitCommand.new(self).main(args) do
        init_tree
        
        tree.init_spm_if_need
        tree.add_scripting_lib_if_need

        main_sync([])
      end
    end

    def main_list(args)
      ListCommand.new(self).main(args) do
        init_tree
        for target in tree.targets
          for script_entry in target.main_swift.script_entries
            path = target.get_script_class_path(script_entry.class_name)
            puts format("    %-16s => %s", 
              script_entry.script_name, path.to_s)
          end
        end
      end
    end

    def main_add(args)
      AddCommand.new(self).main(args) do
        init_tree
        if ! check_tree
          return
        end

        for target in tree.targets.select {|x| x.main_swift }
          for script in target.main_swift.script_entries
            if script.script_name == script_name
              print_error("script #{script_name} is already defined")
              return
            end
          end
        end

        tree.targets[0].add_script_swift(script_name)
        main_sync([])
      end
    end

    def main_sync(args)
      SyncCommand.new(self).main(args) do
        init_tree
        if ! check_tree
          return
        end
        tree.sync_targets
      end
    end
  end
end