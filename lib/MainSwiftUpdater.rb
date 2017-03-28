require "pathname"

require_relative "SwiftUtil"

module SwiftScriptingPlatformTool
  class MainSwiftUpdater
    
    def find_service_main(path)
      lines = SwiftUtil.read(path)
      regex = /ScriptService\.main/
      index = nil
      for i in 0...lines.length
        if regex.match(lines[i])
          index = i
          break
        end
      end
      if index == nil
        return false
      end

      indent = SwiftUtil.count_indent(lines[index])
      end_index = index
      for i in (index + 1)...lines.length
        line_indent, line_body = SwiftUtil.split_indent(lines[i])
        if line_body.length == 0 || indent < line_indent.length
          end_index = i
        else
          break
        end
      end

      return [index, (end_index - index) + 2]
    end

    def write_service_main_if_need(path)
      lines = SwiftUtil.read(path)
      range = find_service_main(path)
      if range == false
        lines = lines.map {|x| SwiftUtil.comment_in(x) }
        
        lines.concat [
          "",
          "try ScriptService.main { register in",
          "}"
        ]

        SwiftUtil.write(path, lines)
      end
    end

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
      
      write_service_main_if_need(path)
      range = find_service_main(path)

      lines = SwiftUtil.read(path)
      main_lines = lines[range[0], range[1]]

      new_main_lines = sync_lines_with_scripts(main_lines, scripts)

      lines.slice!(range[0], range[1])
      lines.insert(range[0], *new_main_lines)

      SwiftUtil.write(path, lines)
    end

    def class_name_to_script_name(name)
      regex = /(?:[A-Z][a-z]*|[a-z]+|[0-9]+)/
      strs = [ name ].map {|x| x.split("-") }.flatten(1)
      strs = strs.map {|x| x.split("_") }.flatten(1)
      strs = strs.map {|x| x.scan(regex) }.flatten(1)
      strs = strs.map {|x| x.downcase }
      return strs.join("-")
    end

    def sync_lines_with_scripts(lines, scripts)
      scripts = scripts.select {|script|
        cls = Regexp.escape(script[:class_name])
        regex = /register\s*\(.*,\s*#{cls}\.self\s*\)/
        !lines.any? {|x| regex.match(x) }
      }

      open_indent = SwiftUtil.count_indent(lines[0])
      entry_indent = open_indent + SwiftUtil.tab_indent_size

      for script in scripts
        name = script[:script_name]
        cls = script[:class_name]
        str = "register(\"#{name}\", #{cls}.self)"
        str = SwiftUtil.indent_right(str, entry_indent)
        lines.insert(lines.length - 1, str)
      end

      return lines
    end
  end
end