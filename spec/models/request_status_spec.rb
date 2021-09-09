require 'rails_helper'

RSpec.describe RequestStatus, type: :model do
  describe 'Validations' do
    context 'when name is present' do
      context 'when name belongs to the allowed stack' do
        it { expect(RequestStatus.new(name: 'approved').valid?).to be(true) }
      end

      context 'when name does not belong to the allowed stack' do
        it { expect(RequestStatus.new(name: 'blahblah').valid?).to be(false) }
      end
    end

    context 'when name is not present' do
      it { expect(RequestStatus.new().valid?).to be(false) }
    end
  end
end
