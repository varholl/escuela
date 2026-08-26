ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Storage keys are derived from course and lesson names now, so workers
    # sharing one directory would collide over the same paths -- and
    # config/storage.yml is read before the workers are forked, so the split has
    # to happen here.
    parallelize_setup do |worker|
      # Repointing the registered service rather than building a new one: blobs
      # resolve their service by name through a registry, so a replacement
      # object would leave every blob with a blank service_name.
      ActiveStorage::Blob.service.instance_variable_set(
        :@root, Rails.root.join("tmp/storage-#{worker}")
      )
    end

    parallelize_teardown do |worker|
      FileUtils.rm_rf Rails.root.join("tmp/storage-#{worker}")
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Attachments are relocated in the background, so model tests need to be
    # able to run and assert on enqueued jobs too, not only integration ones.
    include ActiveJob::TestHelper

    # The database rolls back between tests; the bucket gets the same courtesy,
    # or one test's file counts as a collision in the next.
    teardown do
      FileUtils.rm_rf ActiveStorage::Blob.service.root if ActiveStorage::Blob.service.respond_to?(:root)
    end

    # Add more helper methods to be used by all tests here...
  end
end
