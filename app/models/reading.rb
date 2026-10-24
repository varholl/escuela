# That someone opened a piece, and when they last did -- kept only for those
# who chose to have it remembered (User#remembers_reading?). Nothing about how
# long they stayed or where they went next.
class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :article

  def self.record(user, article)
    reading = find_or_initialize_by(user: user, article: article)
    reading.update!(last_read_at: Time.current)
  rescue ActiveRecord::RecordNotUnique
    # Two tabs opening the same piece at once; the other one wrote it.
    nil
  end
end
