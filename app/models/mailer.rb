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
  
  def got_feedback(question, _)
    common_admin_setup "#{_[:Festival]} Fanatic feedback", _
    headers 'Reply-To' => question.email
    body :question => question
  end

  def new_user(user, _)
    common_admin_setup "New #{_[:Festival]} Fanatic user", _
    body :user => user
  end

  def reset_password(user, _)
    common_setup "Reset your #{_[:Festival]}Fanatic.com password", _
    recipients user.email
    bcc "#{_[:festival][0..3]}fan@#{_[:festival]}fanatic.com"
    body :user => user, :_ => _
  end

private
  def common_setup(subj, _)
    _ ||= Hash.new { |h, k| k.to_s }
    from "#{_[:Festival]} Fanatic <#{_[:festival][0..3]}fan@#{_[:festival]}fanatic.com>"
    #bcc  "stearns@example.com"
    subj = "[#{RAILS_ENV}] #{subj}" if RAILS_ENV != 'production'
    subject subj
  end
  
  def common_admin_setup(subj, _=nil)
    _ ||= Hash.new { |h, k| k.to_s }
    common_setup(subj, _)
    recipients "#{_[:festival][0..3]}fan@#{_[:festival]}fanatic.com"
  end
end
