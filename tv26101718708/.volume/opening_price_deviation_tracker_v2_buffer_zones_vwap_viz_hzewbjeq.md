# Opening Price Deviation Tracker v2 - Buffer Zones - VWAP [ViZ]

- url: https://www.tradingview.com/script/HzEwbJEQ-Opening-Price-Deviation-Tracker-v2-Buffer-Zones-VWAP-ViZ/
- type: indicator
- pine_id: PUB;c275bef0877e4d0aaf66ff09745e4bc7
- version: 1.0

## Description

OPENING PRICE DEVIATION TRACKER v2 — BUFFER ZONES — VWAP [ViZ]



[b]WHAT IT DOES[/b]

Measures how far price has travelled from the opening price of a chosen anchor
period, and maps that distance onto a fixed percentage grid on the chart.

The reasoning is that the open of the current period is a reference every
participant on the instrument shares, and that distance from it expressed in
percent is comparable across instruments and across time in a way raw price
distance is not. A 1% move from the weekly open means the same thing on a
30,000-point index as on a 40-dollar stock.

Around that single idea the script adds a tolerance band on each level, a
permanent record of which levels each period actually reached, a three-timeframe
summary panel, optional trend and volume references, and three alert channels
that differ in what they detect rather than only in speed.

Every component keys back to the same anchor open. This is not a set of unrelated
tools sharing a pane.


[b]1. THE ANCHOR OPEN, AND WHY IT IS LATCHED[/b]

The Timeframe input sets the anchor period — weekly by default, but any timeframe
longer than the chart's.

The script obtains that period's opening price by latching it: on the first chart
bar of a new anchor period, that bar's own open IS the period's open, so the value
is stored and held until the next rollover.

There is no request.security() call anywhere in the script. Not for the anchor
open, not for the three table columns, not for VWAP.

That matters for a specific reason worth stating plainly. The obvious way to build
this is request.security with lookahead enabled, and for an OPEN that is actually
defensible — an open is fixed by the first tick of its period, so requesting it
with lookahead never returns a number that was unknowable at the time. Without the
flag the same call returns the PREVIOUS period's open until the current one closes,
which puts the whole grid one full anchor period behind itself, so simply turning
the flag off is not an option. Latching sidesteps the argument entirely: the value
is a chart bar's own open, so it provably cannot look ahead, there is no
higher-timeframe request to disclose, and there is no real-time-to-historical
transition to reason about. Levels drawn on historical bars are the levels that
genuinely existed at the time, and they do not change on reload.

The period high and low used by the panel are accumulated from chart bars for a
different and stronger reason: a period's extremes are only settled when the period
ENDS, so requesting those with lookahead genuinely would leak future data onto
historical bars. Open safe, extremes not — that distinction is the whole substance
of the question.

Latching does cost something, in the form of four documented behaviours. They are
in the LIMITATIONS section, and reading it will explain most of what could
otherwise look like a bug.


[b]2. THE DEVIATION GRID[/b]

From the latched open the script builds five levels above and five below, spaced by
a fixed percentage step, with the 0% line marking the open itself. Line width
increases with distance, so ±1 is a hairline and ±5 is the heaviest — depth is
readable without checking the labels. Each level carries a right-edge label showing
both its price and its percentage offset. Colours darken progressively outward from
the two base colours you set.

The step comes from a preset list, each labelled with its own value:

   0.25%   — scalping / very low volatility
   0.3875% — reactive / lower timeframes
   0.50%   — intraday
   1.00%   — balanced (default)
   2.00%   — swing / higher timeframes
   3.00%   — high volatility / highest timeframes
   Custom  — any value from 0.1 upward

Because the grid always runs to five levels, the step also fixes its total span: 1%
covers ±5%, 2% covers ±10%, 0.25% covers ±1.25%. Pick the step whose span roughly
brackets what your anchor period typically moves. Too small and price sits
permanently off the top or bottom of the grid; too large and it never leaves the
first band, and nothing the script draws will tell you anything.

As orientation rather than instruction: the lower steps suit major FX pairs and
large-cap equities on intraday anchors, the middle of the range suits indices and
most equities on daily and weekly anchors, and the upper steps suit small caps,
commodities and crypto, or any weekly-and-above anchor. Volatility varies more
inside an asset class than between them, so verify against the instrument in front
of you and switch to Custom once you know what you want.

The step also drives the panel's Zone and To Next rows, the buffer positions, touch
detection and the markers — one number, one grid, everywhere.


[b]3. LINE DISPLAY[/b]

Three modes:

   Off                       — no grid lines; panel, markers and alerts still work
   Show All                  — full grid across history and the live period
   Touched Only (Historical) — live period shows the full grid; completed periods
                               keep only the levels price actually reached

The third is the default and is the one worth understanding. On a chart with months
of history, showing all eleven lines per period is unreadable. Retaining only the
levels each period actually reached leaves a permanent record of how far each period
extended — which is usually the only thing you wanted from the older periods.

Those historical segments are stored as drawn objects and accumulate without an
explicit cap, bounded only by TradingView's 500-line budget. When the ceiling is
reached the platform deletes the oldest, so the recent history you actually look at
is never what disappears. The 0% opening line is exempt from filtering and always
renders in full.


[b]4. BUFFER ZONES[/b]

Each deviation level, and the open itself, can carry a translucent band drawn a set
percentage of price above and below it — eleven bands in total.

Two reasons for them. Price rarely reacts at an exact tick; it reacts in a region
around a reference, so a band represents the level more honestly than a line. And
the band gives an anticipatory alert trigger: entry into the band fires before the
level is reached.

The live period's bands are drawn spanning the current period. Bands from previous
periods are also retained, but only for levels that were actually touched, so past
structure appears where something happened rather than as uniform wallpaper.
Historical retention is capped at 44 periods, which is the limit of the platform's
500-drawing budget once the live period's own eleven boxes are accounted for; lower
it freely for a cleaner chart, nothing else depends on it.

One interaction to be aware of: buffer size is a percentage of price and does not
scale with the grid step. Lead time depends on the RATIO of the two, not the
absolute size. At roughly a quarter of the deviation step the warning is genuinely
early; at half or more the warning and the touch collapse into the same bar. The
default 0.15 against a 1% grid is 15%. Against the 0.3875% preset the same value is
39%, which effectively eliminates the early warning; against the 3% preset it is 5%,
which may be too tight to see. If you change the step, check the buffer against it.


[b]5. TOUCH MARKERS[/b]

Optional, and off by default. A small marker is placed on the first bar of each
period that reaches each level — one marker per level per period, re-armed at every
rollover.

Marker shapes:

● circle — touch: the bar's range reached the level.

▲ ▼ triangle — acceptance: the bar CLOSED beyond the level. Points up above the
open, down below it.

◆ diamond — rejection: the bar tagged the level and closed back, with a retreat wick
larger than the threshold you set.

✕ cross — gap through: the bar reached the level without trading into it.



Three detail modes let you take just the touches, touches plus acceptance, or the
full touch / rejection / acceptance set. Rejection sensitivity is adjustable as a
fraction of the bar's range, 0.5 by default; raise it toward 0.65 for a stricter
read. Marker range is adjustable up to ±5 levels, ±4 by default. The 0% line can be
marked too, optionally. Colours inherit from the grid by default, so a +3 marker
matches the +3 line; the 0% marker is always blue to match the opening-price line.
Each marker's tooltip states the level and the classification.

Markers use the same reach test as the historical line segments — directional above
and below the open, straddle at 0% — so a marker and a retained line segment can
never disagree about whether a level was touched. Markers appear at bar close by
default; an option tags them on the live bar instead, in which case the shape may
still change before the bar closes, because acceptance and rejection both depend on
where the bar ends up. That option is visual only and affects no alert.


[b]6. BAR COLOURING[/b]

Optional, with two selectable sources.

Deviation Levels colours each bar by which of the eleven grid zones it closed in,
using the same progressively darkening shades as the lines, with the "between
levels" colour for bars inside the first band. The candles then carry the deviation
reading themselves, which means you can switch the grid off entirely and still see
depth — a genuinely clean chart that still reports.

VWAP / Bands colours by position relative to the anchored VWAP and its bands
instead: five zones, beyond the outer band, beyond the inner band, and between, on
each side. It falls back to plain above/below VWAP when bands are off. Useful when
you want the grid for structure but volume-weighted price for bias. This mode needs
only volume and a valid anchor, so it works with the VWAP line itself hidden.

Bars before the first anchor rollover are deliberately left uncoloured rather than
being painted a default shade, since no zone reading exists for them yet.


[b]7. MOVING AVERAGE[/b]

Optional SMA or EMA, adjustable period, 200 by default. Context rather than signal:
it exists so you can see whether a level is being approached with or against the
prevailing trend, which usually matters more than the touch itself.


[b]8. VWAP[/b]

Optional anchored VWAP with its own reset selection, independent of the deviation
anchor: daily session, weekly, monthly, quarterly, semi-annual, annual, Match
Deviation Anchor, or a custom timeframe. Daily session matches the standard
TradingView VWAP. The multi-month options are derived from the monthly rollover and
then gated by calendar month, so they land on real calendar boundaries — January /
April / July / October, January / July, and January — rather than drifting from an
arbitrary reference point.

Match Deviation Anchor is the setting for a single consistent frame of reference:
grid and VWAP then reset on the same bar and describe the same period. The
independent options cover the common case of a session VWAP underneath a weekly or
monthly grid.

Two optional band pairs, in either standard-deviation or percentage units, are
independent of the deviation grid preset. The outer pair is rendered a step more
transparent than the inner, so depth reads without a second colour input, and a very
light fill between the inner pair is available but off by default so it does not
compete with the buffer zones. Note that in sigma mode the bands pinch shut at each
anchor reset and flare open over following bars — that is inherent to anchored
standard deviation, not a fault; percentage mode does not do it.

The line and bands are blanked on the anchor bar itself, so the plot BREAKS at each
reset instead of drawing a diagonal from the old period's last value to the new
one's first.

VWAP needs volume, and needs an anchor longer than the chart timeframe. If either
is missing, an on-chart label states which — including when VWAP is hidden but the
VWAP bar-colouring mode is active and starved.


[b]9. THE DATA PANEL[/b]

Projects the same deviation grid onto three user-selectable timeframes, each
measured from that timeframe's own latched opening price. Defaults are daily,
weekly and monthly, and the column matching the indicator's own anchor is marked
with a diamond. The title bar shows the active step, for example "1% grid".

Rows, in Full detail:

Open — that period's opening price, at the symbol's own precision.

Δ from Open — percentage move from that open, with a direction arrow. Colour
intensity scales with magnitude, and the saturation ceiling scales as the square
root of the column's length, so at the 1% preset the daily column saturates around
2%, the weekly around 4.5% and the monthly around 9.2%. Each column is therefore
meaningful on its own scale, rather than one fixed ceiling that the longest column
always maxes out.

Zone — which band price currently occupies, shown as "+1 → +2", "0 → -1" and so on,
filled with the SAME colour as the corresponding chart grid line. Beyond the grid it
reads "> +5" or "< -5" rather than silently clamping.

To Next % — distance to the level above and the level below. This is the practical
number for judging whether a target is in reach.

Range Pos — where price sits inside that period's realised high-low range so far, as
a percentage with a small meter. 90% means price is near the top of everything the
period has covered.

State — bullish, bearish or neutral, combining direction from Δ with conviction from
Range Pos, so it is not merely a restatement of the sign of Δ. When the range is
unknown it degrades to direction only.

Compact detail drops To Next and Range Pos and closes the gap rather than leaving
empty rows. The panel's whole surface palette — header band, row banding,
separators, anchor-column wash — is derived from one background colour input, and
text automatically switches to a dark set on light backgrounds. Colour is carried by
text tint throughout, with the Zone row as the single filled block and the panel's
focal point.

Three column states exist. A column SHORTER than the chart timeframe reads "below
chart TF", because a shorter-timeframe open cannot be resolved honestly from a
longer chart bar. A column whose boundary has not appeared inside the loaded chart
history reads "no boundary yet" — see LIMITATIONS. Otherwise it reports normally.

The point of three columns at once is alignment. Bullish daily, bearish weekly,
bullish monthly is a different situation from all three agreeing, and the panel makes
that visible without changing timeframe.


[b]10. ALERTS — THREE CHANNELS[/b]

The three channels differ in WHAT THEY DETECT, not only in how fast they report.
Each has its own toggle.

BUFFER (early warning) — fires when price first enters the band around a level.
Dispatches intrabar, the moment the band is entered; delivered at the bar close it
would already have been overtaken by events. On by default.

AT LEVEL — fires on any bar whose range CONTAINS a level, and keeps repeating for
as long as price stays there. Dispatches intrabar, on the first qualifying tick.
This is safe intrabar because the test reads only high and low: inside a live bar
the range only ever widens, so once it engulfs a level no later tick can un-happen
it. The cost is partial reporting — a candle running through +1, +2 and +3 names +1,
because that is what was true at the tick it fired. On by default.

FIRST TOUCH — fires the first time each level is reached in the anchor period, then
stays silent about that level until the next period. Dispatches at bar close,
because its wording carries a classification — touch, closed beyond, rejected — and
all of those read where the bar closed, which on a live bar is only the current
price and could flip tick to tick. Evaluated once on a finished bar, it loops every
level and reports all of them. Off by default. Works with the markers hidden.

The two level channels also DETECT differently, which is why both exist. At Level
requires the bar to straddle the level. First Touch tests directionally, so a bar
that jumps clean over a level without trading back into it is reported by First
Touch and is structurally invisible to At Level. That is the gap-through case, and
it is exactly what a news candle does.

So: buffer and at-level answer "tell me now". First touch answers "tell me
everything, a moment later".

All three messages render as "<what happened>: <detail> | Price: <price>", with the
buffer channel adding " | Level: <price>", so anything parsing them downstream sees
one consistent shape. No timestamps are embedded, because every delivery method
TradingView offers already stamps the notification.

TO SET UP: create ONE alert on the indicator with the condition set to "Any alert()
function call". The three toggles decide what it reports. The long string
TradingView pre-fills is the alert's NAME, auto-built from every input — rename it
in the dialog; it is not the message.

If you want a different sound or webhook per channel, add the indicator to the chart
more than once, enable exactly one channel per instance, strip the extra instances
of all drawing, and name each chart alert after its channel. Keep the anchor and
preset identical across instances or the channels start describing different grids.

One known behaviour: if a single bar enters more than one buffer band, the buffer
message names the last one evaluated rather than listing all of them. The alert
still fires; the label is simply not exhaustive. Most visible on fast bars, or when
buffer size approaches half the deviation step and bands begin to overlap.


