<!-- tradingview-pine-id: PUB;d6f820a3bd18412696494435f5f4a8e0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# YURI VWAP Excursion Engine

Source: https://www.tradingview.com/script/2IWwexkc/

## Description

Session VWAP has a deadline that most levels do not. When the session ends the average resets, and whether price got back to it stops being an open question. This script keeps the record of how that question has been answered on the chart in front of you: every time price left VWAP by more than a set distance, how long it took to touch VWAP again, and how often the session simply ran out first.

HOW TO USE IT

Put it on an intraday chart of a symbol that reports volume. One minute bars and coarser are accepted. Leave Regular hours only switched on unless you want pre and post market bars counted into the average.

Read the status line first. The ledger builds as the chart is walked, so it needs loaded history: at the defaults each half of the session wants 15 finished excursions before it reads, and the status counts up until then. If the ledger stays thin on your symbol, the distance is large for it. Lower Distance that starts an excursion and the ledger fills faster, with the trade off set out under THE SENSITIVITY THAT MOVES THE HEADLINE.

Most of the time the pane is empty and the status reads ok, no excursion open. That is the normal state. When price closes further from session VWAP than the distance, the background shades and a line starts. The line is the share of comparable past excursions that were already back at VWAP by the age this one has now reached. Time out gives that age, and Still watched at this age gives how many past excursions the share is built from at that point, which is the cell that says how much weight the line will bear.

The two group rows lower down are the standing record: the same share at a fixed reference age, 60 minutes by default, for excursions that began early in the session and for those that began later. They are there on every bar, whether or not an excursion is open.

WHAT AN EXCURSION IS

An excursion opens on the first bar whose close sits more than the chosen distance from session VWAP, measured in basis points of VWAP. It closes on the first later bar whose range contains VWAP, which is a touch rather than a close through it.

One push that retreats partway and goes out again without reaching VWAP stays a single excursion. That is what makes the number a duration rather than a count of pokes. A bar that trades through VWAP and still closes past the threshold ends one excursion and starts another on the same bar, because the close is tested before the open.

If the session ends with an excursion still open, it is not discarded. It goes into the ledger with the elapsed time kept as a lower bound and a mark saying the deadline arrived first. The pushes that did not come back are the ones a record of return times is most tempted to lose, and a record that loses them is an advertisement.

THE OBVIOUS NUMBER IS THE WRONG ONE

The tempting headline is the share of excursions that got back to VWAP before the close. That number is mostly a clock readout.

Grouped by the hour of the session they started in, that raw share ranked against the minutes remaining in the session at a Spearman of 0.96 across the tested window. A push that leaves at 09:40 has most of the day to come back and a push that leaves at 15:10 has fifty minutes, so comparing the two tells you which one left earlier and little else.

WHAT IS READ INSTEAD

A Kaplan-Meier estimate of the share already back at the current age. Each entry in the ledger contributes to the number still under observation for as long as it was actually watched, contributes an event only where a return was seen, and leaves the pool at the point its session ended if it was still out then. It is neither counted as a failure to return nor thrown away.

Both simpler repairs break, in opposite directions, and the difference is not small at long ages. Admitting an entry only when it was watched at least as long as the age being asked about throws away returns that were already seen, and every one of those is a late departure, because in a fixed length session a short horizon is a late start: on the tested window that reads the later group at 25.5 percent at two hours against 29.5 for Kaplan-Meier. Admitting every entry whose outcome is determined swings it the other way, because a short horizon entry gets in only when it came back fast: 37.5 percent at the same age. At one hour, which is where most of the reading happens, the three land at 17.4, 18.6 and 16.1, so the choice matters much less.

THE CLOCK, AND EXACTLY WHAT SURVIVES

The ledger is kept in two groups split at a settable minute of the session, because departure time separates them. At an age of one hour the early group reads 41.0 percent against 16.1 for the later group, a gap of 24.9 points against a standard error of 5.9, on 122 and 89 entries.

Two things have to be said about that rather than left for you to find.

In a session of fixed length the departure minute and the minutes remaining are one variable with the sign flipped, and the two groups have no overlap on it at all. So this is not a time of day effect sitting on top of a remaining time effect, and no matching inside this design could separate the two. What survives is narrower: after the observation window is equalised at each age, departure time still separates the groups.

And the most likely mechanism is measured in this same script. VWAP is still mobile early in the session and nearly frozen late, so the distance can close from either end. Splitting the same measurement by the same two groups, the VWAP itself supplied a median 38.8 percent of the closing distance for early departures against 16.9 for later ones. That is a ratio of 2.3 against the ratio of 2.5 in the return shares. A reader will take the 41 against 16 as a statement about price behaviour at different times of day, and much of it is a statement about how mobile the session average still is.

