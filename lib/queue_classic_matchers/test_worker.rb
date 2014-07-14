module QueueClassicMatchers
  class TestWorker < QC::Worker
    def initialize(options)
      @klasses = options.delete(:klasses)
      super(options)
    end

    def handle_failure(job, e)
      raise e
    end

    def process(queue, job)
      # Skip over task not matching klasses
      k = job[:method].split('.').first
      if @klasses.nil? || klasses.include?(k)
        super
      else
        # Uncomment for debugging
        # puts "Skipping #{job[:method]}. Klassed: #{klasses.inspect}"
        queue.delete(job[:id])
      end
    end

    def klasses
      @klasses.map(&:to_s)
    end
  end
end
