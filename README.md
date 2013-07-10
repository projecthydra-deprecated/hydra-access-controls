# hydra-access-controls

The hydra-access-controls gem provides access controls models and functionality for Hydra Heads.  See the [hydra-head](http://github.com/projecthydra/hydra-head) gem and the [Hydra Project](http://projecthydra.org) website for more info.

## Installation

Add this line to your application's Gemfile:

    gem 'hydra-access-controls'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydra-access-controls

## Usage

### Policy-based Enforcement (or Collecton-level enforcement)

If you have Policy-based enforcement enabled, then objects will inherit extra GRANT permissions from AdminPolicy objects they are linked to with an isGovernedBy RDF relationship (stored in solr as _is_governed_by_s_ field).  This allows you to grant discover/read/edit access for a whole set of objects by changing the policy they are governed by.

AdminPolicy objects store their inheritable rightsMetadata in a datastream called defaultRights.  This datastream uses the regular Hydra rightsMetadata schema.  Each AdminPolicy object also has its own rightsMetadata datasream, like all other Hydra assets, which specifies who is able to _edit_ the Policy or _use_ it (associate it with objects).

Object-level permissions and Policy-level permissions are combined to produce the list of Individuals & Groups who have access to the object.  This means that if _either_ the object's rightsMetadata or the Policy's defaultRights grants access to an Individual or Group, that access will be allowed.

* Currently, an asset can have only one Policy associated with it -- you can't associate objects with multiple policies

To turn on Policy-based enforcement, 

* include the `Hydra::PolicyAwareAbility` module in your `Ability` class (Make sure to include it _after_ `Hydra::Ability` because it overrides some of the methods provided by that module.)
* include the `Hydra::PolicyAwareAccessControlsEnforcement` module into any appropriate Controllers (or into `ApplicationController`)
 
app/models/ability.rb

```ruby
# Allows you to use CanCan to control access to Models
require 'cancan'
class Ability
  include CanCan::Ability
  include Hydra::Ability
  include Hydra::PolicyAwareAbility
end
```

app/controllers/catalog_controller.rb

```ruby
class CatalogController < ApplicationController  

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement

  # ...
end
```

### Modifying solr field names for enforcement

Hydra uses its own set of default solr field names to track rights-related metadata in solr.  If you want to use your own field names, you can change them in your Hydra config.  You will also have to modify the permissions response handler in your solrconfig.xml to return those fields.

# config/initializers/hydra_config.rb

```ruby
Hydra.configure(:shared) do |config|
  # ... other stuff ...
  config[:permissions] = {
    :catchall => "access_t",
    :discover => {:group =>"discover_access_group_t", :individual=>"discover_access_person_t"},
    :read => {:group =>"read_access_group_t", :individual=>"read_access_person_t"},
    :edit => {:group =>"edit_access_group_t", :individual=>"edit_access_person_t"},
    :owner => "depositor_t",
    :embargo_release_date => "embargo_release_date_dt"
  }
  config[:permissions][:inheritable] = {
    :catchall => "inheritable_access_t",
    :discover => {:group =>"inheritable_discover_access_group_t", :individual=>"inheritable_discover_access_person_t"},
    :read => {:group =>"inheritable_read_access_group_t", :individual=>"inheritable_read_access_person_t"},
    :edit => {:group =>"inheritable_edit_access_group_t", :individual=>"inheritable_edit_access_person_t"},
    :owner => "inheritable_depositor_t",
    :embargo_release_date => "inheritable_embargo_release_date_dt"
  }
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

    $ git submodule init
    $ git submodule update
    $ rake jetty:config
    $ rake jetty:start
    $ rake spec
