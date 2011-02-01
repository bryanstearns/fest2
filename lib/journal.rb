class Journal
  # Add to our activity log -- through the magic of method_missing, 
  # anything you call on Journal becomes a logged activity, like
  #   Journal.payment_recorded(:subject => payment, :object => lease)
  # See app/models/activity.rb for details & philosphy...

  def self.method_missing(method_name, *args)
    Activity.record(method_name, *args)
  end
end
