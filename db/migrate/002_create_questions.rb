class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :email, :question
      t.boolean :acknowledged, :done, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