[b]11. CHOOSING A CHART TIMEFRAME AND ANCHOR[/b]

The useful rule of thumb is that the anchor period should span roughly 20 to 100
bars of the chart timeframe. Fewer and the grid has no room to develop; many more
and the levels are too distant to be actionable within a session.

In practice: 1m to 15m charts pair with daily and weekly anchors, hourly and 4-hour
with weekly and monthly, daily and above with monthly, quarterly and annual. For
the panel, suggested column sets are 4H/D/W under a weekly anchor, D/W/M under a
weekly or monthly anchor, and M/3M/12M under a quarterly anchor.

Some ways it gets used:

Mean-reversion context — a level reached early in a period, price stalling inside
the band, moving average leaning the other way, is a different proposition from the
same level reached mid-expansion. The rejection marker is what separates the two
after the fact.

Continuation context — sequential first-touches inside one period, left on the
chart by the touched-only display, show whether a period is expanding steadily or
stalling at the same band repeatedly. Acceptance triangles at successive levels read
differently from a diamond at the same level three times.

Risk framing — because levels are percentage distances, To Next % converts directly
into stop and target distances in the same units you size positions in.

Period bias — the panel alone, grid switched off, works as a compact
three-timeframe bias readout.

Monitoring — the first-touch channel lets you watch a list of instruments for
meaningful extension from their period open without staring at charts, and the
buffer channel gives the heads-up before it happens.

None of the above is prescriptive. The defaults are a reasonable place to start
rather than a recommendation, and the script is deliberately built so that almost
every part of it can be moved without breaking anything else — so move things.
Put the same anchor on three different chart timeframes and watch how the grid
changes character. Run the panel's three columns as 4H/D/W for a session, then as
D/W/M, and see which alignment you actually read. Switch the VWAP anchor from
session to weekly, or match it to the deviation anchor, and notice how differently
the two reference points behave when they reset together versus separately. Try
the bar colouring on one source, then the other, with the grid lines switched off
entirely. Step the deviation preset up and down on an instrument you know well
until the spacing stops feeling arbitrary — that is usually the moment the tool
starts being useful, and it is different for every instrument and every holding
period. Custom exists for when you get there.

Nothing you change is destructive and nothing is hidden behind a setup process:
every input has a tooltip explaining what it does and, where it matters, what it
interacts with. The fastest way to understand any of this is an afternoon of
switching things on and off on a chart you already have an opinion about.


[b]12. LIMITATIONS AND KNOWN BEHAVIOURS[/b]

These are consequences of the design choice in section 1, and are stated rather
than hidden.

Leading partial period is blank. Nothing is latched until the first rollover INSIDE
loaded history, so the leftmost partial anchor period has no open and therefore no
grid, no buffers, no labels and no bar colour. It scales inversely with chart
resolution — trivial on a 15-minute chart holding thirty weeks, pronounced on a
1-minute chart holding two. Scroll hard left to see it. It is not a fault, and it is
the exact price of using no lookahead.

Columns longer than loaded history report nothing. No boundary in history means no
open, which cascades through every row, so the Δ cell says "no boundary yet" to make
the cause legible instead of leaving the column looking broken. This is a bar-density
effect: roughly 20,000 loaded one-minute bars is about 2.5 months of a 6.5-hour
equity session but under three weeks of a 24-hour instrument, so a monthly column
resolves on the former and not the latter. It also moves with the viewer's data
plan, so two users on the same chart can see different columns populated. The remedy
in every case is to view the same period on a higher chart timeframe — and in
practice column choice tracks chart timeframe anyway.

The open is session-dependent. It is the first chart bar's open under your CURRENT
session settings, which on an extended-hours symbol need not equal the feed's
official daily open. Verified to line up with session boundaries across equities,
indices and FX; it is simply the property to know about when comparing against a
platform VWAP or a broker's stated open.

The first snapshot is skipped. On the very first rollover in loaded history there is
no preceding period to snapshot, so that one period's historical segments and buffer
boxes are absent. It degrades quietly.

Buffer does not scale with the grid, as described in section 4.

The grid is not volatility-adaptive. Levels are fixed arithmetic percentages of the
open. The script does not measure realised volatility and will not widen the grid in
a volatile regime — step selection is yours to make and to revisit.

References need data. The moving average needs its full lookback before plotting;
VWAP needs volume and an anchor longer than the chart timeframe.

Drawing budgets. Retained line segments and markers share TradingView's per-script
object limits. When a ceiling is reached the oldest objects are dropped, so recent
history is never what goes missing. Reducing the marker range or the historical
buffer lookback extends how far back the rest survives.

Chart type. Use standard candles or bars. Heikin Ashi, Renko, Kagi and range bars
synthesise their own prices, which distorts every level, every touch and every alert
this script produces.

Finally, this is a measurement and context tool. It reports where price is relative
to a period open and tells you when that changes. It does not forecast direction,
and nothing in it should be read as a prediction or as a standalone entry system.


[b]13. NOTES[/b]

Open source under the Mozilla Public License 2.0, and the source is heavily
commented — every design decision above, including the ones I chose not to make and
why, is documented in the code itself alongside the reversion instructions.

All logic is self-contained. No external libraries, no imported code from other
authors, no request.security() of any kind.

Defaults ship usable rather than optimal for any one instrument: weekly anchor, 1%
grid, touched-only historical lines, 0.15% buffer with 44 periods of history,
200-period SMA, session VWAP with bands off, deviation bar colouring, markers off,
and the buffer and at-level alert channels enabled.

This is a separate publication from my earlier opening-deviation script rather than
an update to it, because the feature set and default behaviour differ enough that
replacing the original in place would change existing users' charts without warning.
The earlier version remains available and unchanged.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ViZiV

