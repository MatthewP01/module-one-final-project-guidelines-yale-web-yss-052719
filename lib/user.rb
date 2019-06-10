class User < ActiveRecord::Base

  has_many :galaxies
  has_many :planets, through: :galaxies

  # attr_accessor :name

  # @@all = []
  #
  # def initialize(id = nil, name)
  #   @id = id
  #   @name = name
  #
  #   @@all << self
  # end
  #
  # def self.all
  #   @@all
  # end




end
