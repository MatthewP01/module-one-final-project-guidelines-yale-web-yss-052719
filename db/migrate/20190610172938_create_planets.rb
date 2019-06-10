class CreatePlanets < ActiveRecord::Migration[5.0]
  def change
    create_table :planets do |t|
      t.string :name
      t.integer :planet_type_id
      t.integer :galaxy_id
    end
  end
end
