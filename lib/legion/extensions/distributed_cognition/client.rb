# frozen_string_literal: true

module Legion
  module Extensions
    module DistributedCognition
      class Client
        include Runners::DistributedCognition

        def initialize(engine: nil)
          @engine = engine || Helpers::DistributionEngine.new
        end
      end
    end
  end
end
