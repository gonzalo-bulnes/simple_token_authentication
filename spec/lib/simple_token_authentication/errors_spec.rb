require 'spec_helper'

describe SimpleTokenAuthentication::NoAdapterAvailableError do

  it 'is a kind of LoadError', public: true do
    expect(subject).to be_kind_of LoadError
  end

  it 'provides a pointer to its most common cause', public: true do
    expect(subject.to_s).to match("adapters' dependencies")
    expect(subject.to_s).to match('Gemfile')
    expect(subject.to_s).to match('issues/158')
  end
end
