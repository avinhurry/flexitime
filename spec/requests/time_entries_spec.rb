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

    context "when visiting the new entry form" do
      it "prefills clock times based on contracted hours and working days" do
        user.update!(contracted_hours: 36, working_days_per_week: 4)

        travel_to Time.zone.local(2025, 3, 7, 9, 15) do
          get new_time_entry_path

          expect(response).to be_successful

          expected_clock_in = Time.zone.local(2025, 3, 7, 9, 15).change(sec: 0)
          expected_clock_out = expected_clock_in + 9.hours
          document = Capybara.string(response.body)

          expect(input_time_value(document, "time_entry[clock_in]")).to eq(expected_clock_in)
          expect(input_time_value(document, "time_entry[clock_out]")).to eq(expected_clock_out)
        end
      end
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

    context "when viewing entries" do
      it "renders the entry details" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )
        entry.time_entry_breaks.create!(
          break_in: Time.zone.local(2025, 3, 3, 12, 0),
          break_out: Time.zone.local(2025, 3, 3, 12, 30),
          reason: "Lunch"
        )

        get time_entry_path(entry)

        expect(response).to be_successful
        expect(response.body).to include("Time entry")
        expect(response.body).to include("Lunch")
      end

      it "renders a fallback when no breaks exist" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )

        get time_entry_path(entry)

        expect(response).to be_successful
        expect(response.body).to include("No breaks recorded for this entry.")
      end
    end

    context "when managing breaks" do
      it "starts a break" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )

        post start_break_time_entry_path(entry)

        expect(response).to redirect_to(time_entry_path(entry))
        expect(entry.reload.break_in_progress?).to be(true)
      end

      it "ends a break" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )
        entry.time_entry_breaks.create!(break_in: Time.zone.local(2025, 3, 3, 12, 0))

        patch end_break_time_entry_path(entry)

        expect(response).to redirect_to(time_entry_path(entry))
        expect(entry.reload.break_in_progress?).to be(false)
      end

      it "shows an alert when starting a break twice" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )
        entry.time_entry_breaks.create!(break_in: Time.zone.local(2025, 3, 3, 12, 0))

        post start_break_time_entry_path(entry)

        expect(response).to redirect_to(edit_time_entry_path(entry))
        follow_redirect!
        expect(CGI.unescapeHTML(response.body)).to include("A break is already in progress.")
      end

      it "shows an alert when ending without a break" do
        entry = user.time_entries.create!(
          clock_in: Time.zone.local(2025, 3, 3, 9, 0),
          clock_out: Time.zone.local(2025, 3, 3, 17, 0)
        )

        patch end_break_time_entry_path(entry)

        expect(response).to redirect_to(edit_time_entry_path(entry))
        follow_redirect!
        expect(CGI.unescapeHTML(response.body)).to include("No break in progress.")
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

  def input_time_value(document, name)
    value = document.find("input[name='#{name}']").value
    Time.zone.parse(value)
  end
end
