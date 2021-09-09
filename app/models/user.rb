class User < ApplicationRecord
  has_many :subordinates, class_name: 'User', foreign_key: 'manager_id'
  belongs_to :manager, class_name: 'User', optional: true
  has_many :requests, foreign_key: 'employee_id', dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }

  VACATION_DAYS_PER_YEAR = 30

  def this_year_remaining_vacation_days
    current_date = Date.today
    this_year_first_date = current_date.beginning_of_year
    this_year_end_date = current_date.end_of_year

    beginning_of_year_overlapping_request = requests.find do |r|
      this_year_first_date.between?(r.start_date, r.end_date)
    end

    end_of_year_overlapping_request = requests.find do |r|
      this_year_end_date.between?(r.start_date, r.end_date)
    end

    beginning_of_year_booked_days =
      if beginning_of_year_overlapping_request
        (beginning_of_year_overlapping_request.end_date - this_year_first_date).to_i + 1
      else
        0
      end

    end_of_year_booked_days =
      if end_of_year_overlapping_request
        (this_year_end_date - end_of_year_overlapping_request.start_date).to_i + 1
      else
        0
      end

    VACATION_DAYS_PER_YEAR -
      (
        requests
          .where.not(id: [beginning_of_year_overlapping_request&.id, end_of_year_overlapping_request&.id])
          .sum { |r| (r.end_date - r.start_date).to_i + 1 } +
             beginning_of_year_booked_days + end_of_year_booked_days
      )
  end

  def requests_to_resolve
    Request.where(employee: subordinates)
  end
end
