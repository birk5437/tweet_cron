class Post < ActiveRecord::Base

  # TODO: Use Acts as State Machine gem

  validates_presence_of :text, :post_at

  validate :post_at_in_future

  after_save :schedule_job

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

  def schedule_job
    if post_at_changed?
      Resque.remove_delayed(PostSubmitWorker, id)
      Resque::Job.destroy(:tweet_cron, "PostSubmitWorker", id)
      Resque.enqueue_at(post_at, PostSubmitWorker, id)
    end
  end

  def post_at_in_future
    if post_at.present?
      errors.add(:post_at, "must be in the future.") unless post_at >= DateTime.now
    end
  end

end