require 'rails_helper'

feature 'Proposals' do

  background do
    login_as_manager
  end

  context "Create" do

    scenario 'Creating proposals on behalf of someone' do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Create proposal"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end

      fill_in 'proposal_title', with: 'Help refugees'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in 'proposal_description', with: 'This is very important because...'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_video_url', with: 'http://youtube.com'
      check 'proposal_terms_of_service'

      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'

      expect(page).to have_content 'Help refugees'
      expect(page).to have_content '¿Would you like to give assistance to war refugees?'
      expect(page).to have_content 'In summary, what we want is...'
      expect(page).to have_content 'This is very important because...'
      expect(page).to have_content 'http://rescue.org/refugees'
      expect(page).to have_content 'http://youtube.com'
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)

      expect(current_path).to eq(management_proposal_path(Proposal.last))
    end

    scenario "Should not allow unverified users to create proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create proposal"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Show" do
    scenario 'When path matches the friendly url' do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      right_path = management_proposal_path(proposal)
      visit right_path

      expect(current_path).to eq(right_path)
    end

    scenario 'When path does not match the friendly url' do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      right_path = management_proposal_path(proposal)
      old_path = "#{management_proposals_path}/#{proposal.id}-something-else"
      visit old_path

      expect(current_path).to_not eq(old_path)
      expect(current_path).to eq(right_path)
    end
  end

  scenario "Searching" do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")

    user = create(:user, :level_two)
    login_managed_user(user)

    click_link "Support proposals"

    fill_in "search", with: "what you got"
    click_button "Search"

    expect(current_path).to eq(management_proposals_path)

    within("#proposals") do
      expect(page).to have_css('.proposal', count: 1)
      expect(page).to have_content(proposal1.title)
      expect(page).to have_content(proposal1.summary)
      expect(page).to_not have_content(proposal2.title)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal1)}']", text: proposal1.title)
    end
  end

  scenario "Listing" do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")

    user = create(:user, :level_two)
    login_managed_user(user)

    click_link "Support proposals"

    expect(current_path).to eq(management_proposals_path)

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content "#{user.username}"
      expect(page).to have_content "#{user.email}"
      expect(page).to have_content "#{user.document_number}"
    end

    within("#proposals") do
      expect(page).to have_css('.proposal', count: 2)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal1)}']", text: proposal1.title)
      expect(page).to have_content(proposal1.summary)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal2)}']", text: proposal2.title)
      expect(page).to have_content(proposal2.summary)
    end
  end

  context "Voting" do

    scenario 'Voting proposals on behalf of someone in index view', :js do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      within("#proposals") do
        find('.in-favor a').click

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this proposal. Share it!"
      end
      expect(current_path).to eq(management_proposals_path)
    end

    scenario 'Voting proposals on behalf of someone in show view', :js do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      within("#proposals") do
        click_link proposal.title
      end

      find('.in-favor a').click
      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this proposal. Share it!"
      expect(current_path).to eq(management_proposal_path(proposal))
    end

    scenario "Should not allow unverified users to vote proposals" do
      proposal = create(:proposal)

      user = create(:user)
      login_managed_user(user)

      click_link "Support proposals"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Printing" do

    scenario 'Printing proposals' do
      6.times { create(:proposal) }

      click_link "Print proposals"

      expect(page).to have_css('.proposal', count: 5)
      expect(page).to have_css("a[href='javascript:window.print();']", text: 'Print')
    end

    scenario "Filtering proposals to be printed", :js do
      create(:proposal, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:proposal, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Medium proposal').update_column(:confidence_score, 5)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Print proposals"

      expect(page).to have_selector('.js-order-selector[data-order="confidence_score"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      select 'newest', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

      expect(current_url).to include('order=created_at')
      expect(current_url).to include('page=1')

      within '#proposals' do
        expect('Medium proposal').to appear_before('Best proposal')
        expect('Best proposal').to appear_before('Worst proposal')
      end
    end

  end
end
