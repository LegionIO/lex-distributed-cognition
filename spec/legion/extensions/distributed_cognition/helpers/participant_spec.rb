# frozen_string_literal: true

RSpec.describe Legion::Extensions::DistributedCognition::Helpers::Participant do
  subject(:participant) do
    described_class.new(
      name:             'worker-alpha',
      participant_type: :agent,
      domain:           :reasoning,
      capabilities:     %i[computation retrieval]
    )
  end

  describe '#initialize' do
    it 'assigns a UUID' do
      expect(participant.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores name and type' do
      expect(participant.name).to eq('worker-alpha')
      expect(participant.participant_type).to eq(:agent)
    end

    it 'stores capabilities' do
      expect(participant.capabilities).to eq(%i[computation retrieval])
    end
  end

  describe '#contribute!' do
    it 'increments contribution count' do
      expect { participant.contribute!(success: true) }.to change(participant, :contribution_count).by(1)
    end

    it 'increments success count on success' do
      expect { participant.contribute!(success: true) }.to change(participant, :success_count).by(1)
    end

    it 'increases reliability on success' do
      original = participant.reliability
      participant.contribute!(success: true)
      expect(participant.reliability).to be > original
    end

    it 'decreases reliability on failure' do
      original = participant.reliability
      participant.contribute!(success: false)
      expect(participant.reliability).to be < original
    end
  end

  describe '#capable_of?' do
    it 'returns true for known capability' do
      expect(participant).to be_capable_of(:computation)
    end

    it 'returns false for unknown capability' do
      expect(participant).not_to be_capable_of(:transformation)
    end
  end

  describe '#add_capability' do
    it 'adds a new capability' do
      participant.add_capability(:storage)
      expect(participant.capabilities).to include(:storage)
    end

    it 'does not add duplicates' do
      2.times { participant.add_capability(:computation) }
      expect(participant.capabilities.count(:computation)).to eq(1)
    end
  end

  describe '#success_rate' do
    it 'returns 0.0 with no contributions' do
      expect(participant.success_rate).to eq(0.0)
    end

    it 'computes ratio' do
      3.times { participant.contribute!(success: true) }
      participant.contribute!(success: false)
      expect(participant.success_rate).to eq(0.75)
    end
  end

  describe '#agent?' do
    it 'returns true for agent type' do
      expect(participant).to be_agent
    end
  end

  describe '#artifact?' do
    it 'returns false for agent type' do
      expect(participant).not_to be_artifact
    end
  end

  describe '#reliability_label' do
    it 'returns a symbol' do
      expect(participant.reliability_label).to be_a(Symbol)
    end
  end

  describe '#decay!' do
    it 'reduces reliability' do
      original = participant.reliability
      participant.decay!
      expect(participant.reliability).to be < original
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      hash = participant.to_h
      expect(hash).to include(:id, :name, :participant_type, :reliability, :capabilities)
    end
  end
end
