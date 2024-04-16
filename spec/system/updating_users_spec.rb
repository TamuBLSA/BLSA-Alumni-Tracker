# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

RSpec.describe('Updating Users', type: :system) do
  before do
    driven_by(:rack_test)

    Rails.application.load_seed
    @practice_area = PracticeArea.find_by(practice_area: 'Civil Litigation')
    @firm_type = FirmType.create!(
      firm_type: 'Example Firm Type'
    )
    @location_id = Location.create!(
      country: 'USA',
      state: 'New York',
      city: 'New York'
    )

    @user = User.create!(
      First_Name: 'John',
      Last_Name: 'Doe',
      Middle_Name: 'M',
      Profile_Picture: 'https://www.google.com',
      Email: 'csce431@gmail.com',
      Phone_Number: '123-456-7890',
      Current_Job: 'Software Engineer',
      firm_type_id: @firm_type.id,
      location_id: @location_id.id,
      Linkedin_Profile: 'https://www.linkedin.com/in/john-doe',
      practice_areas: [@practice_area],
      is_Admin: true
    )

    @user2 = User.create!(
      First_Name: 'John',
      Last_Name: 'Doe',
      Middle_Name: 'M',
      Profile_Picture: 'https://www.google.com',
      Email: 'NOTcsce431@gmail.com',
      Phone_Number: '123-456-7890',
      Current_Job: 'Software Engineer',
      firm_type_id: @firm_type.id,
      # Location: 'New York',
      location_id: @location_id.id,
      Linkedin_Profile: 'https://www.linkedin.com/in/john-doe',
      practice_areas: [@practice_area],
      is_Admin: false
    )

    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

    login
  end

  # it 'does not save the user if the First Name is missing' do
  #   visit edit_user_path
  #   fill_in 'First name', with: ''
  #   click_on 'Save'
  #   expect(page).to have_content("First name can't be blank")
  # end

  it '(Sunny Day) Update First Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_First_Name', with: 'Jane'

    click_on 'Save'

    expect(page).to(have_content('Jane'))
  end

  it '(Rainy Day) Empty First Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_First_Name', with: ''

    click_on 'Save'

    expect(page).to(have_content("First name can't be blank"))
  end

  it '(Sunny Day) Update Last Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_Last_Name', with: 'Smith'

    click_on 'Save'

    expect(page).to(have_content('Smith'))
  end

  it '(Rainy Day) Empty Last Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_Last_Name', with: ''

    click_on 'Save'

    expect(page).to(have_content("Last name can't be blank"))
  end

  it '(Sunny Day) Update Middle Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_Middle_Name', with: 'L'

    click_on 'Save'

    expect(page).to(have_content('L'))
  end

  it '(Sunny Day) Empty Middle Name' do
    visit edit_user_path(@user.id)

    fill_in 'user_Middle_Name', with: ''

    click_on 'Save'

    expect(page).to(have_content('Profile was successfully updated.'))
  end

  it '(Sunny Day) Update Phone Number' do
    visit edit_user_path(@user.id)

    fill_in 'user_Phone_Number', with: '555-555-5555'

    click_on 'Save'

    expect(page).to(have_content('555-555-5555'))
  end

  it '(Sunny Day) Empty Phone Number' do
    visit edit_user_path(@user.id)

    fill_in 'user_Phone_Number', with: ''

    click_on 'Save'

    expect(page).to(have_content('Profile was successfully updated.'))
  end

  it '(Sunny Day) Update Current Job' do
    visit edit_user_path(@user.id)

    fill_in 'user_Current_Job', with: 'Lawyer'

    click_on 'Save'

    expect(page).to(have_content('Lawyer'))
  end

  it '(Rainy Day) Empty Current Job' do
    visit edit_user_path(@user.id)

    fill_in 'user_Current_Job', with: ''

    click_on 'Save'

    expect(page).to(have_content("Current job can't be blank"))
  end

  it '(Sunny Day) Update Firm Type' do
    @firm_type_new = FirmType.create!(
      firm_type: 'New Firm Type'
    )
    visit edit_user_path(@user.id)

    select @firm_type_new.firm_type, from: 'user_firm_type_id'

    click_on 'Save'

    expect(page).to(have_content(@firm_type_new.firm_type))
  end

  it '(Sunny Day) Update Location to an existing location' do
    @new_location_id = Location.create!(
      country: 'USA',
      state: 'California',
      city: 'San Jose'
    )
    visit edit_user_path(@user.id)
    select @new_location_id.city, from: 'user_location_id'

    click_on 'Save'
    expect(page).to(have_content(@new_location_id.location_string))
  end

  it '(Sunny Day) Update Location to a new location' do
    visit edit_user_path(@user.id)

    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_country', with: 'USA'
    fill_in 'user_location_attributes_state', with: 'California'
    fill_in 'user_location_attributes_city', with: 'San Jose'

    click_on 'Save'
    expect(page).to(have_content('San Jose, California, USA'))
  end

  it '(Rainy Day) Update Location select existing location, and fill out new location areas' do
    @new_location_id = Location.create!(
      country: 'USA',
      state: 'California',
      city: 'San Jose'
    )
    visit edit_user_path(@user.id)
    select @new_location_id.city, from: 'user_location_id'

    fill_in 'user_location_attributes_country', with: 'USA'
    fill_in 'user_location_attributes_state', with: 'California'
    fill_in 'user_location_attributes_city', with: 'San Jose'

    click_on 'Save'
    expect(page).to(have_content(@new_location_id.location_string))
  end

  it '(Rainy Day) Update Location to a new location, but leave country field blank' do
    visit edit_user_path(@user.id)
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_country', with: ''

    click_on 'Save'
    expect(page).to(have_content('Country can\'t be blank'))
  end

  it '(Rainy Day) Update Location to a new location, but leave state field blank' do
    visit edit_user_path(@user.id)
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_state', with: ''

    click_on 'Save'
    expect(page).to(have_content('State can\'t be blank'))
  end

  it '(Rainy Day) Update Location to a new location, but leave city field blank' do
    visit edit_user_path(@user.id)
    select 'Create new location', from: 'user_location_id'
    fill_in 'user_location_attributes_city', with: ''

    click_on 'Save'
    expect(page).to(have_content('City can\'t be blank'))
  end

  it '(Sunny Day) Update Linkedin Profile to valid url' do
    visit edit_user_path(@user.id)

    fill_in 'user_Linkedin_Profile', with: 'https://www.linkedin.com/in/john-doe2'

    click_on 'Save'

    expect(page).to(have_content('https://www.linkedin.com/in/john-doe2'))
  end

  it '(Sunny Day) Update Linkedin Profile to www url with no leading https' do
    visit edit_user_path(@user.id)

    fill_in 'user_Linkedin_Profile', with: 'www.linkedin.com/in/john-doe2'

    click_on 'Save'

    expect(page).to(have_content('https://www.linkedin.com/in/john-doe2'))
  end

  it '(Sunny Day) Update Linkedin Profile to blank' do
    visit edit_user_path(@user.id)

    fill_in 'user_Linkedin_Profile', with: ''

    click_on 'Save'

    expect(page).to(have_content('Profile was successfully updated.'))
  end

  it '(Rainy Day) Linkedin Profile is invalid' do
    visit edit_user_path(@user.id)

    fill_in 'user_Linkedin_Profile', with: 'test'

    click_on 'Save'

    expect(page).to(have_content('Linkedin profile must be a valid LinkedIn URL or blank'))
  end

  it '(Rainy Day) Invalid Linkedin Profile url' do
    visit edit_user_path(@user.id)

    fill_in 'user_Linkedin_Profile', with: 'https://www.lonkedin.com/in/john-doe'

    click_on 'Save'

    expect(page).to(have_content('Linkedin profile must be a valid LinkedIn URL or blank'))
  end

  it '(Rainy Day) User cannot edit a profile that is not theirs' do
    set_admin_false

    visit edit_user_path(@user2.id)

    fill_in 'user_First_Name', with: 'Jane'

    click_on 'Save'

    expect(page).to(have_content('You can only update your own profile.'))
  end

  it '(Sunny Day) Admin users can edit a profile that is not theirs' do
    set_admin_true
    visit edit_user_path(@user2.id)

    fill_in 'user_First_Name', with: 'Jane'

    click_on 'Save'

    expect(page).to(have_content('Jane'))
  end

  it '(Sunny Day) Admin can promote another user to admin' do
    set_admin_true
    visit edit_user_path(@user2.id)

    check 'user_is_Admin'

    click_on 'Save'

    expect(page).to(have_content('true'))
  end

  it '(Rainy Day) Admin cannot remove their own admin status' do
    set_admin_true
    visit edit_user_path(@user.id)

    uncheck 'user_is_Admin'

    click_on 'Save'

    expect(page).to(have_content('You cannot change your own admin status.'))
  end

  it '(Rainy Day) BLSA gmail account cannot be edited, even by an admin' do
    set_admin_true
    blsa_user = User.find_by(Email: 'blsa.tamu@gmail.com')
    visit edit_user_path(blsa_user.id)

    # Attempt to edit the user
    uncheck 'user_is_Admin'

    click_on 'Save'

    expect(page).to(have_content('This account cannot be edited.'))
  end
end
