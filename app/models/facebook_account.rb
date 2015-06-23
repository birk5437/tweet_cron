class FacebookAccount < LinkedAccount

  private #####################################################################

  def set_name
    self.name = auth_data[:info][:name]
  end

end