//@version=6
indicator("Opening Price Deviation Tracker v2 - Buffer Zones - VWAP [ViZ]", shorttitle="OP Dev Tracker [ViZ]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │      DESIGN NOTE — OPENING PRICES ARE LATCHED, NOT REQUESTED  │
// │                                                               │
// │ There is no request.security() call anywhere in this script.  │
// │ Every opening price it uses — the anchor open (2.A) and the   │
// │ three data-table column opens (11.B) — is taken from a chart  │
// │ bar's own `open` on the bar where that period begins, and     │
// │ held in a var until the next boundary.                        │
// │                                                               │
// │ WHY IT IS BUILT THIS WAY:                                     │
// │  The obvious implementation is request.security(..., open,    │
// │  lookahead=barmerge.lookahead_on). That is defensible on its  │
// │  own terms — an OPEN is fixed by the first tick of its period,│
// │  so requesting it with lookahead never returns a value that   │
// │  was unknowable at the time, and it does not repaint on       │
// │  reload. Without the flag the same call hands back the        │
// │  PREVIOUS period's open until the current one closes, putting │
// │  the entire grid one full anchor period behind itself — so    │
// │  simply switching the flag off is not an option.              │
// │                                                               │
// │  Latching sidesteps the argument entirely. The value IS a     │
// │  chart bar's own open, so it provably cannot look ahead, and  │
// │  there is no higher-timeframe request to disclose, defend or  │
// │  have flagged in review. It also removes any realtime-to-     │
// │  historical transition to reason about.                       │
// │                                                               │
// │ WHAT IT COSTS — three real, documented limitations:           │
// │                                                               │
// │  1) LEADING PARTIAL PERIOD IS BLANK. Nothing is latched until │
// │     the first rollover INSIDE loaded history, so the leftmost │
// │     partial anchor period has no open and therefore no grid,  │
// │     no buffers, no labels, no bar colour. Scales inversely    │
// │     with chart resolution: trivial on a 15m chart with ~30    │
// │     weeks loaded, pronounced on a 1m chart with ~2. Scroll    │
// │     hard left to see it; it is not a fault.                   │
// │                                                               │
// │  2) TABLE COLUMNS LONGER THAN LOADED HISTORY REPORT NOTHING.  │
// │     No boundary in history means no open, which cascades: no  │
// │     Δ, no Zone, no To Next, no State. The Δ cell says "no     │
// │     boundary yet" so the cause is legible rather than looking │
// │     broken. This is a bar-density effect, not a bug: ~20k     │
// │     loaded 1m bars is roughly 2.5 months of a 6.5-hour equity │
// │     session but under 3 weeks of a 24h instrument, so a       │
// │     Monthly column resolves on the former and not the latter. │
// │     It also moves with the user's data plan. In practice the  │
// │     column choice tracks the chart timeframe anyway.          │
// │                                                               │
// │  3) THE OPEN IS SESSION-DEPENDENT. This is the first chart    │
// │     bar's open under the CURRENT session settings, which on   │
// │     an extended-hours symbol need not equal the feed's        │
// │     official daily open. Verified to line up with session     │
// │     boundaries across equities, indices and FX, but it is the │
// │     property to be aware of when comparing against a          │
// │     platform VWAP or a broker's stated open.                  │
// │                                                               │
// │  4) FIRST SNAPSHOT IS SKIPPED. On the first rollover in       │
// │     loaded history openPrice[1] is na, so 7.B's guard         │
// │     suppresses that one period's historical segments and      │
// │     buffer boxes. It degrades quietly; it does not error.     │
// │                                                               │
// │ REQUIRED GUARD: because openPrice can be na, Section 10.B     │
// │ tests `not na(openPrice)` before the deviation branch. Without│
// │ it that branch seeds barCol := betweenColor, every comparison │
// │ in the narrowing loop is false, and the whole pre-first-      │
// │ rollover left edge is painted the "between levels" colour —   │
// │ asserting a zone reading that does not exist. Do not remove   │
// │ that guard while 2.A is latched.                              │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │                  ARCHITECTURAL NOTE                           │
// │                                                               │
// │ This script uses THREE independent touch-detection systems:   │
// │                                                               │
// │  1) ONE-SHOT, PER-PERIOD flags (touchedUpper / touchedLower)  │
// │     → drives the historical buffer zone snapshots             │
// │     → drives the historical deviation line snapshots          │
// │     → resets on timeframe.change(timeframe)                   │
// │     → ensures each level only fires ONE event per period      │
// │                                                               │
// │  2) PER-BAR touchLevel() / enteredBuffer()                    │
// │     → touchLevel() builds the AT-LEVEL alert message (8.A)    │
// │     → enteredBuffer() drives the BUFFER alert (8.B)           │
// │     → evaluates fresh every bar, no period-state              │
// │                                                               │
// │  3) ONE-SHOT MARKER flags (tmDone, Section 10.5)              │
// │     → drives the on-chart touch markers                       │
// │     → builds the FIRST-TOUCH alert message                    │
// │     → reuses the SAME reach test as (1), so a marker and a    │
// │       historical line segment can never disagree              │
// │     → re-arms on isRollover, same as (1)                      │
// │                                                               │
// │ ══ ALERT ARCHITECTURE (Sections 8.B and 12) ══                │
// │                                                               │
// │ Every alert() call in a Pine indicator fires the SAME chart   │
// │ alert, so two calls satisfied on the same tick would deliver  │
// │ two notifications for one event. An earlier build solved that │
// │ by MERGING the two level channels into a single dispatch.     │
// │ It worked, but it forced BOTH of them to wait for the bar     │
// │ close, because one of the two could not report any earlier.   │
// │ The faster channel was made slow to accommodate the slower.   │
// │                                                               │
// │ THE MERGE IS GONE. Each channel now dispatches on its own,    │
// │ at the earliest moment its OWN detection can be trusted.      │
// │ They no longer collide, because they no longer arrive at the  │
// │ same instant. Three channels, three toggles, three timings:   │
// │                                                               │
// │  • BUFFER (8.B)        — price entered the band around a      │
// │                          level. Fires INTRABAR, the moment    │
// │                          the band is entered. It is an EARLY  │
// │                          warning; delivered at bar close it   │
// │                          would be worthless.                  │
// │                                                               │
// │  • AT LEVEL (12, ch.2) — the bar's range CONTAINS the level.  │
// │                          Fires INTRABAR, the moment the range │
// │                          reaches it. Re-reports on every      │
// │                          subsequent bar price stays there.    │
// │                                                               │
// │  • FIRST TOUCH (12, ch.3) — first time a level is REACHED     │
// │                          this period, then silent until the   │
// │                          next period. Fires at BAR CLOSE.     │
// │                                                               │
// │ WHY AT-LEVEL IS SAFE INTRABAR:                                │
// │  the straddle test reads `high` and `low` and nothing else.   │
// │  Inside a live bar `high` only ever expands upward and `low`  │
// │  only downward, so once the range engulfs a level it stays    │
// │  engulfed for the remainder of that bar. The event is         │
// │  MONOTONIC — no later tick can un-happen it — so there is     │
// │  nothing waiting on the close to confirm.                     │
// │                                                               │
// │ WHY FIRST-TOUCH WAITS FOR THE CLOSE:                          │
// │  its message carries a CLASSIFICATION — "closed beyond",      │
// │  "rejected" — and both of those read `close`. On a live bar   │
// │  `close` is merely the current price, so the wording would be │
// │  provisional and could contradict itself from tick to tick.   │
// │  The reach itself is every bit as monotonic as at-level's;    │
// │  it is the ADJECTIVE that needs the bar to finish.            │
// │                                                               │
// │ THE PAIRING THAT FALLS OUT OF THIS:                           │
// │  at-level fires on the FIRST qualifying tick, so on a candle  │
// │  that rips through +1, +2 and +3 it reports +1 and you hear   │
// │  about it immediately. First-touch evaluates once at the      │
// │  close, loops every level, and reports all three. One fast    │
// │  channel and one complete channel — obtained by leaving each  │
// │  alone rather than engineering around either.                 │
// │                                                               │
// │ DETECTION DIFFERS TOO, NOT JUST TIMING:                       │
// │  at-level tests `high >= lvl and low <= lvl`: the bar must    │
// │  straddle the level. First-touch tests DIRECTIONALLY,         │
// │  `high >= lvl` above and `low <= lvl` below. So a bar that    │
// │  jumps clean over a level without trading back into it is     │
// │  reported by FIRST TOUCH and is structurally invisible to     │
// │  AT LEVEL. That is the gap-through case, and it is exactly    │
// │  what a news candle does. The two channels are not two        │
// │  speeds of one alert; keep both available.                    │
// │                                                               │
// │ BUFFER LEAD TIME depends on bufferPct RELATIVE to devStep,    │
// │  not on its absolute value. At ~1/4 of the deviation step the │
// │  warning is genuinely early; at 1/2 or more the warning and   │
// │  the touch collapse into the same bar. Defaults ship at       │
// │  0.15 against a 1% grid (15%). The 0.3875% preset without a   │
// │  matching bufferPct change puts it at 39%; the 3% preset      │
// │  puts it at 5%, which may be too tight to be useful.          │
// │                                                               │
// │ NO TIMESTAMPS IN ANY MESSAGE. Every delivery method           │
// │  TradingView offers already stamps the notification, and      │
// │  `timenow` formats in UTC, so an embedded time disagreed with │
// │  the clock printed next to it for anyone outside UTC. To      │
// │  reinstate: str.format_time(timenow, "HH:mm", syminfo.timezone). │
// │                                                               │
// │ MESSAGE FORMAT IS AN INTERFACE. All three channels render as  │
// │  "<what happened>: <detail> | Price: <price>", with the       │
// │  buffer channel adding " | Level: <price>". trimTail() (8.A)  │
// │  strips the trailing "; " that the accumulator loops leave    │
// │  behind, so no fragment ever butts a semicolon against a      │
// │  pipe. Anyone parsing these downstream is relying on that     │
// │  shape — changing the delimiters after publication breaks     │
// │  their webhook silently.                                      │
// │                                                               │
// │ ALERT MECHANISM — WHY alert() AND NOT alertcondition():       │
// │  alertcondition() would give named dropdown entries, per-     │
// │  channel sounds/webhooks, and user-chosen frequency (it takes │
// │  no freq argument at all). It was evaluated and rejected on   │
// │  ALERT-SLOT ECONOMICS: three named conditions across ten      │
// │  watched symbols is thirty alerts instead of ten, which       │
// │  exceeds most plan tiers long before the tenth symbol. Its    │
// │  message must also be a compile-time constant, so dynamic     │
// │  content can only arrive via {{plot("...")}} placeholders —   │
// │  numbers only. The first-touch classification is PROSE and    │
// │  cannot travel that way, so a named entry would carry LESS    │
// │  information than the single alert() master already does.     │
// │  Chart timeframe already serves as the frequency throttle.    │
// │  REVISIT IF: users ask for a different SOUND per channel.     │
// │  That is the one thing no message-string work can replicate.  │
// │  Until then the two-instance pattern below covers it free.    │
// │                                                               │
// │ TWO-INSTANCE PATTERN (optional, no code required):            │
// │  alert() cannot route channels to different chart alerts.     │
// │  For per-channel sounds or webhooks, add the indicator to     │
// │  the chart more than once, enable exactly ONE alert channel   │
// │  per instance, and name each chart alert after its channel.   │
// │  Strip the extra instances of all drawing (lines, labels,     │
// │  buffers, table, MA/VWAP, bar colour) so they cost nothing    │
// │  and so two barcolor() calls do not fight. Keep the anchor    │
// │  timeframe and deviation preset IDENTICAL across instances,   │
// │  or the channels start describing different grids.            │
// │  Leaving one channel enabled on two instances is the only     │
// │  real hazard: it fires twice, once under each alert name.     │
// │                                                               │
// │ ORDER-OF-EXECUTION NOTE (Sections 6 / 7):                     │
// │  On a rollover bar, `openPrice` has ALREADY advanced to the   │
// │  new period, because 2.A latches it on that very bar. Touch   │
// │  accumulation must therefore run AFTER the rollover snapshot  │
// │  + flag reset, otherwise the first bar of a new period would  │
// │  register touches against the new levels and those touches    │
// │  would be attributed to the period that just closed.          │
// │  Accumulation lives in 7.C for exactly this reason — do not   │
// │  move it back above Section 7.                                │
// │                                                               │
// │ HISTORICAL VIEW (snapshot-on-rollover):                       │
// │  • Buffer boxes: capped at `historicalLookback` periods.      │
// │    11 boxes per period + 11 live boxes must fit inside        │
// │    max_boxes_count=500, hence the lookback cap of 44.         │
// │    At the default 44 that is 484 stored + 11 live = 495.      │
// │  • Deviation line segments: NO cap — accumulate indefinitely  │
// │    as a permanent visual memory. Bound only by                │
// │    `max_lines_count`.                                         │
// │  • 0% opening line is always shown in full (no filtering).    │
// │  • The FIRST rollover in loaded history produces no snapshot  │
// │    at all, because openPrice[1] is na there.                  │
// │                                                               │
// │ LINE BUDGET (max_lines_count = 500):                          │
// │  "Touched Only (Historical)" is the DEFAULT view. Each closed │
// │  period emits one segment per touched level, so up to 10.     │
// │  Worst case ~50 periods before the oldest drop off the left   │
// │  edge; in practice 3-6 levels get touched per period, so      │
// │  expect 80-160. When the ceiling is hit TradingView silently  │
// │  deletes the OLDEST lines — the recent history a reader       │
// │  actually looks at is never the part that disappears.         │
// │                                                               │
// │ LABEL BUDGET (max_labels_count = 500):                        │
// │  Shared by Section 5 (11 level labels), Section 9.F (1        │
// │  warning label) and Section 10.5 (touch markers). Markers     │
// │  therefore have ~488 slots. At ±4 levels that is up to 9 per  │
// │  period, roughly 50 periods of marker history. Lowering       │
// │  `touchMaxK` extends that reach.                              │
// │                                                               │
// │ VWAP ANCHORING (Section 9):                                   │
// │  • User-selectable reset period via ta.vwap(src, anchor).     │
// │  • Multi-month anchors are derived from the MONTHLY rollover  │
// │    then gated by calendar month, so they are deterministic.   │
// │  • Guarded against no-volume symbols and against anchors      │
// │    that are not longer than the chart timeframe.              │
// │  • Optional deviation bands in either sigma or percentage     │
// │    units, INDEPENDENT of the deviation grid preset.           │
// │  • Outer band colour derived from the inner band colour with  │
// │    extra transparency, mirroring darkerColor().               │
// │  • The line and bands are blanked ON the anchor bar itself,   │
// │    so the plot BREAKS at each reset instead of drawing a      │
// │    diagonal from the old period's last value to the new.      │
// │  • ta.vwap() is a local-series function, so this block never  │
// │    needed a higher-timeframe request of any kind.             │
// │                                                               │
// │ TWO-TIER VWAP VALIDITY:                                       │
// │  • vwapUsable = volume present AND anchor longer than chart.  │
// │    This is what the bar-colouring mode consumes, so VWAP      │
// │    colouring still works with `Show VWAP` switched off.       │
// │  • vwapValid  = vwapUsable AND showVWAP. Gates the PLOTS.     │
// │  The warning label fires whenever EITHER consumer is starved. │
// │                                                               │
// │ SECTION ORDER NOTE:                                           │
// │  Bar colouring lives at Section 10, AFTER the MA/VWAP block,  │
// │  because the VWAP colouring mode consumes `vwapLine`,         │
// │  `band1Up/Dn`, `band2Up/Dn` and `vwapUsable`. barcolor() is a │
// │  top-level call, so its file position does not affect         │
// │  rendering.                                                   │
// │                                                               │
// │ DATA TABLE (Section 11) — DATA SOURCING:                      │
// │  • Columns are user-selected timeframes (default D/W/M). The  │
// │    column matching the indicator's own anchor is marked ◆.    │
// │  • EVERY value — open, high and low — is accumulated from     │
// │    chart bars by trackTf() (11.B).                            │
// │  • High and low ALWAYS had to be accumulated, under any       │
// │    sourcing strategy: a period's extremes are only settled    │
// │    when the period ENDS, so a lookahead request for them      │
// │    WOULD leak future data onto historical bars. That          │
// │    distinction — open safe, extremes not — is the whole       │
// │    substance of the lookahead question, and the reason        │
// │    "lookahead" is not simply a synonym for "cheating".        │
// │  • `ok` stays false until the chart has actually shown a      │
// │    boundary for that timeframe. A column longer than loaded   │
// │    history therefore reports nothing rather than reporting a  │
// │    truncated period as if it were complete. The Δ cell says   │
// │    "no boundary yet" so the reason is legible.                │
// │  • The Zone and To-Next rows project the SAME deviation grid  │
// │    (devStep) onto each column's own opening price, and paint  │
// │    with the SAME colour arrays the chart lines use — so the   │
// │    table is a readout of this indicator, not generic MTF.     │
// │  • A single devStep applies to every column, so longer        │
// │    columns overflow the ±5 grid more often. Overflow is       │
// │    reported as "> +5" / "< -5" rather than clamped silently.  │
// │  • Any column SHORTER than the chart timeframe renders as     │
// │    dashes: a shorter-timeframe open cannot be resolved        │
// │    honestly from a longer chart bar.                          │
// │  • Text contrast is derived from the panel background, so     │
// │    cells stay legible on light and dark themes alike.         │
// │  • Colour is carried by TEXT tint, not cell fill. The Zone    │
// │    row is the single filled block and acts as the focal       │
// │    point. An earlier filled-background variant of the Δ and   │
// │    State cells was superseded by this and has been removed.   │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │                  Section 1   USER INPUTS                      │
// │                                                               │
// │ INPUT ORDER IS LOAD-BEARING. TradingView keys saved settings  │
// │ to declaration order, so inserting an input mid-list will     │
// │ scramble stored values on charts that already run this        │
// │ script. Add new inputs at the END of the LAST input block     │
// │ only — which is Section 10.5.A, not this section. The last    │
// │ declared input is `enableTouchAlerts`; append below it.       │
// │                                                               │
// │ SAFE to change on an existing input: its LABEL, its TOOLTIP,  │
// │ its GROUP string, and its DEFAULT. The panel reads those;     │
// │ the save file keys by position. UNSAFE: reordering, removing, │
// │ or inserting. Removing an input shifts every input after it.  │
// │                                                               │
// │ ⚠ input.string OPTION TEXT IS ALSO LOAD-BEARING, and for a   │
// │ different reason: the CHOSEN STRING is what gets saved, not   │
// │ its index. Rename an option after publication and every       │
// │ chart holding the old string matches nothing in the list and  │
// │ silently reverts to the default. ADDING options is always     │
// │ safe. Renaming is a breaking change — so the preset labels    │
// │ below are fixed from publication onward. If a preset label    │
// │ ever must change, add the new one and leave the old string    │
// │ resolving in the devStep chain.                               │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   1.A  General Settings
// ───────────────────────────────────────────────
timeframe      = input.timeframe("W", "Timeframe", group="General Settings")
enableBarColor = input.bool(true, "Enable Bar Coloring", tooltip="Master on/off for bar coloring. Use the source selector below to choose what drives it.", group="General Settings")
barColorSource = input.string("Deviation Levels", "Bar Color Source",
                              options=["Deviation Levels", "VWAP / Bands"],
                              group="General Settings",
                              tooltip="Deviation Levels = colors bars by which deviation band price closed in (11 zones). VWAP / Bands = colors bars by position relative to the anchored VWAP and its deviation bands (5 zones). Both modes reuse the Above/Below/Between colors from the Colors group. VWAP mode works even with Show VWAP switched off — it only needs volume data and an anchor longer than the chart timeframe. It falls back to plain above/below VWAP if bands are Off.")

// NOTE: `showLabels` keeps this declaration slot for saved-settings
// compatibility, but belongs to the Deviation Settings group in the panel.
showLabels     = input.bool(true, "Show Deviation Labels", tooltip="Toggle display of the price/percentage labels at the right edge of each deviation level.", group="Deviation Settings")

// ───────────────────────────────────────────────
//   1.B  Deviation Line Display
// ───────────────────────────────────────────────
deviationLineMode = input.string("Touched Only (Historical)", "Deviation Line Display",
                                 options=["Off", "Show All", "Touched Only (Historical)"],
                                 group="Deviation Settings",
                                 tooltip="Off = no deviation lines. Show All = full grid across history and live period. Touched Only (Historical) = live period shows full grid; past periods only show levels price actually touched. The 0% opening line is always shown when lines are enabled.")

deviationTransparency = input.int(65, "Deviation Line Transparency (%)", minval=0, maxval=100, group="Deviation Settings")

showDeviationLines    = deviationLineMode != "Off"
filterHistoricalLines = deviationLineMode == "Touched Only (Historical)"

// ───────────────────────────────────────────────
//   1.C  Deviation Presets
//
//   Labels lead with the NUMBER because the number is the only
//   part that changes behaviour — the words after it are guidance,
//   not a constraint. Asset classes are deliberately kept OUT of
//   the labels and confined to the tooltip: volatility varies more
//   within an asset class than between them, so "3% — crypto" in a
//   dropdown reads as a rule when it is only a starting point.
//
//   ⚠ THE CHAIN BELOW MUST MATCH THE OPTION STRINGS EXACTLY.
//   A string matching no branch falls through to the 1.0 fallback
//   SILENTLY — it does not error — so a typo here behaves like the
//   balanced preset and is easy to miss. If you edit a label,
//   edit both places in the same pass.
// ───────────────────────────────────────────────
devPreset      = input.string("1.00% — Balanced (default)", "Deviation Preset",
                   options=["0.25% — Scalping / very low volatility",
                            "0.3875% — Reactive / lower timeframes",
                            "0.50% — Intraday",
                            "1.00% — Balanced (default)",
                            "2.00% — Swing / higher timeframes",
                            "3.00% — High volatility / highest timeframes",
                            "Custom"],
                   group="Deviation Settings",
                   tooltip="Spacing between deviation levels, as a percentage of the anchor period's opening price. The grid runs to ±5 levels, so the step also sets its total span: 1% covers ±5%, 2% covers ±10%, 0.25% covers ±1.25%. Choose the step whose span roughly brackets what your anchor period typically moves — too small and price sits permanently off the grid, too large and it never leaves the first band. As a rough starting point: the lower steps suit major FX pairs and large-cap equities on intraday charts, the middle of the range suits indices and most equities on daily and weekly anchors, and the upper steps suit small caps, commodities and crypto, or any weekly-and-above anchor. Treat these as directions rather than prescriptions — volatility varies far more within an asset class than between them, so verify against the instrument in front of you and use Custom once you know what you want. NOTE: check Buffer Size against whichever step you pick. Buffer is a percentage of price and does not scale with the grid, so the default 0.15 is 15% of a 1% step but 39% of a 0.3875% step, which collapses the early warning into the touch itself.")

customDevStep  = input.float(1.0, "Custom Deviation Step (%)", minval=0.1, step=0.1, group="Deviation Settings",
                   tooltip="Only used when Deviation Preset = Custom. Any value from 0.1 upward, so the grid can be fitted to an instrument's own behaviour rather than to a preset. The ±5 level structure and everything downstream — buffers, touch detection, the table's Zone and To Next rows — follow this number exactly as they follow a preset.")

devStep = devPreset == "Custom" ? customDevStep :
          devPreset == "0.25% — Scalping / very low volatility" ? 0.25 :
          devPreset == "0.3875% — Reactive / lower timeframes" ? 0.3875 :
          devPreset == "0.50% — Intraday" ? 0.50 :
          devPreset == "1.00% — Balanced (default)" ? 1.0 :
          devPreset == "2.00% — Swing / higher timeframes" ? 2.0 :
          devPreset == "3.00% — High volatility / highest timeframes" ? 3.0 : 1.0

// ───────────────────────────────────────────────
//   1.D  Buffer Zone Settings
// ───────────────────────────────────────────────
showBufferZones    = input.bool(true, "Show Buffer Zones", group="Buffer Zone Settings",
                                tooltip="Draws a translucent band around each deviation level showing the 'zone of influence'.")
enableBufferAlerts = input.bool(true, "Buffer Zone Alerts (early warning)", group="Buffer Zone Settings",
                                tooltip="Fires the moment price first enters the band around a deviation level, before the level itself is reached — a heads-up that price is approaching. Dispatches intrabar, without waiting for the bar to close. How much warning you get depends on the Buffer Size below relative to your Deviation Preset: at roughly a quarter of the deviation step it is a genuine early warning, and at half or more the warning and the touch arrive almost together. Fires independently of whether the buffer zones are drawn on the chart.")
bufferPct          = input.float(0.15, "Buffer Size (% of price)", minval=0.01, step=0.01, group="Buffer Zone Settings",
                                 tooltip="Half-width of each buffer zone, as a percentage of price. Judge this against your Deviation Preset rather than on its own — the default 0.15 against a 1% grid covers 15% of the gap to the next level, but the same 0.15 is 39% of a 0.3875% grid and only 5% of a 3% grid. On low-priced instruments it can fall below one tick; widen it if the boxes render as hairlines.")
bufferTransp       = input.int(85, "Buffer Zone Transparency (%)", minval=0, maxval=100, group="Buffer Zone Settings")

showHistoricalBuffers  = input.bool(true, "Show Historical Buffer Zones", group="Buffer Zone Settings",
                                    tooltip="Display buffer zones from previous periods where the deviation level was touched.")
historicalLookback     = input.int(44, "Historical Buffer Lookback (periods)", minval=1, maxval=44, group="Buffer Zone Settings",
                                   tooltip="How many prior periods of historical buffer zones to keep on the chart. Capped at 44: each stored period reserves 11 boxes and the live period uses 11 more, which is the limit of TradingView's 500-drawing-object budget. Lower this if you prefer a cleaner chart — nothing else depends on it.")
historicalBufferTransp = input.int(92, "Historical Buffer Transparency (%)", minval=0, maxval=100, group="Buffer Zone Settings",
                                   tooltip="Transparency for historical buffer zones. Higher = more translucent.")

// ───────────────────────────────────────────────
//   1.E  Main Colors
// ───────────────────────────────────────────────
aboveColorBase = input.color(color.green, "Above Level 1", group="Colors")
belowColorBase = input.color(color.red, "Below Level 1", group="Colors")
betweenColor   = input.color(color.rgb(204, 145, 8), "Between Levels", group="Colors")

// ───────────────────────────────────────────────
//   1.F  Moving Average Inputs
// ───────────────────────────────────────────────
showMA   = input.bool(true, "Show Moving Average", group="Moving Average Settings")
maLength = input.int(200, "MA Period", group="Moving Average Settings")
maType   = input.string("SMA", "MA Type", options=["SMA", "EMA"], group="Moving Average Settings")
maColor  = input.color(color.yellow, "MA Color", group="Moving Average Settings")

// ───────────────────────────────────────────────
//   1.G  VWAP Inputs
// ───────────────────────────────────────────────
showVWAP      = input.bool(true, "Show VWAP", group="VWAP Settings")
vwapColor     = input.color(color.white, "VWAP Color", group="VWAP Settings")
vwapBandColor = input.color(color.gray, "Band Color", group="VWAP Settings",
     tooltip="Applies to both band pairs. The outer band is rendered a step more transparent than the inner one, so inner/outer reads at a glance without a second colour input.")

vwapAnchorMode = input.string("Daily (Session)", "VWAP Anchor Period",
     options=["Daily (Session)", "Weekly", "Monthly", "Quarterly (3M)",
              "Semi-Annual (6M)", "Annual (12M)", "Match Deviation Anchor", "Custom"],
     group="VWAP Settings",
     tooltip="Where VWAP restarts its accumulation. Daily (Session) matches the standard TradingView VWAP. Quarterly/Semi-Annual/Annual anchor to calendar boundaries (Jan/Apr/Jul/Oct, Jan/Jul, and Jan respectively) and are intended for daily or higher charts. Match Deviation Anchor resets VWAP on the same rollover as the deviation grid.")

vwapCustomTf = input.timeframe("D", "Custom VWAP Anchor", group="VWAP Settings",
     tooltip="Only used when Anchor Period = Custom. Note that multi-period strings like '3D' are aggregated from a reference point in the symbol's history rather than a fixed calendar boundary, so the reset point may not sit where you expect.")

vwapBandMode = input.string("Off", "VWAP Deviation Bands",
     options=["Off", "Standard Deviation", "Percentage"],
     group="VWAP Settings",
     tooltip="Standard Deviation scales with realised dispersion inside the anchored period, so it stays meaningful across daily through annual anchors. Percentage places bands a fixed % away from VWAP, matching how the deviation grid is measured. Bands have their own colour setting. Note: in Standard Deviation mode the bands pinch shut at the start of each anchor period and flare open over the following bars — this is inherent to anchored stdev. Percentage mode does not do this.")

vwapBand1 = input.float(1.0, "Band 1 — σ Multiplier / %", minval=0.0, step=0.05, group="VWAP Settings",
     tooltip="Independent of the Deviation Preset and of the VWAP anchor period. In Standard Deviation mode this is a sigma multiplier (1.0 = ±1σ). In Percentage mode it is a percentage of VWAP (1.0 = ±1%). Set to 0 to hide this band.")
vwapBand2 = input.float(2.0, "Band 2 — σ Multiplier / %", minval=0.0, step=0.05, group="VWAP Settings",
     tooltip="Second, outer band. Same units as Band 1. Set to 0 to hide.")

vwapBandTransp = input.int(55, "Band Transparency (%)", minval=0, maxval=100, group="VWAP Settings")
vwapBandFill   = input.bool(false, "Fill Between Band 1", group="VWAP Settings",
     tooltip="Very light fill between the inner band pair. Off by default so it doesn't compete with the buffer zones.")

// ───────────────────────────────────────────────
//   1.H  Table Settings
// ───────────────────────────────────────────────
showTable = input.bool(true, "Show Data Table", group="Table Settings",
     tooltip="Displays the multi-timeframe deviation table. Turn off for a fully clean chart.")

tableDetail = input.string("Full", "Table Detail", options=["Full", "Compact"], group="Table Settings",
     tooltip="Full = Open, Δ from Open, Zone, To Next, Range Pos, State (6 rows). Compact = Open, Δ from Open, Zone, State (4 rows).")

tableTf1 = input.timeframe("D", "Column 1 Timeframe", group="Table Settings",
     tooltip="Any timeframe LONGER than or equal to the chart timeframe. Shorter timeframes render as dashes, because a shorter-timeframe open cannot be resolved honestly from a longer chart bar. A column also needs at least one of its own boundaries inside the loaded chart history before it can report anything — on very high-resolution charts, long columns will read 'no boundary yet'.")
tableTf2 = input.timeframe("W", "Column 2 Timeframe", group="Table Settings")
tableTf3 = input.timeframe("M", "Column 3 Timeframe", group="Table Settings",
     tooltip="Suggested pairings: 4H anchor → 4H/D/W. Weekly anchor → D/W/M. Quarterly anchor → M/3M/12M.")

tablePosStr = input.string("Top Right", "Table Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left", "Top Center", "Bottom Center"],
     group="Table Settings")

