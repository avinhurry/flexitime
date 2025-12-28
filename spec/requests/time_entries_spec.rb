require "rails_helper"

RSpec.describe "Time entries", type: :request do
  it "shows a newly created entry for its week" do
    user = create(:user, email: "user@example.com")
    sign_in_as(user)

    travel_to Time.zone.local(2025, 3, 7, 10, 0) do
      clock_in = Time.zone.local(2025, 3, 7, 9, 0)
      clock_out = Time.zone.local(2025, 3, 7, 17, 0)

      post time_entries_path, params: { time_entry: { clock_in: clock_in, clock_out: clock_out } }

      week_start = TimeEntry.work_week_range(clock_in).begin.to_date
      expect(response).to redirect_to(time_entries_path(week_start: week_start))

      follow_redirect!

      entry = TimeEntry.order(:id).last
      expect(response.body).to include(entry.clock_in.strftime("%Y-%m-%d"))
    end
  end
end
