module EventMachine
  module Synchrony
    class Multi
      include EventMachine::Deferrable

      attr_reader :requests, :responses

      def initialize
        @requests = []
        @responses = {:callback => {}, :errback => {}}
      end

      def add(name, conn)
        fiber = Fiber.current
        conn.callback { @responses[:callback][name] = conn; check_progress(fiber) }
        conn.errback  { @responses[:errback][name] = conn;  check_progress(fiber) }

        @requests.push(conn)
      end

      def perform
        Fiber.yield
      end

      protected

        def check_progress(fiber)
          if (@responses[:callback].size + @responses[:errback].size) == @requests.size
            succeed

            # continue processing
            fiber.resume(self)
          end
        end
    end
  end
end
