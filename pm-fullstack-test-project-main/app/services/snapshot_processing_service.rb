require 'mail'

class SnapshotProcessingService
  attr_accessor :messages

  def initialize(messages)
    @messages = messages
  end

  # Transforms raw messages into graph-friendly format (nodes, links, topics)
  def transform_messages
    nodes, links = Set.new, Set.new
    topics = Hash.new { |h, k| h[k] = [] }

    messages.each do |message|
      nodes, links, topics = extract_node_link_topic(message, nodes, links, topics)
    end

    # Make the topics unique for each key
    topics.each { |key, value| topics[key] = value.map { |v| v.gsub("Re: ", "") }.uniq }

    { nodes: nodes.to_a, links: links.to_a, topics: topics }
  end

  private

  def extract_node_link_topic(message, nodes, links, topics)
    from_name = extract_name(message[:from])

    message[:to].each do |email|
      to_name = email["Name"]
      key = [from_name, to_name].sort.join("-")

      # Add the sender and recipient to the nodes set
      nodes = add_to_nodes(nodes, from_name, to_name)

      # Add the communication link to the links set
      links = add_to_links(links, from_name, to_name)

      # Add the subject to the topics
      topics = add_to_topics(topics, key, message[:subject])
    end

    [nodes, links, topics]
  end

  def add_to_nodes(nodes, from_name, to_name)
    nodes.add({ id: from_name })
    nodes.add({ id: to_name })
    nodes
  end

  def add_to_links(links, from_name, to_name)
    links.add({ source: from_name, target: to_name })
    links
  end

  def add_to_topics(topics, key, subject)
    topics[key] << subject
    topics
  end

  def extract_name(message_from_string)
    Mail::Address.new(message_from_string).display_name
  end
end
