# frozen_string_literal: true

module TelegramNotification
  module AfterActivity
    class Base < ApplicationService
      def initialize(entity)
        @entity = entity
      end

      def call
        return unless !@entity.informed && (telegram_id = @entity.athlete&.user&.telegram_id)

        Bot.call('sendMessage', chat_id: telegram_id, text: text, disable_web_page_preview: true, parse_mode: 'Markdown')
        @entity.update!(informed: true)
      rescue StandardError => e
        Rollbar.error e
      end

      private

      def text
        <<~TEXT
          С итоговым протоколом забега вы можете ознакомиться на [нашем сайте](#{routes.activity_url(activity)}).
          Все ваши результаты и статистика доступны по [ссылке](#{routes.athlete_url(@entity.athlete)}).
        TEXT
      end

      def activity
        @activity ||= @entity.activity
      end

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end