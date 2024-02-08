require 'rails_helper'

RSpec.describe "education_infos/edit", type: :view do
  let(:education_info) {
    EducationInfo.create!(
      Semester: "MyString",
      Grad_Year: 1,
      University: "MyString",
      Degree_Type: "MyString"
    )
  }

  before(:each) do
    assign(:education_info, education_info)
  end

  it "renders the edit education_info form" do
    render

    assert_select "form[action=?][method=?]", education_info_path(education_info), "post" do

      assert_select "input[name=?]", "education_info[Semester]"

      assert_select "input[name=?]", "education_info[Grad_Year]"

      assert_select "input[name=?]", "education_info[University]"

      assert_select "input[name=?]", "education_info[Degree_Type]"
    end
  end
end
