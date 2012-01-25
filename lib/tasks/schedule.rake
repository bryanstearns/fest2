require 'ruby-debug'

desc "Build my schedule (for debugging)"
task :schedule => :environment do
  me = User.find_by_username("Bryan Stearns")
  festival = Festival.find_by_slug!("piff_2010")
  sched = AutoScheduler.new(me, festival, :unselect => 'future')
  begin
    scheduled_count, prioritized_count = sched.go
    puts "Scheduled #{scheduled_count} of #{prioritized_count} film(s)."
  rescue AutoSchedulingError => e
    puts "Error: #{e.message}"
  end
end
