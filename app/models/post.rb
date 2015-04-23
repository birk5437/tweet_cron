class Post < ActiveRecord::Base

  # TODO: Use Acts as State Machine gem

  validates_presence_of :text

  after_create :post_to_twitter

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = "w9MMAFINKv0UVBTx0e3mdqcoQ"
      config.consumer_secret     = "tzlAgPu6vGZMSYQhanVdH8WVu9IKvjW56WKtipKhMqmdiJSrKD"
      config.access_token        = "3010624916-G2A3RGBeUF6uuUbAyO7ZA3EPt5eYjbVuYGnRwkC"
      config.access_token_secret = "tfd7u4fgUm2MORvVwKWEacnyHIN8ITTgtxOAaVEnfeIoW"
    end
  end

  # TODO: Use Acts as State Machine gem
  def post_to_twitter
    if valid?
      ActiveRecord::Base.transaction do
        self.published = true
        self.published_at = DateTime.now
        tweet = client.update(text)
        self.tweet_id = tweet.id
        save!
      end
    end
  end

  # TODO: Use Acts as State Machine gem
  def delete_from_twitter
    if valid?
      ActiveRecord::Base.transaction do
        self.published = false
        self.published_at = nil
        self.save!
        client.destroy_status(tweet_id) if tweet_id.present?
      end
    end
  end

end