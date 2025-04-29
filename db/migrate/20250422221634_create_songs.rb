class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :youtube_url
      t.boolean :cached
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
