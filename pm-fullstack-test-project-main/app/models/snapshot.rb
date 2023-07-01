require 'mail'

class Snapshot < ApplicationRecord
  serialize :data, JSON

  MESSAGE_COUNT = 500

  class << self
    def take
      # Fetch messages from Postmark
      messages = fetch_messages

      # Transform fetched messages to a format suitable for the graph
      data = transform_messages_to_nodes_and_links(messages)

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

    # Transforms raw messages into graph-friendly format (nodes, links, topics)
    def transform_messages_to_nodes_and_links(messages)
      nodes, links = Set.new, Set.new
      topics = Hash.new { |h, k| h[k] = [] }

      messages.each do |message|
        nodes, links, topics = process_message(message, nodes, links, topics)
      end

      # Make the topics unique for each key
      topics.each { |key, value| topics[key] = value.map { |v| v.gsub("Re: ", "") }.uniq }

      { nodes: nodes.to_a, links: links.to_a, topics: topics }
    end

    def process_message(message, nodes, links, topics)
      from_name = extract_name(message[:from])

      message[:to].each do |email|
        to_name = email["Name"]
        key = [from_name, to_name].sort.join("-")

        # Add the sender and recipient to the nodes set
        nodes << { id: from_name }
        nodes << { id: to_name }
        # Add the communication link to the links set
        links << { source: from_name, target: to_name }

        # Add the subject to the topics
        topics[key] << message[:subject]
      end

      [nodes, links, topics]
    end

    def extract_name(message_from_string)
      Mail::Address.new(message_from_string).display_name
    end
  end
end
