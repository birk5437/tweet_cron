class FacebookPost < Post

  def publish
    self.published = true
    self.published_at = DateTime.now
    profile = client.get_object("me")
    # friends = client.get_connections("me", "friends")
    response = client.put_connections("me", "feed", :message => text)
    # TODO: make this generic instead of 'tweet_id'
    self.tweet_id = response["id"]
    save!
  end

  private #####################################################################

  def client
    @graph ||= Koala::Facebook::API.new(linked_account.auth_data["credentials"]["token"])
  end

end