require "pathname"

require_relative "SwiftUtil"
require_relative "AppUtil"
require_relative "MainSwiftScriptEntry"

module SwiftScriptingPlatformTool
  class MainSwiftSource
    attr_reader :path
    attr_reader :lines
    attr_reader :import_line_index
    attr_reader :script_entries_line_range
    attr_reader :script_entries

    def initialize(path)
      @path = path
      reset
    end

    def reset
      @lines = []
      @import_line_index = nil
      @script_entries_line_range = nil
      @script_entries = []
    end

    def scan
      reset

      @lines = SwiftUtil.read(path)

      scan_import_line
      scan_script_entries
    end

    def scan_import_line
      regex = /^import SwiftScriptingPlatform$/
      lines.each_with_index {|line, index|
        if regex.match(line)
          @import_line_index = index
          break
        end
      }
    end

    def scan_script_entries
      @script_entries_line_range = find_script_entries_lines

      if ! script_entries_line_range
        return
      end

      regex = /register\s*\(\s*\"([\w\-]+)\"\s*,\s*([\w]+)\.self\s*\)/

      for i in 0...script_entries_line_range[1]
        index = script_entries_line_range[0] + i
        m = regex.match(lines[index])
        if m
          entry = MainSwiftScriptEntry.new.tap {|x|
            x.line_index = index
            x.script_name = m[1]
            x.class_name = m[2]
          }
          script_entries.push(entry)
        end
      end
    end

    def save
      SwiftUtil.write(path, lines)
    end

    def find_script_entries_lines
      regex = /ScriptService\.main/
      index = nil
      for i in 0...lines.length
        if regex.match(lines[i])
          index = i
          break
        end
      end
      if index == nil
        return nil
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

    def has_script_class(class_name)
      script_entries.any? {|x|
        x.class_name == class_name
      }
    end

    def insert_import_if_need
      if import_line_index
        return
      end

      insert_lines(0, [ "import SwiftScriptingPlatform" ])
    end

    def add_script_with_class_name(class_name)
      range = script_entries_line_range
      open_indent = SwiftUtil.count_indent(lines[range[0]])
      entry_indent = open_indent + SwiftUtil.tab_indent_size

      script_name = AppUtil.class_name_to_script_name(class_name)

      str = "register(\"#{script_name}\", #{class_name}.self)"
      str = SwiftUtil.indent_right(str, entry_indent)
      insert_lines(range[0] + range[1] - 1, [ str ])
    end

    def remove_script_with_class_name(class_name)
      while true
        index = script_entries.find_index {|x|
          x.class_name == class_name
          }
        if index == nil
          return
        end

        entry = script_entries.slice!(index)
        remove_lines(entry.line_index, 1)
      end
    end

    def insert_lines(index, new_lines)
      lines.insert(index, *new_lines)

      for entry in script_entries
        if index <= entry.line_index
          entry.line_index += new_lines.length
        end
      end
    end

    def remove_lines(index, count)
      lines.slice!(index, count)

      for entry in script_entries
        if index < entry.line_index
          entry.line_index -= count
        end
      end
    end
  end
end
