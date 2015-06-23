SECRET_CONFIG    = YAML::load(open("#{Rails.root}/config/secrets.yml"))
FACEBOOK_CONFIG  = SECRET_CONFIG[Rails.env]["facebook"]