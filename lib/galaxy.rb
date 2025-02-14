class Galaxy < ActiveRecord::Base

  has_many :planets
  has_many :planet_types, through: :planets
  belongs_to :user

  # attr_accessor :name

  def attributes(attribute)
    resource_attr = Planet.all.select do |planet|
      planet.planet_type.name = attribute
    end.count
  end

  def create_planets(num, type_id)
    num.times do
      new_planet = Planet.create(planet_type_id: type_id, galaxy_id: self.id)
      self.planets << new_planet
    end
  end

  def count_planets(type_id)
    self.planets.select do |planet|
      planet.planet_type_id == type_id
    end.count
  end

end