Below about half an hour of age the two groups are not distinguishable on this sample at all. At fifteen minutes the gap is 1.0 points against a standard error of 3.1, so the split matters to the reading only once an excursion has been out a while, which is not when a reader is most likely to be looking at it.

WHAT A RETURN ACTUALLY IS

A return does not mean price moved. VWAP walks toward price as the session accumulates volume, and either side closing the distance ends the excursion the same way. The numbers in the section above are what that is worth. The ledger does not separate the two and does not try to. Reading a return as price coming back is a reading you are adding, not one the script supports.

THE TWO SIDES ARE POOLED, AND THAT WAS CHECKED

At an age of one hour the estimate reads 30.7 percent for the 100 pushes above VWAP and 32.0 percent for the 111 below. That is the same number written twice, so the sides are pooled. A split that buys nothing costs half the sample, and this ledger is thin enough that halving it matters.

MEASURED

All of the following is five minute bars on SPY, QQQ and IWM, sixty sessions each from 2026-06-25 to 2026-09-18, at the default 35 basis point distance and the default split at 120 minutes. They are measurements of this script's own record, not results of a strategy.

Two hundred and eleven excursions in total: 125 came back before the close and 86 were still out when it arrived. Per symbol that is 0.65 excursions a session on SPY, 1.57 on QQQ and 1.30 on IWM, which is the spread you should expect from one distance setting applied to three instruments.

The estimate by age, early group against later group: at 15 minutes 5.7 percent against 4.7, at 30 minutes 16.4 against 7.0, at 60 minutes 41.0 against 16.1, at 120 minutes 62.3 against 29.5. Pooling the two groups at one hour would print 31.4 percent, a number that describes neither.

THE SENSITIVITY THAT MOVES THE HEADLINE

The distance threshold is the setting the gap between the groups depends on, and it does not hold up evenly. At 25 basis points the gap at an hour is 29.1 points against a standard error of 5.2, on 313 excursions. At the default 35 it is 24.9 against 5.9, on 211. At 50 basis points it falls to 8.4 against 9.0, on 96 excursions, which is no gap at all. At 70 it comes back to 24.2 against 13.2, on 44.

Two things to keep in mind reading that. The four rows are not four replications: the 70 basis point excursions are a subset of the 50, which are a subset of the 35, so they are four views of one sixty session sample and the agreement between them counts for much less than four independent tests would. And the default is not the flattering cell. Twenty five basis points has both the larger gap and the larger sample; 35 was set for ledger size, not for the gap.

The 50 basis point row sits about 1.8 standard errors below the 35 row, which on its own is unremarkable, and both groups moved toward each other there rather than one collapsing. But sixty sessions on three US equity ETFs is not enough to settle it, and it is the weakest number in this file.

The split point is steadier. Moving it to 60, 90, 120 and 180 minutes gives early group estimates at an hour of 47.1, 42.6, 41.0 and 37.4 percent against later group estimates of 22.9, 21.6, 16.1 and 14.4. The separation survives every one of those and degrades smoothly, so the default is a choice about where to cut rather than the thing producing the result.

READING IT

The pane draws one line: the share of comparable past excursions already back at the age the open excursion has now reached. It appears while an excursion is open and is absent otherwise. Dotted guides sit at 25, 50 and 75.

That line is a distribution function of the age, so it is non-decreasing while an excursion stays open, and it ranked against that age between 0.88 and 0.93 across the three tested symbols. That is the same kind of clock relation the raw return share was rejected for two sections above, and it is not hidden here: the line rises because the excursion is getting older, not because anything has happened. What it adds over the age printed one row above it in the table is the conversion of that age into a historical frequency. It is not a second piece of information.

The background is shaded while an excursion is open. It is the same shade whichever side of VWAP price left from, on purpose. Which side price is on is on the price chart already, and colouring it here would dress a state as a lean.

The table carries nine rows. The first five describe the bar in front of you: the state, the distance from VWAP in basis points, how long the current excursion has been open, the share already back, and how many entries in this group are still under observation at that age against how many the group holds. That fifth row belongs with the first four rather than with the ledger, because it is read at the current age and the current age is a clock that only runs inside the session. The next three are the ledger behind it: the same estimate at a fixed reference age for each of the two groups, and the size of the whole ledger with how many of its entries were still out at the close. The ninth is a status line.

