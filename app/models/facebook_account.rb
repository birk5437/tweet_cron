class FacebookAccount < LinkedAccount

  def new_post(params={})
    FacebookPost.new(params)
  end

  def account_type
    "Facebook"
  end

  private #####################################################################

  def set_name
    self.name = auth_data[:info][:name]
  end

end