class RequestsController < ApplicationController
  before_action :employee

  def employee_requests
    request_array = []

    employee.requests.send(status_param).each do |request|
      request_array <<
        {
          "id": request.id,
          "author": request.employee.id,
          "status": request.status.name,
          "resolved_by": request.resolved_by&.id,
          "request_created_at": request.created_at,
          "vacation_start_date": request.start_date,
          "vacation_end_date": request.end_date
        }
    end

    render json: request_array
  end

  def create
    request = employee.requests.create(start_date: params[:start_date], end_date: params[:end_date])

    if request.errors.empty?
      request_hash =
        {
          "id": request.id,
          "author": request.employee.id,
          "status": request.status.name,
          "resolved_by": request.resolved_by&.id,
          "request_created_at": request.created_at,
          "vacation_start_date": request.start_date,
          "vacation_end_date": request.end_date
        }

      render json: request_hash, status: :created
    else
      render json: request.errors, status: :unprocessable_entity
    end
  end

  def requests_to_resolve
    requests = employee.requests_to_resolve.send(status_param)
    requests = requests.by_date(params[:date]) if params[:date].present?

    request_array = []

    requests.each do |request|
      request_array <<
        {
          "id": request.id,
          "author": request.employee.id,
          "status": request.status.name,
          "resolved_by": request.resolved_by&.id,
          "request_created_at": request.created_at,
          "vacation_start_date": request.start_date,
          "vacation_end_date": request.end_date
        }
    end

    render json: request_array
  end

  def resolve
    request = Request.find(params[:id])

    if request.employee.manager != employee
      render json: 'You do not have rights to resolve this request.', status: :unprocessable_entity and return
    end

    status = RequestStatus.find_by(name: params[:status])

    request.update(status: status) if status

    if request.errors.empty?
      request_hash =
        {
          "id": request.id,
          "author": request.employee.id,
          "status": request.status.name,
          "resolved_by": request.resolved_by&.id,
          "request_created_at": request.created_at,
          "vacation_start_date": request.start_date,
          "vacation_end_date": request.end_date
        }

      render json: request_hash, status: :created
    else
      render json: request.errors, status: :unprocessable_entity
    end
  end

  private

  def employee
    employee = User.find_by(id: params[:employee_id])

    render json: 'An employee does not exist.', status: :not_found and return unless employee

    employee
  end

  def status_param
    return 'all' unless params[:status]

    RequestStatus.pluck(:name).include?(params[:status]) ? params[:status] : 'none'
  end
end
