# frozen_string_literal: true

module Legion
  module Extensions
    module DistributedCognition
      module Helpers
        class DistributionEngine
          include Constants

          attr_reader :history

          def initialize
            @participants = {}
            @contributions = []
            @history = []
          end

          def register_participant(name:, participant_type:, domain:, capabilities: [])
            unless PARTICIPANT_TYPES.include?(participant_type)
              return { success: false, reason: :invalid_participant_type }
            end

            evict_oldest if @participants.size >= MAX_PARTICIPANTS

            participant = Participant.new(
              name:             name,
              participant_type: participant_type,
              domain:           domain,
              capabilities:     capabilities
            )
            @participants[participant.id] = participant
            record_history(:registered, participant.id)
            participant
          end

          def record_contribution(participant_id:, contribution_type:, success:, context: {})
            participant = @participants[participant_id]
            return { success: false, reason: :not_found } unless participant

            unless CONTRIBUTION_TYPES.include?(contribution_type)
              return { success: false, reason: :invalid_contribution_type }
            end

            participant.contribute!(success: success)
            store_contribution(participant_id, contribution_type, success, context)
            record_history(:contributed, participant_id)
            build_contribution_result(participant, contribution_type)
          end

          def find_capable(capability:)
            @participants.values.select { |p| p.capable_of?(capability) }
                                .sort_by { |p| -p.reliability }
          end

          def by_type(participant_type:)
            @participants.values.select { |p| p.participant_type == participant_type }
          end

          def by_domain(domain:)
            @participants.values.select { |p| p.domain == domain }
          end

          def most_reliable(limit: 5)
            @participants.values.sort_by { |p| -p.reliability }.first(limit)
          end

          def distribution_score
            return 0.0 if @contributions.empty? || @participants.size <= 1

            counts = @contributions.each_with_object(Hash.new(0)) do |contrib, hash|
              hash[contrib[:participant_id]] += 1
            end
            compute_evenness(counts.values)
          end

          def distribution_label
            score = distribution_score
            DISTRIBUTION_LABELS.find { |range, _| range.cover?(score) }&.last || :unknown
          end

          def cognitive_load_balance
            return {} if @participants.empty?

            @participants.transform_values(&:contribution_count)
          end

          def decay_all
            @participants.each_value(&:decay!)
          end

          def prune_failing
            failing_ids = @participants.select { |_id, p| p.reliability <= 0.05 }.keys
            failing_ids.each { |id| @participants.delete(id) }
            failing_ids.size
          end

          def to_h
            {
              total_participants:  @participants.size,
              agent_count:         by_type(participant_type: :agent).size,
              artifact_count:      by_type(participant_type: :artifact).size,
              environment_count:   by_type(participant_type: :environment).size,
              total_contributions: @contributions.size,
              distribution_score:  distribution_score,
              distribution_label:  distribution_label,
              history_count:       @history.size
            }
          end

          private

          def store_contribution(participant_id, contribution_type, success, context)
            entry = {
              participant_id:    participant_id,
              contribution_type: contribution_type,
              success:           success,
              context:           context,
              at:                Time.now.utc
            }
            @contributions << entry
            @contributions.shift while @contributions.size > MAX_CONTRIBUTIONS
          end

          def build_contribution_result(participant, contribution_type)
            {
              success:           true,
              participant_id:    participant.id,
              contribution_type: contribution_type,
              reliability:       participant.reliability,
              success_rate:      participant.success_rate
            }
          end

          def compute_evenness(counts)
            total = counts.sum.to_f
            return 0.0 if total.zero?

            proportions = counts.map { |c| c / total }
            max_entropy = Math.log2(counts.size)
            return 1.0 if max_entropy.zero?

            entropy = -proportions.sum { |p| p.positive? ? p * Math.log2(p) : 0.0 }
            (entropy / max_entropy).clamp(0.0, 1.0)
          end

          def evict_oldest
            oldest_id = @participants.min_by { |_id, p| p.last_active_at }&.first
            @participants.delete(oldest_id) if oldest_id
          end

          def record_history(event, subject_id)
            @history << { event: event, subject_id: subject_id, at: Time.now.utc }
            @history.shift while @history.size > MAX_HISTORY
          end
        end
      end
    end
  end
end
