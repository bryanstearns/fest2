class CreateActivity < ActiveRecord::Migration
  def self.up
    create_table :activity do |t|
      t.string :name
      t.integer :user_id
      t.integer :festival_id
      t.references :subject, :object, :polymorphic => true
      t.text :details
      t.timestamps
    end
    add_index :activity, [:user_id, :name]
  end

  def self.down
    drop_table :activity
  end
end
