require 'spec_helper'

describe "AuthenticationPages" do
	subject { page }
		
	describe "signin page" do
		before { visit signin_path }
		
		it { should have_selector('h1', text: 'Sign in') }
		it { should have_selector('title', text: 'Sign in') }
	end
	
	describe "signin" do
		before { visit signin_path }
		
		describe "with invalid information" do
			before { click_button "Sign in" }

			it { should have_selector('title', text: 'Sign in') }
			it { should have_error_message }
			
			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_error_message }
			end
		end
		
		describe "with valid information" do
			let(:myUser) { FactoryGirl.create(:user) }
			before { sign_in myUser }
			
			it { should have_selector('title', text: myUser.name) }
			it { should have_link('Profile', href: user_path(myUser)) }
			it { should have_link('Sign out', href: signout_path) }
			it { should have_link('Settings', href: edit_user_path(myUser)) }
			it { should have_link('Users', href: users_path) }
			it { should_not have_link('Sign in', href: signin_path) }
			
			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in', href: signin_path) }
			end
		end
	end
	
		
	describe "authorization" do
		describe "for non-signed-in users" do
			let(:myUser) { FactoryGirl.create(:user) }
			
			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(myUser) 
					sign_in myUser
				end
				
				describe "after signin in" do
					it "should render the desired protected page" do
						page.should have_selector('title', text: 'Edit user')
					end
					
					describe "when signing in again" do
						before do
							click_link "Sign out"
							click_link "Sign in"
							sign_in myUser
						end
						
						it "should render the default(profile) page" do
							page.should have_selector('title', text: myUser.name)
						end
					end
				end
			end
			
			describe "in the Users controller" do
				describe "visiting the edit page" do
					before { visit edit_user_path(myUser) }
					it { should have_selector('title', text: 'Sign in') }
					it { should have_selector('div.alert.alert-notice') }
				end
				
				describe "submitting to the update action" do
					before { put user_path(myUser) }
					specify { response.should redirect_to(signin_path) }
				end
				
				describe "visiting the user index" do
					before { visit users_path }
					it{ should have_selector('title', text: 'Sign in') }					
				end
			end
		end
		
		describe "as wrong user" do
			let(:myUser) { FactoryGirl.create(:user) }
			let(:wrongUser) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in myUser }
			
			describe "visiting Users#edit page" do
				before { visit edit_user_path(wrongUser) }				
				it { should_not have_selector('title', text: 'Edit user') }
			end
			
			describe "submitting a PUT request to the Users#update action" do
				before { put user_path(wrongUser) }
				specify { response.should redirect_to(root_path) }
			end
		end
		
		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }
			
			before { sign_in non_admin }
			
			describe "submitting a DELETE request to Users#destroy action" do
				before { delete user_path(user) }
				
				specify { response.should redirect_to(root_path) }
			end
		end
	end
end
