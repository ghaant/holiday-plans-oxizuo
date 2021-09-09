class Request < ApplicationRecord
  belongs_to :status, class_name: 'RequestStatus'
  belongs_to :employee, class_name: 'User'

  before_validation :set_default_status, on: :create
  before_validation :set_resolved_at, on: :update

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :employee, presence: true
  validate :start_date_cannot_be_in_the_past, on: :create
  validate :start_date_cannot_be_greater_than_end_date
  validate :employee_cannot_have_overlapping_requests, on: :create
  validate :employee_doesnot_have_enough_days, on: :create
  validate :resolved_at_must_be_nil_when_pending

  scope :pending,  -> { where(status: RequestStatus.find_by(name: 'pending')) }
  scope :approved, -> { where(status: RequestStatus.find_by(name: 'approved')) }
  scope :rejected, -> { where(status: RequestStatus.find_by(name: 'rejected')) }

  scope :by_date, ->(date) { where('? BETWEEN start_date AND end_date', date) }

  def resolved_by
    status.name != 'pending' ? employee&.manager : nil
  end

  private

  def set_default_status
    self.status = RequestStatus.find_by(name: 'pending')
  end

  def set_resolved_at
    self.resolved_at = status.name != 'pending' ? Date.today : nil
  end

  def start_date_cannot_be_in_the_past
    errors.add(:start_date, 'must be in the future') if start_date && start_date <= Date.today
  end

  def start_date_cannot_be_greater_than_end_date
    errors.add(:end_date, 'must be greater than or equal to start date') if start_date && end_date && start_date > end_date
  end

  def employee_cannot_have_overlapping_requests
    if start_date && end_date &&
      Request.where(employee: employee).where.not('start_date > ? OR end_date < ?', end_date, start_date).exists?

      errors.add(:base, 'A new employee request overlaps with existing ones.')
    end
  end

  def employee_doesnot_have_enough_days
    return unless start_date && end_date 

    current_date = Date.today
    this_year_end_date = current_date.end_of_year

    this_year_request_days =
      1 +
      (
        if this_year_end_date.between?(start_date, end_date)
          this_year_end_date - start_date
        else
          end_date - start_date
        end
      ).to_i

    if employee && this_year_request_days > employee.this_year_remaining_vacation_days
      errors.add(:base, 'The employee does not have enough vacation days.')
    end
  end

  def resolved_at_must_be_nil_when_pending
    if status.name == 'pending' && resolved_at.present?
      errors.add(:resolved_at, 'a pending request can not have resolving time.')
    end
  end
end
