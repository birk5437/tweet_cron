class Post < ActiveRecord::Base

  # TODO: Use Acts as State Machine gem

  # has_and_belongs_to_many :linked_accounts
  belongs_to :linked_account
  attr_accessor :linked_account_ids

  validates_presence_of :text, :linked_account

  validate :post_at_in_future

  after_save :schedule_job

  # TODO: Use Acts as State Machine gem
  def post_to_twitter
    if valid?
      ActiveRecord::Base.transaction do
        self.published = true
        self.published_at = DateTime.now
        save!
        tweet = client.update(text)
        self.tweet_id = tweet.id
        save!
      end
    end
  end

  # TODO: Use Acts as State Machine gem
  def delete_from_twitter
    self.post_at = nil
    if valid?
      ActiveRecord::Base.transaction do
        self.published = false
        self.published_at = nil
        self.save!
        client.destroy_status(tweet_id) if tweet_id.present?
      end
      return true
    else
      return false
    end
  end

  def schedule_job
    if post_at_changed?
      Resque.remove_delayed(PostSubmitWorker, id)
      Resque::Job.destroy(:tweet_cron, "PostSubmitWorker", id)
      Resque.enqueue_at(post_at, PostSubmitWorker, id)
    end
  end

  private #####################################################################

  #custom validation
  def post_at_in_future
    if post_at.present?
      errors.add(:post_at, "must be in the future.") unless post_at >= DateTime.now
    end
  end

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"]
      config.consumer_secret     = SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"]
      config.access_token        = linked_account.auth_data[:oauth_token]
      config.access_token_secret = linked_account.auth_data[:oauth_token_secret]
    end
    # TwitterOAuth::Client.new(
    #     :consumer_key => SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"],
    #     :consumer_secret => SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"],
    #     :token => linked_account.auth_data[:oauth_token],
    #     :secret => linked_account.auth_data[:oauth_token_secret]
    # )
  end

end