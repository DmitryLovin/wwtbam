require "rails_helper"

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe ".answer_correct?" do
    it "true" do
      expect(game_question.answer_correct?("b")).to be_truthy
    end
  end

  describe ".correct_answer_key" do
    it "correct answer key" do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe ".level" do
    it "correct question level" do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe ".text" do
    it "correct question text" do
      expect(game_question.text).to eq(game_question.question.text)
    end
  end

  describe ".variants" do
    it "correct variants" do
      expect(game_question.variants).to eq({ "a" => game_question.question.answer2,
                                             "b" => game_question.question.answer1,
                                             "c" => game_question.question.answer4,
                                             "d" => game_question.question.answer3
                                           })
    end
  end
end
