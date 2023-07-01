require 'rails_helper'

RSpec.describe SnapshotProcessingService, type: :service do
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

  let(:service) { SnapshotProcessingService.new(mock_messages) }
  let(:result) { service.transform_messages }

  describe '#transform_messages' do
    it 'transforms the messages into correct nodes' do
      expect(result[:nodes]).to contain_exactly({ id: 'Mariia Borel' }, { id: 'Viktor Zaremba' })
    end

    it 'transforms the messages into correct links' do
      expect(result[:links]).to contain_exactly({ source: 'Mariia Borel', target: 'Viktor Zaremba' }, { source: 'Viktor Zaremba', target: 'Mariia Borel' })
    end

    it 'transforms the messages into correct topics' do
      expect(result[:topics]).to include('Mariia Borel-Viktor Zaremba' => ['TopicA', 'TopicB', 'TopicC'])
    end

    context 'when messages are empty' do
      let(:mock_messages) { [] }

      it 'handles empty messages gracefully' do
        expect(result[:nodes]).to be_empty
        expect(result[:links]).to be_empty
        expect(result[:topics]).to be_empty
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
        expect(result[:nodes]).to contain_exactly(
          { id: 'John Doe' },
          { id: 'Jane Doe' },
          { id: 'Robert Roe' },
          { id: 'No Name' },
          { id: 'Receiver' }
        )
        expect(result[:links]).to contain_exactly(
          { source: 'John Doe', target: 'Jane Doe' },
          { source: 'John Doe', target: 'Robert Roe' },
          { source: 'No Name', target: 'Receiver' }
        )
        expect(result[:topics]).to include(
          'Jane Doe-John Doe' => ['Group Chat'],
          'John Doe-Robert Roe' => ['Group Chat'],
          'No Name-Receiver' => ['Anonymous Message']
        )
      end
    end
  end
end
