require 'spec_helper'
require 'simple_token_authentication/caches/rails_cache_provider'

describe 'SimpleTokenAuthentication::Caches::RailsCacheProvider' do

  before(:each) do

    stub_const('ActiveSupport::Cache::Store', double())

    @subject = SimpleTokenAuthentication::Caches::RailsCacheProvider
  end

  it_behaves_like 'a cache'

  describe '.base_class' do

    it 'is ::ActiveSupport::Cache::Store', private: true do
      expect(@subject.base_class).to eq ::ActiveSupport::Cache::Store
    end
  end

end
