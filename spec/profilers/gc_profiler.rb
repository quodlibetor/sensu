module Sensu
  module Extension
    class GCProfiler < Profiler
      def name
        'gc_profiler'
      end

      def description
        'creates a ruby garbage collection report'
      end

      def post_init
        GC::Profiler.enable
        @timer = EM::PeriodicTimer.new(60) do
          report
        end
      end

      def report_path
        '/tmp/gc_profiler.' + ::Process.pid.to_s + '.log'
      end

      def report
        result = GC::Profiler.result
        unless result.empty?
          EM::defer do
            File.open(report_path, 'a') do |file|
              file.puts(result)
            end
          end
        end
        GC::Profiler.clear
      end

      def stop
        @timer.cancel
        logger.info('garbage collection profiler generated a report', {
          :path => report_path
        })
        yield
      end
    end
  end
end
