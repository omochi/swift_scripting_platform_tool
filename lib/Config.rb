module SwiftScriptingPlatformTool
  class Config
    attr_accessor :swift_scripting_platform
    attr_accessor :swift_scripting_platform_version

    def initialize
      @swift_scripting_platform = {
        name: "SwiftScriptingPlatform",
        url: "https://github.com/omochi/SwiftScriptingPlatform.git",
        version: %("0.1.0" ..< "0.2.0")
      }
    end

    @@shared = nil

    def self.shared
      if ! @@shared
        @@shared = Config.new
      end
      return @@shared
    end
  end
end