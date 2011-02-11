require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :picks, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :festivals, :through => :subscriptions
  has_many :activity

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :username, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :username, :within => 3..40, :if => :username?
  validates_length_of       :email,    :within => 3..100, :if => :email?
  validates_uniqueness_of   :username, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :username, :email, :password, :password_confirmation

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email, :include => :subscriptions) # need the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  def self.from_param(username_param)
    # Some older URLs might contain _ for space
    username_param.gsub!('_', ' ')
    CGI::unescape(username_param)
  end
  def self.to_param(username)
    CGI::escape(username).gsub('.', '%2E').gsub('_', '%5F')
  end
  def to_param
    User.to_param(username)
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.years # BJS: essentially indefinitely
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def subscription_for(festival_id, options={})
    festival_id = festival_id.id unless festival_id.is_a? Integer
    subscription = options[:create] \
      ? subscriptions.find_or_create_by_festival_id(festival_id) \
      : subscriptions.find_by_festival_id(festival_id) \
  end

  def can_see?(screening)
    subscription = subscription_for(screening.festival_id)
    return subscription ? subscription.can_see?(screening) : !screening.press 
  end

  def has_screenings_for(festival)
    (picks.count(:conditions => ["festival_id = ? and screening_id is not null", festival.id]) > 0)
  end

  def has_rankings_for(festival)
    (picks.count(:conditions => ["festival_id = ? and priority is not null", festival.id]) > 0)
  end

  def best_default_festival(slug)
    # which festival should we show this user by default?
    # Use the newest instance of the last festival they used, or let
    # Festival pick.
    if slug.nil? # no festivals cookie was found.
      # Pick the "best" subscription to use
      slug = subscriptions.last(:include => :festival, :order => "subscriptions.created_at")\
                          .try(:festival).try(:slug)
    end
    if slug
      festival = Festival.published_and_scheduled.in_slug_group(slug.split("_").first).first
      return festival if festival
    end
    Festival.best_default
  end

protected
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") \
      if new_record?
    self.crypted_password = encrypt(password)
  end
      
  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
