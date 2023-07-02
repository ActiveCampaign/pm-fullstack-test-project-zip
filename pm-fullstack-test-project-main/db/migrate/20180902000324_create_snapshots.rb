class CreateSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :snapshots do |t|
      t.text :data, limit: 64.kilobytes

      t.timestamps
    end
  end
end
