class CreateParkings < ActiveRecord::Migration[5.0]
  def change
    create_table :parkings do |t|
      t.string :plate
      t.datetime :entrance
      t.datetime :departure
      t.boolean :pay
      t.boolean :left

      t.timestamps
    end
  end
end
