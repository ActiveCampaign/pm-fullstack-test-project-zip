require 'mail'

class Snapshot < ApplicationRecord
  serialize :data, JSON

  def self.take
    connection = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)

    # Fetch outbound messages
    messages = connection.get_messages(count: 500) # Adjust the count based on your requirements

    # Transform the messages into nodes and links
    nodes = []
    links = []
    messages.each do |message|
      from_address = extract_address(message[:from])
      to_emails = message[:to]
      to_emails.each do |email|
        to_address = email["Name"]
        nodes << { id: from_address }
        nodes << { id: to_address }
        links << { source: from_address, target: to_address }
      end
    end

    # Ensure unique nodes
    nodes.uniq! { |node| node[:id] }

    # Create data for Snapshot
    data = {
      nodes: nodes,
      links: links
    }

    Snapshot.new(data: data)
  end

  def self.extract_address(address_string)
    Mail::Address.new(address_string).display_name
  end
end
