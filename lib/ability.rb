# Allows you to use CanCan to control access to Models
require 'cancan'
class Ability
  include CanCan::Ability
  include Hydra::Ability
  if Hydra.config[:permissions][:policy_aware]
    include Hydra::PolicyAwareAbility
  end
end
