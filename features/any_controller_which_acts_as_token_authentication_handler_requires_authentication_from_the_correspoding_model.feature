# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/9
# See also https://github.com/gonzalo-bulnes/simple_token_authentication/pull/62
Feature: Any controller which acts as token authentication handler requires authentication from the corresponding model
  As a developer
  In order to protect some resources (e.g. `PrivatePost`) with token authentication
  I want any controller which acts as token authentication handler (e.g. `PrivatePostsController`) to require authentication from the corresponding token authenticatable model (e.g. `User`)

  @rspec @replacement_available
  Scenario: Even if others do, controllers which don't act as token authentication handlers do not require authentication
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded Post
    And a scaffolded PrivatePost
    And I prepare the test database

    And the `authenticate_user!` method always raises an exception

    And User `acts_as_token_authenticatable`

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

    And I silence totally the PrivatePostsController spec errors
    And I silence totally the PostsController spec errors

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

  @rspec @replacement_available
  Scenario: Any controller which acts as token authentication handler requires authentication from the corresponding model
    Given I have a dummy app with a Devise-enabled User

    And a scaffolded Post
    And a scaffolded PrivatePost
    And I prepare the test database

    And the `authenticate_user!` method always raises an exception

    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
      acts_as_token_authentication_handler
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

          context "since User `acts_as_token_authenticatable`" do
            context "and ApplicationController#acts_as_authentication_handler WAS called" do

              # See spec/dummy/app/controllers/private_posts_controller.rb

              it "does require authentication" do
                # `authenticate_user!` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda { get private_posts_path }.should raise_exception(RuntimeError)
              end
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

    And I silence totally the PostsController spec errors

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
          since User `acts_as_token_authenticatable`
            and ApplicationController#acts_as_authentication_handler WAS called
              does require authentication
      """
    And the output should match:
      """
      PrivatePostsController
        actions
          all require authentication
      """
    And the output should contain:
      """
      DEPRECATION WARNING: `acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.
      """

  @rspec
  Scenario: Optionally, only explicitely named controller actions require authentication
    Given I have a dummy app with a Devise-enabled User

    And a scaffolded PrivatePost
    And I prepare the test database

    And the `authenticate_user!` method always raises an exception

    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
      acts_as_token_authentication_handler_for User, only: [:create, :update, :destroy]
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

        let!(:private_post) { FactoryGirl.create(:private_post) }

        context "since ApplicationController#acts_as_authentication_handler was skipped" do
          describe "#index" do
            it "does not require auhentication" do
              lambda { get :index, {}, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#new" do
            it "does not require auhentication" do
              lambda { get :new, {}, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#show" do
            it "does not require auhentication" do
              lambda { get :show, { id: private_post.id }, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#edit" do
            it "does not require auhentication" do
              lambda { get :edit, { id: private_post.id }, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
        end

        context "since ApplicationController#acts_as_authentication_handler was called" do
          describe "#create" do
            it "requires auhentication" do
              lambda { get :show, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
          describe "#update" do
            it "requires auhentication" do
              lambda { get :update, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
          describe "#destroy" do
            it "requires auhentication" do
              lambda { get :destroy, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
        end
      end
      """

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should contain:
      """
      PrivatePostsController
      """
    And the output should contain:
      """
        since ApplicationController#acts_as_authentication_handler was skipped
      """
    And the output should contain:
      """
          #index
            does not require auhentication
      """
    And the output should contain:
      """
          #new
            does not require auhentication
      """
    And the output should contain:
      """
          #show
            does not require auhentication
      """
    And the output should contain:
      """
          #edit
            does not require auhentication
      """
    And the output should contain:
      """
        since ApplicationController#acts_as_authentication_handler was called
      """
    And the output should contain:
      """
          #create
            requires auhentication
      """
    And the output should contain:
      """
          #update
            requires auhentication
      """
    And the output should contain:
      """
          #destroy
            requires auhentication
      """

  @rspec
  Scenario: Optionally, explicitely excluded controller actions do not require authentication
    Given I have a dummy app with a Devise-enabled User

    And a scaffolded PrivatePost
    And I prepare the test database

    And the `authenticate_user!` method always raises an exception

    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
      acts_as_token_authentication_handler_for User, except: [:index, :show, :new, :edit]
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

        let!(:private_post) { FactoryGirl.create(:private_post) }

        context "since ApplicationController#acts_as_authentication_handler was skipped" do
          describe "#index" do
            it "does not require auhentication" do
              lambda { get :index, {}, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#new" do
            it "does not require auhentication" do
              lambda { get :new, {}, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#show" do
            it "does not require auhentication" do
              lambda { get :show, { id: private_post.id }, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
          describe "#edit" do
            it "does not require auhentication" do
              lambda { get :edit, { id: private_post.id }, valid_session }.should_not raise_exception(RuntimeError)
            end
          end
        end

        context "since ApplicationController#acts_as_authentication_handler was called" do
          describe "#create" do
            it "requires auhentication" do
              lambda { get :show, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
          describe "#update" do
            it "requires auhentication" do
              lambda { get :update, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
          describe "#destroy" do
            it "requires auhentication" do
              lambda { get :destroy, {  id: private_post.id }, valid_session }.should
                           raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end
        end
      end
      """

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should contain:
      """
      PrivatePostsController
      """
    And the output should contain:
      """
        since ApplicationController#acts_as_authentication_handler was skipped
      """
    And the output should contain:
      """
          #index
            does not require auhentication
      """
    And the output should contain:
      """
          #new
            does not require auhentication
      """
    And the output should contain:
      """
          #show
            does not require auhentication
      """
    And the output should contain:
      """
          #edit
            does not require auhentication
      """
    And the output should contain:
      """
        since ApplicationController#acts_as_authentication_handler was called
      """
    And the output should contain:
      """
          #create
            requires auhentication
      """
    And the output should contain:
      """
          #update
            requires auhentication
      """
    And the output should contain:
      """
          #destroy
            requires auhentication
      """
