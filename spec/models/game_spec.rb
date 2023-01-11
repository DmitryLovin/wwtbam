require "rails_helper"
require "support/my_spec_helper"

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context "Game Factory" do
    it "Game.create_game_for_user! new correct game" do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15)
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context "game mechanics" do
    it "answer correct continues" do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.previous_game_question).to eq(q)
      expect(game_w_questions.current_game_question).not_to eq(q)

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it "correct .take_money!" do
      game = FactoryBot.create(:game_with_questions, user: user, current_level: 10)
      level = game.previous_level
      game.take_money!

      expect(game.finished?).to be_truthy
      expect(game.status).to eq :money
      expect(game.prize).to eq Game::PRIZES[level]
      expect(user.balance).to eq Game::PRIZES[level]
    end
  end

  context "Game .status" do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it "is :fail" do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it "is :timeout" do
      game_w_questions.created_at -= (Game::TIME_LIMIT + 10.minutes)
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it "is :won" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it "is :money" do
      expect(game_w_questions.status).to eq(:money)
    end
  end
end
