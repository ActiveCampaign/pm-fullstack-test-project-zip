class PostmarkClientService
  def initialize(api_token)
    @connection = Postmark::ApiClient.new(api_token)
  end

  def get_messages(count)
    @connection.get_messages(count: count)
  end
end