The data window carries four series: the age, the number still under observation, the size of the group and the size of the ledger. The distance from VWAP is in the table only. It is the same quantity a session VWAP band script already publishes, so it is here to make the excursion definition legible on screen and not as a reading of its own.

The status line names every reason there is no reading rather than printing something plausible in its place. There are nine messages besides the two that begin with ok, in the order they are tested. That the chart is built from synthetic prices. That it is not intraday. That it is a seconds or tick chart. That the symbol reports no volume. That no session has opened yet. That the bar is outside the counting window. That it is the first bar of a session, which has no distance to measure against a one bar average. How far along the ledger is, in excursions. And that this half of the session holds too few excursions to read, which is a different shortage from an empty ledger. Two notes can be appended to either ok message rather than replacing it, so the count of nine stands: how many entries are still under observation at this age when that number is below the floor, and, if it ever happened, that a session held more excursions than the buffer could carry.

On a refused chart the line and all four data window series are empty, all eight value cells in the table are empty, and only the status line speaks. The three dotted guides stay, being fixed levels rather than series, and the row labels stay so the table keeps its shape.

Outside the counting window is not a refusal but it blanks the same way for everything it affects. A bar before the open or after the close has fed nothing into the average and moved no clock, so the line, the shading, the first five table rows and three of the four data window series go empty rather than holding the last in-session value. The three ledger rows and the ledger size series stay, because they are history rather than a reading about that bar.

SETTINGS THAT MATTER

The distance that starts an excursion is the setting to move first and the one to set by the resulting ledger size rather than by taste. Too wide and the ledger holds nothing. Too narrow and it fills with round trips through a VWAP that price was sitting on anyway. It is in basis points of VWAP so that the same setting means the same proportional distance at any price level, and it is instrument specific: the same number gave 0.65 excursions a session on one ETF and 1.57 on another.

The split point decides which past excursions count as a similar time of day. The section above shows what moving it does. Its upper limit is twelve hours, so on an instrument whose counting window runs longer than that the split cannot reach the middle of the session and the two groups stop meaning early and late.

The reference age changes the two group rows in the table and nothing else. It does not touch the line, the live reading or the ledger.

The minimum group size is a floor, and it is worth knowing what it is a floor on. It counts the excursions in that half of the session, not the ones still under observation at the age being read. Those are different numbers and the second is usually much smaller, because an entry leaves the pool once its own session ended. Below the floor the line stays empty and the status line says how many excursions that half of the session holds. Above it the line draws, and whenever the number still under observation falls below the same figure the status line appends that count, so a thin reading says so. On the tested window that appended note was earned on between half and four fifths of the bars that drew a line, which is worth seeing rather than hiding. The same count is the fifth row of the table on every bar. The line itself is drawn dimmed wherever that count is below the floor, so the thin stretch is visible when scrolling back rather than only in the table on the last bar. Where the count reaches zero the estimate is carried forward from the last return the ledger saw, which is past everything it has observed, and the table says so beside the number.

Regular hours only decides both what feeds the average and what the session clock counts. Turning it off counts pre and post market bars into both.

WHAT IT WILL NOT DO

It generates no entries or exits, no alerts and no signals. Nothing in it is one.

It does not say that a push which has been out a long time is coming back. The estimate is a historical frequency and its complement is not a forecast. The excursions that stayed out are in the pool for as long as they were observable, and a push that has been out longer than most is equally consistent with a day that has simply gone somewhere. Nothing here separates those two cases, and treating the reading as a reason to take the other side is a use the record does not support.

It does not distinguish price returning to VWAP from VWAP arriving at price, and the section above says how large that second effect measured.

The estimator assumes that how long an excursion runs and how much session was left when it started are unrelated, and in this design they are related by construction, since the deadline is the session close and the whole file is about departure time mattering. Kaplan-Meier removes the part of that which comes from discarding observations. It does not remove the dependence itself, and no estimator computed from this ledger could.

Which way that pushes the numbers is worth being plain about, because the obvious answer is not the one the data gives. The mechanism is certain: inside the later group the 19 entries that leave the pool before an hour have a mean departure minute of 352, against 222 for the 57 still under observation at that age. Kaplan-Meier credits those departed entries with the return rate of the ones still being watched. If the latest departures were the slower returners, the later group's estimate would be pushed up and the gap this file reports would be conservative. On the tested window they are the faster ones: splitting the later group of 89 at its own median departure, the latest half reads 10.2 percent against 4.3 at thirty minutes, 20.3 against 13.0 at an hour, and 40.3 against 21.7 at ninety. That points the bias the other way, and would make the reported gap too wide rather than too narrow. Those percentages are thinner than they look. The 40.3 rests on 10 events with 6 of 43 entries still under observation, and the 20.3 on 17 of 43. And the deeper problem is not the sample. The test uses the very estimator whose assumption is in question, on the subgroup where that assumption bites hardest, so it is circular by construction rather than merely underpowered. The honest statement is that the sign is not determined here.

