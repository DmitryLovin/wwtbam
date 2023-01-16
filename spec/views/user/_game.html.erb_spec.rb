require "rails_helper"

RSpec.describe "users/_game", type: :view do
  let(:game) do
    FactoryBot.build_stubbed(
      :game, id: 15, created_at: Time.parse("2023.01.16, 13:30"), current_level: 10, prize: 10000
    )
  end

  before do
    allow(game).to receive(:status).and_return(:in_progress)

    render partial: "users/game", object: game
  end

  it "renders game id" do
    expect(rendered).to match("15")
  end

  it "renders game start time" do
    expect(rendered).to match("16 янв., 12:30")
  end

  it "renders game current question" do
    expect(rendered).to match("10")
  end
end
