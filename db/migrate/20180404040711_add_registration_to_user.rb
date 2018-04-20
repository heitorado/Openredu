class AddRegistrationToUser < ActiveRecord::Migration
  def change
    add_column :users, :registration, :string
  end
end
