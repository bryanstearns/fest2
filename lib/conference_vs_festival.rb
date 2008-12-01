
module ConferenceVsFestival
  # Handle Conference vs Festival
  # This sets up string hash at "_", as well as the "conference_mode" value;  
  attr_reader :_
  attr_reader :conference_mode

  def self.included(receiver)
    # Once per process, set up global hashes of strings; we'll pick between 
    # them on a per-session basis
    return unless $conference_strings.nil?
    c = {
      # We start with plural lowercase strings...
      :festivals => "conferences",
      :films => "presentations",
      :screenings => "slots"
    }
    # and add singular and capitalized permutations
    c.keys.each {|k| c[k.to_s.singularize.to_sym] = c[k].singularize }
    c.keys.each {|k| c[k.to_s.capitalize.to_sym] = c[k].capitalize }
    # The festival-mode versions are just the keys as strings
    f = {}
    c.keys.each {|k| f[k] = k.to_s }

    # Also, make sure we can translate :festival_id to :conference_id,
    # :film_id to :presentation_id, and :screening_id to :slot_id
    # (yes, as symbols)
    f[:festival_id] = :festival_id
    c[:festival_id] = :conference_id
    f[:film_id] = :film_id
    c[:film_id] = :presentation_id
    f[:screening_id] = :screening_id
    c[:screening_id] = :slot_id
 
    $conference_strings, $festival_strings = c, f
  end

  def conference_versus_festival
    @conference_mode = ((request.env["HTTP_X_FORWARDED_HOST"] || request.env["SERVER_NAME"] || "dev.festivalfanatic.com").include?("conference"))
    Rails.logger.info("CvF: #{request.env["HTTP_X_FORWARDED_HOST"].inspect} || #{request.env["SERVER_NAME"].inspect} || 'dev.festivalfanatic.com' --> #{@conference_mode}")
    @_ = @conference_mode ? $conference_strings : $festival_strings
  end
  
  def force_festival_mode
    @conference_mode = false
    @_ = $festival_strings
  end
  
  def self.poly_method_name_translation(method, conf_mode, strings)
    # If this name starts with "poly_", translate it:
    # - remove "poly_"
    # - if we're in conference mode, do appropriate substitutions
    # - return the translated name
    # If no translation was done, return nil.
    method_name = method.to_s
    return nil unless method_name.starts_with?("poly_")
    method_name = method_name[5..-1] # remove "poly_"
    if method_name.ends_with?("_url") or method_name.ends_with?("_path")
      method_name = method_name.sub(/festival/, strings[:festival])\
                               .sub(/film/, strings[:film])\
                               .sub(/screening/, strings[:screening]) if conf_mode
    end
    method_name.to_sym
  end
  
  def method_missing(method, *args)
    translated_method = ConferenceVsFestival.poly_method_name_translation(method, conference_mode, _)
    if translated_method
      send(translated_method, *args)
    elsif respond_to? method
      send(method, *args)
    elsif template_exists? && template_public?
      default_render
    else
      raise ActionController::UnknownAction, "No action responded to #{action_name}", caller
    end
  end
end

class ActionView::Base
  # Teach views how to get conference-vs-festival info from their controller
  def _
    controller._
  end
  
  def conference_mode
    controller.conference_mode
  end
  
  def method_missing(method, *args)
    translated_method = ConferenceVsFestival.poly_method_name_translation(method, conference_mode, _)
    if translated_method
      send(translated_method, *args)
    else
      super
    end
  end
end
