require 'spec_helper'

describe SimpleTokenAuthentication::Configuration do

  context 'when included in any class' do

    before(:each) do
      SimpleTokenAuthentication.const_set(:ConfigurableClass, Class.new)
      klass = SimpleTokenAuthentication::ConfigurableClass
      klass.send :include, SimpleTokenAuthentication::Configuration
      @subject = klass.new
    end

    after(:each) do
      SimpleTokenAuthentication.send(:remove_const, :ConfigurableClass)
    end

    describe 'provides #controller_adapters which' do

      it_behaves_like 'a configuration option', 'controller_adapters'

      it "defauts to ['rails']", private: true do
        expect(@subject.controller_adapters).to eq ['rails']
      end
    end

    describe 'provides #model_adapters which' do

      it_behaves_like 'a configuration option', 'model_adapters'

      it "defauts to ['active_record']", private: true do
        expect(@subject.model_adapters).to eq ['active_record']
      end
    end

    describe 'provides #header_names which', header_names_option: true do

      it_behaves_like 'a configuration option', 'header_names'

      it 'defauts to {}', public: true  do
        expect(@subject.header_names).to eq({})
      end
    end

    describe 'provides #sign_in_token which', sign_in_token_option: true do

      it_behaves_like 'a configuration option', 'sign_in_token'

      it 'defauts to false', public: true do
        expect(@subject.sign_in_token).to eq false
      end
    end
  end
end
