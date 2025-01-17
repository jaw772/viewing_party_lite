require 'rails_helper'

RSpec.describe "User Show/Dashboard Page" do

  before(:each) do
    @user_1 = User.create!(username: 'john', email: 'john@gmail.com', password: 'supersecret')
    visit '/login'
    fill_in :username, with: 'john'
    fill_in :password, with: 'supersecret'
    click_on  'Log In'
    @user_2 = User.create!(username: 'sarah', email: 'sarah@gmail.com', password: 'supersecret123')

    @party_1 = ViewingParty.create!(movie_id: 2, duration: 130, start_date: '2022-02-01 21:26:47', user_id: @user_1.id)
    @party_2 = ViewingParty.create!(movie_id: 11, duration: 150, start_date: '2023-02-01 21:26:47', user_id: @user_2.id)
    @party_3 = ViewingParty.create!(movie_id: 33, duration: 1000, start_date: '2024-02-01 21:26:47', user_id: @user_2.id)
    # binding.pry
    PartyUser.create(viewing_party_id: @party_2.id, user_id: @user_1.id)
    PartyUser.create(viewing_party_id: @party_1.id, user_id: @user_2.id)

    json_movie_11 = File.read('./spec/fixtures/movie_11.json')
    json_movie_2 = File.read('./spec/fixtures/movie_2.json')
    json_credits_movie_11 = File.read('./spec/fixtures/credits_movie_11.json')
    json_credits_movie_2 = File.read('./spec/fixtures/credits_movie_2.json')
    json_reviews_movie_11 = File.read('./spec/fixtures/reviews_movie_11.json')
    json_reviews_movie_2 = File.read('./spec/fixtures/reviews_movie_2.json')
    # binding.pry
    stub_request(:get, "https://api.themoviedb.org/3/movie/11?api_key=#{ENV['movie_api_key']}&language=en-US").
         to_return(status: 200, body: json_movie_11, headers: {})
    stub_request(:get, "https://api.themoviedb.org/3/movie/2?api_key=#{ENV['movie_api_key']}&language=en-US").
         to_return(status: 200, body: json_movie_2, headers: {})
    stub_request(:get, "https://api.themoviedb.org/3/movie/2/credits?api_key=#{ENV['movie_api_key']}&language=en-US").
         to_return(status: 200, body: json_credits_movie_2, headers: {})
    stub_request(:get, "https://api.themoviedb.org/3/movie/11/credits?api_key=#{ENV['movie_api_key']}&language=en-US").
         to_return(status: 200, body: json_credits_movie_11, headers: {})
    stub_request(:get, "https://api.themoviedb.org/3/movie/2/reviews?api_key=#{ENV['movie_api_key']}&language=en-US&page=1").
         to_return(status: 200, body: json_reviews_movie_2, headers: {})
    stub_request(:get, "https://api.themoviedb.org/3/movie/11/reviews?api_key=#{ENV['movie_api_key']}&language=en-US&page=1").
         to_return(status: 200, body: json_reviews_movie_11, headers: {})
    visit "/dashboard"
  end

  it 'displays username of user' do
    expect(page).to have_content("john's Dashboard")
  end

  it 'has a button to discover movies' do
    expect(page).to have_button("Discover Movies")
  end

  it 'the discover movies button takes you to correct path' do
    click_on "Discover Movies"

    expect(current_path).to eq("/discover")
  end

  it 'lists viewing parties' do
    # strftime("%-d %B %Y,%l:%M %P")
    within "#party-#{@party_1.id}" do
      expect(page).to have_content("Hosted By: john")
      expect(page).to have_link("Ariel")
      expect(page).to have_content("1 February 2022, 9:26 pm")
      expect(page).to have_content("Hosting")

      expect(page).to have_content('Guest: sarah')
    end
    within "#party-#{@party_2.id}" do
      expect(page).to have_content("Hosted By: sarah")
      expect(page).to have_link("Star Wars")
      expect(page).to have_content("1 February 2023, 9:26 pm")
      expect(page).to have_content("Invited")

      expect(page).to have_content('Guest: john')
    end

    expect(page).to_not have_content("Unforgiven")
  end

  it 'viewing party links take you to correct path - #1' do
    within "#party-#{@party_1.id}" do
      click_on("Ariel")
      expect(current_path).to eq("/movies/#{@party_1.movie_id}")
    end
  end

  it 'viewing party links take you to correct path - #2' do
    within "#party-#{@party_2.id}" do
      click_on("Star Wars")
      expect(current_path).to eq("/movies/#{@party_2.movie_id}")
    end
  end

end
