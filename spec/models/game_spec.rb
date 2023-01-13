require "rails_helper"
require "support/my_spec_helper"

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  describe "#answer_current_question!" do
    context "with right answer" do
      it "continues the game" do
        level = game_w_questions.current_level
        q = game_w_questions.current_game_question
        game_w_questions.answer_current_question!(q.correct_answer_key)
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.current_level).to eq(level + 1)
      end

      it "stop the game due to timeout" do
        game_w_questions.created_at -= (Game::TIME_LIMIT + 10.minutes)
        q = game_w_questions.current_game_question
        game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(game_w_questions.status).to eq(:timeout)
        expect(game_w_questions.finished?).to be_truthy
      end

      it "win the game" do
        game_w_questions.current_level = 14
        q = game_w_questions.current_game_question
        game_w_questions.answer_current_question!(q.correct_answer_key)

        expect(game_w_questions.status).to eq(:won)
        expect(game_w_questions.finished?).to be_truthy
        expect(game_w_questions.prize).to eq(1000000)
      end
    end

    context "with wrong answer" do
      it "stop the game" do
        game_w_questions.answer_current_question!("e")

        expect(game_w_questions.status).to eq(:fail)
        expect(game_w_questions.finished?).to be_truthy
      end

      it "stop the game due to timeout" do
        game_w_questions.created_at -= (Game::TIME_LIMIT + 10.minutes)
        game_w_questions.answer_current_question!("e")

        expect(game_w_questions.status).to eq(:timeout)
        expect(game_w_questions.finished?).to be_truthy
      end
    end
  end

  describe "#create_game_for_user!" do
    it "correctly create" do
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

  describe "#current_game_question" do
    it "correct question" do
      game = FactoryBot.create(:game)
      level = game.current_level
      q = FactoryBot.create(:question, level: level)
      game_question = FactoryBot.create(:game_question, game: game, question: q)
      expect(game.current_game_question).to eq(game_question)
    end
  end

  describe "#previous_level" do
    it "correct prev level" do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  describe "#status" do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ":fail" do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ":timeout" do
      game_w_questions.created_at -= (Game::TIME_LIMIT + 10.minutes)
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ":won" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ":money" do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  describe "#take_money!" do
    it "correctly take money" do
      game = FactoryBot.create(:game_with_questions, user: user, current_level: 10)
      level = game.previous_level
      game.take_money!

      expect(game.finished?).to be_truthy
      expect(game.status).to eq :money
      expect(game.prize).to eq Game::PRIZES[level]
      expect(user.balance).to eq Game::PRIZES[level]
    end
  end
end
