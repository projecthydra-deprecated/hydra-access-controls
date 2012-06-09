require 'active-fedora'
class ModsAsset < ActiveFedora::Base
  include Hydra::ModelMixins::RightsMetadata
  has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

end
