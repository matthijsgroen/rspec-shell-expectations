require 'tmpdir'
require 'pathname'

Before do
  @dir = Dir.mktmpdir
end

After do
  FileUtils.remove_entry_secure @dir
end

def workfolder
  Pathname.new(@dir)
end
