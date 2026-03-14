# lex-distributed-cognition

Distributed cognition modeling for the LegionIO brain-modeled cognitive architecture.

## What It Does

Tracks how cognitive work is spread across participants — agents, tools/artifacts, and environment components. Measures whether cognition is concentrated in one actor or evenly distributed. Manages participant reliability via contribution history and supports capability-based delegation.

Based on Hutchins' theory that cognition is not just internal to an agent but distributed across systems, tools, and environments.

## Usage

```ruby
client = Legion::Extensions::DistributedCognition::Client.new

# Register participants
client.register_cognitive_participant(
  name: 'planning-agent',
  participant_type: :agent,
  domain: :planning,
  capabilities: [:reasoning, :scheduling]
)
client.register_cognitive_participant(
  name: 'memory-store',
  participant_type: :artifact,
  domain: :memory,
  capabilities: [:storage, :retrieval]
)

# Record a contribution
client.record_cognitive_contribution(
  participant_id: '...',
  contribution_type: :computation,
  success: true
)
# => { success: true, reliability: 0.6, success_rate: 1.0 }

# Find capable participants for a task
client.find_capable_participants(capability: :reasoning)
# => { participants: [...sorted by reliability], count: 1 }

# How evenly is cognitive work distributed?
client.distribution_assessment
# => { distribution_score: 0.72, distribution_label: :well_distributed, load_balance: {...} }

# Periodic maintenance: decay reliability, prune failing participants
client.update_distributed_cognition
```

## Distribution Labels

| Score | Label |
|---|---|
| 0.8 – 1.0 | `:fully_distributed` |
| 0.6 – 0.8 | `:well_distributed` |
| 0.4 – 0.6 | `:partially_distributed` |
| 0.2 – 0.4 | `:concentrated` |
| 0.0 – 0.2 | `:centralized` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
