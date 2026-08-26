# Signing in with Google. The pair is unique so two accounts can never claim the
# same Google identity, and both columns are nullable because most people will
# still sign up with a password.
class AddGoogleIdentityToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    add_index :users, [ :provider, :uid ], unique: true
  end
end
