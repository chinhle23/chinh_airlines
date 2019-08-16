class CreateFlights < ActiveRecord::Migration[5.1]
  def change
    create_table :flights do |t|
      t.string :origin
      t.string :destination
      t.integer :price

      t.timestamps
    end
  end
end
