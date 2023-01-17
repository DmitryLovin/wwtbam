require "rails_helper"

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe "#apply_help!" do
    context "when help type is :fifty_fifty" do
      before do
        game_question.apply_help!(:fifty_fifty)
      end

      it "adds help hash" do
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it "has only 2 answers" do
        expect(game_question.help_hash[:fifty_fifty].size).to eq(2)
      end

      it "has correct answer" do
        expect(game_question.help_hash[:fifty_fifty]).to include(game_question.correct_answer_key)
      end
    end

    context "when help type is :friend_call" do
      context "when help wasn't used yet" do
        it "doesn't have hash" do
          expect(game_question.help_hash).not_to include(:friend_call)
        end
      end

      context "when help was used" do
        before do
          game_question.apply_help!(:friend_call)
        end

        it "adds help hash" do
          subject
          expect(game_question.help_hash).to include(:friend_call)
        end

        it "contains string" do
          subject
          expect(game_question.help_hash[:friend_call]).to include("считает, что это вариант")
        end
      end
    end
  end

  describe "#answer_correct?" do
    it "true" do
      expect(game_question.answer_correct?("b")).to be_truthy
    end
  end

  describe "#correct_answer_key" do
    it "correct answer key" do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe "#help_hash" do
    before do
      game_question.help_hash[:key] = "test hash"
    end

    it "adds key to help hash" do
      expect(game_question.help_hash).to include(:key) and eq("test hash")
    end

    it "loads saved help hash from db" do
      game_question.save
      loaded_game_question = GameQuestion.find(game_question.id)

      expect(loaded_game_question.help_hash).to eq({ key: "test hash" })
    end
  end

  describe "#level" do
    it "correct question level" do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe "#text" do
    it "correct question text" do
      expect(game_question.text).to eq(game_question.question.text)
    end
  end

  describe "#variants" do
    it "correct variants" do
      expect(game_question.variants).to eq({ "a" => game_question.question.answer2,
                                             "b" => game_question.question.answer1,
                                             "c" => game_question.question.answer4,
                                             "d" => game_question.question.answer3
                                           })
    end
  end
end
