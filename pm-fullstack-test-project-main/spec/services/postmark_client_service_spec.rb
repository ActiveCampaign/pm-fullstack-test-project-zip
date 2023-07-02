require 'rails_helper'

RSpec.describe PostmarkClientService, type: :service do
  describe '#get_messages' do
    let(:api_token) { 'dummy-api-token' }
    let(:message_count) { 500 }
    let(:mock_postmark_client) { instance_double('Postmark::ApiClient') }

    before do
      allow(Postmark::ApiClient).to receive(:new).with(api_token).and_return(mock_postmark_client)
    end

    it 'fetches messages from the Postmark API' do
      expected_messages = ['message1', 'message2']

      allow(mock_postmark_client).to receive(:get_messages).with(count: message_count).and_return(expected_messages)

      postmark_client_service = PostmarkClientService.new(api_token)
      result = postmark_client_service.get_messages(message_count)

      expect(result).to eq(expected_messages)
    end
  end
end