The ledger is built as the script runs across the loaded history, so two charts of the same symbol with different amounts of history loaded hold different ledgers and print different numbers. The ledger holds the most recent 300 excursions and then begins overwriting the oldest, so on a long chart the reference is recent history rather than all of it.

Excursions are disjoint in time, so unlike a rolling window count they are separate observations rather than overlapping ones. They are still not independent draws. The 211 excursions behind the numbers above come from 180 symbol sessions across three US equity funds that move together, on the same sixty calendar days, so a standard error computed as though they were independent is too small. At 122 entries a 41 percent share carries such a standard error of 4.5 points, and the honest one would be wider.

An excursion that opens on the last bar of a session is committed with a horizon of zero. It counts toward the ledger size and toward the entries marked still out at the close, and it enters no comparison at any age above zero, because there is nothing it could have shown. Three of the 211 excursions in the tested window were of this kind.

The current session's excursions are held back until that session ends, since the horizon each one needs is not known until then. So today's pushes inform tomorrow's reading and not today's.

The tested window contained no half day, so every session in it ran the same length. A shortened session produces shorter horizons and the ledger handles it by construction, but that path was not exercised by the measurements above.

It needs real volume. On a feed reporting tick counts instead of shares, VWAP and everything built on it are approximations, and spot FX has no consolidated volume to build one from.

It needs a standard chart. On Heikin Ashi, Renko, Kagi, Line Break, Point and Figure or Range bars the close is a synthetic price that no share traded at, and a ledger built from those would be a record of something that did not happen. Those charts are refused by name, as are seconds and tick charts.

Every reading is computed on closed bars. The forming bar carries the last closed bar's reading until it closes and takes its own then, and nothing already printed is rewritten afterwards.

This is context for a decision, not the decision.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI VWAP Excursion Engine", "YURI VXE", overlay = false)

// Session VWAP carries a deadline that most levels do not. Whatever price is
// doing when the session ends, the average resets and the question of whether
// price got back to it is closed for good. This keeps the record of how that
// question has been answered on the chart in front of you.
//
// An excursion opens on the first bar whose close sits more than a set distance
// from session VWAP, and closes on the first later bar whose range contains
// VWAP. A session that ends with one still open does not delete it: it is
// committed with the elapsed time kept as a lower bound and a mark saying the
// deadline arrived first. The pushes that did not come back are the ones a
// record of return times is most tempted to lose, and a record that loses them
// is an advertisement.
//
// THE ESTIMATOR. The share of excursions that came back before the close is
// mostly a readout of how much session was left when they started: across three
// US equity ETFs and sixty sessions of five minute bars, that share by hour of
// departure ranked against the minutes remaining at a Spearman of 0.96. So the
// ledger is read with a Kaplan-Meier estimate instead. Each entry contributes
// to the number at risk for as long as it was actually watched, contributes an
// event only where a return was seen, and an entry still out when its session
// ended leaves the risk set at that point rather than being counted as a
// failure to return or thrown away.
//
// The naive alternatives both break, in opposite directions. Admitting an entry
// only when its horizon reaches the age being asked about throws away returns
// that were already seen, and every one of those is a late departure because in
// a fixed length session a short horizon is a late start: on the tested window
// that understates the later group by 4.0 points at two hours. Admitting every
// entry whose outcome is determined swings it the other way, because a short
// horizon entry gets in only when it came back fast, which overstates the later
// group by 8.0 points at the same age.
//
// THE CLOCK. The ledger is kept in two groups split at a settable minute of the
// session. On the tested window, pushes leaving in the first two hours were back
// inside an hour 41.0% of the time against 16.1% for pushes leaving later.
//
// Two things have to be said about that number rather than left to the reader.
// First, in a fixed length session the departure minute and the minutes
// remaining are one variable with the sign flipped, and the two groups have no
// overlap on it at all, so this is not a time of day effect sitting on top of a
// remaining time effect. It is what is left after the observation windows are
// equalised at each age, which is a narrower claim. Second, the most likely
// mechanism is measured in this same file: VWAP itself is still mobile early in
// the session and nearly frozen late, and it supplied a median 38.8% of the
// closing distance for early departures against 16.9% for later ones, a ratio
// of 2.3 against the 2.5 ratio in the return shares. The ledger does not
// separate price coming back from VWAP arriving, so a large part of what looks
// like a clock effect on price is a clock effect on the average.
//
// Below about half an hour of age the two groups are not distinguishable on the
// tested window: the gap at fifteen minutes is 1.0 points against a standard
// error of 3.1.
//
// WHAT THE LINE IS. An empirical distribution function of the age, so it is
// non-decreasing while an excursion stays open and it ranked against that age
// between 0.88 and 0.93 across the three tested symbols. That is the same kind
// of clock relation the raw return share was rejected for, and it is not
// hidden: the line rises because
// the excursion is getting older, and what it adds over the age printed one row
// above it is the conversion of that age into a historical frequency. It is not
// a second piece of information and it is not news arriving.
//
// The complement of the line is not a forecast that the rest are coming back. A
// push that has been out longer than most is equally consistent with a day that
// has simply gone somewhere, and nothing here says which.
//
// The two sides are pooled rather than kept apart, and that is a measurement
// rather than a convenience. On the tested window the same estimate at an hour
// reads 30.7% for the 100 pushes above VWAP and 32.0% for the 111 below. A
// split that buys nothing costs half the sample.
//
// The distance is set in basis points of VWAP rather than in units of the
// deviation, so that the same setting means the same proportional distance at
// any price level, and so that the reading does not inherit a second statistic
// with its own sampling behaviour. It is instrument specific: on five minute
// bars over the tested window the default produced about 0.65 excursions a
// session on one ETF and about 1.57 on another. The status line prints how many
// the ledger is holding, which is the number to set it by.
//
// Everything is computed on closed bars. The forming bar carries the last closed
// bar's reading until it closes and takes its own then; nothing already printed
// is rewritten afterwards.

