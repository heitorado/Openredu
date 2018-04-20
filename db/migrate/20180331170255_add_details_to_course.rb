class AddDetailsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :initials, :string
    add_column :courses, :average, :float
  end
end
