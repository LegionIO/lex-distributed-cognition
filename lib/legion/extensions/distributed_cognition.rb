# frozen_string_literal: true

require 'legion/extensions/distributed_cognition/version'
require 'legion/extensions/distributed_cognition/helpers/constants'
require 'legion/extensions/distributed_cognition/helpers/participant'
require 'legion/extensions/distributed_cognition/helpers/distribution_engine'
require 'legion/extensions/distributed_cognition/runners/distributed_cognition'
require 'legion/extensions/distributed_cognition/client'

module Legion
  module Extensions
    module DistributedCognition
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
