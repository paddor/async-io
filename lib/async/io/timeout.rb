require 'timeout'

module Async
  module IO
    module Timeout
      Error = ::Timeout::Error

      module_function

      def timeout(sec, klass = nil, message = nil)   #:yield: +sec+
        return yield(sec) if sec == nil or sec.zero?

        message ||= "execution expired".freeze
        klass   ||= Error

        stopper = nil
        task = Async annotation: 'timeout task' do
          # warn "#{self.class}: starting task with timeout"
          yield.tap do
            # warn "#{self.class}: task with timeout finished in time"
            stopper.stop if stopper
          end
        end

        stopper = Async annotation: 'stopper' do |t|
          t.sleep sec

          if task&.running?
            # warn "#{self.class}: expired. stopping task"
            e = klass.new message
            task.send :fail!, e
          end
        end

        task.wait
      rescue
        # warn "#{self.class}: raising error #{$!.inspect}"
        raise
      end

    end
  end
end
