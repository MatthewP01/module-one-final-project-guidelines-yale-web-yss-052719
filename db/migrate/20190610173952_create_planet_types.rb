class CreatePlanetTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :planet_types do |t|
      t.string :name
    end
  end
end