tableSizeStr = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Table Settings")

tableBgColor = input.color(#0C0F16, "Panel Background", group="Table Settings",
     tooltip="All other panel tones — header band, row banding, separators — are derived from this one colour, so the panel retints coherently. Text automatically switches to a dark set if you choose a light background.")

tableAccent = input.color(#4A90D9, "Panel Accent", group="Table Settings",
     tooltip="Tints the anchor column and the deviation-step readout in the title bar.")

////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │                  Section 2   CALCULATIONS                     │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   2.A  Opening Price (anchor)  ── LATCHED, NOT REQUESTED
//
//   On the first chart bar of each anchor period, that bar's OWN
//   open IS the period's open. Latch it into a var and hold it
//   until the next rollover. No higher-timeframe request exists,
//   so there is no lookahead flag to justify and nothing that can
//   repaint on reload.
//
//   THE ASSIGNMENT HAPPENS ON THE ROLLOVER BAR, deliberately, so
//   openPrice has already advanced to the new period by the time
//   Section 7 runs. That is what makes the 7.B-before-7.C
//   ordering discipline necessary and correct.
//
//   openPrice[1] resolves correctly: `var` retains history, so on
//   a rollover bar it holds the FINISHED period's open, which is
//   what 7.B's snapshot needs. The single exception is the FIRST
//   rollover in loaded history, where openPrice[1] is na and
//   7.B's guard skips that snapshot.
//
//   COST: na until the first rollover, so the leading partial
//   period draws no grid at all. See limitation (1) at the top.
// ───────────────────────────────────────────────
var float openPrice = na
if timeframe.change(timeframe)
    openPrice := open

// ───────────────────────────────────────────────
//   2.B  Deviation Levels
//
//   na-safe by arithmetic: while openPrice is na every level is
//   na, so plots blank, touch tests fail closed, and labels are
//   only built on barstate.islast. Nothing needs guarding here.
// ───────────────────────────────────────────────
upperLevels = array.new_float(5)
lowerLevels = array.new_float(5)
for i = 0 to 4
    array.set(upperLevels, i, openPrice * (1 + (i+1) * devStep / 100))
    array.set(lowerLevels, i, openPrice * (1 - (i+1) * devStep / 100))

// ───────────────────────────────────────────────
//   2.C  Buffer Zone Boundaries
// ───────────────────────────────────────────────
upperBufferTop = array.new_float(5)
upperBufferBot = array.new_float(5)
lowerBufferTop = array.new_float(5)
lowerBufferBot = array.new_float(5)

for i = 0 to 4
    uLvl = array.get(upperLevels, i)
    lLvl = array.get(lowerLevels, i)
    uHalfWidth = uLvl * bufferPct / 100
    lHalfWidth = lLvl * bufferPct / 100
    array.set(upperBufferTop, i, uLvl + uHalfWidth)
    array.set(upperBufferBot, i, uLvl - uHalfWidth)
    array.set(lowerBufferTop, i, lLvl + lHalfWidth)
    array.set(lowerBufferBot, i, lLvl - lHalfWidth)

openHalfWidth = openPrice * bufferPct / 100
openBufferTop = openPrice + openHalfWidth
openBufferBot = openPrice - openHalfWidth

// ───────────────────────────────────────────────
//   2.D  Darker Color Helper
// ───────────────────────────────────────────────
darkerColor(c, step) =>
    r = math.max(color.r(c) - step, 0)
    g = math.max(color.g(c) - step, 0)
    b = math.max(color.b(c) - step, 0)
    color.rgb(r, g, b)

// ───────────────────────────────────────────────
//   2.E  Shading Color Arrays
// ───────────────────────────────────────────────
upperColors = array.new_color(5)
lowerColors = array.new_color(5)
for i = 0 to 4
    array.set(upperColors, i, darkerColor(aboveColorBase, i * 20))
    array.set(lowerColors, i, darkerColor(belowColorBase, i * 20))

// ───────────────────────────────────────────────
//   2.F  Period Anchor Time
//
//   time(timeframe) is a built-in, not a request.
// ───────────────────────────────────────────────
periodStartTime = time(timeframe)

// ───────────────────────────────────────────────
//   2.G  Live-Period Detection (for line filter)
// ───────────────────────────────────────────────
inLivePeriod    = last_bar_time >= time(timeframe) and last_bar_time <= time_close(timeframe)
showLineThisBar = showDeviationLines and (not filterHistoricalLines or inLivePeriod)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │              Section 3   BUFFER ZONE BOXES                    │
// │                       (current period only)                   │
// │                                                               │
// │ Gated on `not na(openPrice)`. Before the first rollover the   │
// │ boxes simply stay at their na-coloured initial state, which   │
// │ is invisible.                                                 │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////
var box[] upperBufferBoxes = array.new<box>(5, na)
var box[] lowerBufferBoxes = array.new<box>(5, na)
var box   openBufferBox    = na

if barstate.isfirst
    for i = 0 to 4
        array.set(upperBufferBoxes, i, box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=na))
        array.set(lowerBufferBoxes, i, box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=na))
    openBufferBox := box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=na)

if barstate.islast and showBufferZones and not na(openPrice)
    rightEdgeTime = time + (time - time[1])

    for i = 0 to 4
        ub = array.get(upperBufferBoxes, i)
        box.set_lefttop(ub, periodStartTime, array.get(upperBufferTop, i))
        box.set_rightbottom(ub, rightEdgeTime, array.get(upperBufferBot, i))
        box.set_bgcolor(ub, color.new(array.get(upperColors, i), bufferTransp))
        box.set_border_color(ub, color.new(array.get(upperColors, i), bufferTransp))

        lb = array.get(lowerBufferBoxes, i)
        box.set_lefttop(lb, periodStartTime, array.get(lowerBufferTop, i))
        box.set_rightbottom(lb, rightEdgeTime, array.get(lowerBufferBot, i))
        box.set_bgcolor(lb, color.new(array.get(lowerColors, i), bufferTransp))
        box.set_border_color(lb, color.new(array.get(lowerColors, i), bufferTransp))

    box.set_lefttop(openBufferBox, periodStartTime, openBufferTop)
    box.set_rightbottom(openBufferBox, rightEdgeTime, openBufferBot)
    box.set_bgcolor(openBufferBox, color.new(color.blue, bufferTransp))
    box.set_border_color(openBufferBox, color.new(color.blue, bufferTransp))

