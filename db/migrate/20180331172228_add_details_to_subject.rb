class AddDetailsToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :initials, :string
    add_column :subjects, :status, :string
  end
end
