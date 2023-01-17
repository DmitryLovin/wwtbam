require "rails_helper"

RSpec.describe "users/index", type: :view do
  before do
    assign(:users, [
      build_stubbed(:user, name: "John", balance: 5000),
      build_stubbed(:user, name: "Mike", balance: 3000)
    ])

    render
  end

  it "renders players names" do
    expect(rendered).to match("Mike")
    expect(rendered).to match("John")
  end

  it "render players balances" do
    expect(rendered).to match("5 000 ₽")
    expect(rendered).to match("3 000 ₽")
  end

  it "render players in right order" do
    expect(rendered).to match(/John.*Mike/m)
  end
end
