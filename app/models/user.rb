class User < ApplicationRecord
    has_many :friendships, class_name: 'Friendship', dependent: :destroy
    has_many :friends, through: :friendships, source: :user

    after_create :fetch_profile, if: :valid_personal_website?
    before_save :generate_short_url, if: (:will_save_change_to_personal_website? && :valid_personal_website?)

    def query_profiles(text)
        # safe from sql injection
        users = User.where('UPPER(profile) like ?', "%#{text.upcase}%").pluck(:id, :profile).uniq
        results = []
        users.each do |user_id, match|
            next if user_id == self.id
            results.push({match => determine_friendship(self.id, user_id)})
        end
        results
    end

    def determine_friendship(a, b)
        source = User.find(a)
        dest = User.find(b)
        # check if already friends
        source_friends = source.friends.pluck(:id).sort
        return [source.name, dest.name] if source_friends.include?(b)

        # check if mutual friends
        dest_friends = dest.friends.pluck(:id).sort
        common_friends = source_friends & dest_friends

        return [source.name, User.find(common_friends.first).name, dest.name] unless common_friends.empty?

        # else, we need to process more friends
        source_traversal = [[a], source_friends]
        dest_traversal = [[b], dest_friends]

        return find_mutual_friends(source_friends, dest_friends, source_traversal, dest_traversal)
    end
    
    def find_mutual_friends(source_friends, dest_friends, source_traversal, dest_traversal)
        # let's start by processing the smaller list for friends, first
        # we want to get the friends of the friends in the friendlist and then check for common friends with the other list
        if source_friends.length > dest_friends.length
            new_dest_friends = Friendship.where(user_id: dest_friends).pluck(:friend_id).uniq.sort
            dest_friends = new_dest_friends.difference(dest_traversal.flatten)
            dest_traversal.push(dest_friends) unless dest_friends.empty?
        else
            new_source_friends = Friendship.where(user_id: source_friends).pluck(:friend_id).uniq.sort
            source_friends = new_source_friends.difference(source_traversal.flatten)
            source_traversal.push(source_friends) unless source_friends.empty?
        end

        # if we grab more friends of friends and remove already processed and it comes back empty, 
        # we've reached the extent of the friend network
        return if dest_friends.empty? || source_friends.empty? 

        # check if we have any mutual friends
        common_friends = (dest_friends & source_friends).uniq.sort

        unless common_friends.empty?
            common_friend = common_friends.first
            source = process_friends_list(source_traversal, common_friend)
            dest = process_friends_list(dest_traversal, common_friend)

            return (source + dest.reverse).uniq
        end

        # update the list of friends we already processed
        
        find_mutual_friends(source_friends, dest_friends, source_traversal, dest_traversal)
    end

    def process_friends_list(list, common)
        last_item = list.pop

        # grab the friends of the common friend and look for common friends within the last_item
        common_friend = User.find(common)
        friends = User.find(common).friends.pluck(:id).sort

        next_common_friend = (list.last & friends).first

        if list.length == 1
            final_node = list.pop.pop
            return [User.find(final_node).name, common_friend.name]
        else
            return process_friends_list(list, next_common_friend) + [common_friend.name]
        end
    end

    def fetch_profile
        require 'open-uri'

        doc = Nokogiri::HTML.parse(self.personal_website)
        headers = doc.css('h1, h2, h3').map(&:text).join("\n")

        self.update(profile: headers)
    end

    def generate_short_url
        # generic oauth token
        # 6c8820b32649fe8b9f89d7c155f73b7d2f5dd27c
        client = Bitly::API::Client.new(token: '6c8820b32649fe8b9f89d7c155f73b7d2f5dd27c')
        url = client.shorten(long_url: self.personal_website)

        self.shortened_url = url.link
    end

    def valid_personal_website?
        uri = URI.parse(self.personal_website)
        uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
        false
    end

    def friend_count
        self.friends.count
    end
end
