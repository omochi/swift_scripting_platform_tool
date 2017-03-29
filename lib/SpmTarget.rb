require "pathname"

require_relative "MainSwiftSource"

module SwiftScriptingPlatformTool
  class SpmTarget
    attr_reader :dir
    attr_accessor :name
    attr_accessor :main_swift
    
    def initialize(dir)
      @dir = dir

      reset
    end

    def reset
      @name = nil
      @main_swift = nil
    end

    def scan
      reset

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
  end
end