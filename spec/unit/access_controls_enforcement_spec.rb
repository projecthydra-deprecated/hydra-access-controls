require 'spec_helper'
# Need way to find way to stub current_user and RoleMapper in order to run these tests

describe Hydra::AccessControlsEnforcement do
  before do
    class MockController
      include Hydra::AccessControlsEnforcement
      attr_accessor :params
      
      def user_key
        current_user.email
      end

      def session
      end
    end
  end
  subject { MockController.new }
  describe "enforce_access_controls" do
    describe "when the method exists" do
      it "should call the method" do
        subject.params = {:action => :index}
        subject.enforce_access_controls.should be_true
      end
    end
    describe "when the method doesn't exist" do
      it "should not call the method, but should return true" do
        subject.params = {:action => :facet}
        subject.enforce_access_controls.should be_true
      end
    end
  end
  describe "enforce_show_permissions" do
    it "should allow a user w/ edit permissions to view an embargoed object" do
      user = User.new :email=>'testuser@example.com'
      user.stub(:is_being_superuser?).and_return false
      RoleMapper.stub(:roles).with(user.email).and_return(["archivist"])
      subject.stub(:current_user).and_return(user)
      subject.should_receive(:can?).with(:edit, nil).and_return(true)
      subject.stub(:can?).with(:read, nil).and_return(true)
      subject.instance_variable_set :@permissions_solr_document, SolrDocument.new({"edit_access_person_t"=>["testuser@example.com"], "embargo_release_date_dt"=>(Date.parse(Time.now.to_s)+2).to_s})

      subject.params = {}
      subject.should_receive(:load_permissions_from_solr) #This is what normally sets @permissions_solr_document
      lambda {subject.send(:enforce_show_permissions, {}) }.should_not raise_error Hydra::AccessDenied
    end
    it "should prevent a user w/o edit permissions from viewing an embargoed object" do
      user = User.new :email=>'testuser@example.com'
      user.stub(:is_being_superuser?).and_return false
      RoleMapper.stub(:roles).with(user.email).and_return([])
      subject.stub(:current_user).and_return(user)
      subject.should_receive(:can?).with(:edit, nil).and_return(false)
      subject.stub(:can?).with(:read, nil).and_return(true)
      subject.params = {}
      subject.instance_variable_set :@permissions_solr_document, SolrDocument.new({"edit_access_person_t"=>["testuser@example.com"], "embargo_release_date_dt"=>(Date.parse(Time.now.to_s)+2).to_s})
      subject.should_receive(:load_permissions_from_solr) #This is what normally sets @permissions_solr_document
      lambda {subject.send(:enforce_show_permissions, {})}.should raise_error Hydra::AccessDenied, "This item is under embargo.  You do not have sufficient access privileges to read this document."
    end
  end
  describe "apply_gated_discovery" do
    before(:each) do
      @stub_user = User.new :email=>'archivist1@example.com'
      @stub_user.stub(:is_being_superuser?).and_return false
      RoleMapper.stub(:roles).with(@stub_user.email).and_return(["archivist","researcher"])
      subject.stub(:current_user).and_return(@stub_user)
      @solr_parameters = {}
      @user_parameters = {}
    end
    it "should set query fields for the user id checking against the discover, access, read fields" do
      subject.send(:apply_gated_discovery, @solr_parameters, @user_parameters)
      ["discover","edit","read"].each do |type|
        @solr_parameters[:fq].first.should match(/#{type}_access_person_t\:#{@stub_user.email}/)      
      end
    end
    it "should set query fields for all roles the user is a member of checking against the discover, access, read fields" do
      subject.send(:apply_gated_discovery, @solr_parameters, @user_parameters)
      ["discover","edit","read"].each do |type|
        @solr_parameters[:fq].first.should match(/#{type}_access_group_t\:archivist/)        
        @solr_parameters[:fq].first.should match(/#{type}_access_group_t\:researcher/)        
      end
    end
    
    describe "for superusers" do
      it "should return superuser access level" do
        stub_user = User.new(:email=>'suzie@example.com')
        stub_user.stub(:is_being_superuser?).and_return true
        RoleMapper.stub(:roles).with(stub_user.email).and_return(["archivist","researcher"])
        subject.stub(:current_user).and_return(stub_user)
        subject.send(:apply_gated_discovery, @solr_parameters, @user_parameters)
        ["discover","edit","read"].each do |type|    
          @solr_parameters[:fq].first.should match(/#{type}_access_person_t\:\[\* TO \*\]/)          
        end
      end
      it "should not return superuser access to non-superusers" do
        stub_user = User.new(:email=>'suzie@example.com')
        stub_user.stub(:is_being_superuser?).and_return false
        RoleMapper.stub(:roles).with(stub_user.email).and_return(["archivist","researcher"])
        subject.stub(:current_user).and_return(stub_user)
        subject.send(:apply_gated_discovery, @solr_parameters, @user_parameters)
        ["discover","edit","read"].each do |type|
          @solr_parameters[:fq].should_not include("#{type}_access_person_t\:\[\* TO \*\]")              
        end
      end
    end

  end
  
  describe "exclude_unwanted_models" do
    before(:each) do
      stub_user = User.new :email=>'archivist1@example.com'
      stub_user.stub(:is_being_superuser?).and_return false
      subject.stub(:current_user).and_return(stub_user)
      @solr_parameters = {}
      @user_parameters = {}
    end
    it "should set solr query parameters to filter out FileAssets" do
      subject.send(:exclude_unwanted_models, @solr_parameters, @user_parameters)
      @solr_parameters[:fq].should include("-has_model_s:\"info:fedora/afmodel:FileAsset\"")  
    end
  end
end


