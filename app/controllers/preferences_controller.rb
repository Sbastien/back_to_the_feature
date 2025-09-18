class PreferencesController < ApplicationController
  def update_theme
    theme = params[:theme]
    if %w[light dark].include?(theme)
      session[:theme] = theme
      render json: { status: "success", theme: theme }
    else
      render json: { status: "error" }, status: :unprocessable_entity
    end
  end

  def update_locale
    locale = params[:locale]
    if %w[en fr].include?(locale)
      session[:locale] = locale
      I18n.locale = locale
      render json: { status: "success", locale: locale, message: I18n.t("flash.locale_updated") }
    else
      render json: { status: "error", message: I18n.t("common.error") }, status: :unprocessable_entity
    end
  end
end
