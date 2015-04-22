class Post < ActiveRecord::Base
  validates_presence_of :text

  def post_to_twitter
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "w9MMAFINKv0UVBTx0e3mdqcoQ"
      config.consumer_secret     = "tzlAgPu6vGZMSYQhanVdH8WVu9IKvjW56WKtipKhMqmdiJSrKD"
      config.access_token        = "3010624916-G2A3RGBeUF6uuUbAyO7ZA3EPt5eYjbVuYGnRwkC"
      config.access_token_secret = "tfd7u4fgUm2MORvVwKWEacnyHIN8ITTgtxOAaVEnfeIoW"
    end

    client.update(text)

  end

end