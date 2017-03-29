require "pathname"

module SwiftScriptingPlatformTool
  class EntryPointScript
    
    attr_reader :target_name

    def initialize(target_name)
      @target_name = target_name
    end

    def render
      str = <<EOT
#!/bin/bash
set -ue
dir=$(cd "$(dirname "$0")"; pwd)
name=$(basename "$0")
wd=$(pwd)
cd "$dir"
swift build > /dev/null
cd "$wd"
"$dir/.build/debug/#{target_name}" "$name" "$@"
EOT
      return str
    end

    def self.scan_scripts
      scripts = Pathname(".").children
        .select {|x| x.file? && x.executable? }
      return scripts
    end
  end
end