// Excursion ------------------------------------------------------------------
enterBps = input.float(35.0, "Distance that starts an excursion, bps of VWAP", minval = 5.0, maxval = 500.0, step = 5.0, group = "Excursion", tooltip = "One basis point is 0.01%. This is instrument specific and is meant to be set by the resulting ledger size rather than left alone: too wide and the ledger holds nothing, too narrow and it fills with round trips through a VWAP that price was sitting on anyway.")
rthOnly  = input.bool(true, "Regular hours only", group = "Excursion", tooltip = "Off counts pre and post market bars into the average and into the session clock.")

// Ledger ---------------------------------------------------------------------
splitMins = input.int(120, "Split the ledger at, minutes into the session", minval = 20, maxval = 720, group = "Ledger", tooltip = "Excursions that start before this minute are compared only with each other, and the same for the ones that start after. Two groups rather than more, because a finer split runs the comparison sets down to a size that carries no information. On a symbol whose counting window runs longer than twelve hours the cap here cannot reach the middle of the session, and the two groups stop meaning early and late.")
minSample = input.int(15, "Excursions needed in a group before it reads", minval = 5, maxval = 100, group = "Ledger")
refMins   = input.int(60, "Reference age for the two group rows, minutes", minval = 5, maxval = 720, group = "Ledger", tooltip = "The two group rows report the same estimate at this fixed age. It changes those two rows and nothing else.")

showBg    = input.bool(true, "Shade while an excursion is open", group = "Display")
showTable = input.bool(true, "Show readout", group = "Display")

// How many past excursions the ledger holds. A ring: the oldest is overwritten
// once it is full, so the reference is the recent history of the chart rather
// than all of it.
int MAXLED = 300

// Excursions buffered inside the current session before they are committed.
// They are held rather than committed as they happen, because the horizon each
// one needs is the time from its start to the end of its own session, which is
// not known until that session ends.
int MAXPEND = 64

// One slot per minute of a day, which is the resolution the durations are kept
// at and the longest session anything here can meet.
int KSLOTS = 1441

// Renko, Kagi, Heikin Ashi, Point and Figure, Line Break and Range charts each
// derive their close from a rule instead of from a trade. None of the remaining
// gates would object, the status line would sit at ok, and the ledger would end
// up a record of prices nobody paid.
stdOk      = chart.is_standard
intradayOk = timeframe.isintraday
tfOk       = not timeframe.isseconds and not timeframe.isticks
engineOk   = stdOk and intradayOk and tfOk

// ta.* is hoisted to the top level. Inside a conditional it would stop being
// evaluated on every bar and its history would go wrong.
newDay   = ta.change(time_tradingday) != 0
counting = rthOnly ? session.ismarket : true

