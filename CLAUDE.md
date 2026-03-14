# lex-distributed-cognition

**Level 3 Documentation** — Parent: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Distributed cognition modeling for the LegionIO cognitive architecture. Tracks cognitive participants (agents, artifacts, environment components) and their contributions to shared cognitive tasks. Computes distribution evenness using Shannon entropy, manages participant reliability via reinforcement/decay, and identifies capable participants for delegation.

Based on Hutchins' distributed cognition theory: cognition is not just in the head but distributed across agents, tools, and the environment.

## Gem Info

- **Gem name**: `lex-distributed-cognition`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::DistributedCognition`
- **Location**: `extensions-agentic/lex-distributed-cognition/`

## File Structure

```
lib/legion/extensions/distributed_cognition/
  distributed_cognition.rb      # Top-level requires
  version.rb                    # VERSION = '0.1.0'
  client.rb                     # Client class
  helpers/
    constants.rb                # PARTICIPANT_TYPES, CONTRIBUTION_TYPES, reliability labels, distribution labels
    participant.rb              # Participant object with reliability tracking
    distribution_engine.rb      # Engine: registration, contribution tracking, distribution scoring
  runners/
    distributed_cognition.rb    # Runner module: all public methods
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_PARTICIPANTS` | 100 | Participant registry cap |
| `MAX_ARTIFACTS` | 200 | (informational) |
| `MAX_CONTRIBUTIONS` | 1000 | Rolling contribution log cap |
| `PARTICIPANT_TYPES` | `[:agent, :artifact, :environment]` | Valid participant categories |
| `CONTRIBUTION_TYPES` | `[:computation, :storage, :retrieval, :transformation, :communication]` | Valid contribution types |
| `REINFORCEMENT_RATE` | 0.1 | Reliability increase per successful contribution |
| `PENALTY_RATE` | 0.15 | Reliability decrease per failed contribution |
| `DECAY_RATE` | 0.02 | Passive reliability decay per cycle |
| `DEFAULT_RELIABILITY` | 0.5 | Initial participant reliability |
| `DISTRIBUTION_LABELS` | range hash | `fully_distributed / well_distributed / partially_distributed / concentrated / centralized` |

## Runners

All methods in `Legion::Extensions::DistributedCognition::Runners::DistributedCognition`.

| Method | Key Args | Returns |
|---|---|---|
| `register_cognitive_participant` | `name:, participant_type:, domain:, capabilities: []` | `{ success:, participant_id:, name:, participant_type:, domain: }` |
| `record_cognitive_contribution` | `participant_id:, contribution_type:, success:, context: {}` | `{ success:, participant_id:, reliability:, success_rate: }` |
| `find_capable_participants` | `capability:` | `{ success:, participants:, count: }` |
| `most_reliable_participants` | `limit: 5` | `{ success:, participants:, count: }` |
| `distribution_assessment` | — | `{ success:, distribution_score:, distribution_label:, load_balance: }` |
| `participants_by_type` | `participant_type:` | `{ success:, participants:, count: }` |
| `participants_by_domain` | `domain:` | `{ success:, participants:, count: }` |
| `update_distributed_cognition` | — | `{ success:, pruned: }` (decay + prune failing) |
| `distributed_cognition_stats` | — | Full stats hash |

## Helpers

### `Participant`
Attributes: `id`, `name`, `participant_type`, `domain`, `capabilities`, `reliability`, `contribution_count`, `success_count`, `created_at`, `last_active_at`. Key methods: `contribute!(success:)` (adjusts reliability by reinforcement/penalty), `add_capability(capability)`, `capable_of?(capability)`, `success_rate`, `reliability_label`, `decay!`, `stale?`.

### `DistributionEngine`
Central store with `@participants` hash, `@contributions` array, `@history` array. Key methods:
- `register_participant(...)`: validates type, creates Participant, evicts oldest if at capacity
- `record_contribution(...)`: finds participant, calls `contribute!`, logs to `@contributions`
- `find_capable(capability:)`: filters by capability, sorts by reliability descending
- `distribution_score`: Shannon entropy of contribution counts across participants (0=centralized, 1=fully distributed)
- `cognitive_load_balance`: map of participant_id to contribution_count
- `decay_all`: calls `decay!` on all participants
- `prune_failing`: removes participants with reliability ≤ 0.05

## Integration Points

- `register_cognitive_participant` called when lex-mesh agents register
- `record_cognitive_contribution` tracks which agents/artifacts contributed to each lex-tick phase
- `distribution_assessment` provides governance metrics for lex-governance oversight
- `find_capable_participants` supports lex-swarm capability-based role assignment

## Development Notes

- Distribution score uses Shannon entropy normalized by log2(participant_count) → range [0, 1]
- Eviction on capacity removes the participant with the oldest `last_active_at`
- `prune_failing` threshold is 0.05, not the `RELIABILITY_FLOOR` constant (which is 0.0)
