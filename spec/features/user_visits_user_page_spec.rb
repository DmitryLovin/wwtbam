require "rails_helper"

RSpec.feature "USER visit user page", type: :feature do
  let(:user_w_games) { create(:user) }
  let!(:games) do
    [
      create(
        :game,
        user: user_w_games,
        current_level: 10,
        prize: 15000,
        created_at: Time.parse("2023-01-16, 13:10 UTC"),
        finished_at: Time.parse("2023-01-16, 13:30 UTC")
      ),
      create(
        :game,
        user: user_w_games,
        current_level: 12,
        prize: 17000,
        created_at: Time.parse("2023-01-17, 12:12 UTC")
      )
    ]
  end

  scenario "success" do
    visit "/users/#{user_w_games.id}"

    # has user name
    expect(page).to have_content(user_w_games.name)

    # has only two tr in games table
    expect(page).to have_selector("tr", class: "text-center").twice

    # has games with correct status
    expect(page).to have_content("в процессе")
    expect(page).to have_content("деньги")

    # has correct started times
    expect(page).to have_content("17 янв., 12:12")
    expect(page).to have_content("16 янв., 13:10")

    # has game levels
    expect(page).to have_content("10")
    expect(page).to have_content("12")

    # has game prizes
    expect(page).to have_content("15 000 ₽")
    expect(page).to have_content("17 000 ₽")

    # has help statuses
    expect(page).to have_content("50/50").twice
    expect(page).to have_selector("i", class: "bi bi-telephone").twice
    expect(page).to have_selector("i", class: "bi bi-people").twice

    # doesn't have change password link
    expect(page).not_to have_content("Сменить имя и пароль")
  end
end
