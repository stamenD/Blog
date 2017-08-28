require 'spec_helper'

RSpec.describe User do

  describe '#password' do
   
    it 'returns true when password matches with original one(for regular users)' do
      user = build(:user)
      expect(user.password).to eq "123qwe"
    end
  
    it 'returns true when password matches with original one(for admins)' do
      user = build(:admin)
      expect(user.password).to eq "123qwe"
    end
  
  end
end