require 'rails_helper'

RSpec.describe Snapshot, type: :model do
  let(:mock_messages) do
    [
      {
        from: '"Mariia Borel" <mariia@example.com>',
        to: [
          { 'Name' => 'Viktor Zaremba', 'Email' => 'viktor@example.com' }
        ],
        subject: 'TopicA'
      },
      {
        from: '"Mariia Borel" <mariia@example.com>',
        to: [
          { 'Name' => 'Viktor Zaremba', 'Email' => 'viktor@example.com' }
        ],
        subject: 'TopicB'
      },
      {
        from: '"Viktor Zaremba" <viktor@example.com>',
        to: [
          { 'Name' => 'Mariia Borel', 'Email' => 'mariia@example.com' }
        ],
        subject: 'TopicC'
      },
      {
        from: '"Viktor Zaremba" <viktor@example.com>',
        to: [
          { 'Name' => 'Mariia Borel', 'Email' => 'mariia@example.com' }
        ],
        subject: 'Re: TopicA'
      }
    ]
  end

  let(:transformed_data) do
    {
      'nodes' => [
        { 'id' => 'Mariia Borel' },
        { 'id' => 'Viktor Zaremba' }
      ],
      'links' => [
        { 'source' => 'Mariia Borel', 'target' => 'Viktor Zaremba' },
        { 'source' => 'Viktor Zaremba', 'target' => 'Mariia Borel' }
      ],
      'topics' => {
        'Mariia Borel-Viktor Zaremba' => ['TopicA', 'TopicB', 'TopicC']
      }
    }
  end


  let(:snapshot) { Snapshot.take }

  before do
    allow(Postmark::ApiClient).to receive(:new).and_return(double('Postmark::ApiClient', get_messages: mock_messages))
    allow(SnapshotProcessingService).to receive(:new).with(mock_messages).and_return(double(transform_messages: transformed_data))
  end

  describe '.take' do
    context 'when fetch_messages is successful' do
      it 'returns a new Snapshot instance' do
        expect(snapshot).to be_a(Snapshot)
      end

      it 'has the correct transformed data' do
        expect(snapshot.data).to eq(transformed_data)
      end
    end

    context 'when fetch_messages fails' do
      let(:error_msg) { 'API error' }

      before do
        allow(Postmark::ApiClient).to receive(:new).and_return(double('Postmark::ApiClient')).and_raise(StandardError, error_msg)
      end

      it 'logs an error and returns nil' do
        expect(Rails.logger).to receive(:error).with('Error fetching messages from Postmark: API error')
        expect(snapshot).to be_nil
      end
    end
  end
end
