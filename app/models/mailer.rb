class Mailer < ActionMailer::Base
  # This might be helpful when it comes time to embed images in messages...
  # http://www.caboo.se/articles/2006/02/19/how-to-send-multipart-alternative-e-mail-with-inline-attachments

  def mail_test
    # test message; send with
    # $ script/console
    # >> Mailer.deliver_mail_test
    common_admin_setup "mailer test"
    body "This message generated at #{Time.now}."
  end
  
  def got_feedback(question)
    common_admin_setup "Festival Fanatic feedback"
    headers 'Reply-To' => question.email
    body :question => question
  end

  def new_user(user)
    common_admin_setup "New Festival Fanatic user"
    body :user => user
  end

  def reset_password(user)
    common_setup "Reset your FestivalFanatic.com password"
    recipients user.email
    bcc "festfan@festivalfanatic.com"
    body :user => user
  end

private
  def common_setup(subj)
    from "Festival Fanatic <festfan@festivalfanatic.com>"
    headers 'return-path' => "festfan@festivalfanatic.com"
    #bcc  "stearns@example.com"
    subj = "[#{RAILS_ENV}] #{subj}" if RAILS_ENV != 'production'
    subject subj
  end
  
  def common_admin_setup(subj)
    common_setup(subj)
    recipients "festfan@festivalfanatic.com"
  end
end
