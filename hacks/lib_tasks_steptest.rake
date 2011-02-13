desc 'test hack'
task :steptest => :environment do
  s = Time.zone.parse('2011-02-11 11:00')
  puts s.inspect
  e = Time.zone.parse('2011-02-11 23:00')
  a = []
  s.step(e, 60*60) {|x| a << x }
  pp a
end  
