feature "Donation show" do
  context "when a user visits a donation show page" do
    let!(:user) { login_new_user }
    subject!(:donation) do
      Donation.create!(
        amount: 1234,
        date: Date.parse("2000-01-01"),
        recipient: Recipient.create!(name: "Test Recipient"),
        status: "planned",
      )
    end

    before { visit polymorphic_path(subject) }

    it "shows the status of the donation" do
      expect(page).to have_content "Planned"
    end
  end
end

feature "Donation index" do
  context "when a user visits the donation index page for the year 2000" do
    let(:year_2000_index_path) { polymorphic_path(:donations, year: 2000) }
    let!(:user) { login_new_user }
    let!(:donation) do
      Donation.create!(
        amount: 1234,
        date: Date.parse("#{donation_year}-01-01"),
        recipient: Recipient.create!(name: "Test Recipient"),
        status: "planned",
      )
    end

    before { visit year_2000_index_path }

    context "and no donations exist for the year 2000" do
      let(:donation_year) { 2001 }

      it "shows an appropriate message" do
        no_records_message = I18n.t("defaults.no_records", records: "donations")
        expect(find("#donations_table")).to have_content no_records_message
      end
    end

    context "and a donation exists for the year 2000" do
      let(:donation_year) { 2000 }

      it "shows the right labels in the header of the table" do
        header_labels = "Date Recipient Amount Status"
        expect(find("thead > tr:nth-child(1)").text).to eq header_labels
      end

      it "shows information about the donation in the first row of the table" do
        donation_information = "January 1, 2000 Test Recipient $1,234.00 planned Show Edit Destroy"
        expect(find("tbody > tr:nth-child(1)").text).to eq donation_information
      end
    end
  end
end

feature "Donation creation" do
  context "when a user visits the donation index page" do
    let!(:user) { login_new_user }

    before { visit polymorphic_path(:donations) }

    context "and clicks the new donation link" do
      before { click_link I18n.t("defaults.new_link", model: Donation) }

      context "and a recipient exists" do
        let!(:recipient) { Recipient.create!(name: "Test Recipient") }

        before { visit current_path }

        context "and the user fills out and submits the form" do
          before do
            fill_in "donation_amount", with: "100"
            select recipient.name, from: "donation_recipient_id"
            fill_in "donation_date", with: "2000-01-01"
            select "Cash", from: "donation_method"
            select "Planned", from: "donation_status"
            click_button I18n.t("helpers.submit.create", model: Donation)
          end

          it "creates a new donation with the correct attributes" do
            expect(page).to have_content "Donation was successfully recorded."
            expect(Donation.count).to eq 1
            donation = Donation.first
            expect(donation.amount).to eq 100
            expect(donation.date).to eq Date.parse("2000-01-01")
            expect(donation.method).to eq "cash"
            expect(donation.status).to eq "planned"
          end
        end
      end

      context "and no recipients exist" do

      end
    end
  end
end
