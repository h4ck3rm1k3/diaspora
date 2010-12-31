#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  render_views
  let(:user)    { Factory.create(:user) }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }


  let(:mock_access_token) { Object.new }

  let(:omniauth_auth) {
    { 'provider' => 'twitter',
      'uid'      => '2',
      'user_info'   => { 'nickname' => 'grimmin' },
      'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }
      }
  }

  before do
    sign_in :user, user
    @controller.stub!(:current_user).and_return(user)
    mock_access_token.stub!(:token => "12345", :secret => "56789")
  end

  describe '#index' do
    let!(:service1) {a = Factory(:service); user.services << a; a}
    let!(:service2) {a = Factory(:service); user.services << a; a}
    let!(:service3) {a = Factory(:service); user.services << a; a}
    let!(:service4) {a = Factory(:service); user.services << a; a}

    it 'displays all connected serivices for a user' do
      get :index
      assigns[:services].should == user.services
    end
  end

  describe '#create' do
    it 'creates a new OmniauthService' do
      request.env['omniauth.auth'] = omniauth_auth
      lambda{
        post :create
      }.should change(user.services, :count).by(1)
    end

    it 'redirects to getting started if the user is getting started' do
      user.getting_started = true
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to getting_started_path(:step => 3)
    end

    it 'redirects to services url' do
      user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to services_url
    end


    it 'creates a twitter service' do
      Service.delete_all
      user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create

      p "what do we have"
      p user.services.first
      user.services.first.class.name.should == "Service"
      user.services.first.provider.should == "twitter"

      # this is called before the "after build is called"
      ##<Service id: nil, _type: "Services::Twitter", user_id: nil, provider: "twitter", uid: "000005", access_token: "123455", access_secret: "987655", nickname:\ "sirrobertking", created_at: nil, updated_at: nil>
      # so that the type is not set.... #TODO

      user.reload
      user.services.first.class.name.should == "Services::Twitter"

    end
  end
