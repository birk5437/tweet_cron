class PostSubmitWorker

  @queue = :tweet_cron

  def self.perform(post_id)
    current_date = DateTime.now
    post_to_submit = Post.find(post_id)
    post_at_date = DateTime.parse(post_to_submit.post_at.to_s)

    dates_match = %w{ day month year hour minute}.map{ |i|
      current_date.utc.send(i) == post_at_date.utc.send(i)
    }.all?


    if dates_match
      post_to_submit.publish
    else
      raise "ERROR - post_at doesn't match DateTime.now!  Post ID #{post_id} - #{current_date.to_s}, #{post_at_date.to_s}, #{dates_match} "
    end

  end
end