// Volume presence gets its own flag rather than being inferred from the
// accumulator. A running total that takes a single na stays na for the rest of
// the chart, and every test after it would then describe an empty engine
// instead of naming the symbol as the problem. The flag also catches the feeds
// that answer with a hard zero.
var bool sawVolume = false
if not na(volume) and volume > 0.0
    sawVolume := true

// A symbol with no volume cannot carry a volume weighted average, so it is a
// refusal and not a warmup. Refusals blank every line and every value cell and
// leave the status line to do the talking, rather than printing a shape that
// looks like a reading.
readOk = engineOk and sawVolume

// A bar outside the counting window has fed nothing into the average and moved
// no clock, so everything that describes the current bar belongs to the last bar
// that did. Carrying it forward would draw a whole post-market session of a
// number the script is not measuring. The ledger rows are history rather than a
// live reading, so they stay on readOk.
liveOk = readOk and counting

var float cumVol = 0.0
var float cumPV  = 0.0
var int   periodBars = 0

var int  sessionStart = na
var bool sessionOpen  = false
var int  lastMin      = 0

var array<float> durA = array.new<float>(MAXLED, na)
var array<float> horA = array.new<float>(MAXLED, na)
var array<float> grpA = array.new<float>(MAXLED, na)
var int ledPtr = 0
var int ledN   = 0

var array<float> pendDep = array.new<float>(MAXPEND, na)
var array<float> pendDur = array.new<float>(MAXPEND, na)
var int  pendN = 0
var bool pendOverflow = false

var bool  outNow  = false
var int   outDep  = 0
var int   outSide = 0

var float vwapNow = na
var float distBps = na
var int   curMin  = 0
var float curAge  = na

// The survival curve for each departure group, and the number of entries still
// under observation at each age. Rebuilt once per session rather than per bar,
// because nothing is committed to the ledger inside a session.
var array<float> kmE  = array.new<float>(KSLOTS, 0.0)
var array<float> kmL  = array.new<float>(KSLOTS, 0.0)
var array<float> nAtE = array.new<float>(KSLOTS, 0.0)
var array<float> nAtL = array.new<float>(KSLOTS, 0.0)

// Kaplan-Meier for one group. The observed time of an entry is its duration if
// it returned and its horizon if it was still out at the close, so n(u) is the
// reverse cumulative count of observed times and S(t) is the running product of
// (1 - d(u)/n(u)) over the ages where a return was seen.
f_kmBuild(array<float> _nAt, array<float> _km, float _grp) =>
    array.fill(_nAt, 0.0)
    array<float> _ev = array.new<float>(KSLOTS, 0.0)
    if ledN > 0
        for i = 0 to ledN - 1
            if array.get(grpA, i) == _grp
                float _dd = array.get(durA, i)
                float _hh = array.get(horA, i)
                float _obs = na(_dd) ? _hh : _dd
                int _o = math.max(0, math.min(KSLOTS - 1, int(_obs)))
                array.set(_nAt, _o, array.get(_nAt, _o) + 1.0)
                if not na(_dd)
                    int _d = math.max(0, math.min(KSLOTS - 1, int(_dd)))
                    array.set(_ev, _d, array.get(_ev, _d) + 1.0)
    float _run = 0.0
    for k = 0 to KSLOTS - 1
        int _u = KSLOTS - 1 - k
        _run += array.get(_nAt, _u)
        array.set(_nAt, _u, _run)
    float _surv = 1.0
    array.set(_km, 0, 0.0)
    for _u = 1 to KSLOTS - 1
        float _d = array.get(_ev, _u)
        float _n = array.get(_nAt, _u)
        if _d > 0.0 and _n > 0.0
            _surv *= 1.0 - _d / _n
        array.set(_km, _u, (1.0 - _surv) * 100.0)

