require 'rails_helper'

RSpec.describe "New User Form" do

  before(:each) do
    visit '/register'
  end

  it 'displays the fields' do
    expect(page).to have_field(:user_username)
    expect(page).to have_field(:user_email)
    expect(page).to have_field(:user_password)
    expect(page).to have_field(:user_password_confirmation)

    expect(page).to have_button("Register")
  end

  it 'takes to dashboard after submitting' do
    fill_in(:user_username, with: 'john')
    fill_in(:user_email, with: 'john@yahoo.com')
    fill_in(:user_password, with: 'password123')
    fill_in(:user_password_confirmation, with: 'password123')
    click_on "Register"

    added_user = User.where(username: 'john', email: 'john@yahoo.com').first

    expect(current_path).to eq("/dashboard")
  end

  context 'sad paths' do
    it 'doesnt accept blank fields' do
      click_on "Register"

      expect(current_path).to eq('/register')
      expect(page).to have_content("username can't be blank")
      expect(page).to have_content("email can't be blank")
      expect(page).to have_content("password can't be blank")
    end

    it 'doesnt allow taken emails/usernames' do
      user = User.create!(username: 'taken_username', email: 'taken_email', password: '123', password_confirmation: '123')

      fill_in(:user_username, with: 'taken_username')
      fill_in(:user_email, with: 'taken_email')
      click_on "Register"

      expect(current_path).to eq('/register')
      expect(page).to have_content("username has already been taken")
      expect(page).to have_content("email has already been taken")
    end

    it 'doesnt allow unmatching passwords and case sensitive' do
      fill_in(:user_username, with: 'john')
      fill_in(:user_email, with: 'john@yahoo.com')
      fill_in(:user_password, with: 'password123')
      fill_in(:user_password_confirmation, with: 'Password123')
      click_on "Register"

      expect(current_path).to eq('/register')
      expect(page).to have_content("Passwords do not match")
    end
  end

end
