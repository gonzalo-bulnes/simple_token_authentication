require 'spec_helper'

describe "PrivatePosts" do
  describe "GET /private_posts" do

    context "since ApplicationController#acts_as_authentication_handler WAS called" do

      # See est/dummy/app/controllers/private_posts_controller.rb

      it "does require authentication" do
        # `authenticate_user!` is configured to raise an exception when called,
        # see test/dummy/app/controllers/application_controller.rb
        lambda { get private_posts_path }.should raise_exception(RuntimeError)
      end
    end
  end
end
