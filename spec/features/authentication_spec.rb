require 'spec_helper'
RSpec.describe 'Authentication', type: :feature do
 
  def create_valid_accоunt
    visit '/register'
    within 'form' do
      fill_in 'username', with: 'martin'
      fill_in 'password', with: '123qwe'
      fill_in 'mail', with: 'prime@abv.bg'
    end
    click_button 'create' 	
    expect(page.status_code).to eq(200)
  end

  describe 'register' do
    it 'can create a user' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime@abv.bg'
      end

      click_button 'create'
      expect(page.status_code).to eq(200)
      expect(User.all.size).to eq 1
    end

    it 'can not create a user because invalid email' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime'
      end

      click_button 'create'
      expect(page.status_code).to eq(403)
       # expect(last_response).not_to be_ok
      # expect(last_response.status).to eq(403)
      # expect(last_response.body).to include('email')
      # expect(last_response.body).to include('username')
      expect(User.all.size).to eq 0
    end
    
    it 'can not create a user because invalid username' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'mm'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime'
      end

      click_button 'create'
      expect(page.status_code).to eq(403)
      expect(User.all.size).to eq 0
    end  

    it 'can not create a user because invalid password' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime'
      end

      click_button 'create'
      expect(page.status_code).to eq(403)
      expect(User.all.size).to eq 0
    end
   
    it 'does not create users with duplicate username' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'kirila'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime@abv.bg'
      end
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'kirila'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime2@abv.bg'
      end
      click_button 'create'
      expect(User.all.size).to eq 1
    end

    it 'does not create users with duplicate email' do
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'kirila1'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime@abv.bg'
      end
      visit '/register'
      within 'form' do
        fill_in 'username', with: 'kirila2'
        fill_in 'password', with: '123qwe'
        fill_in 'mail', with: 'prime@abv.bg'
      end
      click_button 'create'
      expect(User.all.size).to eq 1
    end
  end

  describe "login" do
    it "can login successfull" do
      
      create_valid_accоunt

      visit '/login'
      within 'form[action="/login"]' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qwe'
      end
      click_button 'login'
      expect(page.status_code).to eq(200)
      expect(page.get_rack_session_key('loginUser')).to eq User.first
    end

    it "can not login successfull because invalid username" do
      create_valid_accоunt
      
      visit '/login'
      within 'form[action="/login"]' do
        fill_in 'username', with: 'martinn'
        fill_in 'password', with: '123qwe'
      end
      click_button 'login'          
      session = page.get_rack_session
      result = session.fetch('loginUser', nil)
      expect(result).to eq nil

    end
    it "can not login successfull because invalid password" do
      create_valid_accоunt
      
      visit '/login'
      within 'form[action="/login"]' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qw4'
      end
      click_button 'login'          
      session = page.get_rack_session
      result = session.fetch('loginUser', nil)
      expect(result).to eq nil
    end
  end

  describe "logout" do
  	it 'signs out a user' do
      create_valid_accоunt
      
      visit '/login'
      within 'form[action="/login"]' do
        fill_in 'username', with: 'martin'
        fill_in 'password', with: '123qwe'
      end
      click_button 'login'

      visit '/'
      click_button 'logout'
      expect(page.get_rack_session_key('loginUser')).to eq false
    end
  end 
end