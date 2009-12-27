module RandomSubsetHelper
  def random_subset(collection, count)
    size = collection.size
    return collection if count == nil or count >= size
    cut = rand(size)
    if cut <= (size - count)
      collection[cut..(cut+count-1)]
    else
      collection[cut..-1] + collection[0..(count-(size-cut+1))]
    end
  end

  def render_random_subset_with_caching(controller, collection, count, 
                                        partial, cache_key)
    # See if we have the rendered set cached
    result = controller.read_fragment cache_key
    unless result
      # Gotta render the whole collection (individually), then save the results
      result = collection.map do |c| 
        controller.send(:render_to_string, :partial => partial, :object => c)
      end
      controller.write_fragment(cache_key, result)
    end

    # Pick a random slice of our results
    random_subset(result, count)
  end
end
