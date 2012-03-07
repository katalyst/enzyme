class Object

  def blank?
    nil? || try(:empty?)
  end

end
