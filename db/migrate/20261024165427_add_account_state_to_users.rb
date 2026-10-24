# Two facts about an account the panel needs and the sessions cannot give.
#
# A person she has turned away keeps her record -- her courses, her messages --
# so the door can be opened again; deactivated_at says when it was shut.
# Sessions are deleted on sign-out, so they cannot say when someone last came
# in; last_signed_in_at is written each time they do.
class AddAccountStateToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deactivated_at, :datetime
    add_column :users, :last_signed_in_at, :datetime

    add_index :users, :deactivated_at
  end
end
