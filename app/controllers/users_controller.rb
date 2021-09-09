class UsersController < ApplicationController
  def employee_remaining_vacation_days
    employee = User.find_by(id: params[:employee_id])

    if employee
      render json:
        {
          employee_id: employee.id,
          year: Date.today.year,
          remaining_vacation_days: User.find(params[:employee_id]).this_year_remaining_vacation_days
        }
    else
      render json: 'An employee does not exist.', status: :not_found
    end
  end
end
