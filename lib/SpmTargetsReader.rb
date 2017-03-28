module SwiftScriptingPlatformTool
  class SpmTargetsReader
    def read
      target_dirs = Pathname("Sources").children.select {|x| x.directory? }
      if target_dirs.length == 0
        target_dirs = [ Pathname("Sources") ]
      end
      
      targets = target_dirs.map {|dir|
        target = read_target_dir(dir)
        target ? [ target ] : []
      }.flatten(1)
     
      if targets.length == 0
        puts "error: no main.swift found"
        return
      end

      return targets
    end

    def read_target_dir(dir)
      Dir.chdir(dir) do
        mains = Pathname.glob("**/main.swift").map {|x| dir + x }
        if mains.length == 1
          return {
            dir: dir,
            main_swift: mains[0]
            }
        end
        if mains.length >= 2
          puts "warning: multiple main.swift found in #{dir.to_s}"
        end
        return nil
      end
    end

  end
end