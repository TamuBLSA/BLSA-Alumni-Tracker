# frozen_string_literal: true

class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  class InvalidEmailError < StandardError; end

  def google_oauth2
    admin = Admin.from_google(**from_google_params)

    if admin.present?
      # store the email so we can track the session
      # puts "Email: #{from_google_params[:email]}"
      session[:email] = from_google_params[:email]
      session[:pfp] = from_google_params[:avatar_url]

      flash[:success] = t('devise.omniauth_callbacks.success', kind: 'Google')
      sign_in_and_redirect(admin, event: :authentication)
    else
      flash[:alert] = t('devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized.")
      redirect_to(new_admin_session_path)
    end
  rescue InvalidEmailError
    flash[:alert] = 'Please use a personal email address. You will lose access to your tamu email address over time.'
    redirect_to(new_admin_session_path)
  end

  protected

  def after_omniauth_failure_path_for(_scope)
    new_admin_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  private

  def from_google_params
    @from_google_params ||= begin
      raise(InvalidEmailError) if auth.info.email.downcase.end_with?('@tamu.edu')

      {
        uid: auth.uid,
        email: auth.info.email,
        full_name: auth.info.name,
        avatar_url: auth.info.image
      }
    end
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
