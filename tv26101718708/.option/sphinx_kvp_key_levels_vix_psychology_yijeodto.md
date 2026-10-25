# Sphinx KVP - Key Levels, VIX & Psychology

- url: https://www.tradingview.com/script/YIjEODTo-Sphinx-KVP-Key-Levels-VIX-Psychology/
- type: indicator
- pine_id: PUB;f5b60e77e50e4f15a72668f7fa2081d7
- version: 11.0

## Description

Sphinx KVP is a context and discipline tool for intraday index futures traders. It combines four questions into one chart and panel:

DESCRIPTION 

Range budget: how much of today's move is already paid for?
Volatility: how big a day is the options market pricing?
Key levels: where are the levels that matter, and is there untaken liquidity beyond the obvious one?
Psychology: am I in a state to trade, and am I about to enter early?

It does not generate buy or sell signals. Every prompt describes where you stand relative to the context, never where price will go.

━━━━━━━━━━━━━━━━━━━━

RANGE BUDGET

The trading day is anchored at the 18:00 New York open. The budget is the median daily range of the last 20 completed days, held constant through the session. The panel shows range used, points of room left above and below, and whether the day is approaching or past its typical size.

VOLATILITY

The implied daily move is taken from the matching CBOE volatility index, locked at the 18:00 open: VIX for ES, VXN for NQ, RVX for RTY, GVZ for GC.

Term structure (VIX9D vs VIX) and VVIX show whether near-term fear is building.
Self-calibration: the script records every completed day and compares the real range with what the average day and the volatility index predicted.
It reports how far off each forecast has been.
It shows an adjusted implied move, because implied volatility normally prices above what actually happens.
It flags a "bigger" or "quieter" day only when today is unusual relative to recent days.
Until enough days are recorded, it uses fixed thresholds and says so.

KEY LEVELS AND KEY ZONES

Liquidity levels are tracked with a naked / swept / broken state:

previous day high/low
Asia and London session high/low
previous 4H candle high/low
previous week high/low (optional)

A swept level (wicked through, back inside) stays on the chart. A broken level is removed as soon as price trades beyond it.

A key zone is where structure and untaken liquidity sit together:

With gamma data loaded: a gamma wall within the confluence radius of an unbroken liquidity level.
Without it: a range-budget projection stands in for the wall.

The nearest key zone above and below price is drawn and listed in the panel.

DON'T FADE (INDUCEMENT) ZONES

The shaded purple zone marks the space between an obvious level and a naked liquidity level just beyond it, when the remaining budget can reach that liquidity. Entering at the obvious level is the early trade. The zone ends in one of three ways:

Swept and reclaimed (closes back inside within the reclaim window): the event worth waiting for.
Swept without reclaim: the level broke.
Price moves away: nothing to act on.

If the budget cannot reach the liquidity, no zone is drawn: the obvious level may simply be the level.

GAMMA (OPTIONAL)

Paste a gamma string exported from your own options data provider:

SYM.DTE:F{flip}|T{unix time}|N{net,call,put}|CW{strike:exposure:oi,...}|PW{...}

Segments are separated by ; and fields are identified by prefix.

Walls: each wall is drawn with a diverging exposure bar (call exposure right, put exposure left) and an open interest bar beneath.
Market mode: read from net gamma exposure or the flip. The panel flags when those two disagree.
Expiry: a 0DTE board exported before the current 18:00 open is marked expired and removed from all calculations. Expired walls can be shown faded for reference.
No gamma: everything else works without it, and market mode falls back to the volatility read.

PSYCHOLOGY

Pre-session checklist: plan reviewed, mentally prepared, max loss set and accepted, sleep quality. Add up to five of your own rules. It counts only when its date is set to today, so it never carries over. Until it is complete, the status reads NOT CLEARED with the next unchecked item.
Loss log: enter the time of each loss. Losses count per CME trading day. Each one starts a cooldown ("step away, get some air"), and reaching your limit shows STOP. Low sleep lowers the limit by one (optional).
Heads-up prompts: entering a Don't Fade zone early, chasing a new extreme late in the budget, budget spent, negative gamma at a wall.

POWER OF 3 CANDLES

The two previous days and today are drawn to the right of price at true levels, built 18:00 to 18:00, with each candle's open marked. Labels show the range and the distance travelled above and below the open.

━━━━━━━━━━━━━━━━━━━━

SETUP

Add to a time-based intraday chart. A 5-minute chart is a good default: levels are identical across timeframes, and reclaims confirm on 5-minute closes.
Optionally paste your gamma string each session. If you also use a separate gamma-level indicator, turn off "Draw key levels".
Each session, set the checklist date to today and tick your items.

ALERTS

Entered a Don't Fade zone · sweep and reclaim · sweep without reclaim · key zone reached · range budget exhausted.

NOTES AND LIMITATIONS

Not for Renko, range or other non-time charts. Session levels and daily data depend on clock-based bars.
CBOE data is delayed on free plans. The implied budget locks from the prior close, so it is unaffected. Live term-structure and VVIX readings will lag.
Pine Script cannot see your fills. Losses are logged by hand.
Alerts store settings at creation. Cooldown and checklist states are shown on the chart only. Re-create alerts after pasting a new gamma string.
Your data, your assumptions. Gamma levels are only as current as the string you paste. Wall roles rest on the standard dealer-positioning assumption, which is a convention, not observed inventory.

This script is for education and decision support. It is not financial advice and makes no claim about future performance.

## Source Code

````pine
//@version=6
// ============================================================
// Sphinx KVP - Key Levels, VIX & Positioning   v1.11.2
// ------------------------------------------------------------
// v1.16.0
//   - THE POINT RULER MOVES TO THE RIGHT of the current candle, on
//     every column. Side is an input; Left is the old behaviour.
//
//     THE DAILY GHOST'S LEVEL NAMES MOVE TO THE LEFT to make room.
//     They were already on the right, so the two would have printed
//     over each other. The rule is simply that they take opposite
//     sides, and it follows the ruler setting - put the ruler back on
//     the left and the names return to the right.
//
//     The clearance lanes follow suit rather than staying put. What
//     needs room on a given side is whatever is printing there: with
//     the ruler on the right it is the next column that must start
//     clear of it, and the gap between the last two candles is now
//     only wide enough for the names. On the weekly and monthly
//     columns, which carry no names, that inner gap closes entirely.
//
//   - The bracket line over each group is off by default. The toggle
//     stays, so it comes back with one setting.
//
// v1.15.2
//   - Candle labels default to TINY, and the spacing inside each
//     group comes in behind them.
//
//     The two go together: the label under a candle is centred on it,
//     so label WIDTH is what sets the minimum spacing, not the candle
//     body. At Small a row like 'room 140 157' needs roughly twelve
//     bars of clear space; at Tiny it needs about half that, which is
//     what lets the columns close up without the text running
//     together. Shrinking the gaps alone would have collided.
//
//     Daily and weekly spacing 7 bars, monthly 6, ruler clearance 8,
//     ghost-name lane 12.
//
//     ALL OF THESE ARE DEFAULTS, and Pine keeps the values already
//     saved on a chart. Remove and re-add the indicator to pick the
//     whole set up at once; changing them by hand one at a time works
//     too but there are six of them now.
//
// v1.15.1
//   - LANE FOR THE DAILY GHOST'S LEVEL NAMES. The tick names print to
//     the RIGHT of the daily ghost while the weekly ruler prints to
//     the LEFT of the weekly one, and the ten-bar gap between the two
//     columns was not wide enough for both - a name like
//     '4hL CW.30/PW.30' ran straight over the W-1 candle. The weekly
//     column now starts clear of that text, and the monthly column
//     follows it along.
//
//     This is the only right-hand overhang in the layout, because the
//     weekly and monthly ghosts carry no tick names.
//
//   - BRACKET LINE over each group, spanning its full width from the
//     first candle to the current one, with the heading sitting on
//     it. Whitespace alone could not mark the groups once each column
//     needed a ruler lane inside it: the gaps within a column had
//     grown as wide as the gaps between columns, so the eye had
//     nothing to go on. The bracket states the span directly and
//     moves with the candle count, spacing and clearances.
//
// v1.15.0
//   - COLUMN HEADINGS centred above each group: DAILY, WEEKLY,
//     MONTHLY, on a toggle.
//
//     The gap between columns and the spacing inside them had ended
//     up nearly equal, so the right side read as one row of candles
//     rather than three groups. The headings carry the grouping
//     directly, which spacing alone was never going to do once a
//     ruler lane had to sit inside each column.
//
//     Each heading is centred on its own group's span - which moves
//     with the candle count, the spacing and the ruler clearance -
//     and sits above the tallest thing in that column, the ghost
//     included, so it clears the ruler's top label.
//
//   - Default gap between columns cut from 20 bars to 10. The
//     headings mark the boundaries now, so the whitespace that was
//     doing that job is no longer needed.
//
//     NOTE AGAIN: a changed default does not reach an instance
//     already on a chart. Set the two gap inputs to 10 by hand, or
//     remove and re-add the indicator.
//
// v1.14.3
//   - PANEL TEXT COLOURS are inputs: one for row labels and headings,
//     one for a value that carries no state. Both default to the grey
//     they were hardcoded to, so nothing changes until they are set.
//
//     The STATE COLOURS ARE DELIBERATELY NOT INCLUDED. Red, amber and
//     green are already inputs further down, and they mean something
//     specific on a row - exhausted, caution, available. Re-colouring
//     a value that is signalling a state would make the panel look
//     tidier and read wrong, so a value only takes the custom neutral
//     when it had no state to show.
//
// v1.14.2
//   - RULER CLEARANCE. Each ruler draws its ticks and labels to the
//     LEFT of its ghost. With the higher columns cut to two candles
//     the previous period now sits exactly where those labels land,
//     and the weekly ruler was printing over the W-1 body.
//
//     The current period's candle and its ghost shift right by a set
//     number of bars, opening a lane for the ruler. The completed
//     candles do not move, so the spacing input still means what it
//     says. The shift applies only where a ruler is actually drawn,
//     and each column's starting position accounts for the one before
//     it, so the three stay evenly separated.
//
//   - Candle bodies default to 2 bars wide in every column. Thin
//     bodies keep the wick and the open tick readable at the width
//     the right-hand lane can afford.
//
//     NOTE: changing a default does not change an instance already on
//     a chart - Pine keeps the saved input values. Set the daily and
//     weekly widths to 2 by hand, or remove and re-add the indicator.
//
// v1.14.1
//   - The weekly and monthly columns drop to TWO candles by default:
//     the last completed period and the current one. The daily column
//     keeps all three.
//
//     The period before last is the weakest of the three and costs
//     the most horizontal room, and at weekly and monthly scale it is
//     far enough behind current price to be reference rather than
//     context. Dropping one candle from each of the two higher
//     columns returns roughly sixteen bars of width on the right.
//
//     The count is an input per column, 1 to 3, so the third candle
//     goes back with a setting rather than an edit. Whatever the
//     count, the current period is always the rightmost candle and
//     the ghost sits behind it.
//
// v1.14.0
//   - MONTHLY RANGE BUDGET, stacked under the weekly one in the same
//     panel, which is now the higher-timeframe box: how much of a
//     typical month this month has delivered, the room left either
//     way, and how many trading days have elapsed.
//
//     The month rolls at the first 18:00 open belonging to a new
//     calendar month, so it follows the CME day like everything else
//     here: the Globex session that opens on the evening of the last
//     day of a month is already the new month's first trading day.
//
//     LOOKBACK DEFAULTS TO 12, NOT 20. Twenty monthly bars is nearly
//     two years and will span several volatility regimes, so the
//     median stops describing anything current. Twelve is one year,
//     which is already long for this purpose.
//
//     NO MONTH-BY-WEEK ROW. The weekly panel's by-day row works
//     because Monday to Friday are equal buckets. Weeks of a month
//     are not - the last one is routinely two or three days - so the
//     numbers would not be comparable across buckets and a short
//     final week would read as a quiet one.
//
//     A monthly budget is context, not a trading input on an
//     intraday chart. The daily budget is the operative frame and the
//     weekly is a reasonable higher-timeframe check; the monthly is
//     there to say whether the week sits inside a month that still
//     has room, and little else.
//
//   - MONTHLY POWER OF 3 CANDLES with their own ghost and ruler, in a
//     third column past the weekly one.
//
//   - PER-COLUMN CANDLE SIZING. Body width and spacing are now set
//     separately for the daily, weekly and monthly columns, defaulting
//     narrower as the timeframe rises, so the three read as a nested
//     set rather than three identical blocks.
//
//     THE CANDLES STAY AT TRUE PRICE. They are not offset vertically
//     to separate them, because their y position is the price the
//     range actually occupied - that is what lets the daily candles
//     double as prior high, low and close references. Separation is
//     horizontal only.
//
//   - TABLE BACKGROUND AND FRAME COLOURS are inputs, so the panels can
//     be made opaque enough to read over a busy chart. The default is
//     near-transparent, matching previous behaviour.
//
// v1.13.2
//   - POINT RULER ON THE WEEKLY GHOST, as on the daily one: a zero
//     line with ticks every N points out to each ghost edge, labelled
//     on the left, and the exact remaining reach at each end. Zero at
//     current price reads as points from here, which is what a swing
//     stop or target is measured in.
//
//     Its own step input, defaulting to 25 points rather than the
//     daily 10. A weekly span runs more than twice a daily one, so
//     the daily step would print two and a half times as many ticks
//     into the same height and the labels would merge. The step still
//     doubles automatically if a span is tall enough to crowd them.
//
//     Labels sit to the LEFT of the weekly ghost, which is the side
//     facing the daily column. If they touch the daily candles, raise
//     the gap after the daily candles.
//
// v1.13.1
//   - The weekly ghost range gets its own toggle, independent of the
//     weekly candles, the way the daily ghost is independent of the
//     daily ones. The candles alone are a history read; the ghost is
//     a forward one, and wanting the first without the second is a
//     reasonable thing to want.
//
// v1.13.0
//   - WEEKLY POWER OF 3 CANDLES with a ghost range, in a column of
//     their own to the right of the daily ones: the two completed
//     weeks and this one, each built from the Sunday 18:00 open with
//     an open tick, so the move above and below the week open reads
//     directly.
//
//     The ghost behind this week's candle spans where the week can
//     still reach inside its budget - up to the week low plus the
//     weekly denominator, down to the week high minus it. As the week
//     extends one way the other side shrinks point for point, and
//     when the budget is used the ghost is gone and the candle is
//     outlined. Identical construction to the daily ghost, one frame
//     up, so the two read the same way.
//
//     NO LEVEL TICKS ON THE WEEKLY GHOST. On the daily ghost a 75
//     point span makes the ticks selective. A weekly span runs more
//     than twice that, so nearly every wall and DOL level on the
//     board would qualify and the marks would stop discriminating
//     between reachable and not. The daily ghost keeps its ticks.
//
// v1.12.1
//   - The weekly budget moves into a table of its own with its own
//     position input, instead of three more rows on a main panel that
//     already runs to a dozen. The two frames are read at different
//     cadences - the daily rows change through the session, the
//     weekly ones barely move inside a day - so stacking them in one
//     block made the panel longer without making it quicker to read.
//
//     NOTE ON OVERLAPPING PANELS: if every row appears doubled, two
//     copies of this script are on the chart drawing to the same
//     position. Pine cannot detect another instance, so there is no
//     guard against it; remove the older one.
//
// v1.12.0
//   - WEEKLY RANGE BUDGET. The same question one frame up: how much
//     of a typical week has this week already delivered, and how much
//     room is left either way.
//
//     Anchored to the Sunday 18:00 NY open, tracked from the clock
//     rather than read off the weekly bar, because TradingView's
//     weekly boundary for CME futures does not reliably land on the
//     Sunday reopen. Only the weekly range statistic comes from the
//     'W' request, with the usual [1] offset so the forming week is
//     excluded from its own benchmark.
//
//     WEEKLY RANGE IS NOT FIVE DAILY RANGES. Price mean-reverts
//     inside the week so the extremes do not stack; on ES the weekly
//     median typically runs around two to two and a half times the
//     daily. A figure near five times the daily average means the
//     calculation is wrong, not that the week is wild.
//
//   - WEEK BY DAY. Extension contribution per trading day, Monday to
//     Friday, measured the same way as any budget here: the points by
//     which a day pushed the running week high or low outward, not
//     the day's own high minus low. A day that trades violently
//     inside the week's existing range has consumed nothing. The five
//     therefore sum to the week's range exactly.
//
//     Unlike an intraday pace read, day-of-week position is worth
//     showing: each trading day contributes meaningfully, so 60% of
//     the weekly budget spent on Tuesday and the same figure on
//     Thursday are genuinely different situations. The panel states
//     which day of five it is and leaves the read there.
//
//     No verdict label. Whether a spent week caps the next session or
//     precedes continuation has not been measured on this instrument.
//
// v1.11.2
//   - FIX: a re-anchored swing could be marked one candle early - the
//     leg extreme took its price from the right-side bars but its time
//     from the pivot candle. The time now comes from the exact 1H bar
//     that printed the low / high.
//
// v1.11.1
//   - FIX (primary swings): v1.11.0 kept whichever swings were first
//     accepted at the start of history, often far from price and off
//     screen. Structure now re-anchors: when the swing high is traded
//     through, the swing low moves to the lowest low of the leg since
//     that swing high formed (the protected low), and the mirror for a
//     broken swing low. Both swings therefore stay with current price.
//
// v1.11.0
//   - PRIMARY SWINGS (structure mode, default). One active 1H swing
//     high and one active 1H swing low. Intermediate pivots that form
//     while a swing is active are ignored; a new swing on a side is
//     only accepted once the active one has been traded through. The
//     previous behaviour (every confirmed pivot, N most recent) remains
//     selectable as 'All pivots'.
//
// v1.10.1
//   - Manual wall slots moved directly under the gamma string.
//
// v1.10.0
//   - Manual walls: three call-wall and three put-wall slots, each a
//     price and an optional size ($M). They join the pasted walls in
//     every way - lines, exposure bars, key zones, inducement, the
//     big-wall checklist rule and the ghost ticks - labelled CW.M /
//     PW.M. They never expire at the 18:00 open; clear a slot by
//     setting it to 0. Size is what ranks them against other walls;
//     a slot with no size draws but never counts as a big wall.
//
// v1.9.0
//   - Point scale on the ghost candle: a zero line (current price by
//     default, or today's open) with ticks every N points up to the top
//     of the ghost and down to the bottom, labelled on the left side,
//     and the exact remaining reach labelled at each end. Reads as
//     'points from here' for placing a stop or target. Step doubles
//     automatically if the ghost is too tall for readable ticks.
//
// v1.8.0
//   - Level ticks on the ghost candle. Every wall and unbroken DOL
//     level that falls inside today's remaining reach (the ghost span)
//     is marked across the candle, in its level colour, with a short
//     name. The ghost itself does not move: it stays the budget; the
//     ticks show which levels that budget can still get to.
//
// v1.7.1
//   - Power of 3 label colour and size are inputs; default brighter.
//
// v1.7.0
//   - PSYCHOLOGY LAYER REMOVED: pre-session checklist, sleep, loss log,
//     cooldown and the status row are gone, along with the entry
//     checklist's 'blocked' state. The heads-up prompts stay - they
//     describe position against the context, not the operator.
//   - Name: the P in KVP now stands for Positioning (dealer gamma).
//   - Ghost range room is measured from current price, so it matches
//     the Room row exactly; it now sits in the TODAY label instead of
//     separate edge labels.
//   - Power of 3 labels sit in one row beneath the whole candle column
//     (below the ghost), clear of the level labels. Default gap after
//     the level labels raised to 18 bars.
//   - Compact panel (default on): hides Avg day, Forecast check, the
//     VIX term-structure row and Box reach.
//
// v1.6.1
//   - Ghost range is the same width as the candle body, with a solid
//     border over its faint fill.
//
// v1.6.0
//   - GHOST RANGE on today's Power of 3 candle. The solid body and wick
//     are what the day has done; a faint box behind them spans where the
//     day could still reach within its budget: up to today's low +
//     budget, down to today's high - budget. Until the day commits to a
//     direction the ghost extends both ways; as price extends one way
//     the other side shrinks point for point, and when the budget is
//     used the ghost is gone. Past budget, the candle is outlined.
//     Budget basis: match Room (default), VIX implied, or VIX adjusted.
//
// v1.5.0
//   - ENTRY CHECKLIST: a second table, scored separately for longs and
//     shorts. Default rules (each switchable and tunable):
//       1. 1H swing sweep and reject - a 1H swing low (high) traded
//          through, then a close back above (below) it within the
//          reject window. Stays valid for a set time, and is cancelled
//          if price trades beyond the sweep's extreme afterwards.
//       2. Range budget near its extreme - room left beyond the sweep
//          extreme is at or under the limit (points or % of budget).
//       3. High magnitude wall at the sweep - a live wall within the
//          tolerance of the sweep extreme, at or above the size ratio
//          of the largest wall on its side. Not scored without gamma.
//       4. Lower-timeframe trigger - SMT / Renko flip happen on another
//          chart and cannot be read here, so this row prompts CONFIRM
//          once the automatic rules pass. Its text is editable.
//     Up to two extra manual rows can be added. The setup row shows
//     READY when every enabled automatic rule passes, and is blocked
//     while the pre-session status is not CLEARED (optional).
//     Alerts: long setup ready, short setup ready.
//
// v1.4.3
//   - Walls per side per board raised from a maximum of 3 to 10, so
//     every strike in the export can be drawn. Call and put walls at
//     the same strike still merge into one line (CW.0/PW.0).
//
// v1.4.2
//   - Power of 3 candles now follow the level labels instead of sitting
//     a fixed distance past the last bar, so the whole right side reads
//     as one lane - lines, bars, labels, candles - and stays clear of
//     the panel at normal zoom. Pine cannot read the panel's position,
//     so this is placement by lane, not by collision.
//
// v1.4.1
//   - Swing strength defaults to 1: a 1H high with a lower high on the
//     candle either side (a 3-candle swing). Confirms one hour later.
//   - A swing is MITIGATED the moment price trades through it, wick
//     included. Its resting stops are gone, so it leaves the pool.
//     Toggle to keep swept swings instead.
//   - Each swing line is drawn from the 1H candle that made it, with a
//     small marker on that candle, so every level can be traced to its
//     swing. Line colour matches the other DOL levels.
//
// v1.4.0
//   - 1H SWING HIGHS AND LOWS join the DOL pool. A swing is a 1H bar
//     whose high (low) is the highest (lowest) of the bars either side
//     of it, confirmed only once the right-side bars have closed, so it
//     never repaints. Each carries the same naked / swept / broken
//     state as every other DOL level and is removed when broken. The
//     most recent unbroken swings per side are kept.
//     These are where stops actually rest, which a single prior
//     candle's high or low only approximates. They key zones and
//     inducement targets exactly like any other DOL level.
//     Chart timeframe must be 1H or lower.
//
// v1.3.0
//   - REGIME NOW SHAPES THE BOXES. Inducement priority:
//       Regime-aware (default): in POSITIVE gamma a large wall
//         (>= the size ratio input, against the largest wall on the
//         board) is a turning point in its own right. The box still
//         shows the liquidity beyond, but reads TWO-WAY - wall can
//         hold - in blue, and the early-entry prompt is replaced.
//         In negative gamma, or with small walls, unchanged.
//       Liquidity first: v1.2 behaviour, every box is don't-fade.
//       Walls first: boxes only when no live walls exist (DOL-only).
//   - VIX NOW SHAPES THE BOXES. Box reach (max distance from the
//     obvious level to the liquidity) scales with the calibrated
//     VIX read: longer on a bigger-than-usual day, shorter on a
//     quieter one. Shown in the panel as 'Box reach'.
//   - Box reach default 0.25 x daily ATR (was 0.50), sized for
//     short-target intraday trading. Inducement shading slightly
//     stronger so it reads on dark themes.
//
// v1.2.3
//   - FIX: with the 0DTE board expired and no other board enabled,
//     the script still counted the expired walls as present, so the
//     DOL-plus-projection fallback for key zones never switched on.
//     Only walls that are actually live now count.
//   - Expired 0DTE walls can be shown faded for overnight reference.
//     They are drawn only; they never enter key zones, inducement or
//     the regime.
//
// v1.2.2
//   - Exposure bars per wall, as in DOL+G: call exposure extends right
//     of a centre axis, put exposure left, both on one scale, with an
//     open interest bar at half height beneath. Square-root scaling by
//     default so one dominant strike does not flatten the rest. Bar
//     height follows the visible price range, so it holds at any zoom.
//     Needs inline magnitudes in the string (strike:mag:oi).
//
// v1.2.1
//   - STALE GAMMA. The export's T field (unix time) is read; if the
//     string predates the current 18:00 open, the 0DTE board has
//     expired. Its walls, flip and net GEX are dropped, the regime
//     falls back to the volatility read, and the panel says to paste
//     today's string. 7D / 30D walls are kept. Strings without a T
//     field can be dated with the 'Gamma string pasted on' input.
//   - Key zone radius has a floor in points, so a wall and a DOL level
//     a quarter point either side of the ATR-based radius no longer
//     switch a zone on and off.
//   - Losses and cooldown count per CME trading day (18:00 to 18:00),
//     not per calendar day. The checklist stays on the calendar date.
//   - DOL levels break as soon as price trades beyond them. A wick
//     through that comes back inside before the bar closes is still a
//     sweep; price currently beyond the level is a break, immediately.
//
// v1.2.0
//   - VIX SELF-CALIBRATES. Each completed 18:00 day records what
//     actually happened next to what the average day and VIX
//     predicted. From that the script learns:
//       * how much VIX usually over-prices the day on this chart,
//         and shows an adjusted expectation alongside the raw one;
//       * what a normal VIX / average-day ratio looks like, so
//         'bigger day than avg' fires only in the top 20% of recent
//         days rather than against a fixed 1.15.
//     Until 20 days are recorded it uses the fixed thresholds and
//     says 'calibrating'. Fixed mode remains selectable.
//   - Forecast check row: average error of the average day and of
//     VIX against the real range, so the lookback choice can be
//     judged on this instrument instead of assumed.
//   - Average day lookback back to 20, matching Range Budget.
//
// v1.1.0
//   - Panel rewritten in plain language. Same numbers, clearer names.
//   - Average day now defaults to a 30-day lookback.
//   - Power of 3 daily candles to the right of price: D-2, D-1 and
//     today, built from the 18:00 NY open, each with an open tick so
//     the move above and below the open reads at a glance.
//
// v1.0.2
//   - Inputs no longer print in the status line (display.none).
//     The gamma string alone ran across the chart and covered
//     the panel.
//
// v1.0.1
//   - FIX: inducement could pair a wall with liquidity inside its own
//     key zone (CW/PW 7745 -> 4hH 7747). The minimum gap is now the
//     larger of the tick setting and the confluence radius, so the
//     liquidity has to sit genuinely beyond the obvious level.
//   - Regime row flags when net GEX and flip side disagree, as in
//     DOL+G: 'NEG - walls break (net) ! flip POS'.
//
// v1.0.0
// One question per layer:
//   Range budget - how much of today's move is already paid for?
//   Volatility   - how big a day is the options market pricing?
//   Gamma / DOL  - where are the levels, and will dealers let
//                  price through them?
//   Positioning  - is there a setup, or am I early?
//
// SELF-CONTAINED so it runs for users without Sphinx DOL+G or
// Sphinx Range Budget on the chart. The context math is a lean
// copy of both:
//   - Budget: 18:00 NY anchor, median DR of completed days,
//     constant intraday.
//   - Gamma: same string format as DOL+G, pasted unchanged. Only
//     the parse, regime resolution and level set are carried.
//     Magnitude bars, harvester and state boxes stay in DOL+G.
//   - DOL: same naked / swept / broken state machine. Asia runs
//     18:00-03:00 and London 03:00-08:30, matching Range Budget.
//
// DR REQUEST uses expr[1] with lookahead_on, so historical and
// realtime bars both read the DR through yesterday. Range Budget
// v2.3.1 uses [1] with lookahead_off, which on HISTORICAL bars
// reads one day further back. Realtime values agree.
//
// IMPLIED BUDGET locks at the 18:00 anchor from the last available
// print of the volatility index, which at 18:00 is the prior
// session close:  index / 100 / sqrt(252) x anchor open.
// Like the DR it does not move intraday.
//
// GAMMA IS OPTIONAL. With it off, or on with the string blank, the
// regime falls back to a volatility read (VIX9D/VIX term structure,
// implied/historical ratio, VVIX) and is labelled as such, and the
// budget projections stand in for walls when building key zones.
//
// INDUCEMENT IS STRUCTURAL, not a percentage. The nearest obvious
// level (a wall, or a DOL level) with a NAKED liquidity level
// beyond it, inside the remaining budget, is flagged. The zone ends
// when that liquidity is swept; a close back inside within the
// reclaim window is the event worth waiting for. If the budget
// cannot reach the liquidity, nothing is flagged - the obvious
// level may simply be the level.
//
// NO PRICE VERDICTS. Every prompt describes the operator's position
// relative to the context, never where price will go.
//
// Alerts snapshot inputs when they are created. Intraday charts only.
// ============================================================

