require 'spec_helper'

describe 'feeds' do
  it 'redirects unauthenticated visitors to login page' do
    visit feeds_path
    current_path.should eq new_user_session_path
  end

  context 'authenticated users' do

    before :each do
      @user = FactoryGirl.create :user
      @feed1 = FactoryGirl.create :feed
      @feed2 = FactoryGirl.create :feed
      @user.feeds << @feed1

      # Ensure no actual HTTP calls are made
      FeedClient.any_instance.stub :fetch
      RestClient.stub :get

      login_user_for_feature @user
      visit feeds_path
    end

    it 'shows feeds the user is suscribed to' do
      page.should have_content @feed1.title
    end

    it 'does not show feeds the user is not suscribed to' do
      page.should_not have_content @feed2.title
    end

  end


end