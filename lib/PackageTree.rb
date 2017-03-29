require "pathname"
require "json"

require_relative "ShellUtil"
require_relative "SwiftUtil"
require_relative "SpmTarget"
require_relative "Config"
require_relative "StartScript"

module SwiftScriptingPlatformTool
  class PackageTree
    attr_reader :path
    attr_reader :spm_inited
    attr_reader :package_json
    attr_reader :is_single_target
    attr_reader :targets
    attr_reader :start_scripts

    def initialize(path)
      @path = path

      reset
    end

    def package_swift_path
      path + "Package.swift"
    end

    def sources_dir
      path + "Sources"
    end

    def reset
      @spm_inited = false
      @package_json = nil
      @is_single_target = false
      @targets = []
      @start_scripts = []
    end
    
    def scan
      reset

      if package_swift_path.exist?
        @spm_inited = true
      else
        @spm_inited = false
      end

      if ! spm_inited
        return
      end

      str = ShellUtil.exec_capture(["swift", "package", "dump-package"])
      @package_json = JSON.parse(str)

      target_dirs = sources_dir.children
        .select {|x| x.directory? }
      if target_dirs.length == 0
        target_dirs = [ sources_dir ]
        @is_single_target = true
      end

      @targets = target_dirs.map {|dir| 
        target = SpmTarget.new(dir)
        target.scan
        target
      }
      if is_single_target
        targets.each {|x|
          x.name = package_json["name"]
        }
      else
        targets.each {|x|
          x.name = x.dir.entries[-1].to_s
        }
      end

      @start_scripts = path.children
        .select {|x| x.file? && x.executable? }
    end

    def init_spm_if_need
      if spm_inited
        return
      end

      Dir.chdir(path) {
        ShellUtil.exec(["swift", "package", "init", "--type", "executable"])
      }

      scan
    end

    def has_scripting_lib
      config = Config.shared.scripting_lib

      deps = package_json["dependencies"] || []
      return deps.any? {|dep|
        path_str = URI.parse(dep["url"]).path
        name = Pathname(path_str).basename(".*").to_s
        name == config[:name]
      }
    end

    def add_scripting_lib_if_need
      if has_scripting_lib
        return
      end

      config = Config.shared.scripting_lib
      lines = SwiftUtil.read(package_swift_path)
      lines.concat [
        "package.dependencies.append(.Package(url: \"#{config[:url]}\",",
        "                                     versions: #{config[:version]}))",
      ]
      SwiftUtil.write(package_swift_path, lines)

      scan
    end

    def sync_targets
      for target in targets
        target.main_swift.insert_import_if_need

        script_class_files = Dir.chdir(target.dir) {
          Pathname.glob("**/*Script.swift").map {|x| target.dir + x }
        }

        script_class_names = script_class_files.map {|x|
          x.basename(".swift").to_s
        }

        for script_class_name in script_class_names
          if target.main_swift.has_script_class(script_class_name)
            next
          end

          target.main_swift.add_script_with_class_name(script_class_name)
        end

        for script_entry in target.main_swift.script_entries
          if script_class_names.any? {|x| x == script_entry.class_name }
            next
          end

          target.main_swift.remove_script_with_class_name(script_entry.class_name)
        end

        target.save
      end

      for s in start_scripts
        s.delete
      end

      for target in targets
        for script_entry in target.main_swift.script_entries
          str = StartScript.new(target.name).render

          path = self.path + script_entry.script_name
          path.binwrite(str)
          FileUtils.chmod("+x", path)
        end
      end

      scan
    end # def
  end # class
end # module