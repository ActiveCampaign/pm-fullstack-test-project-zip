class Snapshot < ApplicationRecord
  serialize :data, JSON

  MESSAGE_COUNT = 500

  class << self
    def take
      # Fetches messages from the Postmark API
      messages = fetch_messages

      # Transform fetched messages to a format suitable for the graph
      data = transform_messages_to_nodes_and_links(messages)

      # Create a new Snapshot instance with the transformed data
      create_snapshot(data)
    rescue StandardError => e
      Rails.logger.error "Error fetching messages from Postmark: #{e.message}"
      nil
    end

    private

    def create_snapshot(data)
      create(data: data)
    end

    def transform_messages_to_nodes_and_links(messages)
      SnapshotProcessingService.new(messages).transform_messages
    end

    def fetch_messages
      PostmarkClientService.new(Rails.application.config.x.postmark.api_token).get_messages(MESSAGE_COUNT)
    end
  end
end
