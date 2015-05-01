require 'rspec/matchers'
require "queue_classic_matchers/version"
require "queue_classic_matchers/test_worker"
require "queue_classic_matchers/test_helper"

module QueueClassicMatchers
  # Your code goes here...
  module QueueClassicMatchers::QueueClassicRspec
    def self.find_by_args(queue_name, method, args)
      q = "SELECT * FROM queue_classic_jobs WHERE q_name = $1 AND method = $2 AND args::text = $3"
      result = QC.default_conn_adapter.execute q, queue_name, method, JSON.dump(args)
      result = [result] unless Array === result
      result.compact
    end

    def self.reset!
      QC.default_conn_adapter.execute "DELETE FROM queue_classic_jobs"
    end
  end

  if defined?(QueueClassicPlus)
    module QueueClassicPlus
      module Job
        def self.included(receiver)
          receiver.class_eval do
            shared_examples_for "a queueable class" do
              subject { described_class }
              its(:queue) { should be_a(::QC::Queue) }
              it { should respond_to(:do) }
              it { should respond_to(:perform) }

              it "should be a valid queue name" do
                subject.queue.name.should be_present
              end
            end
          end
        end
      end
    end

    if RSpec.respond_to?(:configure)
      RSpec.configure do |c|
        c.include QueueClassicMatchers::QueueClassicPlus::Job, type: :job
      end
    end
  end
end

RSpec::Matchers.define :have_queued do |*expected|
  match do |actual|
    method = "#{actual.to_s}._perform"
    queue_name = actual.queue.name
    results = QueueClassicMatchers::QueueClassicRspec.find_by_args(queue_name, method, expected)
    results.size > 0
  end

  failure_message do |actual|
    "should have queued #{actual.inspect} with #{expected.inspect}"
  end

  failure_message_when_negated do |actual|
    "should not have queued #{actual.inspect}"
  end

  description do
    "should enqueue in queue classic"
  end
end

RSpec::Matchers.define :have_queue_size_of do |expected|
  match do |actual|
    actual.queue.count == expected
  end

  failure_message do |actual|
    "should have a queue size of #{expected}. (#{actual.queue.count} instead)"
  end

  failure_message_when_negated do |actual|
    "should not have a queue size of #{expected}."
  end

  description do
    "should have a queue size of #{expected}"
  end
end

RSpec::Matchers.define :change_queue_size_of do |expected|
  supports_block_expectations

  chain :by do |amount|
    @amount = amount
  end

  def amount
    @amount || 1
  end

  match do |actual|
    old = expected.queue.count
    actual.call
    new = expected.queue.count

    new - old == (amount || 1)
  end

  failure_message do |actual|
    "should have a queue size of #{expected} by #{amount}"
  end

  failure_message_when_negated do |actual|
    "should not have a queue size of #{expected} by #{amount}"
  end

  description do
    "should change the queue size"
  end
end


RSpec::Matchers.define :have_scheduled do |*expected_args|
  chain :at do |timestamp|
    @time = timestamp
    @time_info = "at #{@time}"
  end

  match do |actual|
    method = "#{actual.to_s}._perform"
    queue_name = actual.queue.name
    results = QueueClassicMatchers::QueueClassicRspec.find_by_args(queue_name, method, expected_args)

    results.any? do |entry|
      time_matches = if @time
        (Time.parse(entry['scheduled_at']).to_i - @time.to_i).abs <= 2
      else
        true
      end
    end
  end

  failure_message do |actual|
    ["expected that #{actual} would have [#{expected_args.join(', ')}] scheduled", @time_info].join(' ')
  end

  failure_message_when_negated do |actual|
    ["expected that #{actual} would not have [#{expected_args.join(', ')}] scheduled", @time_info].join(' ')
  end

  description do
    "have scheduled arguments"
  end
end
