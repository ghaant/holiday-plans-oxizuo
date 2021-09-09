class RequestStatus < ApplicationRecord
  has_many :requests, foreign_key: 'status_id', dependent: :restrict_with_exception

  validates :name, presence: true, inclusion: { in: %w[pending approved rejected] }, uniqueness: true
end
