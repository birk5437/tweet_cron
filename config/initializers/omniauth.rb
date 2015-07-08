OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_CONFIG["app_id"], FACEBOOK_CONFIG["app_secret"], :scope => 'email,publish_actions'
end


# <script>
#   window.fbAsyncInit = function() {
#     FB.init({
#       appId      : '1778345315725288',
#       xfbml      : true,
#       version    : 'v2.3'
#     });
#   };

#   (function(d, s, id){
#      var js, fjs = d.getElementsByTagName(s)[0];
#      if (d.getElementById(id)) {return;}
#      js = d.createElement(s); js.id = id;
#      js.src = "//connect.facebook.net/en_US/sdk.js";
#      fjs.parentNode.insertBefore(js, fjs);
#    }(document, 'script', 'facebook-jssdk'));
# </script>