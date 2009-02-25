class AddUserKeyToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :key, :string, :limit => 10
    Subscription.reset_column_information
    say_with_time "Adding keys to existing subscriptions" do
      Subscription.all.each do |s|
        s.make_sharable_key
        s.save!
      end
    end
  end

  def self.down
    remove_column :subscriptions, :key
  end
end
