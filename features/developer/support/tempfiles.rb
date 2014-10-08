def files_to_delete
  @files_to_delete ||= []
end

After do
  files_to_delete.each do |f|
    f.delete if f.exist?
  end
end
