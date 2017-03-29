module SwiftScriptingPlatformTool
  class AppUtil
    def self.class_name_to_script_name(str)
      regex = /^([\w\-]*)Script$/
      m = regex.match(str)
      if ! m
        raise "invalid argument: #{str}"
      end
      return camel_case_to_snake_case(m[1], "-")
    end

    def self.script_name_to_class_name(str)
      snake_case_to_camel_case(str) + "Script"
    end

    def self.script_name_to_class_file_name(str)
      script_name_to_class_name(str) + ".swift"
    end

    def self.camel_case_to_snake_case(str, separator="_")
      regex = /(?:[A-Z][a-z]*|[a-z]+|[0-9]+|[_]+)/
      strs = [ str ]
      strs.map! {|x| x.scan(regex) }.flatten!(1)
      strs.map! {|x| x.downcase }
      return strs.join(separator)
    end

    def self.snake_case_to_camel_case(str)
      strs = [ str ]
      strs.map! {|x| x.split("-") }.flatten!(1)
      strs.map! {|x| x.split("_") }.flatten!(1)
      strs.map! {|x| x.length > 0 ? [x] : [] }.flatten!(1)
      strs.map! {|x| x[0].upcase + x[1..-1].downcase }
      return strs.join
    end
  end
end