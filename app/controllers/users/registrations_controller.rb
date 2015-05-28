class Users::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = "There was an error with the recaptcha below. Please re-verify."
      flash.delete :recaptcha_error
      render :new
    end
  end

  def new
    super
  end

  def edit
    super
  end
end
