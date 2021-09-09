require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /employee_remaining_vacation_days" do
    let!(:employee) { create :user }

    context 'when employee exists' do
      it 'returns a meaningful response' do
        get "/employees/#{employee.id}/employee_remaining_vacation_days"

        expect(response.body).to eq(
          {
            employee_id: employee.id,
            year: Date.today.year,
            remaining_vacation_days: User::VACATION_DAYS_PER_YEAR
          }.to_json
        )
      end
    end

    context 'when employee does not exists' do
      it 'returns 404' do
        get "/employees/#{employee.id+1}/employee_remaining_vacation_days"

        expect(response.status).to be(404)
        expect(response.body).to eq("An employee does not exist.")
      end
    end
  end
end
