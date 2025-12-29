FactoryBot.define do
  factory :user do
    email { "lazaro@example.com" }
    verified { false }
    password { 'verysecurepasword1234@!' }
    working_days_per_week { 5 }
  end
end
