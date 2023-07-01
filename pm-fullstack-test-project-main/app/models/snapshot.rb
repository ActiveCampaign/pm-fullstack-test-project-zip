class Snapshot < ApplicationRecord
  serialize :data, JSON

  MESSAGE_COUNT = 500

  class << self
    def take
      # Fetch messages from Postmark
      messages = fetch_messages

      # Transform fetched messages to a format suitable for the graph
      data = SnapshotProcessingService.new(messages).transform_messages

      # Create a new Snapshot instance with the transformed data
      create(data: data)
    rescue StandardError => e
      Rails.logger.error "Error fetching messages from Postmark: #{e.message}"
      nil
    end

    private

    # Fetches messages from the Postmark API
    def fetch_messages
      connection = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)
      connection.get_messages(count: MESSAGE_COUNT)
    end
  end
end
