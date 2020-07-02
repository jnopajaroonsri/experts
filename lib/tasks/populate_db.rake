require 'faker'
require 'factory_bot'

namespace :populate_db do
    task :new_task => :environment do
        50.times do 
            User.create(name: Faker::Name.name, 
                personal_website: Faker::Internet.url + "/#{Faker::Internet.username}", 
                shortened_url: Faker::Internet.domain_word,
                profile: Faker::Music::RockBand.name)
        end
    end

    task :create_friendships => :environment do
        User.all.each do |user|
            4.times do 
                user_id = user.id
                friend_id = User.all.sample.id
                unless Friendship.where('(user_id = ? and friend_id = ?) OR (user_id = ? and friend_id = ?)', user_id, friend_id, friend_id, user_id).count > 0
                    Friendship.create(user_id: user_id, friend_id: friend_id)
                    Friendship.create(user_id: friend_id, friend_id: user_id)
                end
            end
        end
    end
end