if barstate.islast and not showBufferZones
    for i = 0 to 4
        box.set_bgcolor(array.get(upperBufferBoxes, i), na)
        box.set_border_color(array.get(upperBufferBoxes, i), na)
        box.set_bgcolor(array.get(lowerBufferBoxes, i), na)
        box.set_border_color(array.get(lowerBufferBoxes, i), na)
    box.set_bgcolor(openBufferBox, na)
    box.set_border_color(openBufferBox, na)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │              Section 4   PLOT DEVIATION LEVELS                │
// │                                                               │
// │ When `filterHistoricalLines` is ON, the plot is suppressed    │
// │ for past periods (only the CURRENT period's bars plot).       │
// │ Historical line segments do the work for past periods.        │
// │                                                               │
// │ When OFF, plots behave normally (full stepline grid).         │
// │                                                               │
// │ The 0% opening line is exempt — always plots in full.         │
// │                                                               │
// │ Every plot is additionally na for all bars before the first   │
// │ rollover, because openPrice is na there. No explicit guard    │
// │ needed: na propagates through 2.B.                            │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// Upper Levels
plot(showLineThisBar ? array.get(upperLevels, 0) : na, color=color.new(array.get(upperColors, 0), deviationTransparency), title="Upper 1", linewidth=1, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(upperLevels, 1) : na, color=color.new(array.get(upperColors, 1), deviationTransparency), title="Upper 2", linewidth=2, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(upperLevels, 2) : na, color=color.new(array.get(upperColors, 2), deviationTransparency), title="Upper 3", linewidth=3, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(upperLevels, 3) : na, color=color.new(array.get(upperColors, 3), deviationTransparency), title="Upper 4", linewidth=4, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(upperLevels, 4) : na, color=color.new(array.get(upperColors, 4), deviationTransparency), title="Upper 5", linewidth=5, style=plot.style_stepline_diamond)

// Lower Levels
plot(showLineThisBar ? array.get(lowerLevels, 0) : na, color=color.new(array.get(lowerColors, 0), deviationTransparency), title="Lower 1", linewidth=1, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(lowerLevels, 1) : na, color=color.new(array.get(lowerColors, 1), deviationTransparency), title="Lower 2", linewidth=2, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(lowerLevels, 2) : na, color=color.new(array.get(lowerColors, 2), deviationTransparency), title="Lower 3", linewidth=3, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(lowerLevels, 3) : na, color=color.new(array.get(lowerColors, 3), deviationTransparency), title="Lower 4", linewidth=4, style=plot.style_stepline_diamond)
plot(showLineThisBar ? array.get(lowerLevels, 4) : na, color=color.new(array.get(lowerColors, 4), deviationTransparency), title="Lower 5", linewidth=5, style=plot.style_stepline_diamond)

// 0% Line (always rendered when deviation lines are enabled)
plot(openPrice, color=showDeviationLines ? color.new(color.blue, deviationTransparency) : na, title="0% Line", linewidth=2, style=plot.style_line)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │              Section 5   DEVIATION LABELS                     │
// │                                                               │
// │ Prices use format.mintick so precision follows the symbol —   │
// │ 2 decimals on an index, 5 on FX, 8 on satoshi-priced pairs.   │
// │                                                               │
// │ Only builds on barstate.islast, by which point openPrice is   │
// │ latched on any chart containing at least one rollover. The    │
// │ `not na` guard covers the pathological case of a chart with   │
// │ no anchor boundary at all.                                    │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////
var label[] upperLabels = array.new<label>()
var label[] lowerLabels = array.new<label>()
var label zeroLabel = na

if showLabels and barstate.islast and not na(openPrice)
    for l in upperLabels
        if not na(l)
            label.delete(l)
    for l in lowerLabels
        if not na(l)
            label.delete(l)
    if not na(zeroLabel)
        label.delete(zeroLabel)
    array.clear(upperLabels)
    array.clear(lowerLabels)

    for i = 0 to 4
        array.push(upperLabels, label.new(bar_index + 1, array.get(upperLevels, i),
          str.tostring(array.get(upperLevels, i), format.mintick) + " (+" + str.tostring((i+1)*devStep, "#.##") + "%)",
          color=array.get(upperColors, i), textcolor=color.white, style=label.style_label_left, yloc=yloc.price))
        array.push(lowerLabels, label.new(bar_index + 1, array.get(lowerLevels, i),
          str.tostring(array.get(lowerLevels, i), format.mintick) + " (-" + str.tostring((i+1)*devStep, "#.##") + "%)",
          color=array.get(lowerColors, i), textcolor=color.white, style=label.style_label_left, yloc=yloc.price))
    zeroLabel := label.new(bar_index + 1, openPrice, "0% (Opening Price)", color=color.blue, textcolor=color.white, style=label.style_label_left, yloc=yloc.price)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │           Section 6   PER-PERIOD TOUCH STATE                  │
// │                  (declarations only)                          │
// │                                                               │
// │ The ACCUMULATION loop that sets these lives in 7.C, below the │
// │ rollover reset. See the order-of-execution note at the top.   │
// │                                                               │
// │ `isRollover` is the same timeframe.change(timeframe) call     │
// │ that 2.A latches on. Calling it twice is free and keeps the   │
// │ latch physically next to the value it produces.               │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////
var bool[] touchedUpper = array.new_bool(5, false)
var bool[] touchedLower = array.new_bool(5, false)
var bool   touchedOpen  = false

var int currentPeriodStart = na
if na(currentPeriodStart) and not na(periodStartTime)
    currentPeriodStart := periodStartTime

isRollover = timeframe.change(timeframe)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │   Section 7   HISTORICAL BUFFER ZONES + DEVIATION LINES       │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   7.A  Snapshot Storage
// ───────────────────────────────────────────────
var float[] histOpens      = array.new_float()
var int[]   histStartTimes = array.new_int()
var int[]   histEndTimes   = array.new_int()
var box[]   histBoxes      = array.new<box>()

histSlot(period_slot, level_idx) =>
    period_slot * 11 + level_idx

// ───────────────────────────────────────────────
//   7.B  Rollover Snapshot + Reset
//
//   `finishedOpen = openPrice[1]` reads the value the latch held
//   throughout the period that just ended — correct, because 2.A
//   only reassigns ON a rollover bar, so the previous bar still
//   carries the finished period's open.
//
//   On the FIRST rollover in loaded history openPrice[1] is na,
//   so the `not na(finishedOpen)` guard below skips that snapshot
//   entirely. One period of historical segments and buffer boxes
//   is silently absent at the left edge.
// ───────────────────────────────────────────────
if isRollover
    if not na(currentPeriodStart)
        finishedOpen = openPrice[1]

        if not na(finishedOpen)
            // ──────────── Historical Buffer Zones (capped queue) ────────────
            if showHistoricalBuffers
                array.push(histOpens, finishedOpen)
                array.push(histStartTimes, currentPeriodStart)
                array.push(histEndTimes, time)

                for k = 0 to 10
                    array.push(histBoxes, na)

                newPeriodIdx = array.size(histOpens) - 1

                for i = 0 to 4
                    if array.get(touchedUpper, i)
                        uLvl  = finishedOpen * (1 + (i+1) * devStep / 100)
                        uHalf = uLvl * bufferPct / 100
                        uTop  = uLvl + uHalf
                        uBot  = uLvl - uHalf
                        b = box.new(currentPeriodStart, uTop, time, uBot,
                                    xloc=xloc.bar_time,
                                    bgcolor=color.new(array.get(upperColors, i), historicalBufferTransp),
                                    border_color=color.new(array.get(upperColors, i), historicalBufferTransp))
                        array.set(histBoxes, histSlot(newPeriodIdx, i), b)

                    if array.get(touchedLower, i)
                        lLvl  = finishedOpen * (1 - (i+1) * devStep / 100)
                        lHalf = lLvl * bufferPct / 100
                        lTop  = lLvl + lHalf
                        lBot  = lLvl - lHalf
                        b = box.new(currentPeriodStart, lTop, time, lBot,
                                    xloc=xloc.bar_time,
                                    bgcolor=color.new(array.get(lowerColors, i), historicalBufferTransp),
                                    border_color=color.new(array.get(lowerColors, i), historicalBufferTransp))
                        array.set(histBoxes, histSlot(newPeriodIdx, 5 + i), b)

                if touchedOpen
                    oHalf = finishedOpen * bufferPct / 100
                    oTop  = finishedOpen + oHalf
                    oBot  = finishedOpen - oHalf
                    b = box.new(currentPeriodStart, oTop, time, oBot,
                                xloc=xloc.bar_time,
                                bgcolor=color.new(color.blue, historicalBufferTransp),
                                border_color=color.new(color.blue, historicalBufferTransp))
                    array.set(histBoxes, histSlot(newPeriodIdx, 10), b)

                while array.size(histOpens) > historicalLookback
                    array.shift(histOpens)
                    array.shift(histStartTimes)
                    array.shift(histEndTimes)
                    for k = 0 to 10
                        oldBox = array.shift(histBoxes)
                        if not na(oldBox)
                            box.delete(oldBox)

            // ──────────── Historical Deviation Lines (uncapped) ─────────────
            if filterHistoricalLines
                for i = 0 to 4
                    devN = i + 1

                    if array.get(touchedUpper, i)
                        uLvl = finishedOpen * (1 + devN * devStep / 100)
                        line.new(currentPeriodStart, uLvl, time, uLvl,
                                 xloc=xloc.bar_time,
                                 color=color.new(array.get(upperColors, i), deviationTransparency),
                                 width=devN,
                                 style=line.style_solid)

                    if array.get(touchedLower, i)
                        lLvl = finishedOpen * (1 - devN * devStep / 100)
                        line.new(currentPeriodStart, lLvl, time, lLvl,
                                 xloc=xloc.bar_time,
                                 color=color.new(array.get(lowerColors, i), deviationTransparency),
                                 width=devN,
                                 style=line.style_solid)
                // Note: 0% line is excluded — it is always rendered via plot()

    // Reset per-period flags for the new period
    for i = 0 to 4
        array.set(touchedUpper, i, false)
        array.set(touchedLower, i, false)
    touchedOpen        := false
    currentPeriodStart := periodStartTime

// ───────────────────────────────────────────────
//   7.C  Accumulate Touches for the CURRENT Period
//
//   MUST run after 7.B. On a rollover bar `openPrice` — and
//   therefore upperLevels / lowerLevels — already describes the
//   NEW period, because 2.A latched it on this very bar. A touch
//   detected here belongs to the new period, not the one just
//   snapshotted above.
//
//   Fails closed while openPrice is na: `high >= na` is false, so
//   no touches accumulate before the first rollover. No guard
//   required.
//
//   Section 10.5 reuses this exact reach test. If you change the
//   comparison here, change it there too.
// ───────────────────────────────────────────────
for i = 0 to 4
    if high >= array.get(upperLevels, i)
        array.set(touchedUpper, i, true)
    if low <= array.get(lowerLevels, i)
        array.set(touchedLower, i, true)

if high >= openPrice and low <= openPrice
    touchedOpen := true

// ───────────────────────────────────────────────
//   7.D  Hide Historical Buffers When Toggled Off
// ───────────────────────────────────────────────
if barstate.islast and not showHistoricalBuffers
    if array.size(histBoxes) > 0
        for idx = 0 to array.size(histBoxes) - 1
            b = array.get(histBoxes, idx)
            if not na(b)
                box.set_bgcolor(b, na)
                box.set_border_color(b, na)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │                Section 8   ALERT CONDITIONS                   │
// │                                                               │
// │ 8.A builds a message string and does NOT dispatch — Section   │
// │ 12 dispatches it, intrabar, as its own standalone channel.    │
// │ 8.B builds AND dispatches, also intrabar, right here.         │
// │                                                               │
// │ 8.B keeps its own dispatch rather than being routed through   │
// │ Section 12 because it answers a different question — "price   │
// │ is APPROACHING a level" versus "price is AT one" — and the    │
// │ two are deliberately allowed to arrive as separate            │
// │ notifications on the same bar. That sequence, warning then    │
// │ confirmation, is the point of having a buffer at all.         │
// │                                                               │
// │ While openPrice is na every level and every buffer bound is   │
// │ na, so both conditions fail closed and no alert can fire      │
// │ before the first rollover. Correct behaviour — there is no    │
// │ grid to alert against yet.                                    │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   8.A  At-Level Condition  (message only)
//
//   Straddle test: the bar's range must CONTAIN the level. True
//   on every bar that sits there, for as long as it sits there.
//   A bar that jumps clean over a level never satisfies this —
//   that case belongs to the first-touch channel in 10.5.
//
//   Reads `high` and `low` only, never `close`, which is exactly
//   why Section 12 can dispatch this intrabar.
//
//   trimTail() exists because both this loop and 10.5.C append
//   "; " after every fragment, which leaves a trailing separator
//   on the last one. Stripping it at dispatch keeps all three
//   channels rendering the same "detail | Price: x" shape instead
//   of "detail; | Price: x". Cosmetic only — it touches no
//   condition, no timing and no detection.
// ───────────────────────────────────────────────
trimTail(s) =>
    str.endswith(s, "; ") ? str.substring(s, 0, str.length(s) - 2) : s

touchLevel(_lvl) =>
    high >= _lvl and low <= _lvl

touchedLabel = ""

if touchLevel(openPrice)
    touchedLabel += "Opening Price; "

for i = 0 to 4
    up = array.get(upperLevels, i)
    dn = array.get(lowerLevels, i)
    if touchLevel(up)
        touchedLabel += "Upper Deviation " + str.tostring(i + 1) + "; "
    if touchLevel(dn)
        touchedLabel += "Lower Deviation " + str.tostring(i + 1) + "; "

anyDeviationTouch = touchedLabel != ""

// ───────────────────────────────────────────────
//   8.B  Buffer Zone Early-Warning Alerts
//
//   Fires intrabar, the moment the band is entered. A "price is
//   approaching the level" message delivered at the bar close
//   has already been overtaken by events.
//
//   KNOWN LIMITATION: bufferLabel is ASSIGNED (:=) rather than
//   appended, so if one bar enters several buffers at once only
//   the LAST one survives into the message. Harmless at normal
//   spacing; visible on a fast bar that punches through two or
//   three at once, or whenever bufferPct approaches half of
//   devStep and the bands overlap. Left as-is deliberately:
//   fixing it means tracking label and level together, which is
//   real logic rather than string cleanup.
//   TO REPORT ALL: change the four `:=` below to `+=` on the
//   label (bufferLevel would then need its own handling).
// ───────────────────────────────────────────────
approachedFromAbove(_top) =>
    low <= _top and low[1] > _top[1]

approachedFromBelow(_bot) =>
    high >= _bot and high[1] < _bot[1]

enteredBuffer(_top, _bot) =>
    approachedFromAbove(_top) or approachedFromBelow(_bot)

