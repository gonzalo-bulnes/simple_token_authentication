require 'spec_helper'

describe "Posts" do
  describe "GET /posts" do

    context "since ApplicationController#acts_as_authentication_handler was NOT called" do

      # See est/dummy/app/controllers/posts_controller.rb

      it "does not require authentication" do
        get posts_path
        response.status.should be(200)
      end
    end
  end
end
