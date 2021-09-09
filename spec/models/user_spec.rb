require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:pending_status) { create :request_status, name: 'pending' }

  describe 'Validations' do
    context 'when name is present' do
      it { expect(User.new(name: 'John Smith').valid?).to be(true) }
    end

    context 'when name is not present' do
      it { expect(User.new.valid?).to be(false) }
    end
  end

  describe '#this_year_remaining_vacation_days' do
    let!(:employee) { create :user }

    let!(:request_1) do
      r = build :request,
                start_date: Date.today.prev_year.end_of_year,
                end_date: Date.today.prev_year.end_of_year + 5,
                status: pending_status,
                employee: employee

      r.save(validate: false)
    end

    let!(:request_2) do
      create :request,
             start_date: Date.today + 14,
             end_date: Date.today + 15,
             status: pending_status,
             employee: employee
    end

    let!(:request_3) do
      create :request,
             start_date: Date.today.end_of_year,
             end_date: Date.today.end_of_year + 5,
             status: pending_status,
             employee: employee
    end

    it { expect(employee.this_year_remaining_vacation_days).to eq(17) }
  end

  describe '#requests_to_resolve' do
    let!(:manager) { create :user }
    let!(:subordinates) { create_list :user, 2, manager: manager }

    let!(:request_1) { create :request, employee: subordinates.first, status: pending_status }
    let!(:request_2) { create :request, employee: subordinates.last, status: pending_status }
    let!(:other_requests) { create_list :request, 4, status: pending_status }

    it 'returnes only this manager subordinates requests' do
      expect(manager.requests_to_resolve).to match_array([request_1, request_2])
    end
  end
end
