require 'rspec/matchers'
require 'rspec/core'
require 'queue_classic_matchers/version'
require 'queue_classic_matchers/test_worker'
require 'queue_classic_matchers/test_helper'

module QueueClassicMatchers
  # Your code goes here...
  module QueueClassicMatchers::QueueClassicRspec
    def self.find_by_args(queue_name, method, args)
      q = 'SELECT * FROM queue_classic_jobs WHERE q_name = $1 AND method = $2 AND args = $3'
      result = QC.default_conn_adapter.execute q, queue_name, method, JSON.dump(serialized(args))
      result = [result] unless Array === result
      result.compact
    end

    def self.reset!
      QC.default_conn_adapter.execute 'DELETE FROM queue_classic_jobs'
    end

    def self.serialized(args)
      if defined?(QueueClassicPlus) && defined?(Rails)
        ActiveJob::Arguments.serialize(args)
      else
        args
      end
    end
  end

  if defined?(QueueClassicPlus)
    module QueueClassicPlus
      module Job
        def self.included(receiver)
          receiver.class_eval do
            shared_examples_for 'a queueable class' do
              subject { described_class }
              its(:queue) { should be_a(::QC::Queue) }
              it { should respond_to(:do) }
              it { should respond_to(:perform) }

              it 'should be a valid queue name' do
                expect(subject.queue.name).to be_present
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
    'should enqueue in queue classic'
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

  match do |block|
    old_count = expected.queue.count
    block.call
    new_count = expected.queue.count

    @actual = new_count - old_count
    @actual == amount
  end

  match_when_negated do |block|
    old_count = expected.queue.count
    block.call
    new_count = expected.queue.count

    if @amount
      @actual = new_count - old_count
      @actual != amount
    else
      new_count == old_count
    end
  end

  failure_message do
    change = @actual.zero? ? "did not change" : "changed by #{@actual}"
    "should have changed queue size of #{expected} by #{amount} but #{change}"
  end

  failure_message_when_negated do
    chain = @amount.nil? ? "" : " by #{@amount}"
    "should not have changed queue size of #{expected}#{chain}"
  end

  description do
    'should change the queue size'
  end
end


RSpec::Matchers.define :have_scheduled do |*expected_args|
  chain :at do |timestamp|
    @time = timestamp
    @time_info = "at #{@time.to_fs}"
  end

  match do |actual|
    method = "#{actual.to_s}._perform"
    queue_name = actual.queue.name
    results = QueueClassicMatchers::QueueClassicRspec.find_by_args(queue_name, method, expected_args)

    results.any? do |entry|
      if @time
        scheduled_at = entry['scheduled_at']
        scheduled_at = Time.parse(scheduled_at) unless scheduled_at.is_a?(Time) # ActiveRecord < 6
        (scheduled_at.to_i - @time.to_i).abs <= 2
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
    'have scheduled arguments'
  end
end
