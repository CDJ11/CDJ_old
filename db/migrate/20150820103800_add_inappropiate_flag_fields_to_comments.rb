class AddInappropiateFlagFieldsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :flagged_as_inappropiate_at, :datetime
    add_column :comments, :inappropiate_flags_count, :integer, default: 0
  end
end