indicator('Sphinx KVP - Key Levels, VIX & Positioning', 'Sphinx KVP', overlay = true, max_lines_count = 250, max_labels_count = 250, max_boxes_count = 150, max_bars_back = 2000)

TZ = 'America/New_York'
VER = 'v1.16.0'

// ============================================================
// === INPUTS ===
// ============================================================
g_b = 'Range Budget  (anchor 18:00 NY)'
i_method = input.string('Median', 'Average day method', options = ['Median', 'Mean (SMA)', 'EMA'], group = g_b, display = display.none)
i_len = input.int(20, 'Average day lookback (days)', minval = 3, maxval = 120, group = g_b, display = display.none)
i_manual = input.float(0.0, 'Manual DR override (points)', minval = 0, group = g_b, tooltip = 'Pin the denominator when a regime break has outrun the window. Zero disables.', display = display.none)
i_warn = input.float(70.0, 'Caution above (% used)', minval = 1, group = g_b, display = display.none)
i_exh = input.float(100.0, 'Exhausted above (% used)', minval = 1, group = g_b, display = display.none)
i_room = input.string('DR (historical)', 'Room and reach measured against', options = ['DR (historical)', 'Implied (VIX)', 'Larger of the two'], group = g_b, tooltip = 'Sets the projections, the Room row, whether a key zone is inside budget, and whether an inducement target is reachable. DR matches Sphinx Range Budget. Falls back to DR when no implied value is available.', display = display.none)

