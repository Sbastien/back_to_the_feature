module ApplicationHelper
  def localized_time_ago(time)
    if I18n.locale == :fr
      "#{t('time.ago')} #{time_ago_in_words(time)}"
    else
      "#{time_ago_in_words(time)} #{t('time.ago')}"
    end
  end
end
