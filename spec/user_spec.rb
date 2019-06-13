require_relative '../config/environment.rb'

describe "User Class" do
    user = User.new(name: "A")
    it 'should have a name' do
        expect(user.name).to eq("A")
    end
end
