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
        request.reply(
          render_template(
            'events',
            events: format_events(events, request.private_message?),
            date:   Date.today,
          )
        )
      end

      def tomorrow(request)
        events = ::Ragoon::Services::Schedule.new.schedule_get_events(::Ragoon::Services.start_and_end(Date.today + 1))
        request.reply(
          render_template(
            'events',
            events: format_events(events, request.private_message?),
            date:   Date.today + 1,
          )
        )
      end

      Lita.register_handler(self)

      private

      def format_events(events, private)
        events.map { |event| format_event(event, private) }
      end

      def format_event(event, private)
        plan = event[:plan].to_s != '' ? "【#{event[:plan].strip}】" : ''
        period = if event[:allday]
                   '終日'
                 else
                   "#{format_time(event[:start_at])}〜#{format_time(event[:end_at])}"
                 end
        if !private && event[:private]
          title = '予定あり'
          facilities = ''
        else
          title = event[:title]
          facilities = event[:facilities].join(', ')
        end

        {
          plan:       plan,
          period:     period,
          title:      title,
          facilities: facilities,
          private:    event[:private],
        }
      end

      def format_time(time)
        if time.to_s == ''
          ''
        else
          Time.parse(time).localtime.strftime('%R')
        end
      end
    end
  end
end
