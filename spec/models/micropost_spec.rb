require 'spec_helper'

describe Micropost do
	let(:myUser) { FactoryGirl.create(:user) }
	
	before do
		@micropost = myUser.microposts.build(content: "It is a jungle out there")
	end
	
	subject { @micropost }
	
	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:user) }
	its(:user) { should == myUser }
		
	it { should be_valid }
	
	describe "accessible attributes" do
  		it "should not allow access to user_id" do
  			expect do
  				Micropost.new(user_id: "1")
  			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
  		end
  	end

	describe "when user_id is not present" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end

	describe "with blank content" do
		before { @micropost.content = " "}
		it { should_not be_valid }
	end

	describe "with content that is too long" do
		before { @micropost.content = "a" * 141 }
		it { should_not be_valid }
	end
end
