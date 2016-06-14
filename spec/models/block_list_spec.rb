require 'rails_helper'

RSpec.describe BlockList, type: :model do
  describe 'When creating new block list' do
    it 'should not create without block ip' do
      block_list = BlockList.new ({ active: true })

      expect(block_list.invalid?).to be_truthy
      expect { block_list.save! }.to raise_error( ActiveRecord::RecordInvalid, "Validation failed: Block ip can't be blank" )
    end
  end
end