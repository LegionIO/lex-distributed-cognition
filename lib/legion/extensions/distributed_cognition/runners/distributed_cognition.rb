# frozen_string_literal: true

module Legion
  module Extensions
    module DistributedCognition
      module Runners
        module DistributedCognition
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_cognitive_participant(name:, participant_type:, domain:, capabilities: [], **)
            unless Helpers::Constants::PARTICIPANT_TYPES.include?(participant_type)
              return { success: false, error: :invalid_participant_type,
                       valid_types: Helpers::Constants::PARTICIPANT_TYPES }
            end

            result = engine.register_participant(
              name: name, participant_type: participant_type,
              domain: domain, capabilities: capabilities
            )

            return result unless result.is_a?(Helpers::Participant)

            Legion::Logging.debug "[distributed_cognition] registered #{name} " \
                                  "type=#{participant_type} id=#{result.id[0..7]}"
            { success: true, participant_id: result.id, name: name,
              participant_type: participant_type, domain: domain }
          end

          def record_cognitive_contribution(participant_id:, contribution_type:, success:, context: {}, **)
            result = engine.record_contribution(
              participant_id: participant_id, contribution_type: contribution_type,
              success: success, context: context
            )
            Legion::Logging.debug '[distributed_cognition] contribution ' \
                                  "type=#{contribution_type} success=#{success}"
            result
          end

          def find_capable_participants(capability:, **)
            participants = engine.find_capable(capability: capability)
            Legion::Logging.debug '[distributed_cognition] find_capable ' \
                                  "#{capability} count=#{participants.size}"
            { success: true, capability: capability,
              participants: participants.map(&:to_h), count: participants.size }
          end

          def most_reliable_participants(limit: 5, **)
            participants = engine.most_reliable(limit: limit)
            Legion::Logging.debug "[distributed_cognition] most_reliable count=#{participants.size}"
            { success: true, participants: participants.map(&:to_h), count: participants.size }
          end

          def distribution_assessment(**)
            score = engine.distribution_score
            label = engine.distribution_label
            balance = engine.cognitive_load_balance
            Legion::Logging.debug '[distributed_cognition] distribution ' \
                                  "score=#{score.round(3)} label=#{label}"
            { success: true, distribution_score: score, distribution_label: label,
              load_balance: balance }
          end

          def participants_by_type(participant_type:, **)
            participants = engine.by_type(participant_type: participant_type)
            Legion::Logging.debug "[distributed_cognition] by_type=#{participant_type} " \
                                  "count=#{participants.size}"
            { success: true, participant_type: participant_type,
              participants: participants.map(&:to_h), count: participants.size }
          end

          def participants_by_domain(domain:, **)
            participants = engine.by_domain(domain: domain)
            Legion::Logging.debug "[distributed_cognition] by_domain=#{domain} " \
                                  "count=#{participants.size}"
            { success: true, domain: domain,
              participants: participants.map(&:to_h), count: participants.size }
          end

          def update_distributed_cognition(**)
            engine.decay_all
            pruned = engine.prune_failing
            Legion::Logging.debug "[distributed_cognition] decay+prune pruned=#{pruned}"
            { success: true, pruned: pruned }
          end

          def distributed_cognition_stats(**)
            stats = engine.to_h
            Legion::Logging.debug '[distributed_cognition] stats ' \
                                  "participants=#{stats[:total_participants]}"
            { success: true }.merge(stats)
          end

          private

          def engine
            @engine ||= Helpers::DistributionEngine.new
          end
        end
      end
    end
  end
end
