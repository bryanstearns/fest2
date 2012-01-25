module AutoScheduler::Utilities
  def log_it(msg)
    now = Time.zone.now
    @start_time ||= now
    total_time = now - @start_time
    if block_given?
      started = Time.now
      log_it "(starting) #{msg}"
      yield
      duration = Time.now - started
      log_it "(Δ#{duration.to_duration}) #{msg}"
    else
      msg = "#{total_time.to_duration}: #{msg}"

      puts msg if Rails.env.development?
      RAILS_DEFAULT_LOGGER.info msg
    end
    true # so we can do "logit xxx and return"
  end

  def make_map(a)
    a.inject({}) do |h, x|
      k, v = yield x
      h[k] = v if k and v
      h
    end
  end

  def make_map_to_list(a)
    a.inject(Hash.new {|h, k| h[k] = []}) do |h, x|
      pair = yield x
      if pair
        k, v = pair
        h[k] << v if k and v
      end
      h
    end
  end
end
