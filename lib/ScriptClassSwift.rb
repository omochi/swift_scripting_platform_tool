module SwiftScriptingPlatformTool
  class ScriptClassSwift
    attr_reader :class_name
    def initialize(class_name)
      @class_name = class_name
    end
    def render
      str = <<EOT
import SwiftScriptingPlatform

final class #{class_name} : Script {
    init(service: ScriptService) {
        self.service = service
    }
    
    let service: ScriptService
    
    func main(args: [String]) throws {
        print("[#{class_name}.main] args=\\(args)")
    }
}
EOT
      return str
    end
  end
end
