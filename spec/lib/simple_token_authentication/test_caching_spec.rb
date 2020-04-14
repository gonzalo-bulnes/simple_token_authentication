require 'spec_helper'
require 'simple_token_authentication/caches/rails_cache_provider'


describe 'SimpleTokenAuthentication::Caches::RailsCacheProvider' do

  def use_auth_token token
    allow(@entity).to receive(:get_token_from_params_or_headers).and_return(token)
  end

  def authentication
    @controller.send :authenticate_entity_from_token!, @entity
  end

  before(:all) do
    Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)
    SimpleTokenAuthentication.cache_provider_name = 'rails_cache'
    SimpleTokenAuthentication.cache_connection = Rails.cache
    SimpleTokenAuthentication.send(:load_cache_provider)
  end

  before(:each) do
    raise "Cache not configured" unless cache_provider == SimpleTokenAuthentication::Caches::RailsCacheProvider
    Rails.cache.clear
  end

  let(:cache_provider) { SimpleTokenAuthentication.cache_provider }

  describe 'test memory_store operation' do
    it 'uses memory_store to test caching' do

      record_id = 1
      plain_token = 'TestToken1'
      res = cache_provider.get_previous_auth record_id, plain_token
      expect(res).to be_falsey

      authenticated = true
      cache_provider.set_new_auth record_id, plain_token, authenticated

      res = cache_provider.get_previous_auth record_id, plain_token
      expect(res).to eq true

    end
  end

  describe 'test cache works with sign_in' do

    let(:token_authentication_handler) { SimpleTokenAuthentication::TokenAuthenticationHandler }
    let(:id) {2}
    let(:email) {'jondelario@test.com'}
    let(:bad_token) {'TestToken2'}
    let(:good_token) {'hello123!'}
    let(:new_good_token) {'Another token to test'}



    before :each do

      id = 2
      email = 'jondelario@test.com'
      bad_token = 'TestToken2'
      good_token = 'hello123!'

      SimpleTokenAuthentication.persist_token_as = :digest

      @subject = Class.new do
        def self.before_save _
        end
        include SimpleTokenAuthentication::ActsAsTokenAuthenticatable
        acts_as_token_authenticatable

        attr_accessor :email, :id

        def initialize(opt={})
          self.id = opt[:id]
          self.email = opt[:email]
          self.authentication_token = opt[:authentication_token]
        end

      end

      @controller_class = Class.new do
        include SimpleTokenAuthentication::TokenAuthenticationHandler

        def after_successful_token_authentication
          true
        end

      end

      @record = @subject.new(email: email, authentication_token: good_token, id: id)
      @controller = @controller_class.new
      @entity = double(id: id)

      allow(@entity).to receive(:get_identifier_from_params_or_headers).and_return(email)
      use_auth_token(bad_token)
      allow(@controller).to receive(:find_record_from_identifier).and_return(@record)
      allow(@controller).to receive(:perform_sign_in!).and_return(true)

    end


    it "correctly handles a series of authentications" do

      expect(authentication).to be false

      use_auth_token(good_token)

      expect(authentication).to be true

      expect(authentication).to be true

      use_auth_token(bad_token)

      expect(authentication).to be false

    end

    it "handles a cache crash" do

      use_auth_token(good_token)

      expect(authentication).to be true

      Rails.cache.clear

      expect(authentication).to be true

    end

    it "gets the results from cache, not locally" do

      use_auth_token(good_token)

      expect(authentication).to be true

      # Force the token in the User class to be returned as a bad token, without
      # triggering the generation of a new digest. The cache will not be cleared,
      # and so the cache result will be good. If the cache result was not returned
      # for some reason, the authentication would fail (which we'll confirm in a moment)
      @record.send(:persisted_authentication_token=, nil)

      expect(authentication).to be true

      # Clear the cache, demonstrating that the previous test was valid, since it should
      # now fail as the cached value is no longer present
      Rails.cache.clear

      expect(authentication).to be false

    end

    it "clears the cached authentication when the token is changed" do

      use_auth_token(good_token)

      expect(authentication).to be true

      # Update the token, which invalidates the authenticated cache item
      @record.authentication_token = new_good_token

      expect(authentication).to be false

      # Use the new token
      use_auth_token(new_good_token)
      expect(authentication).to be true

    end

    it "tests the speed of the cache versus uncached authentication" do
      SimpleTokenAuthentication.persist_token_as = :digest

      Devise.stretches = 13
      @record.authentication_token = new_good_token

      use_auth_token(new_good_token)

      puts "Testing Cache Speedup"

      total_cache_time = 0
      total_initial_time = 0

      10.times do
        Rails.cache.clear
        t1 = Time.now
        expect(authentication).to be true
        t2 = Time.now
        initial_time = (t2 - t1).to_f
        total_initial_time += initial_time

        t1 = Time.now
        expect(authentication).to be true
        t2 = Time.now
        cache_time = (t2 - t1).to_f
        total_cache_time += cache_time

      end

      speedup = (total_initial_time / total_cache_time)
      puts "Speedup = #{speedup.to_i} times (with hashing cost #{Devise.stretches})"
      expect(speedup).to be > 100

    end

    it "does not break plain text persisted tokens" do
      SimpleTokenAuthentication.persist_token_as = :plain

      @record.authentication_token = new_good_token
      use_auth_token(new_good_token)
      expect(authentication).to be true

      use_auth_token(bad_token)
      expect(authentication).to be false

      use_auth_token(bad_token)
      expect(authentication).to be false

      use_auth_token(new_good_token)
      expect(authentication).to be true

    end

  end

  after :all do
    SimpleTokenAuthentication.persist_token_as = :plain
    SimpleTokenAuthentication.cache_provider_name = nil
    SimpleTokenAuthentication.cache_provider = nil
  end
end
