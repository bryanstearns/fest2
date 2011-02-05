class Activity < ActiveRecord::Base
  # An activity journal entry
  #
  # lib/journal.rb calls Activity.record to log activity.
  #
  # Examples:
  #   # Note that a payment was recorded for this lease
  #   # (also captures the current user as having done this)
  #   Journal.payment_recorded(:subject => payment, :object => lease)
  #
  #   # Save the current user as having activated in this role
  #   # (note: there's no secondary model, but we'll record the
  #   # mode of activation in the serialized "details" column)
  #   Journal.activated(:subject => role, :via => :statement_code)
  #
  # Philosophy:
  # - You'll call Journal from exactly one place for each activity
  #   (so don't copy an activity name - create a new distinct one;
  #   it'd be nice to do a manual step to rename old entries if you
  #   rename an existing activity to be clearer or distinct from
  #   your new one)
  # - Call this from the edges: generally, a controller, rake task,
  #   or mailer, not from a model. These are supposed to be
  #   high-level actions.
  # - If you add a new activity, be sure to try it once to make sure
  #   the resulting entry looks like you expected.
  # - Subject is the thing being created; object is the thing being
  #   created on; either could be blank, though. When showing a log,
  #   of activity in a particular context (like a lease), I expect
  #   to search for entries with that context as subject or object.
  # - Think about what other details might be useful to capture;
  #   current user and time are captured automatically.
  # - Call this *before* doing the work it describes; it might help
  #   when tracking down a subsequent crash.
  # - This is really for managing our system in the short term -
  #   don't record details that are important to preserve, because
  #   we'll purge the Activity table every so often.
  #

  belongs_to :user
  belongs_to :festival
  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true
  serialize :details, Hash
  # xss_terminate :except => [ :details ]

  class JournalError < StandardError; end

  def self.record(activity_name, *options)
    raise JournalError, "Unparsable activity context: #{options.inspect}" \
      if options.length > 1
    
    parameters = parameters_to_record(activity_name, options.first)
    log(parameters)
    create!(parameters)
    nil
  end

  def self.parameters_to_record(activity_name, options)
    params = { :name => activity_name.to_s }
    case options
    when Hash
      # Normally, pass a hash and specify what you want to record
      params[:user_id] = options.delete(:user_id) if options[:user_id]
      params[:user_id] ||= options.delete(:user).id if options[:user]
      params[:festival_id] = options.delete(:festival_id) if options[:festival_id]
      params[:festival_id] ||= options.delete(:festival).id if options[:festival]
      params[:subject] = options.delete(:subject) if options[:subject]
      params[:object] = options.delete(:object) if options[:object]
      params[:details] = options unless options.empty?
    when ActiveRecord::Base
      # If you just have a model, you can pass it in as-is; it'll be 'subject'
      params[:subject] = options
    when nil
      # Really? No context at all?
      nil # pass
    else
      # If you just have a (non-model) value, you can pass it in as-is;
      # it'll be in 'details'
      params[:details] = { :value => options }
    end
    id = ActiveRecord::Base.current_user.id rescue nil
    params[:user_id] ||= id if id # ActiveRecord::Base.current_user.try(:id)
    params
  end

  def self.log(parameters)
    name = parameters[:name]
    others = parameters.without(:name)
    Rails.logger.info("Activity: #{name}#{", #{others.inspect}" if others.present?}")
  end
end
