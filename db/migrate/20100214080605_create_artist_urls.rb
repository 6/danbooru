class CreateArtistUrls < ActiveRecord::Migration
  def self.up
    create_table :artist_urls do |t|
      t.column :artist_id, :integer, :null => false
      t.column :url, :text, :null => false
      t.column :normalized_url, :text, :null => false
      t.timestamps
    end
    
    add_index :artist_urls, :artist_id
    add_index :artist_urls, :normalized_url
  end

  def self.down
    drop_table :artist_urls
  end
end
