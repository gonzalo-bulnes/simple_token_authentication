require 'spec_helper'

describe 'Any class which extends SimpleTokenAuthentication::Adapter' do

  after(:each) do
    SimpleTokenAuthentication.send(:remove_const, :SomeClass)
  end

  before(:each) do
    @subject = define_dummy_class_which_extends(SimpleTokenAuthentication::Adapter)
  end

  describe '.base_class' do

    it 'raises an error if not overwritten', public: true do
      expect{ @subject.base_class }.to raise_error NotImplementedError
    end
  end
end
