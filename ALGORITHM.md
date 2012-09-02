Festival Fanatic's automatic scheduling algorithm
=================================================

(This description extracted from a recent email conversation...)

Festival Fanatic's Scheduling Assistant attempts to build a schedule
that includes as many of the user's higher-priority films as possible.
I don't know if this is "the best way" to accomplish this, but it's
been good enough, and it's proven to have some nice flexibility
recently. I'm writing this off the top of my head, so this might
not exactly match what the app does right now, but it's close (and
if you have questions, I'll be happy to check the source code to
verify what I really do).

The application's data model isn't very surprising:

- each festival has many films
- each film has a duration
- each film has a number of screenings (since each movie is screened one or more times).
- each screening has a start time, as well as an end time calculated from the film's duration.

You've also got a bunch of users, who prioritize the films they want to see:

- each user has a bunch of what I call "picks"
- each pick corresponds to a film, and stores the priority. It might
also have a reference to the specific screening that the user will
be attending for that film, but that starts out empty; it's set
when the screening is scheduled (either manually or automatically).

Based on the festival schedule, I can also build a data structure
that maps each screening to the list of screenings that conflict
(in time) with it. In doing this, I fudge the actual start & end
times of the screenings to allow me time to move from theater to
theater.

---

At this point, if you ignored the automatic scheduler, you'd have
a website with the following features:

- The user could roughly prioritize films in the festival
- The user could see a schedule for the festival
- The user could click on individual screenings to manually select
them. When the user selects a film, the site would automatically
de-select any conflicting screenings (because you can't be in two
places at once), and also, if the user had been scheduled to see
some other screening of that film, it would automatically de-select
that other screening.

That was pretty much version 1.0 of Festival Fanatic. I point this
out because that last little detail (of considering conflicting
screenings as well as other screenings of a given film) come into
play when implementing the scheduler.

--- 

So, the scheduling algorithm is basically economic:

1. I build a list of all the screenings I could schedule next: all screenings for all movies that the user wants to see that haven't been scheduled yet, and don't conflict with a scheduled screening.
2. I calculate a value that's the "cost" of scheduling each screening.
3. I find the "least expensive" screening, and schedule it.

I repeat these steps until there aren't any screenings left to schedule.

The complicated part to that simple description is the second step, how to calculate the cost of scheduling a screening:

The first half of the cost is the cost of the screening itself: it's 
infinite (ok, a really big constant) if the user is already scheduled 
to see a different screening of this film; otherwise:

- I start with the priority the user assigned. It's pretty coarse:
I give the user only a few choices like "I really want to see this",
"I'd like to see this", "I'd see this if I happened to have nothing
else to do", and "I don't want you to schedule this movie at all"
(because it doesn't appeal to me, because I've already seen it, or
because I know it's going to be opening locally soon anyway). Each
of those choices corresponds to a number, and I've played with the
numbers a lot - they started out like 1, 2, 3, 4, 5, but I think
they're now non-linear (and the cost of "I don't want you to schedule
this" is infinite).

- Then, I fudge that number by the count of remaining choosable
screenings (I'm not sure what I actually do, but let's say I multiply
it by 5 minus the count): the idea is, this number goes up for a
movie that has fewer remaining screening opportunities.)

Assuming the first half isn't infinite, the second half is the sum
of the cost of the screenings that conflict with this one. If any
are infinite, they count as zero here (because if you're thinking
about picking a screening of some film, you don't care if it's up
against a screening of another film you don't want to see, or a
film you're seeing at some other time); if any are actually scheduled,
then it counts as negative infinity (because we can't schedule
against a screening that's already scheduled). If the sum is zero
(meaning either no conflicting films, or they're all screenings of
films already scheduled at other times), I use a big (but not
infinite) negative number instead: this gives unconflicting screenings
a very low cost.

The total cost of the screening is the second half subtracted from
the first half: this gives us a number that smaller for high-priority
movies, with fewer remaining choosable screenings, up against fewer
lower-priority screenings. If the first-half cost is infinite, or
if the second is negative-infinite, this makes the resulting total
infinite, which makes the screening unscheduleable.

By calculating this total-cost value for all the screenings, I can
find the smallest and (assuming it's not infinite) schedule it.

To be more efficient, I don't bother calculating the second half
if the first was infinite, and I really skip out of the second-half
calculation as soon as I find a screening that'd make the sum
infinite. Also, after I've scheduled a screening, I remove that
screening, as well as all other screenings of that film, from the
B list (though I still need to consider all screenings in the
conflict list).

---

That's the gist of it. The rest of it is all fudging the numbers
to work out nicely, because each of the factors (like the priorities,
count of remaining screenings, etc) have different weights in the
calculations, and all that came through trial and error. It's not
the met efficient algorithm in the world, but for the number of
users I've got and the size of our festivals, performance hasn't
been a problem.

I've also added things: this past year, the Portland International
Film Festival spread itself all over town, so travel time between
theaters became more variable, and more important. At the moment,
I don't recall how I dealt with this, but I know the calculation
of conflicts is much more complicated now. :-)

