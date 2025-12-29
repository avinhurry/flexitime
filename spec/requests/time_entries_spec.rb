require "cgi"
require "rails_helper"

RSpec.describe "Time entries", type: :request do
  let(:user) { create(:user, email: "user@example.com") }

  context "when signed out" do
    it "redirects to sign in" do
      get time_entries_path
      expect(response).to redirect_to(sign_in_path)
    end
  end

  context "when signed in" do
    before do
      sign_in_as(user)
    end

    context "when creating entries" do
      it "shows a newly created entry for its week" do
        travel_to Time.zone.local(2025, 3, 7, 10, 0) do
          clock_in = Time.zone.local(2025, 3, 7, 9, 0)
          clock_out = Time.zone.local(2025, 3, 7, 17, 0)

          post time_entries_path, params: { time_entry: { clock_in: clock_in, clock_out: clock_out } }

          week_start = TimeEntry.work_week_range(clock_in).begin.to_date
          expect(response).to redirect_to(time_entries_path(week_start: week_start))

          follow_redirect!

      entry = TimeEntry.order(:id).last
      expect(response.body).to include(entry.clock_in.strftime("%-d %b %Y, %H:%M"))
    end
  end

      it "renders errors for invalid data" do
        post time_entries_path, params: { time_entry: { clock_in: Time.zone.now } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(CGI.unescapeHTML(response.body)).to include("Clock out can't be blank")
      end
    end

    context "when updating entries" do
      it "redirects to the updated week start" do
        clock_in = Time.zone.local(2025, 3, 3, 9, 0)
        clock_out = Time.zone.local(2025, 3, 3, 17, 0)
        entry = user.time_entries.create!(clock_in: clock_in, clock_out: clock_out)

        new_clock_in = Time.zone.local(2025, 3, 10, 9, 0)
        new_clock_out = Time.zone.local(2025, 3, 10, 17, 0)

        patch time_entry_path(entry), params: { time_entry: { clock_in: new_clock_in, clock_out: new_clock_out } }

        week_start = TimeEntry.work_week_range(new_clock_in).begin.to_date
        expect(response).to redirect_to(time_entries_path(week_start: week_start))
      end

      it "renders errors for invalid data" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )

        patch time_entry_path(entry), params: { time_entry: { clock_out: nil } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when deleting entries" do
      it "removes the entry and redirects" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )

        delete time_entry_path(entry)

        expect(response).to redirect_to(time_entries_path)
        expect(user.time_entries.find_by(id: entry.id)).to be_nil
      end
    end
  end
end
