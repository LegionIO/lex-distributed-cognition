# frozen_string_literal: true

RSpec.describe Legion::Extensions::DistributedCognition::Helpers::DistributionEngine do
  subject(:engine) { described_class.new }

  let(:agent) do
    engine.register_participant(
      name: 'worker-alpha', participant_type: :agent,
      domain: :reasoning, capabilities: %i[computation retrieval]
    )
  end

  describe '#register_participant' do
    it 'creates and stores a participant' do
      result = agent
      expect(result).to be_a(Legion::Extensions::DistributedCognition::Helpers::Participant)
    end

    it 'rejects invalid participant types' do
      result = engine.register_participant(
        name: 'test', participant_type: :invalid, domain: :test
      )
      expect(result[:success]).to be false
    end

    it 'records history' do
      agent
      expect(engine.history.size).to eq(1)
    end
  end

  describe '#record_contribution' do
    it 'records a successful contribution' do
      result = engine.record_contribution(
        participant_id: agent.id, contribution_type: :computation, success: true
      )
      expect(result[:success]).to be true
      expect(result[:reliability]).to be > 0.5
    end

    it 'returns error for unknown participant' do
      result = engine.record_contribution(
        participant_id: 'bad', contribution_type: :computation, success: true
      )
      expect(result[:success]).to be false
    end

    it 'rejects invalid contribution types' do
      result = engine.record_contribution(
        participant_id: agent.id, contribution_type: :invalid, success: true
      )
      expect(result[:success]).to be false
    end
  end

  describe '#find_capable' do
    it 'finds participants with capability' do
      agent
      results = engine.find_capable(capability: :computation)
      expect(results.size).to eq(1)
    end

    it 'returns empty for unknown capability' do
      agent
      results = engine.find_capable(capability: :transformation)
      expect(results).to be_empty
    end
  end

  describe '#by_type' do
    it 'filters by participant type' do
      agent
      engine.register_participant(
        name: 'db', participant_type: :artifact, domain: :storage
      )
      agents = engine.by_type(participant_type: :agent)
      expect(agents.size).to eq(1)
    end
  end

  describe '#by_domain' do
    it 'filters by domain' do
      agent
      results = engine.by_domain(domain: :reasoning)
      expect(results.size).to eq(1)
    end
  end

  describe '#most_reliable' do
    it 'returns sorted by reliability' do
      agent
      other = engine.register_participant(
        name: 'worker-beta', participant_type: :agent, domain: :reasoning
      )
      3.times { engine.record_contribution(participant_id: other.id, contribution_type: :computation, success: true) }
      results = engine.most_reliable(limit: 2)
      expect(results.first.reliability).to be >= results.last.reliability
    end
  end

  describe '#distribution_score' do
    it 'returns 0.0 with no contributions' do
      expect(engine.distribution_score).to eq(0.0)
    end

    it 'returns higher score for even distribution' do
      other = engine.register_participant(
        name: 'worker-beta', participant_type: :agent, domain: :reasoning
      )
      3.times do
        engine.record_contribution(participant_id: agent.id, contribution_type: :computation, success: true)
        engine.record_contribution(participant_id: other.id, contribution_type: :computation, success: true)
      end
      expect(engine.distribution_score).to be > 0.5
    end
  end

  describe '#distribution_label' do
    it 'returns a symbol' do
      expect(engine.distribution_label).to be_a(Symbol)
    end
  end

  describe '#decay_all' do
    it 'reduces reliability of all participants' do
      original = agent.reliability
      engine.decay_all
      expect(agent.reliability).to be < original
    end
  end

  describe '#prune_failing' do
    it 'removes very unreliable participants' do
      agent
      30.times { agent.decay! }
      pruned = engine.prune_failing
      expect(pruned).to be >= 0
    end
  end

  describe '#to_h' do
    it 'returns summary stats' do
      agent
      stats = engine.to_h
      expect(stats[:total_participants]).to eq(1)
      expect(stats).to include(:distribution_score, :agent_count)
    end
  end
end
