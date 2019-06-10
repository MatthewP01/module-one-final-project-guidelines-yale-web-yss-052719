class PlanetType < ActiveRecord::Base

  has_many :planets
  # belongs_to :galaxy, through: :planets

end
