require 'rails_helper'

feature "Admin custom images" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Upload valid image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom Images"
    end

    within("tr.logo_header") do
      attach_file "site_customization_image_image", "spec/fixtures/files/logo_header.png"
      click_button "Update"
    end

    expect(page).to have_css("tr.logo_header img[src*='logo_header.png']")
    expect(page).to have_css("img[src*='logo_header.png']", count: 2) # one in the admin form an one in the page header
  end

  scenario "Upload invalid image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom Images"
    end

    within("tr.icon_home") do
      attach_file "site_customization_image_image", "spec/fixtures/files/logo_header.png"
      click_button "Update"
    end

    expect(page).to have_content("Width must be 330px")
    expect(page).to have_content("Height must be 240px")
  end

  scenario "Delete image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom Images"
    end

    within("tr.social-media-icon") do
      attach_file "site_customization_image_image", "spec/fixtures/files/social-media-icon.png"
      click_button "Update"
    end

    expect(page).to have_css("img[src*='social-media-icon.png']")

    within("tr.social-media-icon") do
      click_link "Delete"
    end

    expect(page).to_not have_css("img[src*='social-media-icon.png']")
  end
end
