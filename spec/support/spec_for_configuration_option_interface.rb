RSpec.shared_examples 'a configuration option' do |option_name|

  before(:each) do
    @get_option = option_name.to_sym        # e.g. :sign_in_token
    @set_option = option_name.+('=').to_sym # e.g. :sign_in_token=
  end

  it 'is acessible', private: true do
    expect(@subject).to respond_to @get_option
    expect(@subject).to respond_to @set_option
  end

  context 'once set' do

    before(:each) do
      @_original_value = @subject.send @get_option
      @subject.send @set_option, 'custom header'
    end

    after(:each) do
      @subject.send @set_option, @_original_value
    end

    it 'can be retrieved', private: true do
      expect(@subject.send @get_option).to eq 'custom header'
    end
  end
end
