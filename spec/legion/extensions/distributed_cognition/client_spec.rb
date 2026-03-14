# frozen_string_literal: true

RSpec.describe Legion::Extensions::DistributedCognition::Client do
  subject(:client) { described_class.new }

  it 'registers and contributes' do
    created = client.register_cognitive_participant(
      name: 'worker', participant_type: :agent, domain: :test
    )
    result = client.record_cognitive_contribution(
      participant_id: created[:participant_id],
      contribution_type: :computation, success: true
    )
    expect(result[:success]).to be true
  end

  it 'returns stats' do
    result = client.distributed_cognition_stats
    expect(result[:success]).to be true
  end
end
