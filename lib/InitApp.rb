require "pathname"
require "json"
require "uri"

require_relative "ShellUtil"
require_relative "Config"

module SwiftScriptingPlatformTool
  class InitApp
    attr_reader :app
    attr_reader :package_swift_path
    
    def initialize(app)
      @app = app
      @package_swift_path = Pathname("Package.swift")
      @package_json = nil
    end
    
    def main(args)
      init_spm
      load_package
      add_swift_scripting_platform_dependency
    end

    def init_spm
      if Pathname("Package.swift").exist?
        return
      end

      ShellUtil.exec(["swift", "package", "init", "--type", "executable"])
    end

    def load_package
      json_str = ShellUtil.exec_capture(["swift", "package", "dump-package"])
      @package_json = JSON.parse(json_str)
    end

    def has_swift_scripting_platform_dependency
      deps = package_json["dependencies"]
      if ! deps
        return false
      end
      config = Config.shared.swift_scripting_platform
      if deps.any? {|x| 
        url_path_str = URI.parse(x["url"]).path
        name = Pathname(url_path_str).basename(".*").to_s
        config[:name] == name
      }
        return true
      end
      return false
    end

    def add_swift_scripting_platform_dependency
      if has_swift_scripting_platform_dependency
        return
      end

      package_swift = package_swift_path.readlines
      config = Config.shared.swift_scripting_platform
      package_swift << [
        "package.dependencies.append(.Package(url: \"#{config[:url]}\",\n",
        "                                     versions: #{config[:version]}))\n",
      ]
      package_swift_path.binwrite(package_swift.join())
    end

  private
    attr_reader :package_json

  end
end