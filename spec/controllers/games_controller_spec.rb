require "rails_helper"
require "support/my_spec_helper"

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context "anon user" do
    describe ".show" do
      it "redirects to sign_in" do
        get :show, params: { id: game_w_questions.id }

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe ".create" do
      it "redirects to sign_in" do
        post :create

        game = assigns(:game)

        expect(game).to be_nil

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe ".answer" do
      it "redirects to sign_in" do
        put :answer, params: {
          id: game_w_questions.id,
          letter: game_w_questions.current_game_question.correct_answer_key
        }

        game = assigns(:game)

        expect(game).to be_nil

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe ".take_money" do
      it "redirects to sign_in" do
        put :take_money, params: { id: game_w_questions.id }

        game = assigns(:game)

        expect(game).to be_nil

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe ".help" do
      it "redirects to sign_in" do
        put :help, params: {
          id: game_w_questions.id,
          help_type: :fifty_fifty
        }

        game = assigns(:game)

        expect(game).to be_nil

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end
  end

  context "usual user" do
    before(:each) do
      sign_in(user)
    end

    describe ".answer" do
      it "continue the game" do
        put :answer, params: {
          id: game_w_questions.id,
          letter: game_w_questions.current_game_question.correct_answer_key
        }

        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be_truthy
      end

      it "finish the game due the wrong answer" do
        put :answer, params: {
          id: game_w_questions.id,
          letter: "e"
        }

        game = assigns(:game)

        expect(game.finished?).to be_truthy
        expect(game.status).to eq(:fail)

        expect(response).to redirect_to(user_path(game.user))
        expect(flash[:alert]).to be
      end
    end

    describe ".create" do
      it "creates game" do
        generate_questions(60)

        post :create

        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)

        expect(response).to redirect_to(game_path(game))
        expect(flash[:notice]).to be
      end

      it "redirect to first when trying to create second" do
        expect(game_w_questions.finished?).to be_falsey
        expect { post :create }.to change(Game, :count).by(0)

        game = assigns(:game)
        expect(game).to be_nil

        expect(response).to redirect_to(game_path(game_w_questions))
        expect(flash[:alert]).to be
      end
    end

    describe ".show" do
      it "render the game" do
        get :show, params: { id: game_w_questions.id }

        game = assigns(:game)
        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)

        expect(response.status).to eq(200)
        expect(response).to render_template("show")
      end
    end

    describe ".take_money" do
      it "gives user money" do
        game_w_questions.update_attribute(:current_level, 3)

        put :take_money, params: { id: game_w_questions.id }

        game = assigns(:game)

        expect(game.finished?).to be_truthy
        expect(game.prize).to be > 0

        user.reload
        expect(user.balance).to be > 0

        expect(response).to redirect_to(user_path(game.user))
        expect(flash[:warning]).to be
      end
    end
  end

  context "second user" do
    let(:second_user) { FactoryBot.create(:user) }
    before(:each) do
      sign_in(second_user)
    end

    describe ".show" do
      it "not #show the game for second user" do
        second_user = FactoryBot.create(:user)
        sign_in(second_user)

        get :show, params: { id: game_w_questions.id }

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end
  end
end
