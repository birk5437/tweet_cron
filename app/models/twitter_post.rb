class TwitterPost < Post

  def publish
    if valid?
      ActiveRecord::Base.transaction do
        self.published = true
        self.published_at = DateTime.now
        save!
        tweet = client.update(text)
        self.tweet_id = tweet.id
        save!
        return true
      end
    else
      return false
    end
  end

  private #####################################################################

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"]
      config.consumer_secret     = SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"]
      config.access_token        = linked_account.auth_data[:oauth_token]
      config.access_token_secret = linked_account.auth_data[:oauth_token_secret]
    end
  end

end