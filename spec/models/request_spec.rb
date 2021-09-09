require 'rails_helper'

RSpec.describe Request, type: :model do
  before do
    RequestStatus.create(name: 'pending')
    RequestStatus.create(name: 'approved')
    RequestStatus.create(name: 'rejected')
  end

  describe 'default status setting' do
    let!(:request) { create :request, start_date: Date.today + 14, end_date: Date.today + 15 }

    it "set status to 'pending'" do
      expect(request.status.name).to eq('pending')
    end
  end

  describe 'resolved_at setting' do
    let!(:request) { create :request, start_date: Date.today + 14, end_date: Date.today + 15 }

    it 'set resolved_at attribute' do
      expect(request.resolved_at).to be(nil)
      request.update(status: RequestStatus.find_by(name: 'approved'))
      expect(request.resolved_at).not_to be(nil)
    end
  end

  describe 'validations' do
    let!(:employee) { create :user }

    context 'when all attributes are present' do
      it { expect(Request.new(start_date: Date.today + 14, end_date: Date.today + 15, employee: employee).valid?).to be(true) }
    end

    context 'when start_date is not present' do
      it { expect(Request.new(end_date: Date.today + 15, employee: employee).valid?).to be(false) }
    end

    context 'when end_date is not present' do
      it { expect(Request.new(start_date: Date.today + 14, employee: employee).valid?).to be(false) }
    end

    context 'when employee is not present' do
      it { expect(Request.new(start_date: Date.today + 14, end_date: Date.today + 15).valid?).to be(false) }
    end

    context 'start_date is in the past' do
      it { expect(Request.new(start_date: Date.today - 1, end_date: Date.today + 15, employee: employee).valid?).to be(false) }
    end

    context 'start_date is greater than end_date' do
      it { expect(Request.new(start_date: Date.today + 14, end_date: Date.today + 10, employee: employee).valid?).to be(false) }
    end

    context 'an employee is creating an overlapping request' do
      before { Request.create(start_date: Date.today + 14, end_date: Date.today + 15, employee: employee) }

      it { expect(Request.new(start_date: Date.today + 15, end_date: Date.today + 16, employee: employee).valid?).to be(false) }
    end

    context 'an employee has enough days' do
      it { expect(Request.new(start_date: Date.today.end_of_year - 29, end_date: Date.today.end_of_year + 5, employee: employee).valid?).to be(true) }
    end

    context 'an employee does not have enough days' do
      it { expect(Request.new(start_date: Date.today.end_of_year - 30, end_date: Date.today.end_of_year + 5, employee: employee).valid?).to be(false) }
    end

    context 'creating a request with resolved_at attribute' do
      it { expect(Request.new(start_date: Date.today + 14, end_date: Date.today + 15, employee: employee, resolved_at: Date.today).valid?).to be(false) }
    end
  end

  describe 'scopes' do
    let!(:pending_requests) { create_list :request, 3, start_date: Date.today + 14, end_date: Date.today + 16 }
    let!(:approved_requests) { create_list :request, 4, start_date: Date.today + 15, end_date: Date.today + 20 }
    let!(:rejected_requests) { create_list :request, 4, start_date: Date.today + 21, end_date: Date.today + 23 }

    it 'returns only requests with the status matching with a scope name' do
      Request.where(start_date: Date.today + 15).update_all(status_id: RequestStatus.find_by(name: 'approved').id)
      Request.where(start_date: Date.today + 21).update_all(status_id: RequestStatus.find_by(name: 'rejected').id)

      expect(Request.pending.pluck(:status_id).uniq).to eq([RequestStatus.find_by(name: 'pending').id])
      expect(Request.approved.pluck(:status_id).uniq).to eq([RequestStatus.find_by(name: 'approved').id])
      expect(Request.rejected.pluck(:status_id).uniq).to eq([RequestStatus.find_by(name: 'rejected').id])
    end

    it 'returns requests covering a provided date ' do
      expect(Request.by_date(Date.today + 15)).to match_array(pending_requests + approved_requests)
    end
  end

  describe '#resolved_by' do
    let!(:manager) { create :user }
    let!(:subordinate) { create :user, manager: manager }
    let!(:request) { create :request, start_date: Date.today + 14, end_date: Date.today + 15, employee: subordinate }

    it 'returns manager as a resolver' do
      expect(request.resolved_by).to be(nil)
      request.update(status: RequestStatus.find_by(name: 'approved'))
      expect(request.resolved_by).to eq(manager)
    end
  end
end
