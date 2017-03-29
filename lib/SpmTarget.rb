require "pathname"

require_relative "MainSwiftSource"
require_relative "AppUtil"
require_relative "ScriptClassSwift"

module SwiftScriptingPlatformTool
  class SpmTarget
    attr_reader :dir
    attr_accessor :name
    attr_accessor :main_swift
    attr_accessor :script_class_files
    
    def initialize(dir)
      @dir = dir

      reset
    end

    def reset
      @name = nil
      @main_swift = nil
      @script_class_files = []
    end

    def scan
      reset

      @script_class_files = Dir.chdir(dir) {
        Pathname.glob("**/*Script.swift").map {|x| dir + x }
      }

      main_swift_path = nil

      Dir.chdir(dir) do
        files = Pathname.glob("**/main.swift").map {|x| dir + x }
        if files.length >= 2
          puts "warning: multiple main.swift in #{dir.to_s}"
        end
        if files.length > 0
          main_swift_path = files[0]
        end
      end

      @main_swift = MainSwiftSource.new(main_swift_path)
      main_swift.scan
    end

    def save
      main_swift.save
    end

    def has_script_swift(script_name)
      file_name = AppUtil.script_name_to_class_file_name(script_name)
      script_class_files.any? {|x| x.basename.to_s == file_name }
    end

    def add_script_swift(script_name)
      class_name = AppUtil.script_name_to_class_name(script_name)
      str = ScriptClassSwift.new(class_name).render
      path = dir + AppUtil.script_name_to_class_file_name(script_name)
      path.binwrite(str)
    end

    def remove_script_swift(script_name)
      file_name = AppUtil.script_name_to_class_file_name(script_name)
      for file in script_class_files
        if file.basename.to_s == file_name
          file.delete
        end
      end
    end

    def get_script_class_path(script_name)
      file_name = AppUtil.script_name_to_class_file_name(script_name)
      script_class_files.find {|x| 
        x.basename.to_s == file_name }
    end

  end
end