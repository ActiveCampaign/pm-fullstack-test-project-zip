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
        from: 'Viktor Zaremba <viktor@example.com>',
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

  before do
    allow(Postmark::ApiClient).to receive(:new).and_return(double('Postmark::ApiClient', get_messages: mock_messages))
  end

  describe '.take' do
    context 'when fetch_messages is successful' do
      it 'returns a new Snapshot instance' do
        snapshot = Snapshot.take
        expect(snapshot).to be_a(Snapshot)
      end

      it 'transforms the messages into nodes, links, and topics correctly' do
        snapshot = Snapshot.take
        data = snapshot.data.with_indifferent_access

        expect(data[:nodes]).to contain_exactly(
          { id: 'Mariia Borel' },
          { id: 'Viktor Zaremba' }
        )
        expect(data[:links]).to contain_exactly(
          { source: 'Mariia Borel', target: 'Viktor Zaremba' },
          { source: 'Viktor Zaremba', target: 'Mariia Borel' }
        )
        expect(data[:topics]).to include(
          'Mariia Borel-Viktor Zaremba' => ['TopicA', 'TopicB', 'TopicC']
        )
      end

      context 'when message is empty' do
        let(:mock_messages) { [] }

        it 'handles empty messages gracefully' do
          snapshot = Snapshot.take
          data = snapshot.data.with_indifferent_access

          expect(data[:nodes]).to be_empty
          expect(data[:links]).to be_empty
          expect(data[:topics]).to be_empty
        end
      end

      context 'when messages have unusual formats' do
        let(:mock_messages) do
          [
            {
              from: 'John Doe <john@example.com>',
              to: [
                { 'Name' => 'Jane Doe', 'Email' => 'jane@example.com' },
                { 'Name' => 'Robert Roe', 'Email' => 'robert@example.com' }
              ],
              subject: 'Group Chat'
            },
            {
              from: 'No Name <noname@example.com>',
              to: [
                { 'Name' => 'Receiver', 'Email' => 'receiver@example.com' }
              ],
              subject: 'Anonymous Message'
            }
          ]
        end

        it 'handles unusual formats correctly' do
          snapshot = Snapshot.take
          data = snapshot.data.with_indifferent_access

          expect(data[:nodes]).to contain_exactly(
            { id: 'John Doe' },
            { id: 'Jane Doe' },
            { id: 'Robert Roe' },
            { id: 'No Name' },
            { id: 'Receiver' }
          )
          expect(data[:links]).to contain_exactly(
            { source: 'John Doe', target: 'Jane Doe' },
            { source: 'John Doe', target: 'Robert Roe' },
            { source: 'No Name', target: 'Receiver' }
          )
          expect(data[:topics]).to include(
            'Jane Doe-John Doe' => ['Group Chat'],
            'John Doe-Robert Roe' => ['Group Chat'],
            'No Name-Receiver' => ['Anonymous Message']
          )
        end
      end
    end

    context 'when fetch_messages fails' do
      let(:error_msg) { 'API error' }

      it 'logs an error and returns nil' do
        instance = Postmark::ApiClient.new('api_token')

        allow(instance).to receive(:get_messages)
          .with(any_args).and_raise(StandardError.new(error_msg))

        expect(Rails.logger).to receive(:error).with('Error fetching messages from Postmark: API error')

        snapshot = Snapshot.take

        expect(snapshot).to be_nil
      end
    end
  end
end
