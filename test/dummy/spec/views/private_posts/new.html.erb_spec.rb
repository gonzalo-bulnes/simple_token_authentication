require 'spec_helper'

describe "private_posts/new" do
  before(:each) do
    assign(:private_post, stub_model(PrivatePost,
      :title => "MyString",
      :body => "MyText",
      :published => false
    ).as_new_record)
  end

  it "renders new private_post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", private_posts_path, "post" do
      assert_select "input#private_post_title[name=?]", "private_post[title]"
      assert_select "textarea#private_post_body[name=?]", "private_post[body]"
      assert_select "input#private_post_published[name=?]", "private_post[published]"
    end
  end
end
