class ApplicationController < ActionController::Base
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :avatar, :first_name, :last_name, :email, :password, :password_confirmation, :current_password ])
  end

  private

  def store_user_location!
    store_location_for(:user, request.fullpath) unless request.fullpath.include?("/users")
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end
end