enteredOpen   = enteredBuffer(openBufferTop, openBufferBot)
enteredUpper0 = enteredBuffer(array.get(upperBufferTop, 0), array.get(upperBufferBot, 0))
enteredUpper1 = enteredBuffer(array.get(upperBufferTop, 1), array.get(upperBufferBot, 1))
enteredUpper2 = enteredBuffer(array.get(upperBufferTop, 2), array.get(upperBufferBot, 2))
enteredUpper3 = enteredBuffer(array.get(upperBufferTop, 3), array.get(upperBufferBot, 3))
enteredUpper4 = enteredBuffer(array.get(upperBufferTop, 4), array.get(upperBufferBot, 4))
enteredLower0 = enteredBuffer(array.get(lowerBufferTop, 0), array.get(lowerBufferBot, 0))
enteredLower1 = enteredBuffer(array.get(lowerBufferTop, 1), array.get(lowerBufferBot, 1))
enteredLower2 = enteredBuffer(array.get(lowerBufferTop, 2), array.get(lowerBufferBot, 2))
enteredLower3 = enteredBuffer(array.get(lowerBufferTop, 3), array.get(lowerBufferBot, 3))
enteredLower4 = enteredBuffer(array.get(lowerBufferTop, 4), array.get(lowerBufferBot, 4))

enteredUpperArr = array.from(enteredUpper0, enteredUpper1, enteredUpper2, enteredUpper3, enteredUpper4)
enteredLowerArr = array.from(enteredLower0, enteredLower1, enteredLower2, enteredLower3, enteredLower4)

bufferLabel = ""
bufferLevel = 0.0

if enteredOpen
    bufferLabel := "Opening Price"
    bufferLevel := openPrice

for i = 0 to 4
    if array.get(enteredUpperArr, i)
        bufferLabel := "Upper Deviation " + str.tostring(i + 1) + " (Buffer)"
        bufferLevel := array.get(upperLevels, i)
    if array.get(enteredLowerArr, i)
        bufferLabel := "Lower Deviation " + str.tostring(i + 1) + " (Buffer)"
        bufferLevel := array.get(lowerLevels, i)

anyBufferEntry = bufferLabel != ""

// CHANNEL 1 of 3 — BUFFER. Intrabar.
if enableBufferAlerts and anyBufferEntry
    alert("Buffer zone approached: " + bufferLabel +
          " | Price: " + str.tostring(close, format.mintick) +
          " | Level: " + str.tostring(bufferLevel, format.mintick),
          alert.freq_once_per_bar)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │              Section 9   MA / VWAP                            │
// │                                                               │
// │ ta.vwap() and ta.sma/ema() are local-series functions — they  │
// │ read the chart's own bars, so nothing in this block needs a   │
// │ higher-timeframe request.                                     │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   9.A  Moving Average
// ───────────────────────────────────────────────
maLine = maType == "SMA" ? ta.sma(close, maLength) : ta.ema(close, maLength)

// ───────────────────────────────────────────────
//   9.B  VWAP Anchor Resolution
// ───────────────────────────────────────────────
vwapAnchorTf = vwapAnchorMode == "Daily (Session)" ? "D" :
     vwapAnchorMode == "Weekly" ? "W" :
     vwapAnchorMode == "Monthly" ? "M" :
     vwapAnchorMode == "Quarterly (3M)" ? "M" :
     vwapAnchorMode == "Semi-Annual (6M)" ? "M" :
     vwapAnchorMode == "Annual (12M)" ? "M" :
     vwapAnchorMode == "Match Deviation Anchor" ? timeframe :
     vwapCustomTf

vwapMonthStep = vwapAnchorMode == "Quarterly (3M)" ? 3 :
     vwapAnchorMode == "Semi-Annual (6M)" ? 6 :
     vwapAnchorMode == "Annual (12M)" ? 12 : 1

rawAnchor  = timeframe.change(vwapAnchorTf)
vwapAnchor = vwapMonthStep == 1 ? rawAnchor : (rawAnchor and (month - 1) % vwapMonthStep == 0)

// ───────────────────────────────────────────────
//   9.C  Validity Guards  (two tiers)
// ───────────────────────────────────────────────
anchorSeconds  = timeframe.in_seconds(vwapAnchorTf) * vwapMonthStep
chartSeconds   = timeframe.in_seconds(timeframe.period)
anchorTooShort = anchorSeconds <= chartSeconds

var float volAccum = 0.0
volAccum += nz(volume)
volumeAvailable = volAccum > 0

// vwapUsable = the CALCULATION is sound (bar colouring consumes this).
vwapUsable = volumeAvailable and not anchorTooShort
// vwapValid = usable AND the user wants it drawn (plots consume this).
vwapValid = showVWAP and vwapUsable

// ───────────────────────────────────────────────
//   9.D  VWAP Calculation + Bands
// ───────────────────────────────────────────────
vwapLine = ta.vwap(hlc3, vwapAnchor)

[_sdV1, sd1Up, sd1Dn] = ta.vwap(hlc3, vwapAnchor, vwapBand1 > 0 ? vwapBand1 : 1.0)
[_sdV2, sd2Up, sd2Dn] = ta.vwap(hlc3, vwapAnchor, vwapBand2 > 0 ? vwapBand2 : 1.0)

usePctBands = vwapBandMode == "Percentage"

band1Up = usePctBands ? vwapLine * (1 + vwapBand1 / 100) : sd1Up
band1Dn = usePctBands ? vwapLine * (1 - vwapBand1 / 100) : sd1Dn
band2Up = usePctBands ? vwapLine * (1 + vwapBand2 / 100) : sd2Up
band2Dn = usePctBands ? vwapLine * (1 - vwapBand2 / 100) : sd2Dn

bandsRequested = vwapBandMode != "Off"

b1Valid = vwapValid and bandsRequested and vwapBand1 > 0
b2Valid = vwapValid and bandsRequested and vwapBand2 > 0

b1Zone = vwapUsable and bandsRequested and vwapBand1 > 0
b2Zone = vwapUsable and bandsRequested and vwapBand2 > 0

bandCol1 = color.new(vwapBandColor, vwapBandTransp)
bandCol2 = color.new(vwapBandColor, math.min(vwapBandTransp + 15, 100))

// ───────────────────────────────────────────────
//   9.E  MA / VWAP Plots
//
//   TO REVERT the anchor-reset break: delete `and not vwapAnchor`
//   from the three gates below.
// ───────────────────────────────────────────────
vwapPlotOn = vwapValid and not vwapAnchor
b1PlotOn   = b1Valid   and not vwapAnchor
b2PlotOn   = b2Valid   and not vwapAnchor

plot(showMA ? maLine : na, color=maColor, title="Moving Average", linewidth=2)
plot(vwapPlotOn ? vwapLine : na, color=vwapColor, title="VWAP", linewidth=2)

b1UpPlot = plot(b1PlotOn ? band1Up : na, color=bandCol1, title="VWAP Band 1 Upper", linewidth=1)
b1DnPlot = plot(b1PlotOn ? band1Dn : na, color=bandCol1, title="VWAP Band 1 Lower", linewidth=1)
plot(b2PlotOn ? band2Up : na, color=bandCol2, title="VWAP Band 2 Upper", linewidth=1)
plot(b2PlotOn ? band2Dn : na, color=bandCol2, title="VWAP Band 2 Lower", linewidth=1)

fill(b1UpPlot, b1DnPlot,
     color=(vwapBandFill and b1PlotOn) ? color.new(vwapBandColor, 94) : na,
     title="VWAP Band 1 Fill")

// ───────────────────────────────────────────────
//   9.F  Warning Label
// ───────────────────────────────────────────────
var label vwapWarnLabel = na

if barstate.islast
    if not na(vwapWarnLabel)
        label.delete(vwapWarnLabel)
        vwapWarnLabel := na

    needVwapForColor = enableBarColor and barColorSource == "VWAP / Bands"

    if (showVWAP or needVwapForColor) and not vwapUsable
        string subject = "VWAP"
        if not showVWAP
            subject := "VWAP bar coloring"
        else if needVwapForColor
            subject := "VWAP + VWAP bar coloring"

        string reason = "the anchor (" + vwapAnchorMode + ") is not longer than the chart timeframe"
        if not volumeAvailable
            reason := "this symbol has no volume data"

        vwapWarnLabel := label.new(bar_index, high,
              subject + " unavailable — " + reason,
              style=label.style_label_down,
              color=color.new(color.orange, 20),
              textcolor=color.white,
              size=size.small)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │              Section 10   BAR COLORING                        │
// │                                                               │
// │ Gated on `vwapUsable`, NOT `vwapValid`, so VWAP colouring     │
// │ works with the VWAP line itself hidden.                       │
// │                                                               │
// │ ⚠ REQUIRED GUARD — `not na(openPrice)` on the deviation      │
// │ branch. That branch seeds barCol := betweenColor and then     │
// │ narrows it in a loop. With openPrice na, every comparison in  │
// │ that loop is false, so the seed survives and every bar        │
// │ before the first rollover gets painted the "between levels"   │
// │ colour — an entire orange left edge asserting a zone reading  │
// │ that does not exist. The guard leaves barCol na there         │
// │ instead, so those bars keep their natural candle colours.     │
// │ Do not remove it while 2.A is latched.                        │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   10.A  Resolve VWAP Zone Boundaries
// ───────────────────────────────────────────────
float zInnerUp = na
float zOuterUp = na
float zInnerDn = na
float zOuterDn = na

if b1Zone and b2Zone
    zInnerUp := math.min(band1Up, band2Up)
    zOuterUp := math.max(band1Up, band2Up)
    zInnerDn := math.max(band1Dn, band2Dn)
    zOuterDn := math.min(band1Dn, band2Dn)
else if b1Zone
    zInnerUp := band1Up
    zInnerDn := band1Dn
else if b2Zone
    zInnerUp := band2Up
    zInnerDn := band2Dn

// ───────────────────────────────────────────────
//   10.B  Apply Bar Color
// ───────────────────────────────────────────────
color barCol = na

if enableBarColor
    if barColorSource == "Deviation Levels"
        // Guard is required — see the section header.
        if not na(openPrice)
            barCol := betweenColor
            for j = 0 to 4
                i = 4 - j
                if close > array.get(upperLevels, i)
                    barCol := array.get(upperColors, i)
                    break
                else if close < array.get(lowerLevels, i)
                    barCol := array.get(lowerColors, i)
                    break
    else if vwapUsable
        if not na(zOuterUp) and close > zOuterUp
            barCol := array.get(upperColors, 2)
        else if not na(zInnerUp) and close > zInnerUp
            barCol := array.get(upperColors, 0)
        else if not na(zOuterDn) and close < zOuterDn
            barCol := array.get(lowerColors, 2)
        else if not na(zInnerDn) and close < zInnerDn
            barCol := array.get(lowerColors, 0)
        else if na(zInnerUp)
            barCol := close >= vwapLine ? array.get(upperColors, 0) : array.get(lowerColors, 0)
        else
            barCol := betweenColor

barcolor(barCol)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │         Section 10.5   DEVIATION TOUCH MARKERS                │
// │                                                               │
// │ System 3 of the three touch consumers described at the top.   │
// │ Reuses the SAME reach test as 7.C — high >= lvl above,        │
// │ low <= lvl below, straddle at 0% — so a marker and a          │
// │ historical line segment can never disagree about whether a    │
// │ level was touched. That test is DIRECTIONAL, which is why     │
// │ this channel sees gap-throughs that 8.A cannot.               │
// │                                                               │
// │ One marker per level per period, on the FIRST bar that        │
// │ reaches it. Re-armed on isRollover (Section 6).               │
// │                                                               │
// │ This block builds `tmMsg` but does NOT dispatch. Section 12   │
// │ dispatches it AT BAR CLOSE, and that is a property of this    │
// │ block rather than a preference: `sta` resolves to "closed     │
// │ beyond" or "rejected" by reading `close`, so the wording is   │
// │ only settled once the bar is. The REACH is known far earlier; │
// │ the adjective is not.                                         │
// │                                                               │
// │ `tmActive` carries its own `not na(openPrice)` guard, so the  │
// │ block is inert before the first rollover.                     │
// │                                                               │
// │ INPUT ORDER: this block is the LAST input block in the file.  │
// │ Any future input must be appended below these, never above.   │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   10.5.A  Inputs
// ───────────────────────────────────────────────
gTM = "Touch Markers"
gAL = "Alerts"

showTouch = input.bool(false, "Show Touch Markers", group=gTM,
     tooltip="Off by default. Places a small marker on the first bar of each period that reaches each deviation level. Independent of the Deviation Line Display setting — markers still draw with the grid switched off.")

touchMode = input.string("Touch only", "Marker Detail", group=gTM,
     options=["Touch only", "Touch + acceptance", "Touch / rejection / acceptance"],
     tooltip="Touch only = a dot at every first reach. Touch + acceptance = dot for a wick tag, triangle when the bar CLOSES beyond the level. Full = adds a diamond when the bar tags the level and closes back with a wick larger than the rejection threshold. The two richer modes are what make the First Touch alert a bar-close channel: both read where the bar closed.")

touchMaxK = input.int(4, "Mark Levels Up To ±", minval=1, maxval=5, group=gTM,
     tooltip="Capped at 5 to match the deviation grid. Lower values stretch how far back markers survive the shared 500-label budget.")

touchOpenToo = input.bool(false, "Also Mark the 0% Open Line", group=gTM)

touchGaps = input.bool(true, "Mark Gapped-Through Levels", group=gTM,
     tooltip="A bar that reaches a level without trading through it (the whole bar sits beyond it) gets an x-cross instead of being skipped. This is the same case Section 7.C already counts as touched, so leaving it ON keeps markers and historical lines in exact agreement.")

rejFrac = input.float(0.5, "Rejection Wick (share of bar range)", minval=0.1, maxval=0.9, step=0.05, group=gTM,
     tooltip="How far price must retreat from the level, as a fraction of the bar's high-low range, to call it a rejection. Raise toward 0.65 for a stricter read.")

touchLive = input.bool(false, "Tag on the Live Bar", group=gTM,
     tooltip="VISUAL ONLY — this setting does not affect any alert. Off = markers appear when the bar closes. On = a marker appears the moment price reaches the level, and its shape may still change before the bar closes, because acceptance and rejection both depend on where the bar ends up closing. The First Touch alert dispatches at bar close either way, by design; the At Level and Buffer alerts dispatch intrabar either way.")

