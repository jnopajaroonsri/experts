class Friendship < ApplicationRecord
    belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
    belongs_to :user, :foreign_key => 'friend_id', :class_name => 'User'

    after_create :create_inverse_friendship

    def create_inverse_friendship
        # if the inverse bi-directional association doesn't exist, create it
        if Friendship.where(user_id: self.friend_id, friend_id: self.user_id).empty?
            Friendship.create(user_id: self.friend_id, friend_id: self.user_id)
        end
    end
end
