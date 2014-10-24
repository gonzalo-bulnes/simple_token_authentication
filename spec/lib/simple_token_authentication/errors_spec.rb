require 'spec_helper'

describe SimpleTokenAuthentication::NoAdapterAvailableError do

  it 'is a kind of LoadError', public: true do
    expect(subject).to be_kind_of LoadError
  end
end
