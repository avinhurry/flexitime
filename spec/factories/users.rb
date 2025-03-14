FactoryBot.define do
  factory :user do
    email { "lazaro@example.com" }
    verified { false }
    password { 'verysecurepasword1234@!' }
  end
end
