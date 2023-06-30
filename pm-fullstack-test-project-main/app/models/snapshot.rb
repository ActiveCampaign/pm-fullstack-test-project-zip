require 'mail'

class Snapshot < ApplicationRecord
  serialize :data, JSON

  def self.take
    connection = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)

    # See usage docs at https://github.com/wildbit/postmark-gem
    data = {}

    Snapshot.new(data: data)
  end

  def self.extract_address(address_string)
    Mail::Address.new(address_string).display_name
  end
end
