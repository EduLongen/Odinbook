class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.avatar_url = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  include Gravtastic
  gravtastic

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one_attached :avatar

  has_many :friend_requests,
    foreign_key: :requester_id,
    dependent: :destroy

  has_many :requested_friends,
    through: :friend_requests,
    source: :recipient

  has_many :friend_invitations,
    foreign_key: :recipient_id,
    class_name: :FriendRequest,
    dependent: :destroy

  has_many :requesting_friends,
    through: :friend_invitations,
    source: :requester

  has_many :friendships,
    ->(user) { unscope(:where).where('friend_a_id = ? OR friend_b_id = ?', user.id, user.id) },
    dependent: :destroy

  def friends
    join_statement = <<-SQL
      INNER JOIN friendships
        ON (friendships.friend_a_id = users.id OR friendships.friend_b_id = users.id)
        AND (friendships.friend_a_id = #{id} OR friendships.friend_b_id = #{id})
    SQL
    User.joins(join_statement)
        .where.not(id: id)
  end

  def friends_sql
    # SQL implentation, but returns array instead of ActiveRecord Relation
    User.find_by_sql(<<~SQL)
      SELECT users.*
      FROM users
      INNER JOIN friendships
        ON (friendships.friend_a_id = users.id OR friendships.friend_b_id = users.id)
        AND (friendships.friend_a_id = #{id} OR friendships.friend_b_id = #{id})
      WHERE users.id <> #{id};
    SQL
  end
  
  def non_friends_and_pending
    join_statement = <<-SQL
      LEFT OUTER JOIN friendships
        ON (friendships.friend_a_id = users.id OR friendships.friend_b_id = users.id)
        AND (friendships.friend_a_id = #{id} OR friendships.friend_b_id = #{id})
      LEFT OUTER JOIN friend_requests
        ON friend_requests.requester_id = users.id
        AND friend_requests.recipient_id = #{id}
      SQL
    
    User.joins(join_statement)
        .where( friendships: { id: nil }, friend_requests: { id: nil} )
        .where.not(id: id)
  end

  def no_contacts
    join_statement = <<-SQL
      LEFT OUTER JOIN friendships
        ON (friendships.friend_a_id = users.id OR friendships.friend_b_id = users.id)
        AND (friendships.friend_a_id = #{id} OR friendships.friend_b_id = #{id})
      LEFT OUTER JOIN friend_requests
        ON (friend_requests.requester_id = users.id OR friend_requests.recipient_id = users.id)
        AND (friend_requests.requester_id = #{id} OR friend_requests.recipient_id = #{id})
      SQL
    
    User.joins(join_statement)
        .where( friendships: { id: nil }, friend_requests: { id: nil} )
        .where.not(id: id)
  end

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: [150, 150])
    else
      "/default_avatar.png"
    end
  end

end
