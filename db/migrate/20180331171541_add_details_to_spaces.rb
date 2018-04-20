class AddDetailsToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :initials, :string
    add_column :spaces, :turn, :string
  end
end
