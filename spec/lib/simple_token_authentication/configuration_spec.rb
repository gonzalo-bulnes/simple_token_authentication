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

    describe 'provides #header_names which' do

      it 'is acessible', private: true do
        expect(@subject).to respond_to :header_names
        expect(@subject).to respond_to :header_names=
      end

      it 'defauts to {}', private: true  do
        expect(@subject.header_names).to eq({})
      end

      context 'once set' do

        before(:each) do
          @_header_names_original_value = @subject.header_names
          @subject.header_names = 'custom header'
        end

        after(:each) do
          @subject.header_names = @_header_names_original_value
        end

        it 'can be retrieved', private: true do
          expect(@subject.header_names).to eq 'custom header'
        end
      end
    end

    describe 'provides #sign_in_token which' do

      it 'is acessible', private: true do
        expect(@subject).to respond_to :sign_in_token
        expect(@subject).to respond_to :sign_in_token=
      end

      it 'defauts to false', private: true do
        expect(@subject.sign_in_token).to eq false
      end

      context 'once set' do

        before(:each) do
          @_header_names_original_value = @subject.sign_in_token
          @subject.sign_in_token = 'custom header'
        end

        after(:each) do
          @subject.sign_in_token = @_header_names_original_value
        end

        it 'can be retrieved', private: true do
          expect(@subject.sign_in_token).to eq 'custom header'
        end
      end
    end
  end
end
