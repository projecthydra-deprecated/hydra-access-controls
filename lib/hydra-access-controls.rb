require 'active_support'
require 'active-fedora'
require 'cancan'
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
  autoload :RoleMapperBehavior

  module ModelMixins
    autoload :RightsMetadata, 'hydra/model_mixins/rights_metadata'
  end

  # This error is raised when a user isn't allowed to access a given controller action.
  # This usually happens within a call to AccessControlsEnforcement#enforce_access_controls but can be
  # raised manually.
  class AccessDenied < ::CanCan::AccessDenied; end

end
require 'ability'
require 'role_mapper'

