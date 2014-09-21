require 'spec_helper'

describe SimpleTokenAuthentication::TokenGenerator do

  it 'responds to :generate_token', protected: true do
    expect(subject).to respond_to :generate_token
  end
end
