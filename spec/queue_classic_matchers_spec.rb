require 'spec_helper'

describe QueueClassicMatchers do
  class TestJob < QueueClassicPlus::Base
    @queue = :low
    def self.perform
    end
  end

  describe 'have_queued' do
    it 'works with no arguments' do
      expect(TestJob).to_not have_queued
      TestJob.do
      expect(TestJob).to have_queued
    end

    it 'works with argument' do
      args = [1, { foo: true }, [:baz, 'bar']]
      expect(TestJob).to_not have_queued(*args)
      TestJob.do *args
      expect(TestJob).to have_queued(*args)
      expect(TestJob).to_not have_queued(2)
    end
  end

  describe 'have_queue_size_of' do
    it 'works' do
      expect(TestJob).to have_queue_size_of(0)
      expect(TestJob).to_not have_queue_size_of(1)

      TestJob.do

      expect(TestJob).to have_queue_size_of(1)
      expect(TestJob).to_not have_queue_size_of(0)
    end
  end

  describe 'have_scheduled' do
    it 'works' do
      Timecop.freeze do
        t0 = Time.now
        TestJob.enqueue_perform_in 60 * 60, 1

        expect(TestJob).to have_scheduled(1).at(t0 + 60 * 60)
        expect(TestJob).not_to have_scheduled(1).at(t0 + 60 * 60 - 3)
      end
    end
  end

  describe 'change_queue_size_of' do
    it 'works' do
      expect { TestJob.do }.to change_queue_size_of(TestJob)
      expect { TestJob.do }.to change_queue_size_of(TestJob).by(1)
      expect { TestJob.do; TestJob.do }.to change_queue_size_of(TestJob).by(2)
      expect { TestJob }.to_not change_queue_size_of(TestJob)
      expect { TestJob.do; TestJob.do }.to_not change_queue_size_of(TestJob).by(1)
      expect do
        expect { TestJob.do; TestJob.do }.to_not change_queue_size_of(TestJob)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end
