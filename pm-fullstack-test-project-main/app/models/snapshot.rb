require 'mail'

class Snapshot < ApplicationRecord
  serialize :data, JSON

  class << self
    def take
      begin
        # Fetch messages from Postmark
        messages = fetch_messages
      rescue StandardError => e
        Rails.logger.error "Error fetching messages from Postmark: #{e.message}"
        return nil
      end

      # Transform fetched messages to a format suitable for the graph
      data = transform_messages_to_nodes_and_links(messages)

      # Create a new Snapshot instance with the transformed data
      new(data: data)
    end

    private

    # Fetches messages from the Postmark API
    def fetch_messages
      connection = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)
      connection.get_messages(count: 500)
    end

    # Transforms raw messages into graph-friendly format (nodes, links, topics)
    def transform_messages_to_nodes_and_links(messages)
      nodes = Set.new
      links = Set.new
      topics = Hash.new { |h, k| h[k] = [] }

      messages.each do |message|
        from_name = extract_name(message[:from])

        message[:to].each do |email|
          to_name = email["Name"]
          key = [from_name, to_name].sort.join("-")

          # Add the sender and recipient to the nodes set
          nodes << { id: from_name }
          nodes << { id: to_name }
          # Add the communication link to the links set
          links << { source: from_name, target: to_name }

          # Add the subject to the topics, unless it starts with 'Re: '
          topics[key] << message[:subject] unless message[:subject].start_with?('Re: ')
        end
      end

      # Make the topics unique for each key
      topics.each { |key, value| topics[key] = value.uniq }

      { nodes: nodes.to_a, links: links.to_a, topics: topics }
    end

    def extract_name(message_from_string)
      Mail::Address.new(message_from_string).display_name
    end
  end
end
