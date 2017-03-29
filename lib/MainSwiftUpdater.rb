require "pathname"

require_relative "SwiftUtil"
require_relative "MainSwiftCode"

module SwiftScriptingPlatformTool
  class MainSwiftUpdater
    def sync(target)
      regex = /^([\w\-]*)Script\.swift$/

      script_files = Dir.chdir(target[:dir]) {
        Pathname.glob("**/*Script.swift").map {|x| target[:dir] + x }
      }

      scripts = script_files.map {|script_file|
        m = regex.match(script_file.basename.to_s)
        if m[1].length == 0
          next []
        end
        name = class_name_to_script_name(m[1])
        next [{
          class_name: "#{m[1]}Script",
          script_name: name
        }]
      }.flatten(1)

      path = target[:main_swift]
      
      lines = SwiftUtil.read(path)

      MainSwiftCode.write_service_main_if_need(lines)
      range = MainSwiftCode.search_main_code(lines)

      main_code = MainSwiftCode.new
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

    def class_name_to_script_name(name)
      regex = /(?:[A-Z][a-z]*|[a-z]+|[0-9]+)/
      strs = [ name ]
      strs = strs.map {|x| x.split("-") }.flatten(1)
      strs = strs.map {|x| x.split("_") }.flatten(1)
      strs = strs.map {|x| x.scan(regex) }.flatten(1)
      strs = strs.map {|x| x.downcase }
      return strs.join("-")
    end
  end
end