require 'rails_helper'

feature "Welcome screen" do

  scenario 'a regular users sees it the first time he logs in' do
    user = create(:user)

    login_through_form_as(user)

    expect(current_path).to eq(welcome_path)
  end

  scenario 'a regular user does not see it when coing to /email' do

    plain, encrypted = Devise.token_generator.generate(User, :email_verification_token)

    user = create(:user, email_verification_token: plain)

    visit email_path(email_verification_token: encrypted)

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'

    expect(page).to have_content("You are a verified user")

    expect(current_path).to eq(account_path)
  end

  scenario 'it is not shown more than once' do
    user = create(:user, sign_in_count: 2)

    login_through_form_as(user)

    expect(current_path).to eq(proposals_path)
  end

  scenario 'is not shown to organizations' do
    organization = create(:organization)

    login_through_form_as(organization.user)

    expect(current_path).to eq(proposals_path)
  end

  scenario 'it is not shown to level-2 users' do
    user = create(:user, residence_verified_at: Time.current, confirmed_phone: "123")

    login_through_form_as(user)

    expect(current_path).to eq(proposals_path)
  end

  scenario 'it is not shown to level-3 users' do
    user = create(:user, verified_at: Time.current)

    login_through_form_as(user)

    expect(current_path).to eq(proposals_path)
  end

  scenario 'is not shown to administrators' do
    administrator = create(:administrator)

    login_through_form_as(administrator.user)

    expect(current_path).to eq(proposals_path)
  end

end