// A forming bar recalculates from the previous close, and scalars are rewound
// for it while arrays keep whatever was pushed into them. A commit made part way
// through a bar would therefore outlive the rewind and be made a second time
// when the bar finished. Confining the state machine to closed bars removes that
// whole class of double counting, and what it costs is a reading that would have
// been provisional anyway.
if barstate.isconfirmed and engineOk

    // The session clock is not started from an edge on session.ismarket. Some
    // feeds carry nothing at all outside the session, so that flag reads true on
    // every bar they have and there is no edge to catch; a cash index behaves
    // this way. What both kinds of feed do have is the exchange day rolling
    // over, so that is the boundary used here, and the clock begins counting at
    // the first bar that actually feeds the average.
    if newDay
        // The session that just ended is the one whose horizons are now known.
        // An excursion still open at that point is committed as still out, with
        // the elapsed time kept: dropping it is what would bias the ledger, and
        // it is a lower bound rather than a duration.
        if outNow
            if pendN < MAXPEND
                array.set(pendDep, pendN, outDep)
                array.set(pendDur, pendN, na)
                pendN += 1
            else
                pendOverflow := true
        if pendN > 0
            for i = 0 to pendN - 1
                float dep = array.get(pendDep, i)
                float dur = array.get(pendDur, i)
                float hor = lastMin - dep
                if hor >= 0.0
                    array.set(durA, ledPtr, dur)
                    array.set(horA, ledPtr, hor)
                    array.set(grpA, ledPtr, dep <= splitMins ? 0.0 : 1.0)
                    ledPtr := (ledPtr + 1) % MAXLED
                    ledN   := math.min(ledN + 1, MAXLED)
        f_kmBuild(nAtE, kmE, 0.0)
        f_kmBuild(nAtL, kmL, 1.0)
        pendN  := 0
        outNow := false
        cumVol := 0.0
        cumPV  := 0.0
        periodBars := 0
        sessionOpen := false
        lastMin := 0

    if counting
        if not sessionOpen
            sessionOpen  := true
            sessionStart := time
        cumVol += nz(volume)
        cumPV  += nz(volume) * hlc3
        periodBars += 1
        curMin  := int(math.floor((time - sessionStart) / 60000.0))
        lastMin := curMin
        vwapNow := cumVol > 0.0 ? cumPV / cumVol : na

        // A one bar session VWAP is that bar's own hlc3, so a distance measured
        // against it describes the shape of the bar rather than where the bar
        // sits in the day. The bar count is the test that holds up in floating
        // point; asking whether the distance is zero asks something else, and it
        // rests on a difference of two nearly equal quantities whose sign is
        // decided by rounding.
        bool dataOk = periodBars > 1 and not na(vwapNow) and vwapNow > 0.0
        distBps := dataOk ? (close - vwapNow) / vwapNow * 10000.0 : na

        // Closing an open excursion is tested before opening a new one, so a bar
        // that trades through VWAP and still closes past the threshold ends one
        // excursion and starts another on the same bar. One push that retreats
        // partway and goes out again without reaching VWAP stays a single
        // excursion, which is what makes the duration a duration.
        if outNow and dataOk and low <= vwapNow and high >= vwapNow
            if pendN < MAXPEND
                array.set(pendDep, pendN, outDep)
                array.set(pendDur, pendN, curMin - outDep)
                pendN += 1
            else
                pendOverflow := true
            outNow := false

        if not outNow and dataOk and math.abs(distBps) >= enterBps
            outNow  := true
            outDep  := curMin
            outSide := distBps > 0.0 ? 1 : -1

        curAge := outNow ? curMin - outDep : na

// Two array reads, because the curve belongs to the ledger and the ledger does
// not move inside a session.
float share   = na
int   riskNow = 0
int   grpN    = 0

if outNow and not na(curAge)
    bool early = outDep <= splitMins
    int a = math.max(0, math.min(KSLOTS - 1, int(curAge)))
    grpN    := int(early ? array.get(nAtE, 0) : array.get(nAtL, 0))
    riskNow := int(early ? array.get(nAtE, a) : array.get(nAtL, a))
    if grpN >= minSample
        share := early ? array.get(kmE, a) : array.get(kmL, a)

// The two group rows, both at one fixed age.
int   refSlot = math.max(0, math.min(KSLOTS - 1, refMins))
int   eTot    = int(array.get(nAtE, 0))
int   lTot    = int(array.get(nAtL, 0))
float eShare  = eTot >= minSample ? array.get(kmE, refSlot) : na
float lShare  = lTot >= minSample ? array.get(kmL, refSlot) : na

// How many entries the ledger is holding that ended with the deadline rather
// than with a return. One pass, on the only bar the table is drawn on.
int stillOut = 0
if showTable and barstate.islast and ledN > 0
    for i = 0 to ledN - 1
        if na(array.get(durA, i))
            stillOut += 1

// Every reason there is no reading is named. A message saying the ledger is
// filling, on a chart that will not fill one, is worse than no message.
string baseStatus = not stdOk ? "needs a standard chart, this one is built from synthetic prices" : not intradayOk ? "needs an intraday chart" : not tfOk ? "needs a chart of one minute or more" : not sawVolume ? "no volume on this symbol" : na(sessionStart) ? "waiting for a session to open" : not counting ? "outside the counting window" : periodBars <= 1 ? "first bar of the session" : ledN < minSample ? "filling the ledger, " + str.tostring(ledN) + " of " + str.tostring(minSample) + " excursions" : not outNow ? "ok, no excursion open" : grpN < minSample ? "only " + str.tostring(grpN) + " excursions in this half of the session" : "ok"

