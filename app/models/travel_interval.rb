class TravelInterval < ActiveRecord::Base
  DEFAULT_INTRA_INTERVAL = 10.minutes
  DEFAULT_INTER_INTERVAL = 15.minutes

  belongs_to :festival
  belongs_to :user
  belongs_to :location_1, :class_name => 'Location'
  belongs_to :location_2, :class_name => 'Location'

  before_validation :sort_location_ids

  module Extension
    class IntervalCache
      def initialize(festival, user)
        @user = user

        @cache = Hash.new do |hf, fk|
          hf[fk] = {}
        end
        @use_travel_time = user.subscription_for(festival).use_travel_time?
        if @use_travel_time
          conditions = user ? ['user_id is null or user_id = ?', user.id] : 'user_id is null'
          festival.travel_intervals.all(:conditions => conditions, :order => :user_id).inject(@cache) do |h, interval|
            h[interval.location_1_id][interval.location_2_id] = interval.seconds_from
            h[interval.location_2_id][interval.location_1_id] = interval.seconds_to
            h
          end
        end
      end

      def between(from_location, to_location)
        return TravelInterval::DEFAULT_INTRA_INTERVAL unless @use_travel_time

        from_location = from_location.id if from_location.is_a? Location
        to_location = to_location.id if to_location.is_a? Location
        return TravelInterval::DEFAULT_INTRA_INTERVAL if from_location == to_location

        @cache[from_location][to_location] || TravelInterval::DEFAULT_INTER_INTERVAL
      end
    end

    def reset_cache
      @interval_cache = nil
    end

    def between(from_location, to_location, user)
      interval_cache(user).between(from_location, to_location)
    end

    def interval_cache(user)
      @interval_cache ||= {}
      @interval_cache[user] ||= make_cache(user)
    end

    def make_cache(user)
      IntervalCache.new(proxy_owner, user)
    end
  end

protected
  def sort_location_ids
    if self.location_1.id > self.location_2.id
      tmp = self.location_1
      self.location_1 = self.location_2
      self.location_2 = tmp
      tmp = self.seconds_from
      self.seconds_from = self.seconds_to
      self.seconds_to = tmp
    end
    true
  end
end
