require "spec_helper"

describe PrivatePostsController do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/private_posts").to route_to("private_posts#index")
    end

    it "routes to #new" do
      expect(:get => "/private_posts/new").to route_to("private_posts#new")
    end

    it "routes to #show" do
      expect(:get => "/private_posts/1").to route_to("private_posts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/private_posts/1/edit").to route_to("private_posts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/private_posts").to route_to("private_posts#create")
    end

    it "routes to #update" do
      expect(:put => "/private_posts/1").to route_to("private_posts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/private_posts/1").to route_to("private_posts#destroy", :id => "1")
    end

  end
end
