module SwiftScriptingPlatformTool
  class SwiftUtil
    @@indent_regex = /^([ ]*)(.*)$/
    @@tab_indent_size = 4

    def self.tab_indent_size
      return @@tab_indent_size
    end

    def self.read(path)
      return path.readlines.map {|x| x.rstrip }
    end

    def self.write(path, lines)
      path.binwrite(lines.map {|x| x + "\n" }.join)
    end

    def self.normalize_indent(str)
      return str.gsub("\t", " " * @@tab_indent_size)
    end

    def self.split_indent(str)
      str = normalize_indent(str)
      m = @@indent_regex.match(str)
      return [m[1], m[2]]
    end

    def self.count_indent(str)
      return split_indent(str)[0].length
    end

    def self.comment_in(str)
      indent, body = split_indent(str)
      if body.length > 0
        return "// #{indent}#{body}"
      end
      return "#{indent}#{body}"
    end

    def self.indent_right(str, num)
      return " " * num + str
    end
  end
end