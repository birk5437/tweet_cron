class Item < ActiveRecord::Base
  acts_as_votable

  def self.get_listings
    # Gets a listing of links from reddit.
    #
    # @param (see LinksComments#info)
    # @option opts [String] :subreddit The subreddit targeted. Can be psuedo-subreddits like `all` or `mod`. If blank, the front page
    # @option opts [new, controversial, top, saved] :page The page to view.
    # @option opts [new, rising] :sort The sorting method. Only relevant on the `new` page
    # @option opts [hour, day, week, month, year] :t The timeframe. Only relevant on some pages, such as `top`. Leave empty for all time
    # @option opts [1..100] :limit The number of things to return.
    # @option opts [String] :after Get things *after* this thing id
    # @option opts [String] :before Get things *before* this thing id
    # @return (see #clear_sessions)

    reddit = Snoo::Client.new
    result = reddit.get_listing(subreddit: "amazontoprated")
    result["data"]["children"].each do |child|
      data = child["data"]

      i = Item.find_or_initialize_by(reddit_id: data["id"])

      i.url = data["url"],
      i.title = data["title"],
      i.ups = data["ups"],
      i.thumbnail = data["thumbnail"]
      price_string = data["title"][/\[\$\d+\.?\d?\d?\]/].to_s.gsub("[", "").gsub("$", "").gsub("]", "")
      i.price = price_string.to_d if price_string.present?
      i.save! if i.price.present? && i.thumbnail != "nsfw"
    end
  end
end
