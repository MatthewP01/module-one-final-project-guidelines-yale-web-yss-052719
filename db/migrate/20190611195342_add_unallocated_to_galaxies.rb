class AddUnallocatedToGalaxies < ActiveRecord::Migration[5.2]
  def change
    add_column :galaxies, :unallocated, :integer
  end
end