g_w = 'Weekly Budget  (anchor Sunday 18:00 NY)'
i_wk_on = input.bool(true, 'Show weekly budget', group = g_w, tooltip = 'Two rows under the daily budget: how much of a typical week this week has delivered, and the room left either way.\n\nThe higher frame answers a question the daily cannot. A day that has spent its range inside a week that is still mid-range is extended on one frame and ordinary on the other, and fading it is a counter-trend trade on the higher one.', display = display.none)
i_wk_len = input.int(20, 'Average week lookback (weeks)', minval = 3, maxval = 104, group = g_w, tooltip = 'Weeks of completed data behind the weekly denominator. 20 is about five months.', display = display.none)
i_wk_manual = input.float(0.0, 'Manual weekly override (points)', minval = 0, group = g_w, tooltip = 'Pin the weekly denominator when a regime break has outrun the window. Zero disables.', display = display.none)
i_wk_pos = input.string('Middle Right', 'Weekly panel position', options = ['Middle Right', 'Middle Left', 'Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = g_w, tooltip = 'The weekly budget draws in its own table. Keep it clear of the main panel and the entry checklist.', display = display.none)
i_wkc = input.bool(true, 'Weekly Power of 3 candles', group = g_w, tooltip = 'W-2, W-1 and this week, drawn at true price in their own column to the right of the daily candles, with a ghost range showing the week\'s remaining reach.', display = display.none)
i_wk_gh = input.bool(true, '  Ghost range on this week\'s candle', group = g_w, tooltip = 'Faint box behind this week\'s candle showing where the week can still reach inside its budget. Shrinks as the week uses its range; gone when the budget is spent, and the candle outlines instead.', display = display.none)
i_wk_scale = input.bool(true, '  Point scale on the weekly ghost', group = g_w, tooltip = 'Ticks every N points from the zero line to the ghost edges, labelled on the left, with the exact remaining reach at each end.', display = display.none)
i_wk_zero = input.string('Current price', '   Scale zero at', options = ['Current price', 'Week open'], group = g_w, display = display.none)
i_wk_step = input.float(25.0, '   Scale step (points)', minval = 0.25, maxval = 500, step = 0.25, group = g_w, tooltip = 'Larger than the daily step by default: a weekly span is roughly twice a daily one, so the same step would crowd the labels. Doubles automatically if the span is still too tall.', display = display.none)
i_wkc_off = input.int(10, '  Gap after the daily candles (bars)', minval = 2, maxval = 200, group = g_w, display = display.none, tooltip = 'Horizontal space between the daily column and the weekly one. Raise it if the two touch.')
i_wk_w = input.int(2, '  Weekly body width (bars)', minval = 1, maxval = 20, group = g_w, display = display.none)
i_wk_gap = input.int(7, '  Weekly spacing (bars)', minval = 3, maxval = 60, group = g_w, display = display.none)
i_wk_n = input.int(2, '  Weekly candles shown', minval = 1, maxval = 3, group = g_w, display = display.none, tooltip = 'Counts back from the current week. 2 shows last week and this one; 3 adds the week before that. The current week is always rightmost.')
i_wk_days = input.bool(true, '  Week by day', group = g_w, tooltip = 'Extension contribution per trading day, Monday to Friday, with the current day marked. Contribution counts only the points by which a day pushed the running week high or low outward, so the five sum to the week range exactly.', display = display.none)

g_m = 'Monthly Budget  (anchor first 18:00 NY of the month)'
i_mo_on = input.bool(true, 'Show monthly budget', group = g_m, tooltip = 'Stacks under the weekly budget in the same panel. Context for whether the week sits inside a month with room left - not an intraday input.', display = display.none)
i_mo_len = input.int(12, 'Average month lookback (months)', minval = 3, maxval = 60, group = g_m, tooltip = 'Twelve months is one year. Longer windows span several volatility regimes and the median stops describing anything current.', display = display.none)
i_mo_manual = input.float(0.0, 'Manual monthly override (points)', minval = 0, group = g_m, display = display.none)
i_moc = input.bool(true, 'Monthly Power of 3 candles', group = g_m, tooltip = 'M-2, M-1 and this month, in a third column past the weekly one, with their own ghost range.', display = display.none)
i_mo_gh = input.bool(true, '  Ghost range on this month\'s candle', group = g_m, display = display.none)
i_mo_scale = input.bool(true, '  Point scale on the monthly ghost', group = g_m, display = display.none)
i_mo_zero = input.string('Current price', '   Scale zero at', options = ['Current price', 'Month open'], group = g_m, display = display.none)
i_mo_step = input.float(50.0, '   Scale step (points)', minval = 0.25, maxval = 1000, step = 0.25, group = g_m, tooltip = 'Larger again than the weekly step: a monthly span is roughly twice a weekly one.', display = display.none)
i_moc_off = input.int(10, '  Gap after the weekly candles (bars)', minval = 2, maxval = 200, group = g_m, display = display.none)
i_moc_w = input.int(2, '  Monthly body width (bars)', minval = 1, maxval = 20, group = g_m, display = display.none)
i_moc_gap = input.int(6, '  Monthly spacing (bars)', minval = 3, maxval = 60, group = g_m, display = display.none)
i_mo_n = input.int(2, '  Monthly candles shown', minval = 1, maxval = 3, group = g_m, display = display.none, tooltip = 'Counts back from the current month. 2 shows last month and this one; 3 adds the month before that.')

g_v = 'Volatility'
i_vix_on = input.bool(true, 'Use volatility indices', group = g_v, tooltip = 'Requests CBOE indices. Free data is delayed. That does not affect the implied budget, which locks at 18:00 from the prior close, but live term structure and VVIX readings will lag.', display = display.none)
i_vix_es = input.string('VIX (30D)', 'ES implied move from', options = ['VIX (30D)', 'VIX1D'], group = g_v, tooltip = 'VIX1D prices the current day only. Its closing print may not represent the NEXT day, which is what an 18:00 lock needs, so VIX is the default until that is checked against your own data.', display = display.none)
i_vix_sym = input.string('', 'Index symbol override', group = g_v, tooltip = 'Blank = automatic: ES VIX or VIX1D, NQ VXN, RTY RVX, GC GVZ, anything else VIX. Enter e.g. CBOE:VXN to force one.', display = display.none)
i_ts_back = input.float(1.00, 'Backwardation: VIX9D / VIX at or above', minval = 0.5, maxval = 2.0, step = 0.01, group = g_v, display = display.none)
i_ts_cont = input.float(0.95, 'Contango: VIX9D / VIX at or below', minval = 0.5, maxval = 2.0, step = 0.01, group = g_v, display = display.none)
i_cal_mode = input.string('Auto (calibrated)', 'Bigger / quieter day thresholds', options = ['Auto (calibrated)', 'Fixed'], group = g_v, display = display.none, tooltip = 'Auto: the script records every completed day and flags a bigger day only when VIX vs the average day is in the top slice of the calibration window, and a quieter day only in the bottom slice. VIX normally prices above what actually happens, so a fixed ratio fires too often.\n\nUntil the minimum number of days is recorded, Auto uses the fixed values below and the panel says calibrating.')
i_cal_n = input.int(60, '  Calibration window (days)', minval = 20, maxval = 250, group = g_v, display = display.none)
i_cal_min = input.int(20, '  Minimum days before auto applies', minval = 10, maxval = 100, group = g_v, display = display.none)
i_cal_hi = input.int(80, '  Bigger day: ratio above percentile', minval = 50, maxval = 99, group = g_v, display = display.none)
i_cal_lo = input.int(20, '  Quieter day: ratio below percentile', minval = 1, maxval = 50, group = g_v, display = display.none)
i_ir_hi = input.float(1.30, 'Fixed: bigger day at VIX / avg day', minval = 1.0, maxval = 3.0, step = 0.05, group = g_v, display = display.none)
i_ir_lo = input.float(0.85, 'Fixed: quieter day at VIX / avg day', minval = 0.1, maxval = 1.0, step = 0.05, group = g_v, display = display.none)
i_vvix_spk = input.float(8.0, 'VVIX spike (% above its 18:00 value)', minval = 1.0, maxval = 50.0, step = 0.5, group = g_v, display = display.none)

g_g = 'Gamma (optional)'
i_gex_on = input.bool(true, 'Use gamma levels', group = g_g, tooltip = 'Off, or on with the string blank: the regime comes from the volatility read and key zones are built from DOL levels and budget projections.', display = display.none)
i_gstr = input.string('', 'Gamma string', group = g_g, tooltip = 'Same format as Sphinx DOL+G, pasted unchanged:\nSYM.DTE:F{flip}|N{net},{call},{put}|CW{strike[:mag[:oi]]},...|PW{...}\nSegments separated by ;', display = display.none)
i_mw = input.bool(true, 'Use manual walls (below)', group = g_g, display = display.none, tooltip = 'Six slots for walls typed in by hand - from another provider, or when no string is available. Needs "Use gamma levels" on. They never expire; set a slot to 0 to clear it.')
i_cw1 = input.float(0.0, 'CW 1', minval = 0, step = 0.25, group = g_g, inline = 'mc1', display = display.none)
i_cw1m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mc1', display = display.none)
i_cw2 = input.float(0.0, 'CW 2', minval = 0, step = 0.25, group = g_g, inline = 'mc2', display = display.none)
i_cw2m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mc2', display = display.none)
i_cw3 = input.float(0.0, 'CW 3', minval = 0, step = 0.25, group = g_g, inline = 'mc3', display = display.none)
i_cw3m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mc3', display = display.none)
i_pw1 = input.float(0.0, 'PW 1', minval = 0, step = 0.25, group = g_g, inline = 'mp1', display = display.none)
i_pw1m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mp1', display = display.none)
i_pw2 = input.float(0.0, 'PW 2', minval = 0, step = 0.25, group = g_g, inline = 'mp2', display = display.none)
i_pw2m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mp2', display = display.none)
i_pw3 = input.float(0.0, 'PW 3', minval = 0, step = 0.25, group = g_g, inline = 'mp3', display = display.none)
i_pw3m = input.float(0.0, 'size $M', minval = 0, group = g_g, inline = 'mp3', display = display.none)
i_dte0 = input.bool(true, '0DTE', group = g_g, inline = 'gd', display = display.none)
i_dte7 = input.bool(false, '7DTE', group = g_g, inline = 'gd', display = display.none)
i_dte30 = input.bool(true, '30DTE', group = g_g, inline = 'gd', display = display.none)
i_max_rank = input.int(1, 'Walls per side per board (rank)', minval = 1, maxval = 10, group = g_g, display = display.none)
i_mag_keep = input.float(0.30, 'Also admit walls above magnitude ratio', minval = 0.0, maxval = 1.0, step = 0.05, group = g_g, tooltip = 'Uses inline magnitudes only (strike:mag). Same rule as DOL+G.', display = display.none)
i_reg_src = input.string('Auto', 'Regime source', options = ['Auto', 'Net GEX', 'Flip'], group = g_g, display = display.none)
i_gdate = input.time(timestamp('01 Jan 2000 00:00 +0000'), 'Gamma string pasted on (only if no T field)', group = g_g, display = display.none, tooltip = 'Exports carrying a T field (unix time) are dated automatically. For strings without one, set this when you paste; a string dated before the current 18:00 open is treated as expired for 0DTE. Left at the default, no staleness check is made.')
i_exp_show = input.string('Show faded', 'Expired 0DTE walls', options = ['Show faded', 'Hide'], group = g_g, display = display.none, tooltip = 'After the 18:00 open, yesterday\'s 0DTE walls have expired. Show faded draws them in grey for reference only; they take no part in key zones, inducement or the regime.')
i_netgex = input.float(0.0, 'Net GEX manual fallback ($B)', step = 0.01, group = g_g, tooltip = 'Used only when the string carries no N block for 0DTE.', display = display.none)

g_d = 'DOL'
i_pd = input.bool(true, 'Prev day H/L', group = g_d, display = display.none)
i_asia = input.bool(true, 'Asia H/L (18:00-03:00)', group = g_d, display = display.none)
i_lon = input.bool(true, 'London H/L (03:00-08:30)', group = g_d, display = display.none)
i_h4 = input.bool(true, 'Prev 4H candle H/L', group = g_d, display = display.none)
i_sw = input.bool(true, '1H swing highs / lows', group = g_d, display = display.none, tooltip = 'Swing points on the 1H chart, confirmed once the bars to their right have closed. Kept until price trades beyond them. Needs a chart timeframe of 1H or lower.')
i_sw_str = input.int(1, '  Swing strength (1H bars each side)', minval = 1, maxval = 10, group = g_d, display = display.none, tooltip = '1 = a 1H high with a lower high on the candle either side (3-candle swing). 3 = above the three bars either side. Higher values keep only larger swings and confirm later.')
i_sw_wick = input.bool(true, '  Remove a swing when price trades through it', group = g_d, display = display.none, tooltip = 'On: a wick through the swing mitigates it - the stops resting there have been taken. Off: a wick through leaves it as swept, and only a break beyond removes it, like the other DOL levels.')
i_sw_mode = input.string('Primary (structure)', '  Swing logic', options = ['Primary (structure)', 'All pivots'], group = g_d, display = display.none, tooltip = 'Primary: one active swing high and one active swing low. A new swing is only taken once the active one has been traded through, so intermediate pivots inside the range are ignored.\n\nAll pivots: every confirmed pivot, keeping the most recent unbroken ones per side.')
i_sw_max = input.int(4, '  Keep most recent unbroken per side (All pivots)', minval = 1, maxval = 10, group = g_d, display = display.none)
i_pw = input.bool(false, 'Prev week H/L', group = g_d, display = display.none)
i_hide_broken = input.bool(true, 'Mitigate broken levels', group = g_d, tooltip = 'A close beyond a level breaks it; broken levels are dropped. Swept levels (wick, no close beyond) stay.', display = display.none)

g_c = 'Key Zones'
i_confl_min = input.float(4.0, 'Confluence radius minimum (points)', minval = 0.0, maxval = 50.0, step = 0.25, group = g_c, display = display.none, tooltip = 'Floor on the radius below. Stops a zone switching on and off when ATR drifts by a fraction of a point.')
i_merge_ticks = input.int(4, 'Merge tolerance (ticks)', minval = 1, maxval = 40, group = g_c, display = display.none)
i_confl_atr = input.float(0.04, 'Confluence radius (x daily ATR)', minval = 0.005, maxval = 0.5, step = 0.005, group = g_c, tooltip = 'A key zone is a group of levels within this radius holding BOTH structure (a wall, or a projection when gamma is off) AND an unbroken DOL level.', display = display.none)
i_prj_conf = input.bool(false, 'Projections count as structure with gamma on', group = g_c, tooltip = 'With gamma off or blank, budget projections always stand in for walls so DOL-only users still get key zones.', display = display.none)

g_i = 'Inducement'
i_ind = input.bool(true, 'Show inducement zones', group = g_i, display = display.none)
i_ind_obv = input.string('Walls and DOL', 'Obvious level can be', options = ['Walls and DOL', 'Walls and swept DOL', 'Walls only'], group = g_i, tooltip = 'Which levels count as the obvious turning point. The liquidity beyond it must always be a NAKED DOL level.', display = display.none)
i_ind_gap = input.float(0.25, 'Box reach: max gap obvious -> liquidity (x daily ATR)', minval = 0.05, maxval = 3.0, step = 0.05, group = g_i, display = display.none, tooltip = 'How far past the obvious level the liquidity may sit and still form a box. 0.25 is about 18 points on ES at a 73-point ATR. Scaled by the VIX read below when that is on.')
i_ind_pri = input.string('Regime-aware', 'Inducement priority', options = ['Regime-aware', 'Liquidity first', 'Walls first'], group = g_i, display = display.none, tooltip = 'Regime-aware: in positive gamma a large wall can hold on its own, so its box reads TWO-WAY instead of don\'t-fade. Negative gamma: liquidity first.\n\nLiquidity first: every box is don\'t-fade.\n\nWalls first: boxes appear only when there are no live walls.')
i_big_w = input.float(0.70, '  Large wall: size vs biggest wall', minval = 0.1, maxval = 1.0, step = 0.05, group = g_i, display = display.none, tooltip = 'A wall at or above this fraction of the largest wall exposure on the board counts as large. Needs inline magnitudes.')
i_vol_gap = input.bool(true, 'VIX scales box reach', group = g_i, display = display.none, tooltip = 'Uses the same bigger / quieter day read as the panel (calibrated when available).')
i_gap_big = input.float(1.50, '  Bigger day multiplier', minval = 1.0, maxval = 3.0, step = 0.1, group = g_i, display = display.none)
i_gap_quiet = input.float(0.60, '  Quieter day multiplier', minval = 0.2, maxval = 1.0, step = 0.1, group = g_i, display = display.none)
i_ind_min = input.int(4, 'Min gap obvious -> liquidity (ticks)', minval = 1, maxval = 400, group = g_i, tooltip = 'Floor only. The confluence radius also applies, so liquidity inside the obvious level\'s own key zone never counts as beyond it.', display = display.none)
i_recl_bars = input.int(3, 'Reclaim window after sweep (bars)', minval = 1, maxval = 30, group = g_i, display = display.none)


g_q = 'Prompts'
i_q_ind = input.bool(true, 'Early entry (inside inducement)', group = g_q, display = display.none)
i_q_chase = input.bool(true, 'Chasing (new extreme past caution)', group = g_q, display = display.none)
i_q_exh = input.bool(true, 'Budget spent', group = g_q, display = display.none)
i_q_neg = input.bool(true, 'Negative gamma at a wall', group = g_q, display = display.none)

g_ec = 'Entry checklist'
i_ec = input.bool(true, 'Show entry checklist', group = g_ec, display = display.none)
i_ec_pos = input.string('Bottom Right', 'Position', options = ['Bottom Right', 'Bottom Left', 'Top Left', 'Middle Right', 'Middle Left'], group = g_ec, display = display.none)
i_r1 = input.bool(true, '1. 1H swing sweep and reject', group = g_ec, display = display.none, tooltip = 'Long: a 1H swing low traded through, then a close back above it. Short: the mirror at a swing high. Uses the swings from the DOL group, so 1H swings must be on.')
i_r1_rej = input.int(3, '   Close back inside within (chart bars)', minval = 1, maxval = 30, group = g_ec, display = display.none)
i_r1_val = input.int(60, '   Setup valid for (minutes after reject)', minval = 5, maxval = 480, group = g_ec, display = display.none, tooltip = 'Also cancelled early if price trades beyond the sweep extreme after rejecting.')
i_r2 = input.bool(true, '2. Range budget near extreme', group = g_ec, display = display.none, tooltip = 'Room left beyond the sweep extreme, in the sweep direction, must be at or under the limit. Measured at the extreme, not at current price.')
i_r2_mode = input.string('Points', '   Limit in', options = ['Points', '% of budget'], group = g_ec, display = display.none)
i_r2_max = input.float(20.0, '   Room left at most', minval = 0, maxval = 500, step = 1, group = g_ec, display = display.none)
i_r3 = input.bool(true, '3. High magnitude wall at the sweep', group = g_ec, display = display.none, tooltip = 'A live wall near the sweep extreme, at least the size ratio of the largest wall on its own side. Not scored when no gamma string is loaded.')
i_r3_ratio = input.float(0.5, '   Wall size vs largest on its side', minval = 0.05, maxval = 1.0, step = 0.05, group = g_ec, display = display.none)
i_r3_tol = input.float(6.0, '   Within (points) of the sweep extreme', minval = 0.25, maxval = 50, step = 0.25, group = g_ec, display = display.none)
i_r3_side = input.string('Any wall', '   Wall side', options = ['Any wall', 'Puts for longs, calls for shorts'], group = g_ec, display = display.none)
i_r4 = input.bool(true, '4. Lower-timeframe trigger (manual)', group = g_ec, display = display.none)
i_r4_tx = input.string('SMT or Renko flip', '   Trigger text', group = g_ec, display = display.none)
i_rx1 = input.string('', 'Extra manual rule 1', group = g_ec, display = display.none)
i_rx2 = input.string('', 'Extra manual rule 2', group = g_ec, display = display.none)

g_mb = 'Exposure bars'
i_mb = input.bool(true, 'Show exposure bars', group = g_mb, display = display.none, tooltip = 'One bar per wall, to the right of the level lines. Call exposure right of the centre axis, put exposure left, same scale, so the lean IS the net. Purple beneath is open interest: a long OI bar under a short exposure bar is a real position; a short OI bar under a long exposure bar is size that exists mainly because price is near the strike.')
i_mb_len = input.int(16, 'Bar length at the largest wall (bars)', minval = 4, maxval = 80, group = g_mb, display = display.none)
i_mb_gap = input.int(2, 'Gap after level lines (bars)', minval = 0, maxval = 30, group = g_mb, display = display.none)
i_mb_h = input.float(0.012, 'Bar half-height (x visible range)', minval = 0.002, maxval = 0.1, step = 0.002, group = g_mb, display = display.none)
i_mb_sqrt = input.bool(true, 'Square-root scaling', group = g_mb, display = display.none, tooltip = 'On: compresses the largest wall so smaller ones stay readable. Off: length exactly proportional.')
i_mb_op = input.int(35, 'Bar opacity', minval = 0, maxval = 90, group = g_mb, display = display.none)
col_oi = input.color(color.new(#ab47bc, 0), 'Open interest', group = g_mb, display = display.none)

g_p3 = 'Power of 3 candles'
i_p3 = input.bool(true, 'Show daily candles', group = g_p3, display = display.none, tooltip = 'D-2, D-1 and today, each built from the 18:00 NY open to the next 18:00, drawn at true price to the right of the chart. The tick across each candle is its open, so the move above and below the open is visible directly.')
i_p3_off = input.int(18, 'Gap after level labels (bars)', minval = 0, maxval = 300, group = g_p3, display = display.none, tooltip = 'Candles start this many bars after the level label column. Raise it if long labels touch the first candle; lower it to pull the candles in.')
i_p3_gap = input.int(7, 'Spacing (bars)', minval = 3, maxval = 60, group = g_p3, display = display.none)
i_p3_w = input.int(2, 'Body width (bars)', minval = 1, maxval = 20, group = g_p3, display = display.none)
i_p3_lbl = input.bool(true, 'Candle labels', group = g_p3, display = display.none)
col_p3t = input.color(color.new(#d1d4dc, 0), '   Label colour', group = g_p3, inline = 'p3t', display = display.none)
i_p3_ts = input.string('Tiny', 'size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g_p3, inline = 'p3t', display = display.none)
i_gh = input.bool(true, 'Ghost range on today\'s candle', group = g_p3, display = display.none, tooltip = 'Faint box behind today\'s candle showing where the day could still reach within its budget. Shrinks as the day uses its range; gone when the budget is spent.')
i_gh_basis = input.string('Match Room', '   Ghost budget from', options = ['Match Room', 'VIX implied', 'VIX adjusted'], group = g_p3, display = display.none, tooltip = 'Match Room uses the same budget as the Room row, so the ghost edges equal the projections. VIX implied is the raw expected move; VIX adjusted corrects it by how much VIX has over-priced days on this chart. Falls back to Match Room when unavailable.')
i_gh_ticks = input.bool(true, '   Mark reachable levels on the ghost', group = g_p3, display = display.none, tooltip = 'Ticks across the ghost candle at each wall and unbroken DOL level inside today\'s remaining reach. Levels outside the ghost are beyond the budget.')
i_gh_tlbl = input.bool(true, '   Tick names', group = g_p3, display = display.none)
i_gh_scale = input.bool(true, '   Point scale on the ghost', group = g_p3, display = display.none, tooltip = 'Ticks every N points from the zero line to the ghost edges, labelled on the left. Zero at current price reads as points from here - useful for placing a stop or target.')
i_gh_zero = input.string('Current price', '   Scale zero at', options = ['Current price', 'Today\'s open'], group = g_p3, display = display.none)
i_gh_step = input.float(10.0, '   Scale step (points)', minval = 0.25, maxval = 500, step = 0.25, group = g_p3, display = display.none)
i_grp_lbl = input.bool(true, 'Column headings (DAILY / WEEKLY / MONTHLY)', group = g_p3, display = display.none, tooltip = 'Centred above each group of candles. Each heading follows its own column, so it stays centred when the candle count, spacing or ruler clearance changes.')
i_grp_br = input.bool(false, '  Bracket line over each group', group = g_p3, display = display.none, tooltip = 'Spans the group from its first candle to the current one, with the heading on it. Marks the group boundaries directly, which spacing alone cannot once each column carries a ruler lane inside it.')
i_tnclr = input.int(12, '   Gap for ghost level names (bars)', minval = 0, maxval = 80, group = g_p3, display = display.none, tooltip = 'The daily ghost prints its level names to the right. The weekly column starts this far clear of them. Raise it if a long name such as 4hL CW.30/PW.30 still reaches the weekly candles; it only applies while those names are drawn.')
i_rside = input.string('Right', '   Ruler side', options = ['Right', 'Left'], group = g_p3, display = display.none, tooltip = 'Which side of the current candle the point scale prints on. The daily ghost\'s level names always take the other side, so the two never collide.')
i_rclr = input.int(8, '   Ruler clearance (bars)', minval = 0, maxval = 60, group = g_p3, display = display.none, tooltip = 'Width of the lane kept clear for the ruler labels. With the ruler on the right that lane sits between a column and the next one; on the left it sits between the last two candles of the column.')
col_gh = input.color(color.new(#b2b5be, 85), '   Ghost fill', group = g_p3, inline = 'gh', display = display.none)
col_ghb = input.color(color.new(#b2b5be, 35), 'border', group = g_p3, inline = 'gh', display = display.none)
col_p3u = input.color(color.new(#26a69a, 0), 'Up', group = g_p3, inline = 'p3', display = display.none)
col_p3d = input.color(color.new(#ef5350, 0), 'Down', group = g_p3, inline = 'p3', display = display.none)
col_p3o = input.color(color.new(#787b86, 0), 'Open tick', group = g_p3, inline = 'p3', display = display.none)

g_x = 'Display'
i_draw_lvls = input.bool(true, 'Draw key levels', group = g_x, tooltip = 'Turn off when Sphinx DOL+G is on the same chart. Key zones and inducement still draw.', display = display.none)
i_draw_prj = input.bool(false, 'Draw budget projections', group = g_x, display = display.none)
i_back = input.int(40, 'Zone length back (bars)', minval = 5, maxval = 500, group = g_x, display = display.none)
i_pad = input.int(12, 'Right offset (bars)', minval = 0, maxval = 100, group = g_x, display = display.none)
i_stagger = input.int(10, 'Label stagger (bars)', minval = 0, maxval = 60, group = g_x, display = display.none)
col_dol = input.color(color.new(#787b86, 0), 'DOL', group = g_x, inline = 'x1', display = display.none)
col_cw = input.color(color.new(#ef5350, 0), 'CW', group = g_x, inline = 'x1', display = display.none)
col_pw = input.color(color.new(#26a69a, 0), 'PW', group = g_x, inline = 'x1', display = display.none)
col_flip = input.color(color.new(#ffd54f, 0), 'Flip', group = g_x, inline = 'x2', display = display.none)
col_prj = input.color(color.new(#f57c00, 0), 'Projection', group = g_x, inline = 'x2', display = display.none)
col_zone = input.color(color.new(#ffb300, 80), 'Key zone', group = g_x, inline = 'x3', display = display.none)
col_ind = input.color(color.new(#ab47bc, 72), 'Inducement', group = g_x, inline = 'x3', display = display.none)
col_tw = input.color(color.new(#42a5f5, 75), 'Two-way', group = g_x, inline = 'x3', display = display.none)
i_pos = input.string('Top Right', 'Panel position', options = ['Top Right', 'Top Left', 'Middle Right', 'Bottom Right', 'Bottom Left'], group = g_x, display = display.none)
i_compact = input.bool(true, 'Compact panel', group = g_x, display = display.none, tooltip = 'Hides Avg day, Forecast check, the VIX term-structure row and Box reach.')
i_txt = input.string('Small', 'Panel text', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g_x, display = display.none)
col_tblbl = input.color(color.new(color.gray, 0), 'Panel text', group = g_x, inline = 'ttx', display = display.none, tooltip = 'Row labels and section headings across all three panels.')
col_tbval = input.color(color.new(color.gray, 0), 'neutral value', group = g_x, inline = 'ttx', display = display.none, tooltip = 'A value with no state to report. Values that are signalling exhausted, caution or available keep their state colour, which is set in the Range Budget and Display groups - a state colour overridden here would make the panel read wrong.')
col_tbbg = input.color(color.new(#131722, 70), 'Panel background', group = g_x, inline = 'tbg', display = display.none, tooltip = 'Applies to all three panels. Raise the opacity to read over a busy chart; the default is near-transparent, as before.')
col_tbfr = input.color(color.new(#787b86, 75), 'frame', group = g_x, inline = 'tbg', display = display.none)
i_tbfr_w = input.int(1, 'width', minval = 0, maxval = 4, group = g_x, inline = 'tbg', display = display.none)

// ============================================================
// === HELPERS ===
// ============================================================
f0(x) =>
    na(x) ? '-' : str.tostring(x, '#')
f2(x) =>
    na(x) ? '-' : str.tostring(x, '#.##')
fp(x) =>
    na(x) ? '-' : str.tostring(x, format.mintick)

gauge(p) =>
    n = math.min(10, math.max(0, math.round(nz(p) / 10)))
    s = ''
    for i = 0 to 9 by 1
        s := s + (i < n ? '█' : '░')
    s

_dkey(t) =>
    year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)

_rSide = i_rside == 'Right'
_txtsz = i_txt == 'Tiny' ? size.tiny : i_txt == 'Normal' ? size.normal : i_txt == 'Large' ? size.large : size.small
_tbpos = i_pos == 'Top Left' ? position.top_left : i_pos == 'Middle Right' ? position.middle_right : i_pos == 'Bottom Right' ? position.bottom_right : i_pos == 'Bottom Left' ? position.bottom_left : position.top_right

c_red = color.new(#ef5350, 0)
c_amb = color.new(#f9a825, 0)
c_grn = color.new(#26a69a, 0)
c_org = color.new(#ff7043, 0)
c_gry = color.new(#787b86, 0)

// ============================================================
// === SYMBOL & VOLATILITY SOURCE ===
// ============================================================
_tk = syminfo.ticker
chartSym = str.contains(_tk, 'RTY') or str.contains(_tk, 'M2K') ? 'RTY' : str.contains(_tk, 'NQ') ? 'NQ' : str.contains(_tk, 'GC') ? 'GC' : str.contains(_tk, 'ES') ? 'ES' : ''
_autoVol = chartSym == 'NQ' ? 'CBOE:VXN' : chartSym == 'RTY' ? 'CBOE:RVX' : chartSym == 'GC' ? 'CBOE:GVZ' : i_vix_es == 'VIX1D' ? 'CBOE:VIX1D' : 'CBOE:VIX'
volSym = i_vix_sym != '' ? i_vix_sym : _autoVol
volName = str.replace_all(volSym, 'CBOE:', '')

// Requested on the chart timeframe with gaps off, so a chart bar with
// no index print carries the last one. At 18:00 that is the prior
// session close. ignore_invalid_symbol keeps the script running for
// users without access to an index.
_rv = request.security(volSym, timeframe.period, close, ignore_invalid_symbol = true)
_rvix = request.security('CBOE:VIX', timeframe.period, close, ignore_invalid_symbol = true)
_r9d = request.security('CBOE:VIX9D', timeframe.period, close, ignore_invalid_symbol = true)
_rvvix = request.security('CBOE:VVIX', timeframe.period, close, ignore_invalid_symbol = true)
vm = i_vix_on ? _rv : float(na)
vx = i_vix_on ? _rvix : float(na)
v9 = i_vix_on ? _r9d : float(na)
vvx = i_vix_on ? _rvvix : float(na)

// ============================================================
// === DAILY DATA ===
// ============================================================
atr_d = request.security(syminfo.tickerid, 'D', ta.atr(14)[1], lookahead = barmerge.lookahead_on)
atrD = na(atr_d) ? ta.atr(14) * 3 : atr_d

_drF() =>
    _r = high - low
    [ta.sma(_r, i_len)[1], ta.percentile_nearest_rank(_r, i_len, 50)[1], ta.ema(_r, i_len)[1]]
[dr_mean, dr_med, dr_ema] = request.security(syminfo.tickerid, 'D', _drF(), lookahead = barmerge.lookahead_on)

// Weekly range statistic. Same [1] offset discipline as the daily
// one, so the forming week never enters its own benchmark and the
// denominator is constant through the week.
_wrF() =>
    _r = high - low
    [ta.sma(_r, i_wk_len)[1], ta.percentile_nearest_rank(_r, i_wk_len, 50)[1], ta.ema(_r, i_wk_len)[1]]
[wr_mean, wr_med, wr_ema] = request.security(syminfo.tickerid, 'W', _wrF(), lookahead = barmerge.lookahead_on)

// Monthly range statistic, same [1] offset discipline again.
_mrF() =>
    _r = high - low
    [ta.sma(_r, i_mo_len)[1], ta.percentile_nearest_rank(_r, i_mo_len, 50)[1], ta.ema(_r, i_mo_len)[1]]
[mr_mean, mr_med, mr_ema] = request.security(syminfo.tickerid, 'M', _mrF(), lookahead = barmerge.lookahead_on)

[pdh, pdl] = request.security(syminfo.tickerid, 'D', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h4h, h4l] = request.security(syminfo.tickerid, '240', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', [high[1], low[1]], lookahead = barmerge.lookahead_on)

// Visible price range, for exposure bar height. Moves with zoom and
// scroll, so the bars keep the same visual weight at any scale.
_tfms = timeframe.in_seconds() * 1000
_visN = _tfms > 0 ? math.max(10, math.min(2000, int((chart.right_visible_bar_time - chart.left_visible_bar_time) / _tfms))) : 300
_visRange = ta.highest(high, _visN) - ta.lowest(low, _visN)

// ============================================================
// === ANCHOR 18:00 NY ===
// ============================================================
_mod = hour(time, TZ) * 60 + minute(time, TZ)
mins_since = _mod >= 1080 ? _mod - 1080 : _mod + 360
gap_reset = time - time[1] > 43200000
new_anchor = barstate.isfirst or mins_since < nz(mins_since[1], 100000) or gap_reset

var float a_px = na
var float a_hi = na
var float a_lo = na
var int a_bar = na
var int a_time = na

// Completed 18:00-to-18:00 days for the Power of 3 candles. Captured
// here, before the anchor values below are reset for the new day.
var float p1o = na
var float p1h = na
var float p1l = na
var float p1c = na
var float p2o = na
var float p2h = na
var float p2l = na
var float p2c = na
// Calibration history. dayImpl / dayDR hold the previous bar's values
// here, because they are updated further down, after the budget is
// computed - so on the first bar of a new day they still describe
// the day that just ended.
var float dayImpl = na
var float dayDR = na
var array<float> hAct = array.new_float()
var array<float> hImp = array.new_float()
var array<float> hDR = array.new_float()
var float calHi = na
var float calLo = na
var float calOver = na
var float calErrDR = na
var float calErrIV = na
var int calN = 0
if new_anchor and not na(a_px) and a_hi - a_lo > 0
    array.push(hAct, a_hi - a_lo)
    array.push(hImp, nz(dayImpl, -1.0))
    array.push(hDR, nz(dayDR, -1.0))
    while array.size(hAct) > i_cal_n
        array.shift(hAct)
        array.shift(hImp)
        array.shift(hDR)
    _rIV = array.new_float()
    _rOv = array.new_float()
    float _eD = 0.0
    int _nD = 0
    float _eI = 0.0
    int _nI = 0
    for _k = 0 to array.size(hAct) - 1 by 1
        float _act = array.get(hAct, _k)
        float _imp = array.get(hImp, _k)
        float _drk = array.get(hDR, _k)
        if _drk > 0
            _eD += math.abs(_drk - _act) / _act
            _nD += 1
        if _imp > 0
            _eI += math.abs(_imp - _act) / _act
            _nI += 1
            array.push(_rOv, _imp / _act)
            if _drk > 0
                array.push(_rIV, _imp / _drk)
    calN := array.size(_rIV)
    calErrDR := _nD > 0 ? _eD / _nD * 100.0 : float(na)
    calErrIV := _nI > 0 ? _eI / _nI * 100.0 : float(na)
    calOver := array.size(_rOv) > 0 ? array.median(_rOv) : float(na)
    calHi := calN > 0 ? array.percentile_nearest_rank(_rIV, i_cal_hi) : float(na)
    calLo := calN > 0 ? array.percentile_nearest_rank(_rIV, i_cal_lo) : float(na)

if new_anchor and not na(a_px)
    p2o := p1o
    p2h := p1h
    p2l := p1l
    p2c := p1c
    p1o := a_px
    p1h := a_hi
    p1l := a_lo
    p1c := close[1]

if new_anchor
    a_px := open
    a_hi := high
    a_lo := low
    a_bar := bar_index
    a_time := time
else
    a_hi := na(a_hi) ? high : math.max(a_hi, high)
    a_lo := na(a_lo) ? low : math.min(a_lo, low)

// Volatility locked at the anchor. Late-filled only if the index had
// no value at the anchor bar (start of chart history).
var float v_lock = na
var float vvix_lock = na
if new_anchor
    v_lock := vm
    vvix_lock := vvx
else
    if na(v_lock)
        v_lock := vm
    if na(vvix_lock)
        vvix_lock := vvx

// ============================================================
// === BUDGET ===
// ============================================================
adr_auto = i_method == 'Mean (SMA)' ? dr_mean : i_method == 'EMA' ? dr_ema : dr_med
adr = i_manual > 0 ? i_manual : adr_auto
impl = not na(v_lock) and v_lock > 0 and not na(a_px) ? v_lock / 100.0 / math.sqrt(252) * a_px : float(na)
day_rng = a_hi - a_lo
_drOk = not na(adr) and adr > 0
_ivOk = not na(impl) and impl > 0
pct_used = _drOk ? day_rng / adr * 100.0 : float(na)
pct_iv = _ivOk ? day_rng / impl * 100.0 : float(na)
iv_ratio = _drOk and _ivOk ? impl / adr : float(na)

_budRaw = i_room == 'Implied (VIX)' ? impl : i_room == 'Larger of the two' ? (_ivOk and _drOk ? math.max(impl, adr) : _drOk ? adr : impl) : adr
bud = not na(_budRaw) and _budRaw > 0 ? _budRaw : _drOk ? adr : float(na)
budTag = _ivOk and bud == impl ? 'IV' : 'DR'
dayImpl := impl
dayDR := adr
calReady = i_cal_mode == 'Auto (calibrated)' and calN >= i_cal_min
irHi = calReady ? calHi : i_ir_hi
irLo = calReady ? calLo : i_ir_lo
implAdj = _ivOk and not na(calOver) and calOver > 0 and calN >= i_cal_min ? impl / calOver : float(na)

proj_hi = na(bud) ? float(na) : a_lo + bud
proj_lo = na(bud) ? float(na) : a_hi - bud
rem_up = proj_hi - close
rem_dn = close - proj_lo

// ============================================================
// === WEEKLY BUDGET  (anchor Sunday 18:00 NY) ===
// The week open is tracked from the clock, not read off the weekly
// bar: TradingView's weekly boundary for CME futures does not
// reliably land on the Sunday reopen, and the extension reading has
// to start where the week actually started.
// ============================================================
_dow = dayofweek(time, TZ)
// Minutes since the Sunday 18:00 open. Sunday evening belongs to the
// new week; a Sunday bar before 18:00 is the tail of the old one.
_wmins = _dow == 1 and _mod >= 1080 ? _mod - 1080 : _dow == 1 ? 6 * 1440 + _mod + 360 : (_dow - 2) * 1440 + _mod + 360
// A decrease means the week rolled. This also covers a holiday
// Sunday: the count keeps rising through the closure and resets at
// whichever session opens next.
new_week = barstate.isfirst or _wmins < nz(_wmins[1], 1000000)

// Trading day within the week, 0 Monday to 4 Friday. Each CME day
// runs 18:00 to 18:00, so Sunday evening is part of Monday.
_wdIdx = math.min(4, math.max(0, int(_wmins / 1440)))

var float w_px = na
var float w_hi = na
var float w_lo = na
var array<float> wExt = array.new_float(5, 0.0)
var float wrun_hi = na
var float wrun_lo = na

// Completed Sunday-to-Sunday weeks for the weekly Power of 3
// candles. Captured here, before the values below are reset, so the
// pair always describes weeks that have finished.
var float q1o = na
var float q1h = na
var float q1l = na
var float q1c = na
var float q2o = na
var float q2h = na
var float q2l = na
var float q2c = na
if new_week and not na(w_px)
    q2o := q1o
    q2h := q1h
    q2l := q1l
    q2c := q1c
    q1o := w_px
    q1h := w_hi
    q1l := w_lo
    q1c := close[1]

if new_week
    w_px := open
    w_hi := high
    w_lo := low
    wrun_hi := high
    wrun_lo := low
    for _i = 0 to 4 by 1
        array.set(wExt, _i, 0.0)
    array.set(wExt, _wdIdx, high - low)
else
    w_hi := na(w_hi) ? high : math.max(w_hi, high)
    w_lo := na(w_lo) ? low : math.min(w_lo, low)
    // Contribution is the amount by which this bar pushed the running
    // week high or low outward. A bar trading entirely inside the
    // range built so far adds nothing, which is the point.
    float _wup = math.max(0.0, high - nz(wrun_hi, high))
    float _wdn = math.max(0.0, nz(wrun_lo, low) - low)
    array.set(wExt, _wdIdx, array.get(wExt, _wdIdx) + _wup + _wdn)
    wrun_hi := na(wrun_hi) ? high : math.max(wrun_hi, high)
    wrun_lo := na(wrun_lo) ? low : math.min(wrun_lo, low)

wadr_auto = i_method == 'Mean (SMA)' ? wr_mean : i_method == 'EMA' ? wr_ema : wr_med
wadr = i_wk_manual > 0 ? i_wk_manual : wadr_auto
w_rng = w_hi - w_lo
_wkOk = not na(wadr) and wadr > 0
w_pct = _wkOk ? w_rng / wadr * 100.0 : float(na)
w_proj_hi = _wkOk ? w_lo + wadr : float(na)
w_proj_lo = _wkOk ? w_hi - wadr : float(na)
w_rem_up = w_proj_hi - close
w_rem_dn = close - w_proj_lo
w_ext = close - w_px

// Day contribution formatted for the panel, current day marked.
// Declared at global scope - Pine only permits function declarations
// at the top level.
_wf(i) =>
    f0(array.get(wExt, i)) + (i == _wdIdx ? '*' : '')

// ============================================================
// === MONTHLY BUDGET ===
// The month rolls at the first 18:00 open that belongs to a new
// calendar month. Adding six hours pushes an 18:00 bar into the
// following calendar day, which is the trading day it belongs to, so
// the Globex session opening on the evening of the last day of a
// month is already the new month's first trading day.
// ============================================================
_tdm = month(time + 21600000, TZ)
new_month = barstate.isfirst or (new_anchor and _tdm != _tdm[1])

var float m_px = na
var float m_hi = na
var float m_lo = na
var int m_days = 0

// Completed months for the monthly Power of 3 candles, captured
// before the values below are reset.
var float n1o = na
var float n1h = na
var float n1l = na
var float n1c = na
var float n2o = na
var float n2h = na
var float n2l = na
var float n2c = na
if new_month and not na(m_px)
    n2o := n1o
    n2h := n1h
    n2l := n1l
    n2c := n1c
    n1o := m_px
    n1h := m_hi
    n1l := m_lo
    n1c := close[1]

if new_month
    m_px := open
    m_hi := high
    m_lo := low
    m_days := 1
else
    m_hi := na(m_hi) ? high : math.max(m_hi, high)
    m_lo := na(m_lo) ? low : math.min(m_lo, low)
    if new_anchor
        m_days += 1

madr_auto = i_method == 'Mean (SMA)' ? mr_mean : i_method == 'EMA' ? mr_ema : mr_med
madr = i_mo_manual > 0 ? i_mo_manual : madr_auto
m_rng = m_hi - m_lo
_moOk = not na(madr) and madr > 0
m_pct = _moOk ? m_rng / madr * 100.0 : float(na)
m_proj_hi = _moOk ? m_lo + madr : float(na)
m_proj_lo = _moOk ? m_hi - madr : float(na)
m_rem_up = m_proj_hi - close
m_rem_dn = close - m_proj_lo

// ============================================================
// === VOLATILITY READ ===
// ============================================================
ts9 = not na(v9) and not na(vx) and vx > 0 ? v9 / vx : float(na)
tsTxt = na(ts9) ? '-' : ts9 >= i_ts_back ? 'BACKWARD' : ts9 <= i_ts_cont ? 'CONTANGO' : 'FLAT'
vvChg = not na(vvx) and not na(vvix_lock) and vvix_lock > 0 ? (vvx / vvix_lock - 1.0) * 100.0 : float(na)
vvSpike = not na(vvChg) and vvChg >= i_vvix_spk

// -1 trend lean: short-dated fear above 30-day, a bigger day priced
//    than recent days have delivered, or VVIX spiking.
// +1 range lean: a quieter day priced than recent days, or contango
//    with implied not above historical.
bool _volTrend = (not na(ts9) and ts9 >= i_ts_back) or (not na(iv_ratio) and iv_ratio >= irHi) or vvSpike
bool _volRange = (not na(iv_ratio) and iv_ratio <= irLo) or (not na(ts9) and ts9 <= i_ts_cont and (na(iv_ratio) or iv_ratio < 1.0))
volLean = _volTrend ? -1 : _volRange ? 1 : 0

// ============================================================
// === DOL STATE  (2 naked / 1 swept / 0 broken) ===
// ============================================================
_ccl = barstate.isconfirmed ? close : close[1]
// v1.2.1: a level breaks as soon as price is trading beyond it - live
// price on the realtime bar, not the last confirmed close. Realtime var
// state is re-evaluated each tick from the last committed bar, so a
// wick through that returns inside before the close ends as a sweep.
_stH(lvl, st) =>
    na(lvl) ? st : close > lvl ? 0 : high >= lvl ? math.min(st, 1) : st
_stL(lvl, st) =>
    na(lvl) ? st : close < lvl ? 0 : low <= lvl ? math.min(st, 1) : st

in_asia = _mod >= 1080 or _mod < 180
in_lon = _mod >= 180 and _mod < 510

var float asH = na
var float asL = na
var float asH_p = na
var float asL_p = na
var float loH = na
var float loL = na
var float loH_p = na
var float loL_p = na
var int s_asH = 2
var int s_asL = 2
var int s_loH = 2
var int s_loL = 2
var int s_pdh = 2
var int s_pdl = 2
var int s_h4h = 2
var int s_h4l = 2
var int s_pwh = 2
var int s_pwl = 2

if in_asia and not in_asia[1]
    asH := high
    asL := low
else if in_asia
    asH := na(asH) ? high : math.max(asH, high)
    asL := na(asL) ? low : math.min(asL, low)
if not in_asia and in_asia[1]
    asH_p := asH
    asL_p := asL
    s_asH := 2
    s_asL := 2

if in_lon and not in_lon[1]
    loH := high
    loL := low
else if in_lon
    loH := na(loH) ? high : math.max(loH, high)
    loL := na(loL) ? low : math.min(loL, low)
if not in_lon and in_lon[1]
    loH_p := loH
    loL_p := loL
    s_loH := 2
    s_loL := 2

newDay = ta.change(time('D')) != 0
newWk = ta.change(time('W')) != 0
new4h = ta.change(time('240')) != 0
if newDay
    s_pdh := 2
    s_pdl := 2
if newWk
    s_pwh := 2
    s_pwl := 2
if new4h
    s_h4h := 2
    s_h4l := 2

s_pdh := _stH(pdh, s_pdh)
s_pdl := _stL(pdl, s_pdl)
s_pwh := _stH(pwh, s_pwh)
s_pwl := _stL(pwl, s_pwl)
s_h4h := _stH(h4h, s_h4h)
s_h4l := _stL(h4l, s_h4l)
s_asH := _stH(asH_p, s_asH)
s_asL := _stL(asL_p, s_asL)
s_loH := _stH(loH_p, s_loH)
s_loL := _stL(loL_p, s_loL)

// ---------- 1H swings ----------
// [1] with lookahead_on returns the last CLOSED 1H bar's result, so a
// swing appears only after its confirming bars have closed.
_swOk = i_sw and timeframe.in_seconds() <= 3600
_swF() =>
    int _lb = ta.lowestbars(low, i_sw_str + 1)
    int _hb = ta.highestbars(high, i_sw_str + 1)
    [ta.pivothigh(high, i_sw_str, i_sw_str)[1], ta.pivotlow(low, i_sw_str, i_sw_str)[1], time[i_sw_str + 1], ta.lowest(low, i_sw_str + 1)[1], ta.highest(high, i_sw_str + 1)[1], time[1 - nz(_lb[1])], time[1 - nz(_hb[1])]]
[swPH, swPL, swT, swRLo, swRHi, swRLoT, swRHiT] = request.security(syminfo.tickerid, '60', _swF(), lookahead = barmerge.lookahead_on)
new1h = ta.change(time('60')) != 0
var array<float> swHP = array.new_float()
var array<int> swHS = array.new_int()
var array<int> swHT = array.new_int()
var array<float> swLP = array.new_float()
var array<int> swLS = array.new_int()
var array<int> swLT = array.new_int()
// leg extremes for structure re-anchoring (primary mode)
swPrim = i_sw_mode == 'Primary (structure)'
var float legLo = na
var int legLoT = na
var float legHi = na
var int legHiT = na
if _swOk and new1h
    if not na(swPH) and (i_sw_mode == 'All pivots' or array.size(swHP) == 0)
        array.push(swHP, swPH)
        array.push(swHS, 2)
        array.push(swHT, swT)
        legLo := swRLo
        legLoT := swRLoT
        while array.size(swHP) > i_sw_max
            array.shift(swHP)
            array.shift(swHS)
            array.shift(swHT)
    if not na(swPL) and (i_sw_mode == 'All pivots' or array.size(swLP) == 0)
        array.push(swLP, swPL)
        array.push(swLS, 2)
        array.push(swLT, swT)
        legHi := swRHi
        legHiT := swRHiT
        while array.size(swLP) > i_sw_max
            array.shift(swLP)
            array.shift(swLS)
            array.shift(swLT)
float evSwH = na
float evSwL = na
// track the leg extremes since each active swing formed
if _swOk and swPrim
    if array.size(swHP) > 0 and (na(legLo) or low < legLo)
        legLo := low
        legLoT := time
    if array.size(swLP) > 0 and (na(legHi) or high > legHi)
        legHi := high
        legHiT := time
bool brkH = false
bool brkL = false
if _swOk and array.size(swHP) > 0
    for _k = array.size(swHP) - 1 to 0
        int _st = _stH(array.get(swHP, _k), array.get(swHS, _k))
        if array.get(swHS, _k) == 2 and _st < 2
            float _lv = array.get(swHP, _k)
            evSwH := na(evSwH) ? _lv : math.max(evSwH, _lv)
        if (_st == 0 and i_hide_broken) or (i_sw_wick and _st <= 1)
            array.remove(swHP, _k)
            array.remove(swHS, _k)
            array.remove(swHT, _k)
            brkH := true
        else
            array.set(swHS, _k, _st)
if _swOk and array.size(swLP) > 0
    for _k = array.size(swLP) - 1 to 0
        int _st = _stL(array.get(swLP, _k), array.get(swLS, _k))
        if array.get(swLS, _k) == 2 and _st < 2
            float _lv = array.get(swLP, _k)
            evSwL := na(evSwL) ? _lv : math.min(evSwL, _lv)
        if (_st == 0 and i_hide_broken) or (i_sw_wick and _st <= 1)
            array.remove(swLP, _k)
            array.remove(swLS, _k)
            array.remove(swLT, _k)
            brkL := true
        else
            array.set(swLS, _k, _st)
// structure re-anchor: a broken swing hands the opposite side the
// extreme of the leg that broke it
if _swOk and swPrim
    float _nL = brkH ? legLo : float(na)
    int _nLT = legLoT
    float _nH = brkL ? legHi : float(na)
    int _nHT = legHiT
    if not na(_nL) and _nL <= low
        array.clear(swLP)
        array.clear(swLS)
        array.clear(swLT)
        array.push(swLP, _nL)
        array.push(swLS, 2)
        array.push(swLT, _nLT)
        legHi := high
        legHiT := time
    if not na(_nH) and _nH >= high
        array.clear(swHP)
        array.clear(swHS)
        array.clear(swHT)
        array.push(swHP, _nH)
        array.push(swHS, 2)
        array.push(swHT, _nHT)
        legLo := low
        legLoT := time
    if brkH and array.size(swHP) == 0
        legLo := na
    if brkL and array.size(swLP) == 0
        legHi := na

// ============================================================
// === GAMMA PARSE  (once; the string is an input) ===
//   Split on the FIRST colon only, fields identified by prefix.
//   Same rules as DOL+G v2.12.1 onward.
// ============================================================
var array<float> gP = array.new_float()
var array<bool> gC = array.new_bool()
var array<float> gR = array.new_float()
var array<string> gN = array.new_string()
var array<string> gD = array.new_string()
var array<float> gO = array.new_float()
var float g_flip = na
var float g_net = na
var float g_T = na

_inlineMax(arr) =>
    float _mx = 0.0
    int _n = array.size(arr)
    if _n > 0
        for _i = 0 to _n - 1 by 1
            _tt = str.split(array.get(arr, _i), ':')
            if array.size(_tt) >= 2
                _m = str.tonumber(array.get(_tt, 1))
                if not na(_m)
                    _mx := math.max(_mx, math.abs(_m))
    _mx

if barstate.isfirst and i_gex_on and chartSym != '' and str.length(i_gstr) > 0
    _segs = str.split(str.replace_all(i_gstr, ' ', ''), ';')
    int _ns = array.size(_segs)
    if _ns > 0
        for _si = 0 to _ns - 1 by 1
            string _seg = array.get(_segs, _si)
            _cix = str.pos(_seg, ':')
            if not na(_cix) and _cix > 0
                string _head = str.substring(_seg, 0, _cix)
                string _body = str.substring(_seg, _cix + 1)
                _dpr = str.split(_head, '.')
                if array.size(_dpr) >= 2
                    if array.get(_dpr, 0) == chartSym
                        string _dte = array.get(_dpr, 1)
                        _ppr = str.split(_body, '|')
                        string _cwp = ''
                        string _pwp = ''
                        float _flp = na
                        float _nt = na
                        int _nf = array.size(_ppr)
                        if _nf > 0
                            for _fi = 0 to _nf - 1 by 1
                                string _fld = array.get(_ppr, _fi)
                                if str.startswith(_fld, 'CW')
                                    _cwp := _fld
                                else if str.startswith(_fld, 'PW')
                                    _pwp := _fld
                                else if str.startswith(_fld, 'N')
                                    _nv = str.split(str.substring(_fld, 1), ',')
                                    if array.size(_nv) >= 1
                                        _nt := str.tonumber(array.get(_nv, 0))
                                else if str.startswith(_fld, 'F')
                                    _flp := str.tonumber(str.substring(_fld, 1))
                                else if str.startswith(_fld, 'T')
                                    float _tv = str.tonumber(str.substring(_fld, 1))
                                    if not na(_tv)
                                        _tv := _tv > 100000000000 ? _tv : _tv * 1000
                                        g_T := na(g_T) ? _tv : math.max(g_T, _tv)
                        if _dte == '0'
                            g_flip := _flp
                            g_net := _nt
                        bool _on = _dte == '0' and i_dte0 or _dte == '7' and i_dte7 or _dte == '30' and i_dte30
                        if _on
                            for _side = 0 to 1 by 1
                                string _txt = _side == 0 ? _cwp : _pwp
                                if str.length(_txt) > 2
                                    _arr = str.split(str.substring(_txt, 2), ',')
                                    float _mx = _inlineMax(_arr)
                                    int _nw = array.size(_arr)
                                    if _nw > 0
                                        for _wi = 0 to _nw - 1 by 1
                                            _tok = str.split(array.get(_arr, _wi), ':')
                                            float _v = str.tonumber(array.get(_tok, 0))
                                            float _inl = array.size(_tok) >= 2 ? str.tonumber(array.get(_tok, 1)) : float(na)
                                            float _mw = not na(_inl) and _mx > 0 ? math.abs(_inl) / _mx : float(na)
                                            if not na(_v) and (_wi < i_max_rank or not na(_mw) and _mw >= i_mag_keep)
                                                array.push(gP, _v)
                                                array.push(gC, _side == 0)
                                                array.push(gR, na(_inl) ? 0.0 : math.abs(_inl))
                                                array.push(gN, (_side == 0 ? 'CW.' : 'PW.') + _dte)
                                                array.push(gD, _dte)
                                                array.push(gO, array.size(_tok) >= 3 ? nz(str.tonumber(array.get(_tok, 2))) : 0.0)

// Manual walls: appended once, after the string. Board 'M' never expires.
if barstate.isfirst and i_gex_on and i_mw
    _mwP = array.from(i_cw1, i_cw2, i_cw3, i_pw1, i_pw2, i_pw3)
    _mwS = array.from(i_cw1m, i_cw2m, i_cw3m, i_pw1m, i_pw2m, i_pw3m)
    for _k = 0 to 5 by 1
        float _v = array.get(_mwP, _k)
        if _v > 0
            array.push(gP, _v)
            array.push(gC, _k < 3)
            array.push(gR, math.abs(array.get(_mwS, _k)))
            array.push(gN, (_k < 3 ? 'CW' : 'PW') + '.M')
            array.push(gD, 'M')
            array.push(gO, 0.0)

// ============================================================
// === REGIME ===
//   Gamma when available (net GEX, else flip, on a closing basis).
//   Otherwise the volatility lean, labelled so it is never read as
//   a dealer-positioning claim.
// ============================================================
// Staleness: the string is dated by its T field, else by the input.
// A string from before the current 18:00 open carries an expired 0DTE
// board. Only evaluated where the string can actually be stale - the
// bars after it was exported.
float gDate = not na(g_T) ? g_T : i_gdate > timestamp('02 Jan 2000 00:00 +0000') ? float(i_gdate) : float(na)
gStale = i_gex_on and str.length(i_gstr) > 0 and not na(gDate) and not na(a_time) and gDate < a_time
_flipEff = gStale ? float(na) : g_flip
_netRaw = gStale ? float(na) : g_net
_netEff = not na(_netRaw) ? _netRaw : i_netgex != 0 and not gStale ? i_netgex : float(na)
_regFlip = na(_flipEff) ? 0 : _ccl > _flipEff ? 1 : -1
_regNet = na(_netEff) or _netEff == 0 ? 0 : _netEff > 0 ? 1 : -1
_useNet = i_reg_src == 'Net GEX' or i_reg_src == 'Auto' and _regNet != 0
_gexSig = not i_gex_on ? 0 : _useNet ? _regNet : _regFlip
regFromGex = _gexSig != 0
regSig = regFromGex ? _gexSig : volLean
regSrc = regFromGex ? (_useNet ? 'net' : 'flip') : 'vol'
regTxt = regFromGex ? (regSig == 1 ? 'Calm - dealers dampen moves' : 'Fast - dealers amplify moves') : regSig == 1 ? 'Range day lean' : regSig == -1 ? 'Trend day lean' : 'Neutral'
// Net exposure and flip side disagree: same flag as DOL+G.
regSplit = regFromGex and _regNet != 0 and _regFlip != 0 and _regNet != _regFlip
_liveW = 0
if array.size(gP) > 0
    for _gi = 0 to array.size(gP) - 1 by 1
        if not (gStale and array.get(gD, _gi) == '0')
            _liveW += 1
gexLive = i_gex_on and _liveW > 0
prjCounts = not gexLive or i_prj_conf

// ============================================================
// === ENTRY CHECKLIST ENGINE (every bar, so alerts work) ===
// ============================================================
// Long side tracks swing-low sweeps, short side swing-high sweeps.
var float eL_lvl = na
var float eL_ext = na
var int eL_bar = na
var int eL_rejT = na
var float eS_lvl = na
var float eS_ext = na
var int eS_bar = na
var int eS_rejT = na

if not na(evSwL)
    eL_lvl := evSwL
    eL_ext := low
    eL_bar := bar_index
    eL_rejT := na
else if not na(eL_lvl)
    if low < eL_ext
        if not na(eL_rejT)
            eL_lvl := na
            eL_rejT := na
        else
            eL_ext := low
if not na(eL_lvl) and na(eL_rejT) and barstate.isconfirmed
    if close > eL_lvl
        eL_rejT := time_close
    else if bar_index - eL_bar >= i_r1_rej
        eL_lvl := na
if not na(eL_rejT) and time - eL_rejT > i_r1_val * 60000
    eL_lvl := na
    eL_rejT := na

if not na(evSwH)
    eS_lvl := evSwH
    eS_ext := high
    eS_bar := bar_index
    eS_rejT := na
else if not na(eS_lvl)
    if high > eS_ext
        if not na(eS_rejT)
            eS_lvl := na
            eS_rejT := na
        else
            eS_ext := high
if not na(eS_lvl) and na(eS_rejT) and barstate.isconfirmed
    if close < eS_lvl
        eS_rejT := time_close
    else if bar_index - eS_bar >= i_r1_rej
        eS_lvl := na
if not na(eS_rejT) and time - eS_rejT > i_r1_val * 60000
    eS_lvl := na
    eS_rejT := na

// Rule 1
r1L = not na(eL_lvl) and not na(eL_rejT)
r1S = not na(eS_lvl) and not na(eS_rejT)
// Rule 2: room measured from the sweep extreme (current price if none)
_r2thr = i_r2_mode == 'Points' ? i_r2_max : na(bud) ? float(na) : i_r2_max / 100.0 * bud
refL = not na(eL_lvl) ? eL_ext : low
refS = not na(eS_lvl) ? eS_ext : high
roomL = na(proj_lo) ? float(na) : refL - proj_lo
roomS = na(proj_hi) ? float(na) : proj_hi - refS
r2L = not na(roomL) and not na(_r2thr) and roomL <= _r2thr
r2S = not na(roomS) and not na(_r2thr) and roomS <= _r2thr
// Rule 3: a large live wall near the sweep extreme
float _mxC = 0.0
float _mxP = 0.0
int _nLive = 0
if array.size(gP) > 0
    for _gi = 0 to array.size(gP) - 1 by 1
        if i_gex_on and not (gStale and array.get(gD, _gi) == '0')
            _nLive += 1
            if array.get(gC, _gi)
                _mxC := math.max(_mxC, array.get(gR, _gi))
            else
                _mxP := math.max(_mxP, array.get(gR, _gi))
r3On = i_r3 and _nLive > 0
_bigWall(ref, isLong) =>
    string _w = ''
    if not na(ref) and array.size(gP) > 0
        for _gi = 0 to array.size(gP) - 1 by 1
            bool _live = i_gex_on and not (gStale and array.get(gD, _gi) == '0')
            bool _isC = array.get(gC, _gi)
            bool _sideOk = i_r3_side == 'Any wall' or (isLong ? not _isC : _isC)
            float _mx = _isC ? _mxC : _mxP
            if _live and _sideOk and _mx > 0 and math.abs(array.get(gP, _gi) - ref) <= i_r3_tol and array.get(gR, _gi) / _mx >= i_r3_ratio
                _w := array.get(gN, _gi) + ' ' + str.tostring(array.get(gP, _gi), '#') + ' (' + str.tostring(array.get(gR, _gi), '#') + ')'
                break
    _w
w3L = r3On ? _bigWall(refL, true) : ''
w3S = r3On ? _bigWall(refS, false) : ''
r3L = w3L != ''
r3S = w3S != ''
// Score: enabled automatic rules only; rule 3 only when gamma is live
int ecTot = (i_r1 ? 1 : 0) + (i_r2 ? 1 : 0) + (r3On ? 1 : 0)
int ecL = (i_r1 and r1L ? 1 : 0) + (i_r2 and r2L ? 1 : 0) + (r3On and r3L ? 1 : 0)
int ecS = (i_r1 and r1S ? 1 : 0) + (i_r2 and r2S ? 1 : 0) + (r3On and r3S ? 1 : 0)
readyL = i_ec and ecTot > 0 and ecL == ecTot
readyS = i_ec and ecTot > 0 and ecS == ecTot
evReadyL = readyL and not readyL[1]
evReadyS = readyS and not readyS[1]
if evReadyL
    alert('KVP ' + chartSym + ': LONG setup ready - ' + (na(eL_lvl) ? '' : 'SwL ' + fp(eL_lvl) + ' swept and rejected. ') + 'Confirm ' + i_r4_tx, alert.freq_once_per_bar_close)
if evReadyS
    alert('KVP ' + chartSym + ': SHORT setup ready - ' + (na(eS_lvl) ? '' : 'SwH ' + fp(eS_lvl) + ' swept and rejected. ') + 'Confirm ' + i_r4_tx, alert.freq_once_per_bar_close)

_ecPos = i_ec_pos == 'Bottom Left' ? position.bottom_left : i_ec_pos == 'Top Left' ? position.top_left : i_ec_pos == 'Middle Right' ? position.middle_right : i_ec_pos == 'Middle Left' ? position.middle_left : position.bottom_right
var table ect = table.new(_ecPos, 3, 12, border_width = 1, bgcolor = col_tbbg, frame_color = col_tbfr, frame_width = i_tbfr_w)

_wkPos = i_wk_pos == 'Middle Left' ? position.middle_left : i_wk_pos == 'Top Right' ? position.top_right : i_wk_pos == 'Top Left' ? position.top_left : i_wk_pos == 'Bottom Right' ? position.bottom_right : i_wk_pos == 'Bottom Left' ? position.bottom_left : position.middle_right
var table wtb = table.new(_wkPos, 2, 10, border_width = 0, bgcolor = col_tbbg, frame_color = col_tbfr, frame_width = i_tbfr_w)

// ============================================================
// === LEVEL POOL ===
//   cT: 0 DOL, 1 call wall, 2 put wall, 3 projection
// ============================================================
var array<float> cP = array.new_float()
var array<string> cK = array.new_string()
var array<int> cT = array.new_int()
var array<int> cS = array.new_int()
var array<float> cR = array.new_float()
var array<float> cO = array.new_float()

_push(p, k, t, s, r, o) =>
    array.push(cP, p)
    array.push(cK, k)
    array.push(cT, t)
    array.push(cS, s)
    array.push(cR, r)
    array.push(cO, o)
    true

_dol(lvl, k, st) =>
    bool _ok = not na(lvl) and (not i_hide_broken or st != 0)
    if _ok
        _push(lvl, k, 0, st, 0.0, 0.0)
    _ok

// merge nodes (one drawn level each)
var array<float> nP = array.new_float()
var array<string> nK = array.new_string()
var array<string> nDn = array.new_string()
var array<bool> nG = array.new_bool()
var array<bool> nD = array.new_bool()
var array<bool> nNk = array.new_bool()
var array<bool> nPj = array.new_bool()
var array<bool> nCWd = array.new_bool()
var array<float> nRC = array.new_float()
var array<float> nRP = array.new_float()
var array<float> nOI = array.new_float()

// confluence groups
var array<float> zLo = array.new_float()
var array<float> zHi = array.new_float()
var array<bool> zS = array.new_bool()
var array<bool> zD = array.new_bool()
var array<string> zN = array.new_string()

_obvOK(j) =>
    bool _w = array.get(nG, j)
    bool _dd = array.get(nD, j)
    bool _nkk = array.get(nNk, j)
    _w or i_ind_obv == 'Walls and DOL' and _dd or i_ind_obv == 'Walls and swept DOL' and _dd and not _nkk

// inducement state, carried across bars
var float iO_dn = na
var float iT_dn = na
var string iON_dn = ''
var string iTN_dn = ''
var int iSw_dn = na
var float iO_up = na
var float iT_up = na
var string iON_up = ''
var string iTN_up = ''
var int iSw_up = na
var bool iBig_dn = false
var bool iBig_up = false

// per-bar results
float zU_lo = na
float zU_hi = na
string zU_n = ''
float zD_lo = na
float zD_hi = na
string zD_n = ''
string atZ = ''

bool evEnter = false
bool evRecl = false
bool evFail = false
bool evZone = false
evExh = not na(pct_used) and pct_used >= i_exh and nz(pct_used[1]) < i_exh

var array<line> dL = array.new_line()
var array<label> dB = array.new_label()
var array<box> dX = array.new_box()
var table tb = table.new(_tbpos, 2, 32, border_width = 0, bgcolor = col_tbbg, frame_color = col_tbfr, frame_width = i_tbfr_w)

put(_r, _k, _v, _cv) =>
    table.cell(tb, 0, _r, _k, text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
    table.cell(tb, 1, _r, _v, text_color = _cv == color.gray ? col_tbval : _cv, text_size = _txtsz, text_halign = text.align_left)

wput(_r, _k, _v, _cv) =>
    table.cell(wtb, 0, _r, _k, text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
    table.cell(wtb, 1, _r, _v, text_color = _cv == color.gray ? col_tbval : _cv, text_size = _txtsz, text_halign = text.align_left)

// ============================================================
// === MAIN (last bar) ===
// ============================================================
if barstate.islast
    // ---------- pool ----------
    array.clear(cP)
    array.clear(cK)
    array.clear(cT)
    array.clear(cS)
    array.clear(cR)
    array.clear(cO)
    if i_pd
        _dol(pdh, 'PDH', s_pdh)
        _dol(pdl, 'PDL', s_pdl)
    if i_asia
        _dol(asH_p, 'AsH', s_asH)
        _dol(asL_p, 'AsL', s_asL)
    if i_lon
        _dol(loH_p, 'LoH', s_loH)
        _dol(loL_p, 'LoL', s_loL)
    if i_h4
        _dol(h4h, '4hH', s_h4h)
        _dol(h4l, '4hL', s_h4l)
    if i_pw
        _dol(pwh, 'PWH', s_pwh)
        _dol(pwl, 'PWL', s_pwl)
    if _swOk
        if array.size(swHP) > 0
            for _k = 0 to array.size(swHP) - 1 by 1
                _dol(array.get(swHP, _k), 'SwH', array.get(swHS, _k))
        if array.size(swLP) > 0
            for _k = 0 to array.size(swLP) - 1 by 1
                _dol(array.get(swLP, _k), 'SwL', array.get(swLS, _k))
    if gexLive
        for _gi = 0 to array.size(gP) - 1 by 1
            if gStale and array.get(gD, _gi) == '0'
                continue
            _push(array.get(gP, _gi), array.get(gN, _gi), array.get(gC, _gi) ? 1 : 2, -1, array.get(gR, _gi), array.get(gO, _gi))
    if prjCounts and not na(proj_hi)
        _push(proj_hi, 'PrjH', 3, -1, 0.0, 0.0)
        _push(proj_lo, 'PrjL', 3, -1, 0.0, 0.0)

    // ---------- merge pass (sorted linear grouping) ----------
    array.clear(nP)
    array.clear(nK)
    array.clear(nDn)
    array.clear(nG)
    array.clear(nD)
    array.clear(nNk)
    array.clear(nPj)
    array.clear(nCWd)
    array.clear(nRC)
    array.clear(nRP)
    array.clear(nOI)
    int _np = array.size(cP)
    float _mtol = i_merge_ticks * syminfo.mintick
    if _np > 0
        _idx = array.sort_indices(cP, order.ascending)
        float _sum = 0.0
        int _cnt = 0
        string _k = ''
        string _dn = ''
        bool _g = false
        bool _d = false
        bool _nk = false
        bool _pj = false
        float _rc = 0.0
        float _rp = 0.0
        int _nc = 0
        int _npw = 0
        float _oi = 0.0
        float _prev = na
        for _q = 0 to _np - 1 by 1
            int _i = array.get(_idx, _q)
            float _p = array.get(cP, _i)
            if _q > 0 and _p - _prev > _mtol
                array.push(nP, math.round(_sum / _cnt / syminfo.mintick) * syminfo.mintick)
                array.push(nK, _k)
                array.push(nDn, _dn)
                array.push(nG, _g)
                array.push(nD, _d)
                array.push(nNk, _nk)
                array.push(nPj, _pj)
                array.push(nCWd, _rc > 0 or _rp > 0 ? _rc >= _rp : _nc >= _npw)
                array.push(nRC, _rc)
                array.push(nRP, _rp)
                array.push(nOI, _oi)
                _oi := 0.0
                _sum := 0.0
                _cnt := 0
                _k := ''
                _dn := ''
                _g := false
                _d := false
                _nk := false
                _pj := false
                _rc := 0.0
                _rp := 0.0
                _nc := 0
                _npw := 0
            _sum += _p
            _cnt += 1
            _oi += array.get(cO, _i)
            int _ty = array.get(cT, _i)
            string _kn = array.get(cK, _i)
            _k := _k == '' ? _kn : str.contains(_k, _kn) ? _k : _k + '/' + _kn
            if _ty == 0
                int _st = array.get(cS, _i)
                _dn := _dn == '' ? _kn : _dn + '/' + _kn
                _d := _d or _st >= 1
                _nk := _nk or _st == 2
            else if _ty == 1
                _g := true
                _nc += 1
                _rc += array.get(cR, _i)
            else if _ty == 2
                _g := true
                _npw += 1
                _rp += array.get(cR, _i)
            else
                _pj := true
            _prev := _p
        array.push(nP, math.round(_sum / _cnt / syminfo.mintick) * syminfo.mintick)
        array.push(nK, _k)
        array.push(nDn, _dn)
        array.push(nG, _g)
        array.push(nD, _d)
        array.push(nNk, _nk)
        array.push(nPj, _pj)
        array.push(nCWd, _rc > 0 or _rp > 0 ? _rc >= _rp : _nc >= _npw)
        array.push(nRC, _rc)
        array.push(nRP, _rp)
        array.push(nOI, _oi)

    // ---------- confluence groups (complete linkage) ----------
    array.clear(zLo)
    array.clear(zHi)
    array.clear(zS)
    array.clear(zD)
    array.clear(zN)
    int _nn = array.size(nP)
    if _nn > 0
        float _ctol = math.max(i_confl_atr * atrD, i_confl_min)
        float _gmin = na
        for _j = 0 to _nn - 1 by 1
            float _pz = array.get(nP, _j)
            bool _isS = array.get(nG, _j) or array.get(nPj, _j)
            bool _isD = array.get(nD, _j)
            if _j == 0 or _pz - _gmin > _ctol
                array.push(zLo, _pz)
                array.push(zHi, _pz)
                array.push(zS, _isS)
                array.push(zD, _isD)
                array.push(zN, array.get(nK, _j))
                _gmin := _pz
            else
                int _gz = array.size(zLo) - 1
                array.set(zHi, _gz, _pz)
                array.set(zS, _gz, array.get(zS, _gz) or _isS)
                array.set(zD, _gz, array.get(zD, _gz) or _isD)
                array.set(zN, _gz, array.get(zN, _gz) + '/' + array.get(nK, _j))

    // ---------- nearest key zones ----------
    float _zpad = 2 * syminfo.mintick
    int _nz = array.size(zLo)
    if _nz > 0
        for _z = 0 to _nz - 1 by 1
            if array.get(zS, _z) and array.get(zD, _z)
                float _lo = array.get(zLo, _z)
                float _hi = array.get(zHi, _z)
                if close >= _lo - _zpad and close <= _hi + _zpad
                    atZ := array.get(zN, _z)
                else if _lo > close
                    if na(zU_lo) or _lo < zU_lo
                        zU_lo := _lo
                        zU_hi := _hi
                        zU_n := array.get(zN, _z)
                else
                    if na(zD_hi) or _hi > zD_hi
                        zD_lo := _lo
                        zD_hi := _hi
                        zD_n := array.get(zN, _z)
    evZone := not na(zU_lo) and high >= zU_lo - _zpad and high[1] < zU_lo - _zpad or not na(zD_hi) and low <= zD_hi + _zpad and low[1] > zD_hi + _zpad

    // ---------- inducement ----------
    float _vMul = i_vol_gap and not na(iv_ratio) ? (iv_ratio >= irHi ? i_gap_big : iv_ratio <= irLo ? i_gap_quiet : 1.0) : 1.0
    float _gap = i_ind_gap * atrD * _vMul
    float _mxR0 = 0.0
    if _nn > 0
        for _j = 0 to _nn - 1 by 1
            if array.get(nG, _j)
                _mxR0 := math.max(_mxR0, math.max(array.get(nRC, _j), array.get(nRP, _j)))
    bool _allowInd = i_ind and (i_ind_pri != 'Walls first' or not gexLive)
    // v1.0.1: the liquidity must sit OUTSIDE the obvious level's own
    // confluence radius. A target two points past the wall is the same
    // zone, not a level beyond it.
    float _gmn = math.max(i_ind_min * syminfo.mintick, math.max(i_confl_atr * atrD, i_confl_min))

    // manage the active zone BELOW price
    if not na(iT_dn)
        bool _stillDn = false
        if _nn > 0
            for _j = 0 to _nn - 1 by 1
                if array.get(nNk, _j) and math.abs(array.get(nP, _j) - iT_dn) <= _mtol
                    _stillDn := true
                    break
        if na(iSw_dn)
            if low <= iT_dn
                iSw_dn := bar_index
            else if not _stillDn or close > iO_dn + _gap
                iO_dn := na
                iT_dn := na
                iON_dn := ''
                iTN_dn := ''
        if not na(iSw_dn) and not na(iT_dn) and barstate.isconfirmed
            if close > iT_dn
                evRecl := true
                alert('KVP ' + chartSym + ': ' + iTN_dn + ' ' + fp(iT_dn) + ' swept and reclaimed', alert.freq_once_per_bar_close)
                iO_dn := na
                iT_dn := na
                iON_dn := ''
                iTN_dn := ''
                iSw_dn := na
            else if bar_index - iSw_dn >= i_recl_bars
                evFail := true
                iO_dn := na
                iT_dn := na
                iON_dn := ''
                iTN_dn := ''
                iSw_dn := na

    // manage the active zone ABOVE price
    if not na(iT_up)
        bool _stillUp = false
        if _nn > 0
            for _j = 0 to _nn - 1 by 1
                if array.get(nNk, _j) and math.abs(array.get(nP, _j) - iT_up) <= _mtol
                    _stillUp := true
                    break
        if na(iSw_up)
            if high >= iT_up
                iSw_up := bar_index
            else if not _stillUp or close < iO_up - _gap
                iO_up := na
                iT_up := na
                iON_up := ''
                iTN_up := ''
        if not na(iSw_up) and not na(iT_up) and barstate.isconfirmed
            if close < iT_up
                evRecl := true
                alert('KVP ' + chartSym + ': ' + iTN_up + ' ' + fp(iT_up) + ' swept and reclaimed', alert.freq_once_per_bar_close)
                iO_up := na
                iT_up := na
                iON_up := ''
                iTN_up := ''
                iSw_up := na
            else if bar_index - iSw_up >= i_recl_bars
                evFail := true
                iO_up := na
                iT_up := na
                iON_up := ''
                iTN_up := ''
                iSw_up := na

    // search for new zones: nearest obvious level, then the nearest
    // NAKED liquidity beyond it, within the gap and inside the budget
    if _allowInd and na(iT_dn) and _nn > 1
        int _io = -1
        for _j = _nn - 1 to 0
            if array.get(nP, _j) <= close and _obvOK(_j)
                _io := _j
                break
        if _io > 0
            float _po = array.get(nP, _io)
            for _j = _io - 1 to 0
                float _pt = array.get(nP, _j)
                if _po - _pt > _gap
                    break
                if array.get(nNk, _j) and _po - _pt >= _gmn and (na(proj_lo) or _pt >= proj_lo)
                    iO_dn := _po
                    iT_dn := _pt
                    iON_dn := array.get(nK, _io)
                    iTN_dn := array.get(nDn, _j)
                    iBig_dn := array.get(nG, _io) and _mxR0 > 0 and math.max(array.get(nRC, _io), array.get(nRP, _io)) / _mxR0 >= i_big_w
                    break

    if _allowInd and na(iT_up) and _nn > 1
        int _iu = -1
        for _j = 0 to _nn - 1
            if array.get(nP, _j) > close and _obvOK(_j)
                _iu := _j
                break
        if _iu >= 0 and _iu < _nn - 1
            float _po = array.get(nP, _iu)
            for _j = _iu + 1 to _nn - 1
                float _pt = array.get(nP, _j)
                if _pt - _po > _gap
                    break
                if array.get(nNk, _j) and _pt - _po >= _gmn and (na(proj_hi) or _pt <= proj_hi)
                    iO_up := _po
                    iT_up := _pt
                    iON_up := array.get(nK, _iu)
                    iTN_up := array.get(nDn, _j)
                    iBig_up := array.get(nG, _iu) and _mxR0 > 0 and math.max(array.get(nRC, _iu), array.get(nRP, _iu)) / _mxR0 >= i_big_w
                    break

    // Two-way: positive gamma, from gamma data, at a large wall.
    bool twDn = i_ind_pri == 'Regime-aware' and regFromGex and regSig == 1 and iBig_dn and not na(iT_dn)
    bool twUp = i_ind_pri == 'Regime-aware' and regFromGex and regSig == 1 and iBig_up and not na(iT_up)
    bool _inDn = not na(iT_dn) and na(iSw_dn) and close <= iO_dn and close > iT_dn
    bool _inUp = not na(iT_up) and na(iSw_up) and close >= iO_up and close < iT_up
    bool _entDn = not na(iT_dn) and low <= iO_dn and low[1] > iO_dn
    bool _entUp = not na(iT_up) and high >= iO_up and high[1] < iO_up
    if _entDn or _entUp
        evEnter := true
        string _em = _entDn ? iON_dn + ' ' + fp(iO_dn) + ' - liquidity at ' + iTN_dn + ' ' + fp(iT_dn) + ' not taken' : iON_up + ' ' + fp(iO_up) + ' - liquidity at ' + iTN_up + ' ' + fp(iT_up) + ' not taken'
        alert('KVP ' + chartSym + ': early - ' + _em, alert.freq_once_per_bar)


    // ---------- behaviour prompt (first that applies) ----------
    bool _atWall = false
    if _nn > 0
        for _j = 0 to _nn - 1 by 1
            if array.get(nG, _j) and math.abs(array.get(nP, _j) - close) <= 2 * _mtol
                _atWall := true
                break
    string prompt = ''
    if i_q_ind and _inDn
        prompt := twDn ? 'Two-way - ' + iON_dn + ' can hold (POS gamma); ' + iTN_dn + ' ' + fp(iT_dn) + ' still in play' : 'Early - ' + iTN_dn + ' ' + fp(iT_dn) + ' below not taken yet'
    else if i_q_ind and _inUp
        prompt := twUp ? 'Two-way - ' + iON_up + ' can hold (POS gamma); ' + iTN_up + ' ' + fp(iT_up) + ' still in play' : 'Early - ' + iTN_up + ' ' + fp(iT_up) + ' above not taken yet'
    else if i_q_ind and not na(iSw_dn)
        prompt := iTN_dn + ' swept - wait for the close back above ' + fp(iT_dn)
    else if i_q_ind and not na(iSw_up)
        prompt := iTN_up + ' swept - wait for the close back below ' + fp(iT_up)
    else if i_q_chase and not na(pct_used) and pct_used >= i_warn and (high >= a_hi or low <= a_lo)
        prompt := 'Chasing? New extreme at ' + f0(pct_used) + '% of budget'
    else if i_q_exh and not na(pct_used) and pct_used >= i_exh
        prompt := 'Budget spent - A+ only'
    else if i_q_neg and regFromGex and regSig == -1 and _atWall
        prompt := 'NEG gamma at a wall - let it prove itself'

    // ---------- drawing ----------
    if array.size(dL) > 0
        for _o = 0 to array.size(dL) - 1 by 1
            line.delete(array.get(dL, _o))
    if array.size(dB) > 0
        for _o = 0 to array.size(dB) - 1 by 1
            label.delete(array.get(dB, _o))
    if array.size(dX) > 0
        for _o = 0 to array.size(dX) - 1 by 1
            box.delete(array.get(dX, _o))
    array.clear(dL)
    array.clear(dB)
    array.clear(dX)

    int _xr = bar_index + i_pad
    int _xl = math.max(0, bar_index - i_back)
    int _xa = na(a_bar) ? _xl : math.max(a_bar, bar_index - 4500)

    // exposure bar scale: one scale for calls and puts, OI on its own
    float _mxR = 0.0
    float _mxO = 0.0
    if _nn > 0
        for _j = 0 to _nn - 1 by 1
            if array.get(nG, _j)
                _mxR := math.max(_mxR, math.max(array.get(nRC, _j), array.get(nRP, _j)))
                _mxO := math.max(_mxO, array.get(nOI, _j))
    bool _bars = i_mb and _mxR > 0
    int _half = math.max(2, math.round(i_mb_len / 2.0))
    int _xmid = _xr + i_mb_gap + _half
    int _xlb = _bars ? _xr + i_mb_gap + i_mb_len + 2 : _xr
    float _bh = not na(_visRange) and _visRange > 0 ? _visRange * i_mb_h : atrD * 0.02

    if _bars
        float _axLo = na
        float _axHi = na
        for _j = 0 to _nn - 1 by 1
            if array.get(nG, _j)
                float _pb = array.get(nP, _j)
                float _rc = array.get(nRC, _j)
                float _rp = array.get(nRP, _j)
                float _oj = array.get(nOI, _j)
                _axLo := na(_axLo) ? _pb : math.min(_axLo, _pb)
                _axHi := na(_axHi) ? _pb : math.max(_axHi, _pb)
                float _fc = _rc / _mxR
                float _fp = _rp / _mxR
                int _lc = _rc > 0 ? math.max(1, math.round((i_mb_sqrt ? math.sqrt(_fc) : _fc) * _half)) : 0
                int _lp = _rp > 0 ? math.max(1, math.round((i_mb_sqrt ? math.sqrt(_fp) : _fp) * _half)) : 0
                if _lc > 0
                    color _cc = color.new(col_cw, i_mb_op)
                    array.push(dX, box.new(_xmid, _pb + _bh, _xmid + _lc, _pb - _bh, border_color = _cc, border_width = 1, bgcolor = _cc))
                if _lp > 0
                    color _cp = color.new(col_pw, i_mb_op)
                    array.push(dX, box.new(_xmid - _lp, _pb + _bh, _xmid, _pb - _bh, border_color = _cp, border_width = 1, bgcolor = _cp))
                if _oj > 0 and _mxO > 0
                    float _fo = _oj / _mxO
                    int _lo2 = math.max(1, math.round((i_mb_sqrt ? math.sqrt(_fo) : _fo) * _half))
                    color _co = color.new(col_oi, math.min(95, i_mb_op + 15))
                    array.push(dX, box.new(_xmid, _pb - _bh, _xmid + _lo2, _pb - _bh * 1.55, border_color = _co, border_width = 1, bgcolor = _co))
        if not na(_axLo) and _axHi > _axLo
            array.push(dL, line.new(_xmid, _axLo, _xmid, _axHi, color = color.new(color.gray, 55), width = 1))

    if i_draw_lvls and _nn > 0
        float _lg = 0.02 * atrD
        float _lp = na
        int _col = 0
        for _j = 0 to _nn - 1 by 1
            bool _gw = array.get(nG, _j)
            bool _hasDol = array.get(nDn, _j) != ''
            if _gw or _hasDol
                float _pl = array.get(nP, _j)
                color _c = _gw ? (array.get(nCWd, _j) ? col_cw : col_pw) : col_dol
                string _sty = _gw or array.get(nNk, _j) ? line.style_solid : array.get(nD, _j) ? line.style_dashed : line.style_dotted
                array.push(dL, line.new(_xa, _pl, _xr, _pl, color = _c, width = _gw ? 2 : 1, style = _sty))
                _col := not na(_lp) and math.abs(_pl - _lp) < _lg ? (_col + 1) % 3 : 0
                _lp := _pl
                string _lt2 = str.replace_all(str.replace_all(array.get(nK, _j), '/PrjH', ''), '/PrjL', '')
                array.push(dB, label.new(_xlb + _col * i_stagger, _pl, _lt2, style = label.style_label_left, color = color.new(color.black, 100), textcolor = _c, size = size.small))

    // swing origins: a line from the 1H candle that made each swing to
    // the level set, and a marker on that candle
    if i_draw_lvls and _swOk
        int _tNow = time
        for _sd = 0 to 1 by 1
            _ap = _sd == 0 ? swHP : swLP
            _at = _sd == 0 ? swHT : swLT
            int _ns = array.size(_ap)
            if _ns > 0
                for _k = 0 to _ns - 1 by 1
                    float _sp = array.get(_ap, _k)
                    int _st0 = array.get(_at, _k)
                    if not na(_st0) and _st0 < _tNow
                        array.push(dL, line.new(_st0, _sp, _tNow, _sp, xloc = xloc.bar_time, color = color.new(col_dol, 30), width = 1, style = line.style_solid))
                        array.push(dB, label.new(_st0, _sp, _sd == 0 ? '▼' : '▲', xloc = xloc.bar_time, style = _sd == 0 ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = col_dol, size = size.tiny))

    if i_gex_on and gStale and i_exp_show == 'Show faded' and array.size(gP) > 0
        color _ec = color.new(color.gray, 55)
        for _gi = 0 to array.size(gP) - 1 by 1
            if array.get(gD, _gi) == '0'
                float _ep = array.get(gP, _gi)
                array.push(dL, line.new(_xa, _ep, _xr, _ep, color = _ec, width = 1, style = line.style_dotted))
                array.push(dB, label.new(_xlb, _ep, array.get(gN, _gi) + ' exp', style = label.style_label_left, color = color.new(color.black, 100), textcolor = _ec, size = size.tiny))

    if i_gex_on and not na(_flipEff)
        array.push(dL, line.new(_xa, _flipEff, _xr, _flipEff, color = col_flip, width = 1, style = line.style_dotted))
        array.push(dB, label.new(_xlb, _flipEff, 'flip', style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_flip, size = size.tiny))

    if i_draw_prj and not na(proj_hi)
        array.push(dL, line.new(_xa, proj_hi, _xr, proj_hi, color = col_prj, width = 1, style = line.style_dashed))
        array.push(dL, line.new(_xa, proj_lo, _xr, proj_lo, color = col_prj, width = 1, style = line.style_dashed))
        array.push(dB, label.new(_xr, proj_hi, 'Prj ' + budTag, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_prj, size = size.tiny))
        array.push(dB, label.new(_xr, proj_lo, 'Prj ' + budTag, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_prj, size = size.tiny))

    if not na(zU_lo)
        array.push(dX, box.new(_xl, zU_hi + _zpad, _xr, zU_lo - _zpad, border_color = color.new(col_zone, 40), border_width = 1, bgcolor = col_zone))
        array.push(dB, label.new(_xl, zU_hi + _zpad, 'KEY', style = label.style_label_lower_left, color = color.new(color.black, 100), textcolor = color.new(col_zone, 0), size = size.tiny))
    if not na(zD_hi)
        array.push(dX, box.new(_xl, zD_hi + _zpad, _xr, zD_lo - _zpad, border_color = color.new(col_zone, 40), border_width = 1, bgcolor = col_zone))
        array.push(dB, label.new(_xl, zD_lo - _zpad, 'KEY', style = label.style_label_upper_left, color = color.new(color.black, 100), textcolor = color.new(col_zone, 0), size = size.tiny))

    if i_ind and not na(iT_dn)
        color _bcD = twDn ? col_tw : col_ind
        array.push(dX, box.new(_xl, iO_dn, _xr, iT_dn, border_color = color.new(_bcD, 60), border_width = 1, border_style = line.style_dashed, bgcolor = _bcD))
        array.push(dL, line.new(_xl, iT_dn, _xr, iT_dn, color = color.new(_bcD, 0), width = 2, style = line.style_dashed))
        array.push(dB, label.new(_xl, iT_dn, (not na(iSw_dn) ? 'swept: ' : twDn ? 'two-way: ' : 'wait: ') + iTN_dn, style = label.style_label_upper_left, color = color.new(color.black, 100), textcolor = color.new(_bcD, 0), size = size.small))
    if i_ind and not na(iT_up)
        color _bcU = twUp ? col_tw : col_ind
        array.push(dX, box.new(_xl, iT_up, _xr, iO_up, border_color = color.new(_bcU, 60), border_width = 1, border_style = line.style_dashed, bgcolor = _bcU))
        array.push(dL, line.new(_xl, iT_up, _xr, iT_up, color = color.new(_bcU, 0), width = 2, style = line.style_dashed))
        array.push(dB, label.new(_xl, iT_up, (not na(iSw_up) ? 'swept: ' : twUp ? 'two-way: ' : 'wait: ') + iTN_up, style = label.style_label_lower_left, color = color.new(color.black, 100), textcolor = color.new(_bcU, 0), size = size.small))

    // ---------- Power of 3 candles ----------
    if i_p3
        int _hw = math.max(1, math.round(i_p3_w / 2))
        // The inner gap holds whatever prints on the LEFT of the
        // current candle: the level names when the ruler is on the
        // right, the ruler itself when it is on the left.
        int _dclr = not i_gh ? 0 : _rSide ? (i_gh_ticks and i_gh_tlbl ? i_tnclr : 0) : (i_gh_scale ? i_rclr : 0)
        int _b0 = _xlb + i_p3_off
        float _gB = i_gh_basis == 'VIX implied' and _ivOk ? impl : i_gh_basis == 'VIX adjusted' and not na(implAdj) ? implAdj : bud
        float _gHi = na(_gB) ? float(na) : math.max(a_hi, a_lo + _gB)
        float _gLo = na(_gB) ? float(na) : math.min(a_lo, a_hi - _gB)
        bool _gOver = not na(_gB) and a_hi - a_lo >= _gB
        if i_gh and not na(_gHi) and not na(a_px)
            int _gx = _b0 + 2 * i_p3_gap + _dclr
            int _gw = _hw
            array.push(dX, box.new(_gx - _gw, _gHi, _gx + _gw, _gLo, border_color = col_ghb, border_width = 1, border_style = line.style_solid, bgcolor = col_gh))
            if i_gh_scale
                float _z = i_gh_zero == 'Current price' ? close : a_px
                float _st = i_gh_step
                while (_gHi - _gLo) / _st > 30
                    _st *= 2
                color _sc = col_p3t
                int _xa = _rSide ? _gx + _gw : _gx - _gw
                int _xt = _rSide ? _xa + 2 : _xa - 2
                int _xl0 = _rSide ? _xa + 3 : _xa - 3
                array.push(dL, line.new(_rSide ? _gx - _gw - 1 : _xl0, _z, _rSide ? _xl0 : _gx + _gw + 1, _z, color = _sc, width = 1))
                array.push(dB, label.new(_xl0, _z, '0', style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _sc, size = size.tiny))
                for _sd = 0 to 1 by 1
                    float _edge = _sd == 0 ? _gHi : _gLo
                    float _dir = _sd == 0 ? 1.0 : -1.0
                    int _n = int(math.floor(math.abs(_edge - _z) / _st))
                    if _n > 0
                        for _k = 1 to _n by 1
                            float _tp = _z + _dir * _k * _st
                            if math.abs(_edge - _tp) >= _st * 0.4
                                array.push(dL, line.new(_xa, _tp, _xt, _tp, color = color.new(_sc, 30), width = 1))
                                array.push(dB, label.new(_xl0, _tp, (_sd == 0 ? '+' : '-') + str.tostring(_k * _st, '#.##'), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = color.new(_sc, 30), size = size.tiny))
                    if math.abs(_edge - _z) > 0
                        array.push(dL, line.new(_xa, _edge, _xl0, _edge, color = _sc, width = 1))
                        array.push(dB, label.new(_xl0, _edge, (_sd == 0 ? '+' : '-') + f0(math.abs(_edge - _z)), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _sc, size = size.tiny))
            if i_gh_ticks and _nn > 0
                float _tLast = na
                for _j = 0 to _nn - 1 by 1
                    float _tp = array.get(nP, _j)
                    bool _tw = array.get(nG, _j)
                    bool _td = array.get(nD, _j)
                    if (_tw or _td) and _tp >= _gLo and _tp <= _gHi
                        color _tc = _tw ? (array.get(nCWd, _j) ? col_cw : col_pw) : col_dol
                        array.push(dL, line.new(_gx - _gw - 1, _tp, _gx + _gw + 1, _tp, color = _tc, width = _tw ? 2 : 1))
                        if i_gh_tlbl and (na(_tLast) or math.abs(_tp - _tLast) >= atrD * 0.02)
                            string _tn = str.replace_all(str.replace_all(array.get(nK, _j), '/PrjH', ''), '/PrjL', '')
                            array.push(dB, label.new(_rSide ? _gx - _gw - 2 : _gx + _gw + 2, _tp, _tn, style = _rSide ? label.style_label_right : label.style_label_left, color = color.new(color.black, 100), textcolor = _tc, size = size.tiny))
                            _tLast := _tp
        // one label row beneath the whole column (candles and ghost)
        float _rowY = math.min(nz(p2l, a_lo), math.min(nz(p1l, a_lo), a_lo))
        if i_gh and not na(_gLo)
            _rowY := math.min(_rowY, _gLo)
        _rowY -= atrD * 0.02
        for _ci = 0 to 2 by 1
            float _o = _ci == 0 ? p2o : _ci == 1 ? p1o : a_px
            float _h = _ci == 0 ? p2h : _ci == 1 ? p1h : a_hi
            float _l = _ci == 0 ? p2l : _ci == 1 ? p1l : a_lo
            float _c = _ci == 0 ? p2c : _ci == 1 ? p1c : close
            if not na(_o) and not na(_h) and not na(_l) and not na(_c)
                int _x = _b0 + _ci * i_p3_gap + (_ci == 2 ? _dclr : 0)
                color _pc = _c >= _o ? col_p3u : col_p3d
                float _top = math.max(_o, _c)
                float _bot = math.min(_o, _c)
                float _pd = _top == _bot ? syminfo.mintick * 0.5 : 0.0
                array.push(dL, line.new(_x, _h, _x, _l, color = _pc, width = 1))
                array.push(dX, box.new(_x - _hw, _top + _pd, _x + _hw, _bot - _pd, border_color = _ci == 2 and _gOver ? c_amb : _pc, border_width = _ci == 2 and _gOver ? 2 : 1, border_style = _ci == 2 and not _gOver ? line.style_dashed : line.style_solid, bgcolor = color.new(_pc, _ci == 2 ? 30 : 25)))
                array.push(dL, line.new(_x - _hw - 1, _o, _x + _hw + 1, _o, color = col_p3o, width = 2))
                if i_p3_lbl
                    string _tg = _ci == 0 ? 'D-2' : _ci == 1 ? 'D-1' : 'TODAY'
                    string _tx = _tg + '\n' + f0(_h - _l) + (_ci == 2 and not na(_gB) ? ' of ' + f0(_gB) : '') + ' pts\n▲' + f0(_h - _o) + ' ▼' + f0(_o - _l)
                    if _ci == 2 and i_gh and not na(_gB)
                        _tx := _tx + (_gOver ? '\nbudget spent' : '\nroom ▲' + f0(_gHi - close) + ' ▼' + f0(close - _gLo))
                    array.push(dB, label.new(_x, _rowY, _tx, style = label.style_label_up, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))
        // Heading above the group. Anchored over the tallest thing in
        // the column, ghost included, so the label body clears the
        // ruler's topmost tick label.
        if i_grp_lbl or i_grp_br
            float _dTop = math.max(nz(p2h, a_hi), math.max(nz(p1h, a_hi), a_hi))
            if i_gh and not na(_gHi)
                _dTop := math.max(_dTop, _gHi)
            _dTop += atrD * 0.03
            int _dL = _b0 - _hw
            int _dR = _b0 + 2 * i_p3_gap + _dclr + _hw
            if i_grp_br
                array.push(dL, line.new(_dL, _dTop, _dR, _dTop, color = color.new(col_p3t, 55), width = 1))
            if i_grp_lbl
                array.push(dB, label.new(int((_dL + _dR) / 2), _dTop, 'DAILY', style = label.style_label_down, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))

    // ---------- weekly Power of 3 candles ----------
    // Same geometry as the daily column so the two read alike. The
    // column sits past the daily one; with the daily candles off it
    // takes their place rather than leaving a gap.
    if i_wkc
        int _whw = math.max(1, math.round(i_wk_w / 2))
        // No level names on this ghost, so the inner gap is needed
        // only when the ruler prints on the left.
        int _wclr = not _rSide and i_wk_gh and i_wk_scale ? i_rclr : 0
        // A column plus its lane is the same width whichever side the
        // ruler sits on - the two terms simply swap places - so this
        // stays side-agnostic. _dclr is local to the daily block and
        // must not be referenced here.
        int _wb0 = _xlb + i_p3_off + (i_p3 ? 2 * i_p3_gap + (i_gh and i_gh_scale ? i_rclr : 0) + (i_gh and i_gh_ticks and i_gh_tlbl ? i_tnclr : 0) + i_wkc_off : 0)

        float _gwHi = _wkOk ? math.max(w_hi, w_lo + wadr) : float(na)
        float _gwLo = _wkOk ? math.min(w_lo, w_hi - wadr) : float(na)
        bool _gwOver = _wkOk and w_rng >= wadr
        if i_wk_gh and not na(_gwHi) and not na(w_px)
            int _gwx = _wb0 + (i_wk_n - 1) * i_wk_gap + _wclr
            array.push(dX, box.new(_gwx - _whw, _gwHi, _gwx + _whw, _gwLo, border_color = col_ghb, border_width = 1, border_style = line.style_solid, bgcolor = col_gh))
            if i_wk_scale
                float _wz = i_wk_zero == 'Current price' ? close : w_px
                float _wst = i_wk_step
                while (_gwHi - _gwLo) / _wst > 30
                    _wst *= 2
                color _wsc = col_p3t
                int _wxa = _rSide ? _gwx + _whw : _gwx - _whw
                int _wxt = _rSide ? _wxa + 2 : _wxa - 2
                int _wxl0 = _rSide ? _wxa + 3 : _wxa - 3
                array.push(dL, line.new(_rSide ? _gwx - _whw - 1 : _wxl0, _wz, _rSide ? _wxl0 : _gwx + _whw + 1, _wz, color = _wsc, width = 1))
                array.push(dB, label.new(_wxl0, _wz, '0', style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _wsc, size = size.tiny))
                for _wsd = 0 to 1 by 1
                    float _wedge = _wsd == 0 ? _gwHi : _gwLo
                    float _wdir = _wsd == 0 ? 1.0 : -1.0
                    int _wn = int(math.floor(math.abs(_wedge - _wz) / _wst))
                    if _wn > 0
                        for _wk = 1 to _wn by 1
                            float _wtp = _wz + _wdir * _wk * _wst
                            // skip a tick that would sit on top of the
                            // edge label, which carries the exact reach
                            if math.abs(_wedge - _wtp) >= _wst * 0.4
                                array.push(dL, line.new(_wxa, _wtp, _wxt, _wtp, color = color.new(_wsc, 30), width = 1))
                                array.push(dB, label.new(_wxl0, _wtp, (_wsd == 0 ? '+' : '-') + str.tostring(_wk * _wst, '#.##'), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = color.new(_wsc, 30), size = size.tiny))
                    if math.abs(_wedge - _wz) > 0
                        array.push(dL, line.new(_wxa, _wedge, _wxl0, _wedge, color = _wsc, width = 1))
                        array.push(dB, label.new(_wxl0, _wedge, (_wsd == 0 ? '+' : '-') + f0(math.abs(_wedge - _wz)), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _wsc, size = size.tiny))
        // Baseline spans only the candles actually drawn, so a hidden
        // W-2 does not drag the label row down to a low off the column.
        float _wRowY = math.min(i_wk_n >= 2 ? nz(q1l, w_lo) : w_lo, i_wk_n >= 3 ? nz(q2l, w_lo) : w_lo)
        _wRowY := math.min(_wRowY, w_lo)
        if i_wk_gh and not na(_gwLo)
            _wRowY := math.min(_wRowY, _gwLo)
        _wRowY -= atrD * 0.02
        // _wi is the drawn slot, left to right. _ws is the period it
        // holds: 0 the week before last, 1 last week, 2 this week. The
        // current week is always the rightmost slot whatever the count.
        for _wi = 0 to i_wk_n - 1 by 1
            int _ws = 3 - i_wk_n + _wi
            float _wo = _ws == 0 ? q2o : _ws == 1 ? q1o : w_px
            float _wh = _ws == 0 ? q2h : _ws == 1 ? q1h : w_hi
            float _wl = _ws == 0 ? q2l : _ws == 1 ? q1l : w_lo
            float _wc = _ws == 0 ? q2c : _ws == 1 ? q1c : close
            if not na(_wo) and not na(_wh) and not na(_wl) and not na(_wc)
                int _wx = _wb0 + _wi * i_wk_gap + (_wi == i_wk_n - 1 ? _wclr : 0)
                color _wpc = _wc >= _wo ? col_p3u : col_p3d
                float _wtop = math.max(_wo, _wc)
                float _wbot = math.min(_wo, _wc)
                float _wpd = _wtop == _wbot ? syminfo.mintick * 0.5 : 0.0
                array.push(dL, line.new(_wx, _wh, _wx, _wl, color = _wpc, width = 1))
                array.push(dX, box.new(_wx - _whw, _wtop + _wpd, _wx + _whw, _wbot - _wpd, border_color = _ws == 2 and i_wk_gh and _gwOver ? c_amb : _wpc, border_width = _ws == 2 and i_wk_gh and _gwOver ? 2 : 1, border_style = _ws == 2 and i_wk_gh and not _gwOver ? line.style_dashed : line.style_solid, bgcolor = color.new(_wpc, _ws == 2 ? 30 : 25)))
                array.push(dL, line.new(_wx - _whw - 1, _wo, _wx + _whw + 1, _wo, color = col_p3o, width = 2))
                if i_p3_lbl
                    string _wtg = _ws == 0 ? 'W-2' : _ws == 1 ? 'W-1' : 'THIS WK'
                    string _wtx = _wtg + '\n' + f0(_wh - _wl) + (_ws == 2 and _wkOk ? ' of ' + f0(wadr) : '') + ' pts\n▲' + f0(_wh - _wo) + ' ▼' + f0(_wo - _wl)
                    if _ws == 2 and i_wk_gh and _wkOk
                        _wtx := _wtx + (_gwOver ? '\nbudget spent' : '\nroom ▲' + f0(_gwHi - close) + ' ▼' + f0(close - _gwLo)) + '\nday ' + str.tostring(_wdIdx + 1) + ' of 5'
                    array.push(dB, label.new(_wx, _wRowY, _wtx, style = label.style_label_up, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))
        if i_grp_lbl or i_grp_br
            float _wTop = math.max(i_wk_n >= 2 ? nz(q1h, w_hi) : w_hi, i_wk_n >= 3 ? nz(q2h, w_hi) : w_hi)
            _wTop := math.max(_wTop, w_hi)
            if i_wk_gh and not na(_gwHi)
                _wTop := math.max(_wTop, _gwHi)
            _wTop += atrD * 0.03
            int _wL = _wb0 - _whw
            int _wR = _wb0 + (i_wk_n - 1) * i_wk_gap + _wclr + _whw
            if i_grp_br
                array.push(dL, line.new(_wL, _wTop, _wR, _wTop, color = color.new(col_p3t, 55), width = 1))
            if i_grp_lbl
                array.push(dB, label.new(int((_wL + _wR) / 2), _wTop, 'WEEKLY', style = label.style_label_down, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))

    // ---------- monthly Power of 3 candles ----------
    // Third column, past the weekly one. Same construction again; the
    // candles sit at TRUE PRICE, so the columns are separated
    // horizontally only - a vertical offset would put the body
    // somewhere the range never traded.
    if i_moc
        int _mhw = math.max(1, math.round(i_moc_w / 2))
        int _mclr = not _rSide and i_mo_gh and i_mo_scale ? i_rclr : 0
        int _mb0 = _xlb + i_p3_off + (i_p3 ? 2 * i_p3_gap + (i_gh and i_gh_scale ? i_rclr : 0) + (i_gh and i_gh_ticks and i_gh_tlbl ? i_tnclr : 0) + i_wkc_off : 0) + (i_wkc ? (i_wk_n - 1) * i_wk_gap + (i_wk_gh and i_wk_scale ? i_rclr : 0) + i_moc_off : 0)
        float _gmHi = _moOk ? math.max(m_hi, m_lo + madr) : float(na)
        float _gmLo = _moOk ? math.min(m_lo, m_hi - madr) : float(na)
        bool _gmOver = _moOk and m_rng >= madr
        if i_mo_gh and not na(_gmHi) and not na(m_px)
            int _gmx = _mb0 + (i_mo_n - 1) * i_moc_gap + _mclr
            array.push(dX, box.new(_gmx - _mhw, _gmHi, _gmx + _mhw, _gmLo, border_color = col_ghb, border_width = 1, border_style = line.style_solid, bgcolor = col_gh))
            if i_mo_scale
                float _mz = i_mo_zero == 'Current price' ? close : m_px
                float _mst = i_mo_step
                while (_gmHi - _gmLo) / _mst > 30
                    _mst *= 2
                color _msc = col_p3t
                int _mxa = _rSide ? _gmx + _mhw : _gmx - _mhw
                int _mxt = _rSide ? _mxa + 2 : _mxa - 2
                int _mxl0 = _rSide ? _mxa + 3 : _mxa - 3
                array.push(dL, line.new(_rSide ? _gmx - _mhw - 1 : _mxl0, _mz, _rSide ? _mxl0 : _gmx + _mhw + 1, _mz, color = _msc, width = 1))
                array.push(dB, label.new(_mxl0, _mz, '0', style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _msc, size = size.tiny))
                for _msd = 0 to 1 by 1
                    float _medge = _msd == 0 ? _gmHi : _gmLo
                    float _mdir = _msd == 0 ? 1.0 : -1.0
                    int _mn = int(math.floor(math.abs(_medge - _mz) / _mst))
                    if _mn > 0
                        for _mk = 1 to _mn by 1
                            float _mtp = _mz + _mdir * _mk * _mst
                            if math.abs(_medge - _mtp) >= _mst * 0.4
                                array.push(dL, line.new(_mxa, _mtp, _mxt, _mtp, color = color.new(_msc, 30), width = 1))
                                array.push(dB, label.new(_mxl0, _mtp, (_msd == 0 ? '+' : '-') + str.tostring(_mk * _mst, '#.##'), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = color.new(_msc, 30), size = size.tiny))
                    if math.abs(_medge - _mz) > 0
                        array.push(dL, line.new(_mxa, _medge, _mxl0, _medge, color = _msc, width = 1))
                        array.push(dB, label.new(_mxl0, _medge, (_msd == 0 ? '+' : '-') + f0(math.abs(_medge - _mz)), style = _rSide ? label.style_label_left : label.style_label_right, color = color.new(color.black, 100), textcolor = _msc, size = size.tiny))
        float _mRowY = math.min(i_mo_n >= 2 ? nz(n1l, m_lo) : m_lo, i_mo_n >= 3 ? nz(n2l, m_lo) : m_lo)
        _mRowY := math.min(_mRowY, m_lo)
        if i_mo_gh and not na(_gmLo)
            _mRowY := math.min(_mRowY, _gmLo)
        _mRowY -= atrD * 0.02
        for _mi = 0 to i_mo_n - 1 by 1
            int _ms = 3 - i_mo_n + _mi
            float _mo = _ms == 0 ? n2o : _ms == 1 ? n1o : m_px
            float _mh = _ms == 0 ? n2h : _ms == 1 ? n1h : m_hi
            float _ml = _ms == 0 ? n2l : _ms == 1 ? n1l : m_lo
            float _mc = _ms == 0 ? n2c : _ms == 1 ? n1c : close
            if not na(_mo) and not na(_mh) and not na(_ml) and not na(_mc)
                int _mx = _mb0 + _mi * i_moc_gap + (_mi == i_mo_n - 1 ? _mclr : 0)
                color _mpc = _mc >= _mo ? col_p3u : col_p3d
                float _mtop = math.max(_mo, _mc)
                float _mbot = math.min(_mo, _mc)
                float _mpd = _mtop == _mbot ? syminfo.mintick * 0.5 : 0.0
                array.push(dL, line.new(_mx, _mh, _mx, _ml, color = _mpc, width = 1))
                array.push(dX, box.new(_mx - _mhw, _mtop + _mpd, _mx + _mhw, _mbot - _mpd, border_color = _ms == 2 and i_mo_gh and _gmOver ? c_amb : _mpc, border_width = _ms == 2 and i_mo_gh and _gmOver ? 2 : 1, border_style = _ms == 2 and i_mo_gh and not _gmOver ? line.style_dashed : line.style_solid, bgcolor = color.new(_mpc, _ms == 2 ? 30 : 25)))
                array.push(dL, line.new(_mx - _mhw - 1, _mo, _mx + _mhw + 1, _mo, color = col_p3o, width = 2))
                if i_p3_lbl
                    string _mtg = _ms == 0 ? 'M-2' : _ms == 1 ? 'M-1' : 'THIS MO'
                    string _mtx = _mtg + '\n' + f0(_mh - _ml) + (_ms == 2 and _moOk ? ' of ' + f0(madr) : '') + ' pts\n▲' + f0(_mh - _mo) + ' ▼' + f0(_mo - _ml)
                    if _ms == 2 and i_mo_gh and _moOk
                        _mtx := _mtx + (_gmOver ? '\nbudget spent' : '\nroom ▲' + f0(_gmHi - close) + ' ▼' + f0(close - _gmLo)) + '\nday ' + str.tostring(m_days)
                    array.push(dB, label.new(_mx, _mRowY, _mtx, style = label.style_label_up, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))
        if i_grp_lbl or i_grp_br
            float _mTop = math.max(i_mo_n >= 2 ? nz(n1h, m_hi) : m_hi, i_mo_n >= 3 ? nz(n2h, m_hi) : m_hi)
            _mTop := math.max(_mTop, m_hi)
            if i_mo_gh and not na(_gmHi)
                _mTop := math.max(_mTop, _gmHi)
            _mTop += atrD * 0.03
            int _mL = _mb0 - _mhw
            int _mR = _mb0 + (i_mo_n - 1) * i_moc_gap + _mclr + _mhw
            if i_grp_br
                array.push(dL, line.new(_mL, _mTop, _mR, _mTop, color = color.new(col_p3t, 55), width = 1))
            if i_grp_lbl
                array.push(dB, label.new(int((_mL + _mR) / 2), _mTop, 'MONTHLY', style = label.style_label_down, color = color.new(color.black, 100), textcolor = col_p3t, size = i_p3_ts == 'Tiny' ? size.tiny : i_p3_ts == 'Normal' ? size.normal : i_p3_ts == 'Large' ? size.large : size.small))

    // ---------- panel ----------
    table.clear(tb, 0, 0, 1, 31)
    color _hbg = color.new(color.gray, 85)
    table.cell(tb, 0, 0, 'Sphinx KVP', text_color = col_tblbl, text_size = _txtsz, bgcolor = _hbg, text_halign = text.align_left)
    table.cell(tb, 1, 0, (chartSym == '' ? syminfo.ticker : chartSym) + '  ' + VER, text_color = col_tblbl, text_size = _txtsz, bgcolor = _hbg, text_halign = text.align_left)
    int rw = 1
    string _srcTx = regFromGex ? (_useNet ? 'gamma, net' : 'gamma, flip') : 'from VIX'
    if gStale
        table.cell(tb, 0, rw, 'Gamma', text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
        table.cell(tb, 1, rw, 'From before the 18:00 open - 0DTE expired, paste today\'s string', text_color = color.white, bgcolor = color.new(c_red, 25), text_size = _txtsz, text_halign = text.align_left)
        rw += 1
    put(rw, 'Market mode', regTxt + '  (' + _srcTx + ')' + (regSplit ? '  ⚠ mixed: price ' + (_regFlip == 1 ? 'above' : 'below') + ' flip' : ''), regSig == 1 ? c_grn : regSig == -1 ? c_red : color.gray)
    rw += 1
    color _gc = na(pct_used) ? color.gray : pct_used >= i_exh ? c_red : pct_used >= i_warn ? c_amb : c_grn
    put(rw, gauge(pct_used), 'Range used ' + f0(day_rng) + ' of ' + f0(adr) + ' pts  (' + f0(pct_used) + '%)', _gc)
    rw += 1
    if not i_compact
        put(rw, 'Avg day (' + str.tostring(i_len) + 'd)', i_manual > 0 ? f0(adr) + ' pts  (manual)' : f0(adr) + ' pts', color.gray)
        rw += 1
    if _ivOk
        float _dv = _drOk ? (iv_ratio - 1.0) * 100.0 : float(na)
        string _vw = na(iv_ratio) ? '' : iv_ratio >= irHi ? 'bigger day than usual' : iv_ratio <= irLo ? 'quieter day than usual' : 'about normal'
        put(rw, volName + ' expects', f0(impl) + ' pts' + (na(implAdj) ? '' : '  (~' + f0(implAdj) + ' real)') + '  ·  ' + _vw + (na(_dv) ? '' : ' (' + (_dv >= 0 ? '+' : '') + f0(_dv) + '%)'), na(iv_ratio) ? color.gray : iv_ratio >= irHi ? c_red : iv_ratio <= irLo ? c_grn : color.gray)
        rw += 1
        string _fc = calN < i_cal_min ? 'calibrating (' + str.tostring(calN) + ' of ' + str.tostring(i_cal_min) + ' days)' : 'avg day off ' + f0(calErrDR) + '%  ·  VIX off ' + f0(calErrIV) + '%  ·  VIX runs ' + (calOver >= 1 ? '+' : '') + f0((calOver - 1.0) * 100.0) + '% vs real  (' + str.tostring(calN) + 'd)'
        if not i_compact
            put(rw, 'Forecast check', _fc, color.gray)
            rw += 1
    put(rw, 'Room ▲ / ▼', f0(rem_up) + ' / ' + f0(rem_dn) + ' pts' + (budTag == 'IV' ? '  (VIX)' : ''), color.gray)
    rw += 1
    if i_vix_on and not i_compact
        string _tsP = tsTxt == 'BACKWARD' ? 'Stressed - near-term fear' : tsTxt == 'CONTANGO' ? 'Calm' : tsTxt == 'FLAT' ? 'Edgy' : '-'
        string _vvP = na(vvChg) ? '' : '  ·  VVIX ' + (vvSpike ? 'rising fast' : 'steady') + ' (' + (vvChg >= 0 ? '+' : '') + f0(vvChg) + '%)'
        put(rw, volName + ' ' + f2(vm), _tsP + _vvP, vvSpike or tsTxt == 'BACKWARD' ? c_red : tsTxt == 'CONTANGO' ? c_grn : color.gray)
        rw += 1
    if atZ != ''
        put(rw, 'At key level', atZ, c_amb)
        rw += 1
    put(rw, 'Next key ▲', na(zU_lo) ? '-' : fp(zU_lo) + '  ' + zU_n + (not na(proj_hi) and zU_lo > proj_hi ? '  beyond budget' : ''), na(zU_lo) ? color.gray : not na(proj_hi) and zU_lo > proj_hi ? color.gray : c_amb)
    rw += 1
    put(rw, 'Next key ▼', na(zD_hi) ? '-' : fp(zD_hi) + '  ' + zD_n + (not na(proj_lo) and zD_hi < proj_lo ? '  beyond budget' : ''), na(zD_hi) ? color.gray : not na(proj_lo) and zD_hi < proj_lo ? color.gray : c_amb)
    rw += 1
    if i_ind
        put(rw, twUp ? 'Two-way ▲' : 'Don\'t fade ▲', na(iT_up) ? '-' : not na(iSw_up) ? iTN_up + ' swept  ·  wait for close back below ' + fp(iT_up) : twUp ? iON_up + ' ' + fp(iO_up) + ' can hold  ·  liquidity at ' + iTN_up + ' ' + fp(iT_up) : iON_up + ' ' + fp(iO_up) + '  ·  wait for ' + iTN_up + ' ' + fp(iT_up), na(iT_up) ? color.gray : color.new(twUp ? col_tw : col_ind, 0))
        rw += 1
        put(rw, twDn ? 'Two-way ▼' : 'Don\'t fade ▼', na(iT_dn) ? '-' : not na(iSw_dn) ? iTN_dn + ' swept  ·  wait for close back above ' + fp(iT_dn) : twDn ? iON_dn + ' ' + fp(iO_dn) + ' can hold  ·  liquidity at ' + iTN_dn + ' ' + fp(iT_dn) : iON_dn + ' ' + fp(iO_dn) + '  ·  wait for ' + iTN_dn + ' ' + fp(iT_dn), na(iT_dn) ? color.gray : color.new(twDn ? col_tw : col_ind, 0))
        rw += 1
        if not i_compact
            put(rw, 'Box reach', f0(_gap) + ' pts max' + (_vMul > 1 ? '  (bigger day)' : _vMul < 1 ? '  (quieter day)' : '') + (i_ind_pri == 'Walls first' and gexLive ? '  ·  off: walls first' : ''), color.gray)
            rw += 1
    if prompt != ''
        table.cell(tb, 0, rw, 'Heads up', text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
        table.cell(tb, 1, rw, prompt, text_color = color.white, bgcolor = color.new(c_amb, 35), text_size = _txtsz, text_halign = text.align_left)

    // ---------- higher timeframe budgets ----------
    table.clear(wtb, 0, 0, 1, 9)
    int wr = 1
    if i_wk_on or i_mo_on
        color _wkh = color.new(color.gray, 85)
        if i_wk_on
            table.cell(wtb, 0, 0, 'Weekly budget', text_color = col_tblbl, text_size = _txtsz, bgcolor = _wkh, text_halign = text.align_left)
            table.cell(wtb, 1, 0, 'day ' + str.tostring(_wdIdx + 1) + ' of 5', text_color = col_tblbl, text_size = _txtsz, bgcolor = _wkh, text_halign = text.align_left)
            color _wgc = na(w_pct) ? color.gray : w_pct >= i_exh ? c_red : w_pct >= i_warn ? c_amb : c_grn
            wput(wr, gauge(w_pct), f0(w_rng) + ' of ' + f0(wadr) + ' pts  (' + f0(w_pct) + '%)', _wgc)
            wr += 1
            wput(wr, 'Room ▲ / ▼', f0(w_rem_up) + ' / ' + f0(w_rem_dn) + ' pts', color.gray)
            wr += 1
        else
            wr := 0
        if i_wk_on and i_wk_days
            wput(wr, 'By day', 'Mo ' + _wf(0) + '  Tu ' + _wf(1) + '  We ' + _wf(2) + '  Th ' + _wf(3) + '  Fr ' + _wf(4), color.gray)
            wr += 1
        if i_mo_on
            color _mkh = color.new(color.gray, 85)
            table.cell(wtb, 0, wr, 'Monthly budget', text_color = col_tblbl, text_size = _txtsz, bgcolor = _mkh, text_halign = text.align_left)
            table.cell(wtb, 1, wr, 'day ' + str.tostring(m_days), text_color = col_tblbl, text_size = _txtsz, bgcolor = _mkh, text_halign = text.align_left)
            wr += 1
            color _mgc = na(m_pct) ? color.gray : m_pct >= i_exh ? c_red : m_pct >= i_warn ? c_amb : c_grn
            wput(wr, gauge(m_pct), f0(m_rng) + ' of ' + f0(madr) + ' pts  (' + f0(m_pct) + '%)', _mgc)
            wr += 1
            wput(wr, 'Room ▲ / ▼', f0(m_rem_up) + ' / ' + f0(m_rem_dn) + ' pts', color.gray)

    // ---------- entry checklist ----------
    table.clear(ect, 0, 0, 2, 11)
    if i_ec
        color _eh = color.new(color.gray, 85)
        table.cell(ect, 0, 0, 'Entry checklist', text_color = col_tblbl, text_size = _txtsz, bgcolor = _eh, text_halign = text.align_left)
        table.cell(ect, 1, 0, '▲ Long', text_color = col_tblbl, text_size = _txtsz, bgcolor = _eh, text_halign = text.align_left)
        table.cell(ect, 2, 0, '▼ Short', text_color = col_tblbl, text_size = _txtsz, bgcolor = _eh, text_halign = text.align_left)
        int er = 1
        if i_r1
            string _aL = r1L ? '✓ SwL ' + fp(eL_lvl) : not na(eL_lvl) ? '… SwL ' + fp(eL_lvl) + ' swept' : '✗ no sweep'
            string _aS = r1S ? '✓ SwH ' + fp(eS_lvl) : not na(eS_lvl) ? '… SwH ' + fp(eS_lvl) + ' swept' : '✗ no sweep'
            table.cell(ect, 0, er, '1H sweep + reject', text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 1, er, _aL, text_color = r1L ? c_grn : not na(eL_lvl) ? c_amb : color.gray, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 2, er, _aS, text_color = r1S ? c_grn : not na(eS_lvl) ? c_amb : color.gray, text_size = _txtsz, text_halign = text.align_left)
            er += 1
        if i_r2
            string _lim = i_r2_mode == 'Points' ? f0(i_r2_max) + ' pts' : f0(i_r2_max) + '%'
            table.cell(ect, 0, er, 'Room ≤ ' + _lim, text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 1, er, (r2L ? '✓ ' : '✗ ') + f0(roomL) + ' pts left', text_color = r2L ? c_grn : color.gray, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 2, er, (r2S ? '✓ ' : '✗ ') + f0(roomS) + ' pts left', text_color = r2S ? c_grn : color.gray, text_size = _txtsz, text_halign = text.align_left)
            er += 1
        if i_r3
            table.cell(ect, 0, er, 'Big wall ≤ ' + str.tostring(i_r3_tol, '#.##') + ' pts', text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 1, er, not r3On ? '– no gamma' : r3L ? '✓ ' + w3L : '✗ none', text_color = r3L ? c_grn : color.gray, text_size = _txtsz, text_halign = text.align_left)
            table.cell(ect, 2, er, not r3On ? '– no gamma' : r3S ? '✓ ' + w3S : '✗ none', text_color = r3S ? c_grn : color.gray, text_size = _txtsz, text_halign = text.align_left)
            er += 1
        _man = array.new_string()
        if i_r4
            array.push(_man, i_r4_tx)
        if i_rx1 != ''
            array.push(_man, i_rx1)
        if i_rx2 != ''
            array.push(_man, i_rx2)
        if array.size(_man) > 0
            for _mi = 0 to array.size(_man) - 1 by 1
                table.cell(ect, 0, er, array.get(_man, _mi), text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
                table.cell(ect, 1, er, readyL ? '→ confirm' : '·', text_color = readyL ? c_amb : color.gray, text_size = _txtsz, text_halign = text.align_left)
                table.cell(ect, 2, er, readyS ? '→ confirm' : '·', text_color = readyS ? c_amb : color.gray, text_size = _txtsz, text_halign = text.align_left)
                er += 1
        string _sL = readyL ? 'READY' : str.tostring(ecL) + ' of ' + str.tostring(ecTot)
        string _sS = readyS ? 'READY' : str.tostring(ecS) + ' of ' + str.tostring(ecTot)
        color _cL = readyL ? c_grn : color.new(color.gray, 60)
        color _cS = readyS ? c_grn : color.new(color.gray, 60)
        table.cell(ect, 0, er, 'Setup', text_color = col_tblbl, text_size = _txtsz, text_halign = text.align_left)
        table.cell(ect, 1, er, _sL, text_color = color.white, bgcolor = color.new(_cL, 25), text_size = _txtsz, text_halign = text.align_left)
        table.cell(ect, 2, er, _sS, text_color = color.white, bgcolor = color.new(_cS, 25), text_size = _txtsz, text_halign = text.align_left)

// ============================================================
// === ALERTS ===
//   Alerts snapshot inputs at creation: re-create alerts after
//   pasting a new gamma string.
// ============================================================
alertcondition(evEnter, 'KVP: entered inducement', 'Price entered an inducement zone - the liquidity beyond the obvious level has not been taken')
alertcondition(evRecl, 'KVP: sweep and reclaim', 'Inducement liquidity swept and closed back inside')
alertcondition(evFail, 'KVP: sweep without reclaim', 'Inducement liquidity swept, no reclaim inside the window')
alertcondition(evZone, 'KVP: key zone reached', 'Price reached the nearest key zone')
alertcondition(evExh, 'KVP: budget exhausted', 'Daily range budget fully consumed')
alertcondition(evReadyL, 'KVP: long setup ready', 'Entry checklist: all automatic long rules pass - confirm the lower-timeframe trigger')
alertcondition(evReadyS, 'KVP: short setup ready', 'Entry checklist: all automatic short rules pass - confirm the lower-timeframe trigger')

// ============================================================
// === DATA WINDOW ===
// ============================================================
plot(pct_used, 'Budget used % (DR)', display = display.data_window)
plot(pct_iv, 'Budget used % (IV)', display = display.data_window)
plot(adr, 'DR', display = display.data_window)
plot(impl, 'Implied budget', display = display.data_window)
plot(iv_ratio, 'Implied / DR', display = display.data_window)
plot(ts9, 'VIX9D / VIX', display = display.data_window)
plot(vvChg, 'VVIX % vs 18:00', display = display.data_window)
plot(regSig, 'Regime (1 / 0 / -1)', display = display.data_window)
plot(volLean, 'Vol lean (1 / 0 / -1)', display = display.data_window)
plot(irHi, 'Bigger-day threshold', display = display.data_window)
plot(irLo, 'Quieter-day threshold', display = display.data_window)
plot(calOver, 'VIX / real range (median)', display = display.data_window)
plot(implAdj, 'VIX expects, adjusted', display = display.data_window)
plot(calN, 'Calibration days', display = display.data_window)

plot(w_rng, 'Week range', display = display.data_window)
plot(wadr, 'Week denominator', display = display.data_window)
plot(w_pct, 'Week used %', display = display.data_window)
plot(w_rem_up, 'Week room up', display = display.data_window)
plot(w_rem_dn, 'Week room down', display = display.data_window)
plot(w_ext, 'Week extension', display = display.data_window)
plot(_wdIdx + 1, 'Week day of 5', display = display.data_window)
plot(array.get(wExt, 0), 'Week ext Mon', display = display.data_window)
plot(array.get(wExt, 1), 'Week ext Tue', display = display.data_window)
plot(array.get(wExt, 2), 'Week ext Wed', display = display.data_window)
plot(array.get(wExt, 3), 'Week ext Thu', display = display.data_window)
plot(array.get(wExt, 4), 'Week ext Fri', display = display.data_window)

plot(m_rng, 'Month range', display = display.data_window)
plot(madr, 'Month denominator', display = display.data_window)
plot(m_pct, 'Month used %', display = display.data_window)
plot(m_rem_up, 'Month room up', display = display.data_window)
plot(m_rem_dn, 'Month room down', display = display.data_window)
plot(m_days, 'Month trading day', display = display.data_window)
````
