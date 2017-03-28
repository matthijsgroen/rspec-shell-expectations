class StringFileIO < StringIO
  def read
    string
  end

  def write(new_string)
    self.string = new_string
  end
end
