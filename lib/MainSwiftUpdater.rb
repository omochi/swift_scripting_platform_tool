require "pathname"

require_relative "SwiftUtil"
require_relative "MainSwiftCode"
require_relative "AppUtil"

module SwiftScriptingPlatformTool
  class MainSwiftUpdater
    attr_reader :main_code
    attr_reader :target

    def sync(target)
      @target = target

      script_files = Dir.chdir(target[:dir]) {
        Pathname.glob("**/*Script.swift").map {|x| target[:dir] + x }
      }

      scripts = script_files.map {|script_file|
        class_name = script_file.basename(".swift").to_s
        script_name = AppUtil.class_name_to_script_name(class_name)
        {
          class_name: class_name,
          script_name: script_name
        }
      }

      path = target[:main_swift]
      
      lines = SwiftUtil.read(path)
      add_import_lib_if_need(lines)

      MainSwiftCode.write_service_main_if_need(lines)
      range = MainSwiftCode.search_main_code(lines)

      @main_code = MainSwiftCode.new
      main_code.scan_lines(lines[*range])

      for script in scripts
        if main_code.entries.any? {|x| x[:class_name] == script[:class_name] }
          next
        end
        main_code.add_entry(script[:script_name], script[:class_name])
      end

      for entry in main_code.entries
        if scripts.any? {|x| x[:class_name] == entry[:class_name] }
          next
        end
        for remove_entry in main_code.entries
          .select {|x| x[:class_name] == entry[:class_name] }
          main_code.remove_entry(remove_entry[:line_index])
        end
      end

      lines.slice!(*range)
      lines.insert(range[0], *main_code.lines)

      SwiftUtil.write(path, lines)
    end

    def find_import_lib(lines)
      regex = /import SwiftScriptingPlatform/
      lines.any? {|line| regex.match(line) }
    end

    def add_import_lib_if_need(lines)
      if find_import_lib(lines)
        return
      end

      lines.insert(0, "import SwiftScriptingPlatform")
    end
  end
end