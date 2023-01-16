require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:user) { FactoryBot.build_stubbed(:user, id: 5, name: "John", balance: 5000) }

  before do
    assign(:user, user)
    assign(:games, [nil])
  end

  it "renders user name" do
    render
    expect(rendered).to match("John")
  end

  it "renders button to change password" do
    allow(view).to receive(:current_user).and_return(user)
    render
    expect(rendered).to match(link_to "Сменить имя и пароль", edit_user_registration_path(user))
  end

  it "does not render button to change password for different user" do
    render
    expect(rendered).not_to match(link_to "Сменить имя и пароль", edit_user_registration_path(user))
  end

  it "renders games" do
    stub_template "users/_game.html.erb" => "game template"
    render
    expect(rendered).to match("game template")
  end
end
