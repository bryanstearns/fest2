class AddFestivalSlugGroup < ActiveRecord::Migration
  def self.up
    add_column :festivals, :slug_group, :string

    say_with_time "Initializing festival slug groups" do
      Festival.reset_column_information
      Festival.all.each do |f|
        f.slug_group = f.slug.split('_').first
        puts "Festival #{f.slug} gets slug group #{f.slug_group.inspect}"
        f.save!
      end
    end
  end

  def self.down
    remove_column :festivals, :slug_group, :string
  end
end
