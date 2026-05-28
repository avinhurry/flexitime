require "cgi"
require "rails_helper"

RSpec.describe "Day credits", type: :request do
  let(:user) { create(:user, email: "user@example.com", contracted_hours: 37, working_days_per_week: 4) }

  context "when signed out" do
    it "redirects to sign in" do
      get new_day_credit_path
      expect(response).to redirect_to(sign_in_path)
    end
  end

  context "when signed in" do
    before do
      sign_in_as(user)
    end

    it "prefills the credit from one fifth of contracted weekly hours" do
      get new_day_credit_path(date: "2025-03-03")

      expect(response).to be_successful

      document = Capybara.string(response.body)
      expect(document.find("input[name='day_credit[credit_date]']").value).to eq("2025-03-03")
      expect(document.find("input[name='day_credit[credited_hours_part]']").value).to eq("7")
      expect(document.find("input[name='day_credit[credited_minutes_part]']").value).to eq("24")
    end

    it "creates a credit and shows it on the week" do
      post day_credits_path, params: {
        day_credit: {
          credit_date: "2025-03-03",
          credit_type: "bank_holiday",
          credited_hours_part: "7",
          credited_minutes_part: "24",
          note: "Spring bank holiday"
        }
      }

      expect(response).to redirect_to(time_entries_path(week_start: Date.new(2025, 3, 3)))

      follow_redirect!

      expect(response.body).to include("Bank holiday")
      expect(response.body).to include("7h 24m")
      expect(response.body).to include("Spring bank holiday")
    end

    it "renders errors for invalid credit minutes" do
      post day_credits_path, params: {
        day_credit: {
          credit_date: "2025-03-03",
          credit_type: "bank_holiday",
          credited_hours_part: "7",
          credited_minutes_part: "60"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(CGI.unescapeHTML(response.body)).to include("Credited minutes part must be less than 60")
    end

    it "updates a credit" do
      day_credit = create(:day_credit, user: user, note: "Original")

      patch day_credit_path(day_credit), params: {
        day_credit: {
          credit_date: "2025-03-04",
          credit_type: "annual_leave",
          credited_hours_part: "7",
          credited_minutes_part: "24",
          note: "Updated"
        }
      }

      expect(response).to redirect_to(time_entries_path(week_start: Date.new(2025, 3, 3)))
      expect(day_credit.reload.credit_type).to eq("annual_leave")
      expect(day_credit.note).to eq("Updated")
    end

    it "deletes a credit" do
      day_credit = create(:day_credit, user: user)

      delete day_credit_path(day_credit)

      expect(response).to redirect_to(time_entries_path(week_start: Date.new(2025, 3, 3)))
      expect(user.day_credits.find_by(id: day_credit.id)).to be_nil
    end
  end
end
