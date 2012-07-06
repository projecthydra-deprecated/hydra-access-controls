require 'spec_helper'

describe Ability do
  before do
    class Rails; end
    class User; end
    class Devise; end
    class Hydra::SuperuserAttributes; end
    module Blacklight
      module Exceptions
        class InvalidSolrID < StandardError
          def initialize(opt)
          end
        end
      end
    end
    Devise.stub(:authentication_keys).and_return(['email'])
    Hydra::SuperuserAttributes.stub(:silenced)
    Hydra::SuperuserAttributes.stub(:silenced=)
    @solr_resp = stub("solr response")
    Blacklight.stub(:solr).and_return(stub("solr", :find=>@solr_resp))
    
    Rails.stub(:root).and_return('spec/support')
    Rails.stub(:env).and_return('test')

    Hydra.stub(:config).and_return({:permissions=>{
      :catchall => "access_t",
      :discover => {:group =>"discover_access_group_t", :individual=>"discover_access_person_t"},
      :read => {:group =>"read_access_group_t", :individual=>"read_access_person_t"},
      :edit => {:group =>"edit_access_group_t", :individual=>"edit_access_person_t"},
      :owner => "depositor_t",
      :embargo_release_date => "embargo_release_date_dt"
    }})
  end

  context "for a not-signed in user" do
    before do
      User.any_instance.stub(:email).and_return(nil)
      User.any_instance.stub(:new_record?).and_return(true)
      User.any_instance.stub(:is_being_superuser?).and_return(false)
    end
    subject { Ability.new(nil) }
    it "should call custom_permissions" do
      Ability.any_instance.should_receive(:custom_permissions)
      subject.can?(:delete, 7)
    end
    it "should be able to read objects that are public" do
      @solr_resp.stub(:docs).and_return([{'read_access_group_t' =>['public']}])
      public_object = ModsAsset.new
      subject.can?(:read, public_object).should be_true
    end
    it "should not be able to read objects that are registered" do
      registered_object = ModsAsset.new
      @solr_resp.stub(:docs).and_return([{'read_access_group_t' =>['registered']}])
      subject.can?(:read, registered_object).should_not be_true
    end
    it "should not be able to create objects" do
      subject.can?(:create, :any).should be_false
    end
  end
  context "for a signed in user" do
    subject { Ability.new(stub("user", :email=>'archivist1@example.com', :new_record? => false, :is_being_superuser? =>false)) }
    it "should be able to read objects that are public" do
      public_object = ModsAsset.new
      @solr_resp.stub(:docs).and_return([{'read_access_group_t' =>['public']}])
      subject.can?(:read, public_object).should be_true
    end
    it "should be able to read objects that are registered" do
      registered_object = ModsAsset.new
      @solr_resp.stub(:docs).and_return([{'read_access_group_t' =>['registered']}])
      subject.can?(:read, registered_object).should be_true
    end
    it "should be able to create objects" do
      subject.can?(:create, :any).should be_true
    end
  end
end
