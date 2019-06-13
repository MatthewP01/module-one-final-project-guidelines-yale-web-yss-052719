require_relative '../config/environment.rb'
require 'shoulda/matchers'

describe "Galaxy Class" do 
    galaxy = Galaxy.create(name: "A Galaxy", user_id: 1)
    planet_type = PlanetType.create(name: "A Planet Resource")
    planet = Planet.create(name: "A Planet", planet_type_id: planet_type.id, galaxy_id: galaxy.id)
    it 'should have a name' do
        expect(galaxy.name).to eq("A Galaxy")
    end
    it 'should have a user id' do
        expect(galaxy.user_id).to eq(1)
    end

    it 'should have many planet types through planets' do
        expect(galaxy.planet_types).to include(planet_type)
        # expect(galaxy).to have_many(:planet_types)
    end
end