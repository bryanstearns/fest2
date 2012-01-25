module AutoScheduler::Utilities
  def logit(msg)
    puts msg
    RAILS_DEFAULT_LOGGER.info msg
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
