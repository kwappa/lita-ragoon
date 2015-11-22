module Lita
  module Handlers
    class Ragoon < Handler
      route(/\Aragoon.*today\Z/i, :today)

      def today(request)
        events = ::Ragoon::Services::Schedule.new.schedule_get_events
        request.reply(render_template('today', events: events))
      end

      Lita.register_handler(self)
    end
  end
end
