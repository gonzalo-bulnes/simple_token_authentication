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

    describe 'does provide #fallback which', fallback_option: true do

      it 'is readable', private: true do
        expect(@subject).to respond_to :fallback
      end

      it 'can\'t be written', private: true do
        expect(@subject).not_to respond_to :fallback=
      end

      it 'defaults to :devise', private: true do
        expect(@subject.fallback).to eq :devise
      end
    end

    describe 'provides #parse_options which' do

      describe 'replaces :fallback_to_devise by :fallback' do

        context 'when :fallback option is set' do

          it 'removes :fallback_to_devise', private: true do
            options = { fallback: 'anything', fallback_to_devise: true }
            expect(@subject.parse_options(options)).to eq({ fallback: 'anything' })
          end
        end

        context 'when :fallback option is omitted' do
          context 'and :fallback_to_devise is true' do

            it 'replaces it by fallback: :devise', private: true do
              options = { fallback_to_devise: true }
              expect(@subject.parse_options(options)).to eq({ fallback: :devise })
            end
          end

          context 'and :fallback_to_devise is false' do

            context 'when :fallback default is :devise' do
              it 'replaces :fallback_to_devise by fallback: :none', private: true do
                SimpleTokenAuthentication.stub(:fallback).and_return(:devise)
                options = { fallback_to_devise: false }
                expect(@subject.parse_options(options)).to eq({ fallback: :none })
              end
            end

            context 'when :fallback default is not :devise' do
              it 'replaces :fallback_to_devise by :fallback default', private: true do
                SimpleTokenAuthentication.stub(:fallback).and_return('anything_but_devise')
                options = { fallback_to_devise: false }
                expect(@subject.parse_options(options)).to eq({ fallback: 'anything_but_devise' })
              end
            end
          end

          context 'and :fallback_to_devise is omitted' do
            it 'sets :fallback to its default value', private: true do
              SimpleTokenAuthentication.stub(:fallback).and_return('any_value')
              options = {}
              expect(@subject.parse_options(options)).to eq({ fallback: 'any_value' })
            end
          end
        end
      end
    end
  end
end
