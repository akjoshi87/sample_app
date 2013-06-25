include ApplicationHelper

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-error', text: 'Invalid')
	end
end

def sign_in(myUser)
	visit signin_path
	fill_in "Email", with: myUser.email
	fill_in "Password", with: myUser.password
	click_button "Sign in"
	# Sign in when not using Capybara
	cookies[:remember_token] = myUser.remember_token
end
