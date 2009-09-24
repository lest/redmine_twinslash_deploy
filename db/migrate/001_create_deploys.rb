class CreateDeploys < ActiveRecord::Migration
  def self.up
    create_table :deploys do |t|
      t.integer :project_id, :null => false
      t.string :name, :default => '', :null => false
      t.string :template, :default => '', :null => false
      t.string :suffix, :default => '', :null => false
      t.string :svn_path, :default => '', :null => false
      t.boolean :is_remote, :default => false, :null => false
    end
  end

  def self.down
    drop_table :deploys
  end
end
