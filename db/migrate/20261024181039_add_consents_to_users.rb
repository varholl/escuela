# Two permissions, each off until given, each kept as the moment it was given
# so there is a record of when someone said yes.
class AddConsentsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :reading_history_consent_at, :datetime
    add_column :users, :news_consent_at, :datetime
  end
end
