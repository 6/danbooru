class CreateNoteVersions < ActiveRecord::Migration
  def self.up
    create_table :note_versions do |t|
      t.column :note_id, :integer, :null => false
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
      t.column :x, :integer, :null => false
      t.column :y, :integer, :null => false
      t.column :width, :integer, :null => false
      t.column :height, :integer, :null => false
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :body, :text, :null => false
      t.timestamps
    end
    
    add_index :note_versions, :note_id
    add_index :note_versions, :updater_id
  end

  def self.down
    drop_table :note_versions
  end
end