touchInherit = input.bool(true, "Inherit Deviation Colors", group=gTM,
     tooltip="Uses the same shade arrays as the grid lines and buffer boxes, so a +3 marker matches the +3 line. Turn off to use the two flat colours below. The 0% marker is always blue, matching the opening-price line.")

touchUpCol = input.color(#4A90D9, "Above Open", group=gTM, inline="tmc")
touchDnCol = input.color(#D9534F, "Below Open", group=gTM, inline="tmc")

touchSizeStr = input.string("Tiny", "Marker Size", options=["Tiny", "Small"], group=gTM)
touchTrn     = input.int(25, "Marker Transparency", minval=0, maxval=90, group=gTM)

// ── Alert channel toggles (2 of the 3 channels; the buffer toggle
//    lives with the buffer settings, next to the size control that
//    determines how much warning it actually buys you).
//
//    The LABELS describe what each channel DETECTS, because that is
//    the permanent distinction — once per level versus repeating,
//    directional versus straddle. Timing is stated in the tooltips
//    instead: it is fixed per channel and derived from what each one
//    can honestly report, but it belongs to Section 12 and not to
//    the label text.
//
//    Declaration position is fixed. Only labels, tooltips and group
//    strings are free to change.
touchAlerts = input.bool(false, "First Touch (once per level, per period)", group=gAL,
     tooltip="Reports a deviation level the FIRST time price reaches it in the current anchor period, then stays quiet about that level until the next period begins. Also catches levels that a bar jumped straight over without trading back into them, which the At Level channel cannot see, and reports EVERY level a single bar reached rather than just the first. Dispatches at the bar's close, because its wording — touch, closed beyond, rejected — depends on where the bar closed. This is the complete-but-later channel. Works with the on-chart markers hidden.")

enableTouchAlerts = input.bool(true, "At Level (repeats while price is there)", group=gAL,
     tooltip="Reports every bar whose range contains a deviation level, so it keeps repeating for as long as price hovers at that level. Requires price to actually trade through the level — a bar that gaps clean over it is not reported here. Dispatches the MOMENT the bar's range reaches the level, without waiting for the close, so on a candle that runs through several levels at once it names the first one and tells you immediately. This is the fast-but-partial channel, and the script's default.")

// ───────────────────────────────────────────────
//   10.5.B  State + helpers
// ───────────────────────────────────────────────
TM_CAP = 5
var bool[] tmDone = array.new_bool(TM_CAP * 2 + 1, false)

if isRollover or barstate.isfirst
    array.fill(tmDone, false)

tmSize = touchSizeStr == "Tiny" ? size.tiny : size.small

// The anchor must be LONGER than the chart timeframe, otherwise every
// bar is its own period and the one-shot guard means nothing. Fails
// silently — Section 9.F already warns about anchor/timeframe mismatch.
tmSane = timeframe.in_seconds(timeframe) > chartSeconds

tmLevel(k) => openPrice * (1 + k * devStep / 100)

tmCol(k) =>
    color c = color.blue
    if k > 0
        c := touchInherit ? array.get(upperColors, int(math.min(k - 1, 4))) : touchUpCol
    else if k < 0
        c := touchInherit ? array.get(lowerColors, int(math.min(math.abs(k) - 1, 4))) : touchDnCol
    c

// ───────────────────────────────────────────────
//   10.5.C  Detect + draw   (message only, no dispatch)
//
//   With `touchLive` off — the default — this whole block only
//   runs on barstate.isconfirmed, so tmMsg is populated on the
//   bar's closing tick and nowhere else. Section 12's channel 3
//   uses once_per_bar_close, which evaluates on that same tick.
//
//   With `touchLive` on, the block also runs intrabar for the
//   MARKER's benefit. The alert is unaffected: Pine rolls back
//   var state on every real-time tick, so the closing tick
//   re-runs this loop from the previously committed tmDone, and
//   `high`/`low` still carry any spike, so tmMsg repopulates
//   correctly at the close regardless.
// ───────────────────────────────────────────────
string tmMsg = ""
tmActive = (showTouch or touchAlerts) and tmSane and not na(openPrice)

if tmActive and (barstate.isconfirmed or touchLive)
    for k = -touchMaxK to touchMaxK
        if k == 0 and not touchOpenToo
            continue
        i = k + TM_CAP
        if array.get(tmDone, i)
            continue
        lvl = tmLevel(k)
        if na(lvl)
            continue

        up = k > 0

        // Identical to 7.C's accumulation test.
        reached = k > 0 ? high >= lvl : k < 0 ? low <= lvl : (high >= lvl and low <= lvl)
        hitNow  = high >= lvl and low <= lvl
        gapNow  = reached and not hitNow

        if not (reached and (hitNow or touchGaps))
            continue

        array.set(tmDone, i, true)

        rng      = math.max(high - low, syminfo.mintick)
        accepted = k != 0 and (up ? close > lvl : close < lvl)
        pull     = up ? lvl - close : close - lvl
        rejected = k != 0 and not accepted and pull / rng >= rejFrac

        st  = label.style_circle
        trn = touchTrn
        sta = "touch"

        if gapNow
            st  := label.style_xcross
            sta := "gap through"
        else if touchMode != "Touch only" and accepted
            st  := up ? label.style_triangleup : label.style_triangledown
            trn := math.max(0, touchTrn - 15)
            sta := "closed beyond"
        else if touchMode == "Touch / rejection / acceptance" and rejected
            st  := label.style_diamond
            sta := "rejected"

        tmMsg += (k > 0 ? "+" : "") + str.tostring(k) + " (" + sta + "); "

        if showTouch
            label.new(bar_index, lvl, text="", style=st, size=tmSize,
                 color=color.new(tmCol(k), trn),
                 tooltip=(k > 0 ? "+" : "") + str.tostring(k) + " deviation  ·  " + sta +
                         "\n" + str.tostring(lvl, format.mintick))


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │         Section 11   DEVIATION DATA TABLE                     │
// │                                                               │
// │ Projects the indicator's own deviation grid (devStep) onto    │
// │ three user-selected timeframes, each measured from that       │
// │ timeframe's OWN opening price.                                │
// │                                                               │
// │  Open       — that period's opening price (format.mintick)    │
// │  Δ from Open— % move from it, gradient-scaled per column      │
// │  Zone       — which deviation band price occupies, painted    │
// │               with the SAME colour as the chart's grid line   │
// │  To Next    — % to the level above / below (Full mode only)   │
// │  Range Pos  — 0-100 position inside the period's range so far │
// │  State      — direction (Δ) + conviction (Range Pos)          │
// │                                                               │
// │ Every one of those derives from a LATCHED open. A column with │
// │ no boundary inside loaded history reports nothing at all      │
// │ rather than reporting a truncated period as if it were        │
// │ complete — see limitation (2) at the top of the file.         │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ───────────────────────────────────────────────
//   11.A  Helpers
// ───────────────────────────────────────────────
fmtP(v) => na(v) ? "—" : str.tostring(v, format.mintick)
fmt2(v) => na(v) ? "—" : str.tostring(v, "#.00")

tfLabel(_tf) =>
    string r = _tf
    if _tf == "D" or _tf == "1D"
        r := "Daily"
    else if _tf == "W" or _tf == "1W"
        r := "Weekly"
    else if _tf == "M" or _tf == "1M"
        r := "Monthly"
    else if _tf == "3M"
        r := "Quarterly"
    else if _tf == "6M"
        r := "Semi-Ann"
    else if _tf == "12M"
        r := "Annual"
    r

// Which grid slot does price occupy, measured from this period's open?
// kf is the floor of (pct / devStep), so it works identically above and
// below the open: kf = 1 means price sits between +1 and +2 deviations,
// kf = -2 means between -1 and -2.
zoneFloor(o, step) =>
    float pct = na
    int   kf  = na
    if not na(o) and o != 0 and step > 0
        pct := (close - o) / o * 100
        kf  := int(math.floor(pct / step))
    [pct, kf]

zoneText(kf) =>
    string s = "—"
    if not na(kf)
        if kf >= 5
            s := "> +5"
        else if kf <= -6
            s := "< -5"
        else if kf >= 1
            s := "+" + str.tostring(kf) + " → +" + str.tostring(kf + 1)
        else if kf == 0
            s := "0 → +1"
        else if kf == -1
            s := "0 → -1"
        else
            s := "-" + str.tostring(math.abs(kf) - 1) + " → -" + str.tostring(math.abs(kf))
    s

// Reuses the chart's own colour arrays, so the cell shade matches the line.
zoneCol(kf) =>
    color c = color.new(color.gray, 75)
    if not na(kf)
        if kf >= 1
            c := array.get(upperColors, math.min(kf - 1, 4))
        else if kf <= -2
            c := array.get(lowerColors, math.min(math.abs(kf) - 2, 4))
        else
            c := betweenColor
    c

nextText(o, step, kf) =>
    string s = "—"
    if not na(o) and not na(kf) and step > 0 and close > 0
        lb = o * (1 + kf * step / 100)
        ub = o * (1 + (kf + 1) * step / 100)
        s := "↑" + fmt2((ub - close) / close * 100) + "  ↓" + fmt2((close - lb) / close * 100)
    s

rangePos(h, l) =>
    na(h) or na(l) or h == l ? na : (close - l) / (h - l) * 100

// Direction from Δ (capped at ±3 deviations) plus conviction from range
// position (±1.5). Range position is what makes this independent of the
// Δ row rather than a restatement of its sign. When the range is unknown
// posN is 0 and this degrades to direction-only.
stateScore(pct, rp, step) =>
    float sc = na
    if not na(pct) and step > 0
        dirN = math.max(math.min(pct / step, 3.0), -3.0)
        posN = na(rp) ? 0.0 : (rp - 50.0) / 50.0 * 1.5
        sc := dirN + posN
    sc

// NOTE: an earlier filled-CELL variant of the State and Δ renderers
// (stateText / stateCol / deltaCol) lived here. Section 11.C moved the
// panel to text-tinted colour with the Zone row as the only filled
// block, which orphaned all three. They have been removed rather than
// left as dead weight — see stateGlyph / stateTxtCol / deltaTxtCol.

// Gradient ceiling scales as sqrt(time), the standard volatility scaling,
// normalised so a DAILY column saturates at 2 x devStep. At the 1% preset
// that gives roughly 2% / 4.5% / 9.2% for D / W / M — so each column's
// colour is meaningful on its own scale instead of one fixed ceiling that
// the monthly row always maxes out.
daySeconds = timeframe.in_seconds("D")
gradCeil(colS) => devStep * 2.0 * math.sqrt(math.max(colS, 1) * 1.0 / daySeconds)

// ───────────────────────────────────────────────
//   11.B  Column Metadata + Chart-Bar Accumulation
//
//   trackTf() supplies open, high and low from chart bars. The
//   open is latched on the column's boundary bar exactly as 2.A
//   latches the anchor open; high and low keep accumulating after
//   it.
//
//   WHY HIGH/LOW MUST BE ACCUMULATED REGARDLESS: a period's
//   extremes are only settled when that period ENDS, so
//   requesting them with lookahead WOULD return future data on
//   historical bars. That is the genuine abuse the rule exists to
//   stop, and it is precisely what makes the OPEN case different:
//   an open is fixed at the period's first tick. Losing sight of
//   that distinction is how "lookahead" became shorthand for
//   "cheating" when it is only sometimes true.
//
//   `ok` gates everything. It stays false until the chart has
//   actually shown a boundary for that timeframe, so a column
//   longer than loaded history reports nothing rather than
//   reporting a truncated period as though it were complete.
//   Each call site gets its own var instances.
// ───────────────────────────────────────────────
tf1Secs = timeframe.in_seconds(tableTf1)
tf2Secs = timeframe.in_seconds(tableTf2)
tf3Secs = timeframe.in_seconds(tableTf3)
anchorTfSecs = timeframe.in_seconds(timeframe)

trackTf(tf) =>
    var float o  = na
    var float h  = na
    var float l  = na
    var bool  ok = false
    if timeframe.change(tf)
        o  := open
        h  := high
        l  := low
        ok := true
    else if ok
        h := math.max(h, high)
        l := math.min(l, low)
    [o, ok ? h : na, ok ? l : na]

[o1, h1, l1] = trackTf(tableTf1)
[o2, h2, l2] = trackTf(tableTf2)
[o3, h3, l3] = trackTf(tableTf3)

headArr = array.from(tfLabel(tableTf1), tfLabel(tableTf2), tfLabel(tableTf3))
secsArr = array.from(tf1Secs, tf2Secs, tf3Secs)
openArr = array.from(o1, o2, o3)
highArr = array.from(h1, h2, h3)
lowArr  = array.from(l1, l2, l3)

// ───────────────────────────────────────────────
//   11.C  Derived palette, text helpers, layout
//
//   Every surface tone is derived from tableBgColor by blending it
//   toward a lift target, so one colour input retints the whole
//   panel. Colour is carried by TEXT; the Zone row is the single
//   filled block and acts as the panel's focal point.
//
//   NOTE: the two ternary chains below use a 6-space continuation
//   indent. Pine rejects continuation indents that are a multiple
//   of 4 (it reads them as a new block), so do not re-align these.
// ───────────────────────────────────────────────
tableFull = tableDetail == "Full"

// ── Surface derivation
surfLum = 0.299 * color.r(tableBgColor) + 0.587 * color.g(tableBgColor) + 0.114 * color.b(tableBgColor)
darkUI  = surfLum < 128
liftTgt = darkUI ? #1A2130 : #93A0B0        // what "lighter" means for this surface

pSurfA = color.new(tableBgColor, 0)                                   // rows, tone A
pSurfB = color.new(color.from_gradient(0.30, 0, 1, tableBgColor, liftTgt), 0)  // rows, tone B
pHead  = color.new(color.from_gradient(0.55, 0, 1, tableBgColor, liftTgt), 0)  // header + footer band
pSep   = color.new(color.from_gradient(0.60, 0, 1, tableBgColor, liftTgt), 0)  // separator hairline

// Anchor wash kept deliberately faint. The Zone row carries its own
// tint and State sits on the header band, so a strong wash renders
// as two disconnected patches rather than a continuous column — the
// ◆ and the brightened header text do the marking instead.
pAncA  = color.new(color.from_gradient(0.14, 0, 1, pSurfA, tableAccent), 0)
pAncB  = color.new(color.from_gradient(0.20, 0, 1, pSurfB, tableAccent), 0)

// ── Text hierarchy, flipped for light surfaces
pHdr  = darkUI ? #EAEEF6 : #0B0E14
pVal  = darkUI ? #D8E4F0 : #1E2530
pLbl  = darkUI ? #6B8CAE : #55606E
pNeu  = darkUI ? #7A8CA3 : #6A7484
pDim  = darkUI ? #4A6080 : #98A2B0
pZnTx = darkUI ? color.white : #0B0E14

// Pulls a grid colour to a readable contrast against the chosen
// surface — lifts it on dark, darkens it on light. Same spirit as
// darkerColor() in 2.D, but surface-aware. A pure-black Above/Below
// input is the one case this cannot rescue.
fitColor(c) =>
    r0  = color.r(c)
    g0  = color.g(c)
    b0  = color.b(c)
    lum = 0.299 * r0 + 0.587 * g0 + 0.114 * b0
    k   = darkUI ? (lum > 1.0 ? math.max(1.0, 150.0 / lum) : 1.0) : (lum > 110.0 ? 110.0 / lum : 1.0)
    color.rgb(math.min(r0 * k, 255), math.min(g0 * k, 255), math.min(b0 * k, 255))

rowBg(alt, anc) =>
    anc ? (alt ? pAncB : pAncA) : (alt ? pSurfB : pSurfA)

barMeter(pct, w) =>
    n = na(pct) ? 0 : int(math.round(math.max(0.0, math.min(100.0, pct)) / 100.0 * w))
    str.repeat("▰", n) + str.repeat("▱", w - n)

// Magnitude rides the text's transparency rather than the cell
// background, so gradCeil() still does real work.
deltaTxtCol(pct, ceil) =>
    color c = pNeu
    if not na(pct) and ceil > 0
        f    = math.min(math.abs(pct) / ceil, 1.0)
        base = fitColor(pct >= 0 ? aboveColorBase : belowColorBase)
        c := color.from_gradient(f, 0, 1, color.new(base, 45), color.new(base, 0))
    c

stateTxtCol(sc) =>
    color c = pNeu
    if not na(sc) and (sc > 1.0 or sc < -1.0)
        f    = math.min(math.abs(sc) / 3.0, 1.0)
        base = fitColor(sc > 0 ? aboveColorBase : belowColorBase)
        c := color.from_gradient(f, 0, 1, color.new(base, 40), color.new(base, 0))
    c

stateGlyph(sc) =>
    na(sc) ? "—" : sc > 1.0 ? "▲ Bullish" : sc < -1.0 ? "▼ Bearish" : "— Neutral"

// Range Pos is a position gauge, not a directional opinion — the
// meter's fill already carries the reading, so the text stays at the
// neutral tone rather than adding a fourth colour vote per column.
// TO BRIGHTEN: return pVal instead of pNeu.
rangeTxtCol(rp) =>
    na(rp) ? pDim : pNeu

tablePos = tablePosStr == "Top Right"    ? position.top_right :
      tablePosStr == "Middle Right"      ? position.middle_right :
      tablePosStr == "Bottom Right"      ? position.bottom_right :
      tablePosStr == "Top Left"          ? position.top_left :
      tablePosStr == "Middle Left"       ? position.middle_left :
      tablePosStr == "Bottom Left"       ? position.bottom_left :
      tablePosStr == "Top Center"        ? position.top_center :
      position.bottom_center

tableSize = tableSizeStr == "Tiny"  ? size.tiny :
      tableSizeStr == "Small"       ? size.small :
      tableSizeStr == "Large"       ? size.large :
      size.normal

// Separator positions are computed, not fixed, so Compact mode
// leaves no empty rows behind.
rTitle = 0
rHead  = 1
rSep1  = 2
rOpen  = 3
rDelta = 4
rSep2  = 5
rZone  = 6
rNext  = tableFull ? 7 : -1
rRange = tableFull ? 8 : -1
rSep3  = tableFull ? 9 : 7
rState = tableFull ? 10 : 8

var table myTable = table.new(tablePos, 4, 11, bgcolor=pSurfA, frame_color=color.new(pSep, 40), frame_width=1, border_color=pSurfA, border_width=0)


// ───────────────────────────────────────────────
//   11.D  Build
//
//   THREE column states:
//     • below chart TF        — structurally unresolvable
//     • no boundary yet       — resolvable, but this chart's
//                               history has not reached one
//     • normal
//   The middle state is announced in the Δ cell so an all-dashes
//   column reads as "not enough history" rather than "broken".
// ───────────────────────────────────────────────
if barstate.islast
    table.clear(myTable, 0, 0, 3, 10)

    if showTable
        // ── Title band
        table.cell(myTable, 0, rTitle, " ▸ OPEN DEVIATION", text_color=pHdr, bgcolor=pHead, text_size=tableSize, text_halign=text.align_left)
        table.cell(myTable, 1, rTitle, "", bgcolor=pHead, text_size=size.tiny)
        table.cell(myTable, 2, rTitle, "", bgcolor=pHead, text_size=size.tiny)
        table.cell(myTable, 3, rTitle, str.tostring(devStep, "#.##") + "% grid  ", text_color=fitColor(tableAccent), bgcolor=pHead, text_size=tableSize, text_halign=text.align_right)

        // ── Label column
        table.cell(myTable, 0, rHead, "", bgcolor=pHead, text_size=size.tiny)
        table.cell(myTable, 0, rOpen,  "  Open",        text_color=pLbl, bgcolor=rowBg(false, false), text_size=tableSize, text_halign=text.align_left)
        table.cell(myTable, 0, rDelta, "  Δ from Open", text_color=pLbl, bgcolor=rowBg(true,  false), text_size=tableSize, text_halign=text.align_left)
        table.cell(myTable, 0, rZone,  "  Zone",        text_color=pHdr, bgcolor=rowBg(false, false), text_size=tableSize, text_halign=text.align_left)
        if tableFull
            table.cell(myTable, 0, rNext,  "  To Next %", text_color=pLbl, bgcolor=rowBg(true,  false), text_size=tableSize, text_halign=text.align_left)
            table.cell(myTable, 0, rRange, "  Range Pos", text_color=pLbl, bgcolor=rowBg(false, false), text_size=tableSize, text_halign=text.align_left)
        table.cell(myTable, 0, rState, "  State",        text_color=pLbl, bgcolor=pHead, text_size=tableSize, text_halign=text.align_left)

        // ── Separator hairlines (lighter than the rows, not darker)
        for c = 0 to 3
            table.cell(myTable, c, rSep1, "", bgcolor=pSep, text_size=size.tiny)
            table.cell(myTable, c, rSep2, "", bgcolor=pSep, text_size=size.tiny)
            table.cell(myTable, c, rSep3, "", bgcolor=pSep, text_size=size.tiny)

        // ── Timeframe columns
        for c = 0 to 2
            col     = c + 1
            colSecs = array.get(secsArr, c)
            isAnc   = colSecs == anchorTfSecs
            colOk   = colSecs >= chartSeconds

            table.cell(myTable, col, rHead,
                 array.get(headArr, c) + (isAnc ? " ◆  " : "  "),
                 text_color=isAnc ? pHdr : pLbl, bgcolor=pHead,
                 text_size=tableSize, text_halign=text.align_right)

            if not colOk
                table.cell(myTable, col, rOpen,  "—  ",              text_color=pDim, bgcolor=rowBg(false, isAnc), text_size=tableSize, text_halign=text.align_right)
                table.cell(myTable, col, rDelta, "below chart TF  ", text_color=pDim, bgcolor=rowBg(true,  isAnc), text_size=tableSize, text_halign=text.align_right)
                table.cell(myTable, col, rZone,  "—  ",              text_color=pDim, bgcolor=rowBg(false, isAnc), text_size=tableSize, text_halign=text.align_right)
                if tableFull
                    table.cell(myTable, col, rNext,  "—  ", text_color=pDim, bgcolor=rowBg(true,  isAnc), text_size=tableSize, text_halign=text.align_right)
                    table.cell(myTable, col, rRange, "—  ", text_color=pDim, bgcolor=rowBg(false, isAnc), text_size=tableSize, text_halign=text.align_right)
                table.cell(myTable, col, rState, "—  ", text_color=pDim, bgcolor=pHead, text_size=tableSize, text_halign=text.align_right)
            else
                o = array.get(openArr, c)
                h = array.get(highArr, c)
                l = array.get(lowArr,  c)

                [pct, kf] = zoneFloor(o, devStep)
                rp = rangePos(h, l)
                sc = stateScore(pct, rp, devStep)

                table.cell(myTable, col, rOpen, fmtP(o) + "  ",
                     text_color=pVal, bgcolor=rowBg(false, isAnc),
                     text_size=tableSize, text_halign=text.align_right)

                // Distinguishes "no latched open yet" from a plain na,
                // so the cause of an empty column is visible in the
                // panel itself.
                table.cell(myTable, col, rDelta,
                     (na(pct) ? (na(o) ? "no boundary yet" : "—") : (pct >= 0 ? "▲ " : "▼ ") + fmt2(pct) + "%") + "  ",
                     text_color=na(pct) ? pDim : deltaTxtCol(pct, gradCeil(colSecs)), bgcolor=rowBg(true, isAnc),
                     text_size=tableSize, text_halign=text.align_right)

                // The one filled row in the panel — tinted with the SAME
                // colour as the corresponding chart grid line.
                table.cell(myTable, col, rZone, zoneText(kf) + "  ",
                     text_color=pZnTx, bgcolor=color.new(zoneCol(kf), 55),
                     text_size=tableSize, text_halign=text.align_right)

                if tableFull
                    table.cell(myTable, col, rNext, nextText(o, devStep, kf) + "  ",
                         text_color=pVal, bgcolor=rowBg(true, isAnc),
                         text_size=tableSize, text_halign=text.align_right)
                    table.cell(myTable, col, rRange,
                         barMeter(rp, 5) + " " + (na(rp) ? "—" : str.tostring(int(math.round(rp))) + "%") + "  ",
                         text_color=rangeTxtCol(rp), bgcolor=rowBg(false, isAnc),
                         text_size=tableSize, text_halign=text.align_right)

                table.cell(myTable, col, rState, stateGlyph(sc) + "  ",
                     text_color=stateTxtCol(sc), bgcolor=pHead,
                     text_size=tableSize, text_halign=text.align_right)


////////////////////////////////////////////////////////////////////////////////
// ┌───────────────────────────────────────────────────────────────┐
// │            Section 12   LEVEL ALERT DISPATCH                  │
// │                                                               │
// │ Channels 2 and 3 of 3. Channel 1 (BUFFER) dispatches in 8.B.  │
// │                                                               │
// │ These two are dispatched SEPARATELY, not merged. An earlier   │
// │ build combined them into one alert() call to avoid two        │
// │ notifications landing on the same bar — but that forced the   │
// │ intrabar channel to wait for the bar close, because the       │
// │ other one could not report any sooner. The merge solved a     │
// │ cosmetic problem by creating a real one.                      │
// │                                                               │
// │ Kept apart, they do not collide in the first place: AT LEVEL  │
// │ has already fired and been delivered long before FIRST TOUCH  │
// │ is even evaluated. Same bar, different moments.               │
// │                                                               │
// │ ── CHANNEL 2 — AT LEVEL — alert.freq_once_per_bar             │
// │  Fires on the first tick of a bar whose range contains a      │
// │  level. Safe intrabar because 8.A reads `high` and `low` and  │
// │  never `close`: inside a live bar the range only ever widens, │
// │  so a straddle cannot be undone by a later tick.              │
// │  COST: `touchedLabel` describes the range AT THAT TICK, so a  │
// │  candle running through +1, +2 and +3 reports +1 only. That   │
// │  is the accepted price of hearing about it immediately, and   │
// │  it is what channel 3 exists to cover.                        │
// │                                                               │
// │ ── CHANNEL 3 — FIRST TOUCH — alert.freq_once_per_bar_close    │
// │  Fires on the closing tick. 10.5.C populates tmMsg on         │
// │  barstate.isconfirmed, and once_per_bar_close evaluates on    │
// │  that same tick, so the two are aligned by construction.      │
// │  It waits because its wording reads `close` — "closed         │
// │  beyond", "rejected" — which on a live bar is only the        │
// │  current price and could flip tick to tick.                   │
// │  BENEFIT: evaluated once, on a finished bar, it loops every   │
// │  level and reports ALL of them, including any the bar gapped  │
// │  clean over. This is the completeness channel.                │
// │                                                               │
// │ SO: buffer and at-level answer "tell me NOW". First touch     │
// │ answers "tell me EVERYTHING, a moment later".                 │
// │                                                               │
// │ trimTail() (defined in 8.A) strips the trailing "; " that     │
// │ both accumulator loops leave on their last fragment, so all   │
// │ three channels render the same shape. See MESSAGE FORMAT IS   │
// │ AN INTERFACE at the top before changing any delimiter.        │
// │                                                               │
// │ IF YOU EVER WANT FIRST TOUCH INTRABAR TOO: switch it to       │
// │ once_per_bar and turn "Tag on the Live Bar" ON so tmMsg       │
// │ populates on unconfirmed bars. Understand what it costs —     │
// │ the classification becomes provisional, AND Pine rolls back   │
// │ var state on every real-time tick, so tmDone does not hold    │
// │ within a bar and only the first level reached gets reported.  │
// │ You would be converting the complete channel into a second    │
// │ copy of the fast one. The proper fix, if completeness at      │
// │ speed is ever genuinely needed, is a `varip` bitmask —        │
// │ varip is the one storage class Pine does not roll back —      │
// │ guarding a per-level dispatch at alert.freq_all.              │
// │                                                               │
// │ SETUP: create ONE alert on this indicator with the condition  │
// │ set to "Any alert() function call". The three toggles decide  │
// │ what it reports. Note that the long string TradingView shows  │
// │ in the alert list is the alert's NAME, auto-built from every  │
// │ input — rename it in the alert dialog; it is not the message. │
// │ For separate per-channel sounds or webhooks, see the          │
// │ TWO-INSTANCE PATTERN at the top of the file.                  │
// │                                                               │
// │ No alert can fire before the first anchor rollover in loaded  │
// │ history, because every level is na until then. On a live      │
// │ chart that is historical only — the latch is long since       │
// │ populated by the time anything fires.                         │
// └───────────────────────────────────────────────────────────────┘
////////////////////////////////////////////////////////////////////////////////

// ── CHANNEL 2 of 3 — AT LEVEL. Intrabar, the moment the range reaches it.
if enableTouchAlerts and anyDeviationTouch
    alert("At level: " + trimTail(touchedLabel) + " | Price: " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar)

// ── CHANNEL 3 of 3 — FIRST TOUCH. Bar close, because the wording needs it.
if touchAlerts and tmMsg != ""
    alert("First touch: " + trimTail(tmMsg) + " | Price: " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
````
