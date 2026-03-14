# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module DistributedCognition
      module Helpers
        class Participant
          include Constants

          attr_reader :id, :name, :participant_type, :domain, :capabilities,
                      :reliability, :contribution_count, :success_count,
                      :created_at, :last_active_at

          def initialize(name:, participant_type:, domain:, capabilities: [])
            @id                 = SecureRandom.uuid
            @name               = name
            @participant_type   = participant_type
            @domain             = domain
            @capabilities       = capabilities
            @reliability        = DEFAULT_RELIABILITY
            @contribution_count = 0
            @success_count      = 0
            @created_at         = Time.now.utc
            @last_active_at     = @created_at
          end

          def contribute!(success:)
            @contribution_count += 1
            @success_count      += 1 if success
            @last_active_at      = Time.now.utc
            adjust_reliability(success)
          end

          def add_capability(capability)
            @capabilities << capability unless @capabilities.include?(capability)
          end

          def capable_of?(capability)
            @capabilities.include?(capability)
          end

          def success_rate
            return 0.0 if @contribution_count.zero?

            @success_count.to_f / @contribution_count
          end

          def reliability_label
            RELIABILITY_LABELS.find { |range, _| range.cover?(@reliability) }&.last || :unknown
          end

          def agent?
            @participant_type == :agent
          end

          def artifact?
            @participant_type == :artifact
          end

          def decay!
            @reliability = (@reliability - DECAY_RATE).clamp(RELIABILITY_FLOOR, RELIABILITY_CEILING)
          end

          def stale?
            (Time.now.utc - @last_active_at) > STALE_THRESHOLD
          end

          def to_h
            {
              id:                 @id,
              name:               @name,
              participant_type:   @participant_type,
              domain:             @domain,
              capabilities:       @capabilities,
              reliability:        @reliability,
              reliability_label:  reliability_label,
              contribution_count: @contribution_count,
              success_rate:       success_rate,
              created_at:         @created_at,
              last_active_at:     @last_active_at
            }
          end

          private

          def adjust_reliability(success)
            delta = success ? REINFORCEMENT_RATE : -PENALTY_RATE
            @reliability = (@reliability + delta).clamp(RELIABILITY_FLOOR, RELIABILITY_CEILING)
          end
        end
      end
    end
  end
end
