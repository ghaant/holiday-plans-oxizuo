require 'rails_helper'

RSpec.describe "Requests", type: :request do
  let!(:employee) { create :user }

  before do
    RequestStatus.create(name: 'pending')
    RequestStatus.create(name: 'approved')
  end

  describe 'callbacks' do
    context 'when employee does not exists' do
      it 'returns 404' do
        get "/requests/#{employee.id+1}/mine"

        expect(response.status).to be(404)
        expect(response.body).to eq("An employee does not exist.")

        post '/requests'
        expect(response.status).to be(404)
        expect(response.body).to eq("An employee does not exist.")

        get "/requests/#{employee.id+1}/to_resolve"

        post '/requests'
        expect(response.status).to be(404)
        expect(response.body).to eq("An employee does not exist.")

        patch "/requests/#{employee.id+1}"
        expect(response.status).to be(404)
        expect(response.body).to eq("An employee does not exist.")
      end
    end
  end

  describe "GET /requests/:employee_id/mine" do
    context 'when employee exists' do
      context 'and does not have any requests' do
        it 'returns an empty array when there is no requests' do
          get "/requests/#{employee.id}/mine"

          expect(response.body).to eq('[]')
        end
      end

      context 'and has requests' do
        let!(:employee_request) { create :request, employee: employee }
        let!(:other_requests) { create_list :request, 4 }

        it "returns only employee's requests" do
          get "/requests/#{employee.id}/mine"

          expect(response.body).to eq(
            [
              {
                "id": employee_request.id,
                "author": employee.id,
                "status": 'pending',
                "resolved_by": employee_request.resolved_by&.id,
                "request_created_at": employee_request.created_at,
                "vacation_start_date": employee_request.start_date,
                "vacation_end_date": employee_request.end_date
              }
            ].to_json
          )
        end
      end
    end
  end

  describe 'POST /requests' do
    context 'valid params' do
      it 'creates a new request' do
        expect {
          post '/requests', params: { employee_id: employee.id, start_date: Date.today + 14, end_date: Date.today + 15 }
        }.to change(employee.requests, :count).by(1)

        request = Request.last
        expect(response.status).to be(201)
        expect(response.body).to eq(
          {
            "id": request.id,
            "author": request.employee.id,
            "status": request.status.name,
            "resolved_by": request.resolved_by&.id,
            "request_created_at": request.created_at,
            "vacation_start_date": request.start_date,
            "vacation_end_date": request.end_date
          }.to_json
        )
      end
    end

    context 'invalid params' do
      it 'returns 422' do
        post '/requests', params: { employee_id: employee.id }
        expect(response.status).to be(422)
        expect(response.body).to eq("{\"start_date\":[\"can't be blank\"],\"end_date\":[\"can't be blank\"]}")
      end
    end
  end

  describe 'resolving requests' do
    let!(:manager) { create :user }
    let!(:subordinate) { create :user, manager: manager }
    let!(:request) { create :request, employee: subordinate }

    describe 'GET /requests/:employee_id/to_resolve' do
      it 'returns the right response' do
        get "/requests/#{manager.id}/to_resolve", params: { date: request.start_date }

        expect(response.status).to eq(200)
        expect(response.body).to eq(
          [
            {
              "id": request.id,
              "author": subordinate.id,
              "status": 'pending',
              "resolved_by": request.resolved_by&.id,
              "request_created_at": request.created_at,
              "vacation_start_date": request.start_date,
              "vacation_end_date": request.end_date
            }
          ].to_json
        )
      end
    end

    describe 'PATCH /requests/:id' do
      context 'the manager has rights to resolve' do
        it 'changes the status of the request' do
          patch "/requests/#{request.id}", params: { employee_id: manager.id, status: 'approved' }

          expect(request.reload.status.name).to eq('approved')
          expect(response.status).to eq(201)
          expect(response.body).to eq(
            {
              "id": request.id,
              "author": subordinate.id,
              "status": 'approved',
              "resolved_by": request.resolved_by.id,
              "request_created_at": request.created_at,
              "vacation_start_date": request.start_date,
              "vacation_end_date": request.end_date
            }.to_json
          )
        end
      end

      context 'the manager does not has rights to resolve' do
        let!(:another_manager) { create :user }

        it 'returns 422' do
          patch "/requests/#{request.id}", params: { employee_id: another_manager.id, status: 'approved' }

          expect(request.status.name).to eq('pending')
          expect(response.status).to eq(422)
          expect(response.body).to eq("You do not have rights to resolve this request.")
        end
      end
    end
  end
end
