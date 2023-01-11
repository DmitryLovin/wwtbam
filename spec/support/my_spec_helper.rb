module MySpecHelper
  def generate_questions(num)
    num.times do
      FactoryBot.create(:question)
    end
  end
end

RSpec.configure do |c|
  c.include MySpecHelper
end
