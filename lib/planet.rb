class Planet < ActiveRecord::Base

  belongs_to :galaxy
  # belongs_to :user, through: :galaxies
  belongs_to :planet_type
  has_one :user, through: :galaxy

end
