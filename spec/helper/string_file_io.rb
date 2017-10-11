class StringFileIO < StringIO
  def read(length = 0)
    string
  end

  def write(new_string)
    self.string = new_string
  end
end
