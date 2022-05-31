module ApplicationHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def friendship_indicator(user)
    display = 
      if current_user == user
        return
      elsif current_user.friends.include?(user)
        "#{button_to destroy_friendship_path,
             method: :delete,
             data: { confirm: "Really unfriend #{user.name}?" },
             params: { friend_a_id: user.id, friend_b_id: current_user.id },
             class: "button is-small is-danger is-light px-2 mx-3" do
               "<i class='fas fa-user-minus'></i>".html_safe
             end}
        <i class='fas fa-user-friends'></i>"
      elsif invitation = current_user.friend_invitations.find_by(requester: user)
        "#{link_to delete_friend_request_path(invitation),
            method: :delete,
            class: 'delete-request delete-request-show',
            data: { confirm: "Delete #{invitation.requester.name}'s friend request?" } do
              "<i class='fas fa-user-times'></i>".html_safe
           end}
        #{link_to confirm_friend_request_path(invitation),
            method: :post,
            class: 'confirm-request' do
              "<i class='fas fa-user-check'></i>".html_safe
          end}"
      elsif current_user.requested_friends.include?(user)
        "<i class='far fa-clock'></i>"
      else
        button_to friend_requests_path,
          method: :post,
          class: 'add-friend',
          params: { recipient_id: user.id } do
            "<i class='fas fa-user-plus'></i>".html_safe
          end
      end
    display.html_safe
  end
  
end