class TwitterAccount < LinkedAccount

  def new_post(params={})
    TwitterPost.new(params)
  end

  def account_type
    "Twitter"
  end

  private #####################################################################

  def set_name
    self.name = auth_data[:screen_name]
  end

end