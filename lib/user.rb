class User < ActiveRecord::Base

  has_many :galaxies
  has_many :planets, through: :galaxies

end
