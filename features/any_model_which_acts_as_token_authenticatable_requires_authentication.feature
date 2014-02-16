# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/9
Feature: Any model which acts as token authenticatable requires authentication
  As a developer
  In order to protect some models with token authentication
  I want any model which acts as token authenticatable to require authentication

  @rspec
  Scenario: Even if others do, models which don't act as token authenticatable do not require authentication
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded Post
    And a scaffolded PrivatePost
    And I prepare the test database

    And I overwrite "app/controllers/application_controller.rb" with:
      """
      class ApplicationController < ActionController::Base
        # Prevent CSRF attacks by raising an exception.
        # For APIs, you may want to use :null_session instead.
        protect_from_forgery with: :exception

        # While `acts_as_token_authentication_handler` was not called,
        # neither should be `authenticate_user!`.
        # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8
        #
        # Yet once `acts_as_token_authentication_handler` was called, `authenticate_user!`
        # should also be called. Run `rspec` to ensure that's being true.
        # If called, the `authenticate_user!` method will raise an exception, that
        # allows both cases to be covered by their own spec example.
        #
        # See test/dummy/app/controllers/posts_controller.rb and
        # test/dummy/app/controllers/private_posts_controller.rb

        def authenticate_user!
          raise "`authenticate_user!` was called."
        end
      end
      """

    And I overwrite "app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        # Include default devise modules. Others available are:
        # :confirmable, :lockable, :timeoutable and :omniauthable
        devise :database_authenticatable, :registerable,
               :recoverable, :rememberable, :trackable, :validatable

        acts_as_token_authenticatable
      end
      """

    And I write to "spec/requests/posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "Posts" do
        describe "GET /posts" do

          context "since ApplicationController#acts_as_authentication_handler was NOT called" do

            # See spec/dummy/app/controllers/posts_controller.rb

            it "does not require authentication" do
              get posts_path
              response.status.should be(200)
            end
          end
        end
      end
      """

    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since ApplicationController#acts_as_authentication_handler was NOT called" do

            # See spec/dummy/app/controllers/private_posts_controller.rb

            it "does not require authentication" do
              get posts_path
              response.status.should be(200)
            end
          end
        end
      end
      """

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      PrivatePosts
        GET /private_posts
          since ApplicationController#acts_as_authentication_handler was NOT called
            does not require authentication
      """
    And the output should match:
      """
      Posts
        GET /posts
          since ApplicationController#acts_as_authentication_handler was NOT called
            does not require authentication
      """

  @rspec
  Scenario: Any model which `acts_as_token_authenticatable` requires authentication
    Given I have a dummy app with a Devise-enabled User

    And I run `rails generate scaffold post title:string body:text --test-framework rspec --fixture-replacement factory_girl`
    And I run `rails generate scaffold private_post title:string body:text --test-framework rspec --fixture-replacement factory_girl`
    And I prepare the test database

    And I overwrite "app/controllers/application_controller.rb" with:
      """
      class ApplicationController < ActionController::Base
        # Prevent CSRF attacks by raising an exception.
        # For APIs, you may want to use :null_session instead.
        protect_from_forgery with: :exception

        # While `acts_as_token_authentication_handler` was not called,
        # neither should be `authenticate_user!`.
        # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8
        #
        # Yet once `acts_as_token_authentication_handler` was called, `authenticate_user!`
        # should also be called. Run `rspec` to ensure that's being true.
        # If called, the `authenticate_user!` method will raise an exception, that
        # allows both cases to be covered by their own spec example.
        #
        # See test/dummy/app/controllers/posts_controller.rb and
        # test/dummy/app/controllers/private_posts_controller.rb

        def authenticate_user!
          raise "`authenticate_user!` was called."
        end
      end
      """

    And I overwrite "app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        # Include default devise modules. Others available are:
        # :confirmable, :lockable, :timeoutable and :omniauthable
        devise :database_authenticatable, :registerable,
               :recoverable, :rememberable, :trackable, :validatable

        acts_as_token_authenticatable
      end
      """

    And I overwrite "app/controllers/private_posts_controller.rb" with:
      """
      class PrivatePostsController < ApplicationController

        # Please do notice that this controller DOES call `acts_as_authentication_handler`.
        # See test/dummy/spec/requests/posts_specs.rb
        acts_as_token_authentication_handler

        before_action :set_private_post, only: [:show, :edit, :update, :destroy]

        # GET /private_posts
        def index
          @private_posts = PrivatePost.all
        end

        # GET /private_posts/1
        def show
        end

        # GET /private_posts/new
        def new
          @private_post = PrivatePost.new
        end

        # GET /private_posts/1/edit
        def edit
        end

        # POST /private_posts
        def create
          @private_post = PrivatePost.new(private_post_params)

          if @private_post.save
            redirect_to @private_post, notice: 'Private post was successfully created.'
          else
            render action: 'new'
          end
        end

        # PATCH/PUT /private_posts/1
        def update
          if @private_post.update(private_post_params)
            redirect_to @private_post, notice: 'Private post was successfully updated.'
          else
            render action: 'edit'
          end
        end

        # DELETE /private_posts/1
        def destroy
          @private_post.destroy
          redirect_to private_posts_url, notice: 'Private post was successfully destroyed.'
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_private_post
            @private_post = PrivatePost.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def private_post_params
            params.require(:private_post).permit(:title, :body)
          end
      end
      """

    And I write to "spec/requests/posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "Posts" do
        describe "GET /posts" do

          context "since ApplicationController#acts_as_authentication_handler was NOT called" do

            # See spec/dummy/app/controllers/posts_controller.rb

            it "does not require authentication" do
              get posts_path
              response.status.should be(200)
            end
          end
        end
      end
      """

    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since ApplicationController#acts_as_authentication_handler WAS called" do

            # See spec/dummy/app/controllers/private_posts_controller.rb

            it "does require authentication" do
              # `authenticate_user!` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda { get private_posts_path }.should raise_exception(RuntimeError)
            end
          end
        end
      end
      """

    And I overwrite "spec/controllers/private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe PrivatePostsController do

        # This should return the minimal set of attributes required to create a valid
        # PrivatePost. As you add validations to PrivatePost, be sure to
        # adjust the attributes here as well.
        let(:valid_attributes) { { "title" => "MyString" } }

        # This should return the minimal set of values that should be in the session
        # in order to pass any filters (e.g. authentication) defined in
        # PrivatePostsController. Be sure to keep this updated too.
        let(:valid_session) { {} }

        describe "actions" do
          it "all require authentication" do
            # That's true for all actions, yet I think there's no need to repeat them all here.
            lambda { get :index, {}, valid_session }.should raise_exception(RuntimeError)
            lambda { get :new, {}, valid_session }.should raise_exception(RuntimeError)
          end
        end
      end
      """

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      Posts
        GET /posts
          since ApplicationController#acts_as_authentication_handler was NOT called
            does not require authentication
      """
    And the output should match:
      """
      PrivatePosts
        GET /private_posts
          since ApplicationController#acts_as_authentication_handler WAS called
            does require authentication
      """
    And the output should match:
      """
      PrivatePostsController
        actions
          all require authentication
      """
