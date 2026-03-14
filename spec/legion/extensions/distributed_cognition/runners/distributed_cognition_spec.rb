# frozen_string_literal: true

RSpec.describe Legion::Extensions::DistributedCognition::Runners::DistributedCognition do
  let(:runner_host) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#register_cognitive_participant' do
    it 'registers a participant' do
      result = runner_host.register_cognitive_participant(
        name: 'worker', participant_type: :agent, domain: :test
      )
      expect(result[:success]).to be true
      expect(result[:participant_id]).to be_a(String)
    end

    it 'rejects invalid type' do
      result = runner_host.register_cognitive_participant(
        name: 'test', participant_type: :invalid, domain: :test
      )
      expect(result[:success]).to be false
    end
  end

  describe '#record_cognitive_contribution' do
    it 'records a contribution' do
      created = runner_host.register_cognitive_participant(
        name: 'worker', participant_type: :agent, domain: :test
      )
      result = runner_host.record_cognitive_contribution(
        participant_id: created[:participant_id],
        contribution_type: :computation, success: true
      )
      expect(result[:success]).to be true
    end
  end

  describe '#find_capable_participants' do
    it 'finds capable participants' do
      runner_host.register_cognitive_participant(
        name: 'worker', participant_type: :agent,
        domain: :test, capabilities: [:computation]
      )
      result = runner_host.find_capable_participants(capability: :computation)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#most_reliable_participants' do
    it 'returns reliable participants' do
      result = runner_host.most_reliable_participants(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#distribution_assessment' do
    it 'returns distribution metrics' do
      result = runner_host.distribution_assessment
      expect(result[:success]).to be true
      expect(result).to include(:distribution_score, :distribution_label)
    end
  end

  describe '#participants_by_type' do
    it 'filters by type' do
      runner_host.register_cognitive_participant(
        name: 'db', participant_type: :artifact, domain: :storage
      )
      result = runner_host.participants_by_type(participant_type: :artifact)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#participants_by_domain' do
    it 'filters by domain' do
      runner_host.register_cognitive_participant(
        name: 'worker', participant_type: :agent, domain: :reasoning
      )
      result = runner_host.participants_by_domain(domain: :reasoning)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#update_distributed_cognition' do
    it 'runs decay and prune cycle' do
      result = runner_host.update_distributed_cognition
      expect(result[:success]).to be true
      expect(result).to include(:pruned)
    end
  end

  describe '#distributed_cognition_stats' do
    it 'returns stats' do
      result = runner_host.distributed_cognition_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_participants, :distribution_score)
    end
  end
end