// The floor is on the size of the half of the session, not on how many entries
// are still being watched at the age being read. That is the right gate for a
// survival estimate, which uses every event up to the age rather than only the
// entries that outlived it, but it means the precision at long ages is not
// gated at all. So the count is appended to the status whenever it falls below
// the same floor, and named outright when it reaches zero, where the curve is
// carried forward from the last event and the age is past everything the ledger
// has seen. The count is also the table row directly below the estimate.
bool statusIsOk = baseStatus == "ok" or baseStatus == "ok, no excursion open"
bool thinNow = outNow and not na(share) and riskNow < minSample
string thinNote = not thinNow ? "" : riskNow == 0 ? "; nothing still under observation at this age, the estimate is carried forward" : "; only " + str.tostring(riskNow) + " still under observation at this age"

// The overflow flag is sticky, because a session that lost excursions has left
// a hole in the ledger that later sessions do not fill. Both notes hang off an
// ok status rather than replacing a message that matters more, so the count of
// reasons there is no reading is unchanged.
string statusText = baseStatus + (statusIsOk ? thinNote : "") + (pendOverflow and statusIsOk ? "; a session overflowed the excursion buffer" : "")

color sideColor = not outNow ? color.gray : color.teal

// The shading says an excursion is open and nothing else. It is deliberately
// the same colour on both sides: which side of VWAP price left from is on the
// price chart already, and colouring it here would dress a state as a lean.
bgcolor(showBg and liveOk and outNow ? color.new(color.teal, 90) : na)

// The line is drawn dimmed wherever the count still under observation is below
// the floor, which is the long-age tail. The estimate there is a correct
// Kaplan-Meier value and it keeps drawing at every age; what changes is that
// it no longer looks like a reading standing on a full group. One plot call
// with a series colour rather than two complementary ones, which would leave
// a one bar hole wherever the condition flips.
color shareColor = thinNow ? color.new(color.orange, 55) : color.new(color.orange, 0)

plot(liveOk ? share : na, "Share of comparable excursions already back", shareColor, 2)

hline(50, "Half", color.new(color.gray, 60), hline.style_dotted)
hline(25, "Quarter", color.new(color.gray, 80), hline.style_dotted)
hline(75, "Three quarters", color.new(color.gray, 80), hline.style_dotted)

plot(liveOk and not na(curAge) ? curAge : na, "Age of the open excursion (min)", display = display.data_window)
plot(liveOk and outNow ? float(riskNow) : na, "Still under observation at this age", display = display.data_window)
plot(liveOk and outNow ? float(grpN) : na, "Excursions in this group", display = display.data_window)
plot(readOk ? float(ledN) : na, "Excursions in the ledger", display = display.data_window)

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 9, border_width = 1)
    table.cell(t, 0, 0, "State", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, not liveOk ? "" : not outNow ? "no excursion open" : outSide > 0 ? "out above VWAP" : "out below VWAP", text_color = color.white, bgcolor = color.new(sideColor, 25), text_size = size.small)
    table.cell(t, 0, 1, "Distance from VWAP", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, not liveOk ? "" : na(distBps) ? "-" : str.tostring(distBps, "#.#") + " bps", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 2, "Time out", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, not liveOk ? "" : na(curAge) ? "-" : str.tostring(curAge, "0") + " min", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 3, "Comparable already back", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, not liveOk ? "" : na(share) ? "-" : str.tostring(share, "0") + "%" + (riskNow == 0 ? " carried forward" : ""), text_color = color.white, bgcolor = color.new(na(share) ? color.gray : color.orange, 25), text_size = size.small)
    table.cell(t, 0, 4, "Still watched at this age", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, not liveOk ? "" : not outNow ? "-" : str.tostring(riskNow) + " of " + str.tostring(grpN) + " in this group", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 5, "Early group at " + str.tostring(refMins) + " min", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 5, not readOk ? "" : na(eShare) ? "-" : str.tostring(eShare, "0") + "% of " + str.tostring(eTot), text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 6, "Later group at " + str.tostring(refMins) + " min", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 6, not readOk ? "" : na(lShare) ? "-" : str.tostring(lShare, "0") + "% of " + str.tostring(lTot), text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 7, "Ledger", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 7, not readOk ? "" : str.tostring(ledN) + " excursions, " + str.tostring(stillOut) + " still out at the close", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 8, "Status", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 8, statusText, text_color = statusIsOk ? color.gray : color.orange, text_size = size.small)
````
