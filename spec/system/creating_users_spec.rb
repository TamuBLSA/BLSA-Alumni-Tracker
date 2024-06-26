# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

RSpec.describe('Creating Users', type: :system) do
  before do
    driven_by(:rack_test)
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
    Rails.application.load_seed
    @location_id = Location.create!(
      country: 'USA',
      state: 'California',
      city: 'San Jose'
    )
    login
  end

  it '(Sunny Day) saves and displays the resulting user using a new location' do
    # login automatically creates a user, so we need to destroy user
    # set_user
    destroy_user
    visit new_user_path

    fill_in 'user_First_Name', with: 'John'
    fill_in 'user_Last_Name', with: 'Doe'
    fill_in 'user_Middle_Name', with: 'M'
    fill_in 'user_Phone_Number', with: '123-456-7890'
    fill_in 'user_Current_Job', with: 'Software Engineer'
    select 'Government', from: 'user_firm_type_id'
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_country', with: 'USA'
    fill_in 'user_location_attributes_state', with: 'New York'
    fill_in 'user_location_attributes_city', with: 'New York'
    fill_in 'user_Linkedin_Profile', with: 'https://www.linkedin.com/in/john-doe'
    select 'Civil Litigation', from: 'user_practice_area_ids'
    select 'Real Estate Law', from: 'user_practice_area_ids'

    click_on 'Save'

    expect(page).to(have_content('John'))
    expect(page).to(have_content('Doe'))
    expect(page).to(have_content('M'))
    expect(page).to(have_content('csce431@gmail.com'))
    expect(page).to(have_content('123-456-7890'))
    expect(page).to(have_content('Software Engineer'))
    expect(page).to(have_content('Government'))
    expect(page).to(have_content('USA'))
    expect(page).to(have_content('New York'))
    expect(page).to(have_content('New York'))
    expect(page).to(have_content('https://www.linkedin.com/in/john-doe'))
    expect(page).to(have_content('Civil Litigation'))
    expect(page).to(have_content('Real Estate Law'))
    expect(@user.is_Admin).to(eq(false))
  end

  it '(Rainy Day) does not save the user if the First Name is missing' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    fill_in 'user_First_Name', with: ''
    click_on 'Save'
    expect(page).to(have_content("First name can't be blank"))
  end

  it '(Rainy Day) does not save the user if the Last Name is missing' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    fill_in 'user_Last_Name', with: ''
    click_on 'Save'
    expect(page).to(have_content("Last name can't be blank"))
  end

  it '(Rainy Day) does not save the user if the Current Job is missing' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    fill_in 'user_Current_Job', with: ''
    click_on 'Save'
    expect(page).to(have_content("Current job can't be blank"))
  end

  # not sure how to add rainy day case since user only has the options given to them
  # it '(Rainy Day) does not save the user if the Firm Type is missing' do
  #   visit new_user_path
  #   select '', from: 'user_firm_type_id'
  #   click_on 'Save'
  #   expect(page).to(have_content("Firm Type can't be blank"))
  # end

  it '(Rainy Day) does not save the user if the Linkedin Profile is not a valid link' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    fill_in 'user_Linkedin_Profile', with: 'test'
    click_on 'Save'
    expect(page).to(have_content('Linkedin profile must be a valid LinkedIn URL or blank'))
  end

  it '(Rainy Day) does not save the user if the Linkedin Profile link is not to linkedin' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    fill_in 'user_Linkedin_Profile', with: 'https://www.myspace.com/john-doe'
    click_on 'Save'
    expect(page).to(have_content('Linkedin profile must be a valid LinkedIn URL or blank'))
  end

  it '(Rainy Day) does not save the user if the Practice Area is missing' do
    visit new_user_path
    select @location_id.city, from: 'user_location_id'
    click_on 'Save'
    expect(page).to(have_content("Practice areas can't be blank"))
  end

  it '(Rainy Day) does not save if user leaves country field blank' do
    visit new_user_path
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_country', with: ''

    click_on 'Save'
    expect(page).to(have_content('Country can\'t be blank'))
  end

  it '(Rainy Day) does not save if user leaves state field blank' do
    visit new_user_path
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_state', with: ''

    click_on 'Save'
    expect(page).to(have_content('State can\'t be blank'))
  end

  it '(Rainy Day) does not save if users leaves city field blank' do
    visit new_user_path
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_city', with: ''

    click_on 'Save'
    expect(page).to(have_content('City can\'t be blank'))
  end
end
