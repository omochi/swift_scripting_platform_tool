require "shellwords"

module SwiftScriptingPlatformTool
  class ShellUtil

    def self.exec(cmd)
      if cmd.is_a?(Array)
        return exec(cmd.shelljoin)
      end

      system(cmd)

      if ! $?.success?
        raise "exec failled: [#{cmd}]"
      end
    end

    def self.exec_capture(cmd)
      if cmd.is_a?(Array)
        return exec_capture(cmd.shelljoin)
      end

      ret = `#{cmd}`
      
      if ! $?.success?
        raise "exec failed: [#{cmd}]"
      end

      return ret
    end

  end
end