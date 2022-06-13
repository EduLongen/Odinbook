class UserMailer < ApplicationMailer

  default from: 'users@odinbook.com'

  def welcome_email
    mail(to: @user.email, subject: 'Welcome to Odinbook!')
  end

end
