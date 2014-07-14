module QueueClassicMatchers
  module TestHelper
    def run_queue name, klasses = nil
      q = QC::Queue.new(name)
      worker = TestWorker.new(q_name: name, klasses: klasses)
      while q.count > 0
        worker.work
      end
    end
  end
end
