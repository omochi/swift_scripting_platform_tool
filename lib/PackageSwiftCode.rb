require "json"
require "uri"
require "pathname"

require_relative "ShellUtil"

module SwiftScriptingPlatformTool
  class PackageSwiftCode
    attr_reader :path
    attr_reader :json
    def initialize
      @path = Pathname("Package.swift")
      @json = nil
    end
    def load
      str = ShellUtil.exec_capture(["swift", "package", "dump-package"])
      @json = JSON.parse(str)
    end
    def init_spm_if_need
      if path.exist?
        return
      end

      ShellUtil.exec(["swift", "package", "init", "--type", "executable"])
    end
    def has_scripting_lib
      config = Config.shared.scripting_lib

      deps = json["dependencies"] || []
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

      lines = SwiftUtil.read(path)
      lines.concat [
        "package.dependencies.append(.Package(url: \"#{config[:url]}\",",
        "                                     versions: #{config[:version]}))",
      ]
      SwiftUtil.write(path, lines)
    end
  end
end
