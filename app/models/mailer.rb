class Mailer < ActionMailer::Base
  # This might be helpful when it comes time to embed images in messages...
  # http://www.caboo.se/articles/2006/02/19/how-to-send-multipart-alternative-e-mail-with-inline-attachments

  default_url_options[:host] = case Rails.env
  when "production"
    "festivalfanatic.com"
  when "stage"
    "stage.festivalfanatic.com"
  else
    "localhost:3000"
  end

  def mail_test
    # test message; send with
    # $ script/console
    # >> Mailer.deliver_mail_test
    common_admin_setup "mailer test"
    body "This message generated at #{Time.zone.now}."
  end
  
  def got_feedback(question)
    common_admin_setup "Festival Fanatic feedback"
    headers 'Reply-To' => question.email
    body :question => question
  end

  def new_user(user)
    common_setup "Welcome to Festival Fanatic"
    recipients user.email
    bcc "festfan@festivalfanatic.com"
    body :user => user
  end

  def reset_password(user)
    common_setup "Reset your FestivalFanatic.com password"
    recipients user.email
    bcc "festfan@festivalfanatic.com"
    body :user => user
  end

  def admin_message(subject, details)
    common_setup subject
    recipients "festfan@festivalfanatic.com"
    body :details => details
  end

  def schedule_changed(screening, users, change_type)
    festival = screening.festival
    common_setup("Schedule change for #{festival.name}, " +
                 Date.today.to_s(:mdy_numbers_slashed))
    recipients "Festival Fanatic <festfan@festivalfanatic.com>"
    body :festival => festival, :screening => screening,
         :users => users, :change_type => change_type
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
