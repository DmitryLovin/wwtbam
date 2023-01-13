require "rails_helper"
require "support/my_spec_helper"

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }
  let(:game) { assigns(:game) }

  context "anon user" do
    describe "#show" do
      before do
        get :show, params: { id: game_w_questions.id }
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sing in" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end

    describe "#create" do
      before do
        post :create
      end

      it "does not create a game" do
        expect(game).to be_nil
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end

    describe "#answer" do
      before do
        put :answer, params: {
          id: game_w_questions.id,
          letter: game_w_questions.current_game_question.correct_answer_key
        }
      end

      it "does not assign the game" do
        expect(game).to be_nil
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign_in" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end

    describe "#take_money" do
      before do
        put :take_money, params: { id: game_w_questions.id }
      end

      it "does not assign the game" do
        expect(game).to be_nil
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign_in" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end

    describe "#help" do
      before do
        put :help, params: {
          id: game_w_questions.id,
          help_type: :fifty_fifty
        }
      end

      it "does not assign the game" do
        expect(game).to be_nil
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign_in" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end
  end

  context "usual user" do
    before do
      sign_in(user)
    end

    describe "#answer" do
      context "with right answer" do
        before do
          put :answer, params: {
            id: game_w_questions.id,
            letter: game_w_questions.current_game_question.correct_answer_key
          }
        end

        it "continues the game" do
          expect(game.finished?).to be_falsey
        end

        it "changes current level" do
          expect(game.current_level).to be > 0
        end

        it "has response status 302" do
          expect(response.status).to eq(302)
        end

        it "redirect to current game" do
          expect(response).to redirect_to(game_path(game))
        end

        it "does not have flash" do
          expect(flash.empty?).to be_truthy
        end
      end

      context "with wrong answer" do
        before do
          put :answer, params: {
            id: game_w_questions.id,
            letter: "e"
          }
        end

        it "finish the game" do
          expect(game.finished?).to be_truthy
        end

        it "has status :fail" do
          expect(game.status).to eq(:fail)
        end

        it "has response status 302" do
          expect(response.status).to eq(302)
        end

        it "redirects to user page" do
          expect(response).to redirect_to(user_path(game.user))
        end

        it "has alert flash" do
          expect(flash[:alert]).to be
        end
      end
    end

    describe "#create" do
      before do
        generate_questions(60)
      end

      context "first game" do
        before do
          post :create
        end

        it "is not finished" do
          expect(game.finished?).to be_falsey
        end

        it "assigns user" do
          expect(game.user).to eq(user)
        end

        it "has response status 302" do
          expect(response.status).to eq(302)
        end

        it "redirects to game page" do
          expect(response).to redirect_to(game_path(game))
        end

        it "has notice flash" do
          expect(flash[:notice]).to be
        end
      end

      context "game already exists" do
        let!(:existing_game) { game_w_questions }
        subject { post :create }

        it "doesn't change games count" do
          expect { subject }.to change(Game, :count).by(0)
        end

        it "doesn't assign the game" do
          subject
          expect(game).to be_nil
        end

        it "has response status 302" do
          subject
          expect(response.status).to eq(302)
        end

        it "redirects to first game" do
          subject
          expect(response).to redirect_to(game_path(existing_game))
        end

        it "has alert flash" do
          subject
          expect(flash[:alert]).to be
        end
      end
    end

    describe "#help" do
      before do
        put :help, params: {
          id: game_w_questions.id,
          help_type: :fifty_fifty
        }
      end

      it "assign the game" do
        expect(game).not_to be_nil
      end

      it "uses help" do
        game_w_questions.reload
        expect(game_w_questions.fifty_fifty_used?).to be_truthy
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign_in" do
        expect(response).to redirect_to(game_path(game_w_questions))
      end

      it "has info flash" do
        expect(flash[:info]).to be
      end

      context "next question with already used help" do
        before do
          game_w_questions.answer_current_question!(game_w_questions.current_game_question.correct_answer_key)
          game_w_questions.reload
          put :help, params: {
            id: game_w_questions.id,
            help_type: :fifty_fifty
          }
        end

        it "redirects to game page" do
          expect(response).to redirect_to(game_path(game_w_questions))
        end

        it "has alert flash" do
          expect(flash[:alert]).to be
        end
      end
    end

    describe "#show" do
      before do
        get :show, params: { id: game_w_questions.id }
      end

      it "has a game in progress" do
        expect(game.finished?).to be_falsey
      end

      it "assign a game with correct user" do
        expect(game.user).to eq(user)
      end

      it "has response status 200" do
        expect(response.status).to eq(200)
      end

      it "renders show template" do
        expect(response).to render_template("show")
      end
    end

    describe "#take_money" do
      before do
        game_w_questions.update_attribute(:current_level, 3)
        put :take_money, params: { id: game_w_questions.id }
      end

      it "finish the game" do
        expect(game.finished?).to be_truthy
      end

      it "has a prize" do
        expect(game.prize).to be > 0
      end

      it "gives user money" do
        user.reload
        expect(user.balance).to be > 0
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to user page" do
        expect(response).to redirect_to(user_path(game.user))
      end

      it "has warning flash" do
        expect(flash[:warning]).to be
      end
    end
  end

  context "second user" do
    let(:second_user) { FactoryBot.create(:user) }
    before do
      sign_in(second_user)
    end

    describe "#show" do
      before do
        get :show, params: { id: game_w_questions.id }
      end

      it "has response status 302" do
        expect(response.status).to eq(302)
      end

      it "redirects to root page" do
        expect(response).to redirect_to(root_path)
      end

      it "has alert flash" do
        expect(flash[:alert]).to be
      end
    end
  end
end
