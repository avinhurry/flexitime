FactoryBot.define do
  factory :day_credit do
    user
    credit_date { Date.new(2025, 3, 3) }
    credit_type { "bank_holiday" }
    credited_minutes { DayCredit.default_credited_minutes_for(user) }
  end
end
