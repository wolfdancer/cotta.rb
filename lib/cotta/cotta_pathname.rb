class Pathname
  def cotta_parent
    parent_path = parent
    if (parent_path == self || parent_path.to_s == '..')
      return nil
    end
    return parent_path
  end
end