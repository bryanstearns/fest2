Festival Fanatic
================

[http://festivalfanatic.com/](http://festivalfanatic.com/)

(c) 2005-2012 Bryan Stearns -- available under
[the same terms as Ruby](https://raw.github.com/ruby/ruby/22a173df3f462244103a02261c276eeee8926863/COPYING)

Festival Fanatic was created to help me schedule my attendance at
film festivals: it's impossible to see everything, and each film
screens only a few times in conflict with other films. It mimics
the process I used on paper, but does a better job (in less time).

From the user's perspective, it's a three-step process:

- The user assigns rough priorities to each film, four buckets
from "I *really* want to see this" down to "I'd see this if
nothing better was scheduled", plus a fifth "Never schedule this
for me" choice.

- The user configures a few options that guide the "scheduling
assistant", then runs the assistant, which uses the options and
priorities to select screenings to fill available time with the
highest-priority films.

- The user can view the schedule and manually tweak it by 
scheduling and unscheduling individual screenings. At any time
before or during the festival, the user can change priorities
and re-run the scheduler, which will discard the scheduling from
that point forward and rebuild the schedule for the remainder of
the festival -- this is useful as "buzz" about films spreads
around the festival.

The scheduling-assistant algorithm at the heart of Festival Fanatic
(described in ALGORITHM.md) has evolved over time, but some form
of it has been the "toy program" that I used to try out new programming
languages for many years.

This version is the last Rails 2.x version of Festival Fanatic; it
started as my first significant Ruby program and has many vestiges
of my own unfamiliarity with Ruby and (more importantly) Rails'
conventions; I partially rewrote it in 2008 (which is when this
git repository was created), but it's still pretty crufty: I'm both 
proud of it and embarrassed by it at the same time.

This summer (2012), I've started a new version of the application
from scratch, using Rails 3. Starting from scratch is allowing me
to experiment with library choices that weren't available when I
started this version, lets me practice test-driven development
in a way that I hadn't before, and is letting me design the new
appearance for mobile devices first. My goal is to finish the new
version in time for next year's Portland International Film Festival.

