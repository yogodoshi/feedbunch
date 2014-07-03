##
# Test that a user is logged in, during an acceptance test.
#
# To see if the user is logged in, we check the presence of a "Logout" link in the navbar.

def user_should_be_logged_in
  expect(page).to have_css 'div.navbar #user-dropdown', visible: true
end

##
# Test that a user is not logged in, during an acceptance test.
#
# To see if the user is not logged in, we check the absence of a "Logout" link in the navbar.

def user_should_not_be_logged_in
  expect(page).not_to have_css 'div.navbar div.navbar-inner ul li a#sign_out'
end

##
# Test that an email has been sent during acceptance testing. Accepts the following optional named arguments:
#
# - path - if passed, tests that the mail contains a link to this path. Ideally we'd like to test using full URLs
# but this not possible because during testing links inside emails generated by ActionMailer use the hostname
# "www.example.com" instead of the actual "localhost:3000" returned by Rails URL helpers.
# - to - if passed, tests that this is the value of the email's "to" header.
# - text - if passed, tests that this text is present in the email body
#
# Return value is the href of the link if "path" option is passed, nil otherwise.

def mail_should_be_sent(path: nil, to: nil, text: nil)
  email = ActionMailer::Base.deliveries.pop
  expect(email.present?).to be true

  if to.present?
    expect(email.to.first).to eq to
  end

  href = nil
  # Test each part of a multipart email.
  if email.multipart?
    path_ok = false
    text_ok = false
    email.parts.each do |part|
      if path.present?
        partBody = Nokogiri::HTML part.body.to_s
        link = partBody.at_css "a[href*=\"#{path}\"]"
        if link.present?
          path_ok = true
          href = link[:href]
        end
      end

      if text.present?
        text_ok = true if part.body.to_s.include? text
      end
    end

    expect(path_ok).to be true if path.present?
    expect(text_ok).to be true if text.present?
  else
    if path.present?
      emailBody = Nokogiri::HTML email.body.to_s
      link = emailBody.at_css "a[href*=\"#{path}\"]"
      expect(link.present?).to be true
      href = link[:href]
    end

    if text.present?
      expect(email.body.to_s).to include text
    end
  end

  return href
end

##
# Test that no email has been sent during acceptance testing

def mail_should_not_be_sent
  email = ActionMailer::Base.deliveries.pop
  expect(email.present?).to be false
end

##
# Test that the count of unread entries in a folder equals the passed argument.
# Receives as argument the folder and the expected entry count.

def unread_folder_entries_should_eq(folder, count)
  if folder=='all'
    within '#sidebar #folders-list #folder-none #all-feeds span.badge' do
      expect(page).to have_content "#{count}"
    end
  else
    within "#sidebar #folders-list #folder-#{folder.id} #open-folder-#{folder.id} span.folder-unread-badge" do
      expect(page).to have_content "#{count}"
    end
  end
end

##
# Test that the count of unread entries in a feed equals the passed argument.
# Receives as arguments:
# - the feed to look at
# - the expected entry count
# - the user performing the action

def unread_feed_entries_should_eq(feed, count, user)
  folder = feed.user_folder user
  folder_id = folder.try(:id) || 'none'
  open_folder folder if folder.present?
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder_id} a[data-sidebar-feed][data-feed-id='#{feed.id}']"
  within "#sidebar #folders-list #folder-#{folder_id} a[data-sidebar-feed][data-feed-id='#{feed.id}'] span.badge" do
    expect(page).to have_content "#{count}"
  end
end

##
# Test that an alert with the passed id is shown on the page, and that it disappears automatically
# after 5 seconds.

def should_show_alert(alert_id)
  expect(page).to have_css "div##{alert_id}", visible: true

  # It should close automatically after 5 seconds
  sleep 5
  expect(page).not_to have_css "div##{alert_id}", visible: true
end

##
# Test that an alert with the passed id is hidden-

def should_hide_alert(alert_id)
  expect(page).not_to have_css "div##{alert_id}", visible: true
end

##
# Test that the passed entry is visible.

def entry_should_be_visible(entry)
  expect(page).to have_css "#feed-entries #entry-#{entry.id}"
  within "#feed-entries #entry-#{entry.id}" do
    expect(page).to have_text entry.title, visible: true
  end
end

##
# Test that the passed entry is not visible.

def entry_should_not_be_visible(entry)
  expect(page).not_to have_css "#feed-entries #entry-#{entry.id}"
end

##
# Test that the passed entry is visible and marked as read

def entry_should_be_marked_read(entry)
  expect(page).to have_css "a[data-entry-id='#{entry.id}'].entry-read"
end

##
# Test that the passed entry is visible and marked as unread

def entry_should_be_marked_unread(entry)
  expect(page).to have_css "a[data-entry-id='#{entry.id}'].entry-unread"
end

##
# Test that the passed entry is open.

def entry_should_be_open(entry)
  expect(page).to have_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary.in"
end

##
# Test that the passed entry is open.

def entry_should_be_closed(entry)
  expect(page).to have_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary", visible: false
  expect(page).not_to have_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary.in", visible: false
  expect(page).not_to have_text entry.summary
end

##
# Test that the passed feed is currently selected for reading

def feed_should_be_selected(feed)
  expect(page).to have_css "#sidebar .active > [data-sidebar-feed][data-feed-id='#{feed.id}']"
end

##
# Test that the passed folder is open in the sidebar

def folder_should_be_open(folder)
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder.id}"
  expect(page).to have_css "#sidebar #folders-list #feeds-#{folder.id}.in"
end

##
# Test that the passed folder is closed in the sidebar

def folder_should_be_closed(folder)
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder.id}"
  expect(page).not_to have_css "#sidebar #folders-list #feeds-#{folder.id}.in"
end