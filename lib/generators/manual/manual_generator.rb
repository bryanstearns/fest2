class ManualGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      clean_name = @name.underscore.gsub(' ','_')
      m.template\
        "template.rb",
        "db/manual/#{Date.today.strftime("%y%m%d")}_#{clean_name}.rb",
        :assigns => { :username => `whoami`.strip }
    end
  end
end


