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

    it 'works wiht argument' do
      expect(TestJob).to_not have_queued(1)
      TestJob.do 1
      expect(TestJob).to have_queued(1)
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
      end
    end
  end
end
