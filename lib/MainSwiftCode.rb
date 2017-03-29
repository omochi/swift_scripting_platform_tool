require_relative "SwiftUtil"

module SwiftScriptingPlatformTool
  class MainSwiftCode
    attr_accessor :lines
    attr_accessor :entries
    
    def initialize
      @lines = []
      @entries = []
    end

    def scan_lines(lines)
      @lines = lines

      regex = /register\s*\(\s*\"([\w\-]+)\"\s*,\s*([\w]+)\.self\s*\)/

      @entries = lines.each.with_index.map {|line, index|
        m = regex.match(line)
        m ? [ {
          script_name: m[1],
          class_name: m[2],
          line_index: index
          } ] : []
      }.flatten(1)
    end

    def add_entry(script_name, class_name)
      index = lines.length - 1
      @entries.push({
        script_name: script_name,
        class_name: class_name,
        line_index: index
      })

      open_indent = SwiftUtil.count_indent(lines[0])
      entry_indent = open_indent + SwiftUtil.tab_indent_size

      str = "register(\"#{script_name}\", #{class_name}.self)"
      str = SwiftUtil.indent_right(str, entry_indent)
      lines.insert(index, str)
    end

    def remove_entry(index)
      lines.slice!(index)

      @entries = entries.map {|entry|
        if entry[:line_index] == index
          next []
        end
        if entry[:line_index] > index
          entry[:line_index] -= 1
          next [ entry ]
        end
        next [ entry ]
      }.flatten(1)
    end

    def self.search_main_code(lines)
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

    def self.write_service_main_if_need(lines)
      range = search_main_code(lines)
      if range == false
        lines.map! {|x| SwiftUtil.comment_in(x) }
        
        lines.concat [
          "",
          "try ScriptService.main { register in",
          "}"
        ]
      end
    end



  end
end