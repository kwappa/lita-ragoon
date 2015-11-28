module Lita
  module Handlers
    class Ragoon < Handler
      config :slack_owner_id
      config :slack_room_id

      route(
        /\Aragoon.*today\Z/i, :today,
        command: true,
        help: {
          t('help.today.syntax') => t('help.today.desc'),
        }
      )

      route(
        /\Aragoon.*tomorrow\Z/i, :tomorrow,
        command: true,
        help: {
          t('help.tomorrow.syntax') => t('help.tomorrow.desc'),
        }
      )

      def today(request)
        events = ::Ragoon::Services::Schedule.new.schedule_get_events
        request.reply(render_template('today', events: events))
      end

      def tomorrow(request)
        events = ::Ragoon::Services::Schedule.new.schedule_get_events(::Ragoon::Services.start_and_end(Date.today + 1))
        request.reply(render_template('today', events: events))
      end

      Lita.register_handler(self)
    end
  end
end
