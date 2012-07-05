require 'active_support'
require 'active-fedora'
require 'deprecation'
require "hydra-access-controls/version"
begin
  require 'hydra/model_mixins'
rescue LoadError
end
require 'hydra/datastream'

module Hydra
  extend ActiveSupport::Autoload
  autoload :AccessControlsEnforcement
  autoload :AccessControlsEvaluation
  autoload :Ability
  autoload :PolicyAwareAbility
  autoload :AdminPolicy
  autoload :RoleMapperBehavior

  module ModelMixins
    autoload :RightsMetadata, 'hydra/model_mixins/rights_metadata'
  end

end
require 'ability'
require 'role_mapper'

