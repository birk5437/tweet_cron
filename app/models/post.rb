class Post < ActiveRecord::Base

  # TODO: Use Acts as State Machine gem

  belongs_to :linked_account
  attr_accessor :linked_account_ids

  before_validation :set_type
  validates_presence_of :text, :linked_account

  validate :post_at_in_future

  after_save :schedule_job

  # TODO: Use Acts as State Machine gem
  #override in subclass
  def publish
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
    if post_at.present? && post_at_changed?
      errors.add(:post_at, "must be in the future.") unless post_at >= DateTime.now
    end
  end

  def client

    # TwitterOAuth::Client.new(
    #     :consumer_key => SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"],
    #     :consumer_secret => SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"],
    #     :token => linked_account.auth_data[:oauth_token],
    #     :secret => linked_account.auth_data[:oauth_token_secret]
    # )
  end

  def set_type
    if linked_account.present?
      self.type = "#{linked_account.account_type}Post"
    end
  end

end