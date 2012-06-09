require 'active_support'
require 'active-fedora'
require 'deprecation'
require "hydra-access-controls/version"
require 'hydra/model_mixins'
require 'hydra/datastream'

module Hydra
  extend ActiveSupport::Autoload
  autoload :AccessControlsEnforcement
  autoload :AccessControlsEvaluation
  autoload :Ability
  autoload :RoleMapperBehavior
end
require 'ability'
require 'role_mapper'

