# frozen_string_literal: true

module Legion
  module Extensions
    module DistributedCognition
      module Helpers
        module Constants
          MAX_PARTICIPANTS = 100
          MAX_ARTIFACTS = 200
          MAX_CONTRIBUTIONS = 1000
          MAX_HISTORY = 300

          DEFAULT_RELIABILITY = 0.5
          RELIABILITY_FLOOR = 0.0
          RELIABILITY_CEILING = 1.0

          REINFORCEMENT_RATE = 0.1
          PENALTY_RATE = 0.15
          DECAY_RATE = 0.02
          STALE_THRESHOLD = 120

          PARTICIPANT_TYPES = %i[agent artifact environment].freeze

          CONTRIBUTION_TYPES = %i[
            computation storage retrieval transformation communication
          ].freeze

          RELIABILITY_LABELS = {
            (0.8..)     => :highly_reliable,
            (0.6...0.8) => :reliable,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :unreliable,
            (..0.2)     => :failing
          }.freeze

          DISTRIBUTION_LABELS = {
            (0.8..)     => :fully_distributed,
            (0.6...0.8) => :well_distributed,
            (0.4...0.6) => :partially_distributed,
            (0.2...0.4) => :concentrated,
            (..0.2)     => :centralized
          }.freeze
        end
      end
    end
  end
end
