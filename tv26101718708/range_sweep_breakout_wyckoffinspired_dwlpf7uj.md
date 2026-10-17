# Range Sweep Breakout (Wyckoff-inspired)

- url: https://www.tradingview.com/script/dwLpf7uJ/
- type: indicator
- pine_id: PUB;364c88d7670b4c5e9119896c4dfbe63e
- version: 1.0

## Description

█ OVERVIEW
Range Sweep Breakout is an indicator inspired by the Wyckoff method. It takes one principle from it that can be seen in any consolidation, without the phase model and without volume: before price leaves a range, it often collects stops on the opposite side first.

Inside a consolidation, price moves between two edges. Just beyond them sit stop orders: below the bottom they protect longs, and above the top they protect shorts. A wick beyond an edge, after which price returns to the middle, can trigger those stops and knock one side out of the market. In Wyckoff, that move under support is a Spring, and the one above resistance is a UTAD.

The wick alone confirms nothing. A stop hunt is confirmed only once price has moved back far enough into the range, by a set percentage of its height.

A confirmed sweep points to the expected direction:
• Spring below the range → expected breakout up.
• UTAD above the range → expected breakout down.

The most recent confirmed sweep sets the bias of the range. A breakout in line with the bias is marked as SOS or SOW. A breakout with no prior confirmed sweep is a plain BO. A breakout against the last sweep gives no signal by default; once such a breakout is confirmed, the range is still closed and drawn in grey. Both of these behaviours can be changed in the Signals group.

A failed breakout does not disappear from the chart. The label stays, the range stays active, and the extreme of the failed breakout becomes a candidate for the next sweep on that side.

A range in which price does move between two levels, but the regression line of the closes drifts in one direction, is rejected. That is a trend with pullbacks, not a consolidation.

A range edge is not set by a single extreme wick. The indicator takes the second-highest swing high and the second-lowest swing low. A single move further beyond that edge stays outside the range and can be treated as a sweep.

The indicator tracks one range at a time.

Why the simplification
The mechanics described by Wyckoff have not gone away. A large player still cannot buy or sell a large position all at once without moving price against itself. It therefore builds the position inside a range and collects liquidity where the stop-losses sit. A Spring and an upthrust are, in practice, the same thing that is now called a liquidity sweep. The pace and the tools have changed, not the principle itself.

What has blurred is the textbook pattern. The full A–E phase layout, with every event in place, is a teaching model. On a live chart you usually see only a fragment: a range, one false breakout, and an exit. Looking for the complete set of events ends in fitting labels to noise.

The same layout also repeats across many timeframes. On the lower ones the events are compressed, and there are many apparent ranges, so two valid readings of the same chart often differ. Volume is less reliable than it used to be, especially on forex, where only tick volume is available.

That is why the indicator does not try to reconstruct the whole pattern. It looks for one repeatable event: a false break of a range edge and a return to the middle. The filter is the loose part, not the logic. A sweep without a return into the range is not a sweep.

The cleanest structures appear on liquid instruments and on higher timeframes (4h, 1D, 1W). On low timeframes the indicator will more often show local stop collection inside a larger move.

Hence the name “Wyckoff-inspired”, not “Wyckoff”. The indicator does not use phases A–E, does not analyse the climax, secondary tests or LPS/LPSY, and does not use volume. Direction comes only from the most recent confirmed sweep.

█ CONCEPTS
The indicator combines consolidation detection, swing structure, sweeps on both sides of the range, their confirmation, and the breakout. The pieces depend on each other: the range must meet the consolidation conditions, the sweep must be confirmed, and the breakout is judged against the most recent confirmed sweep.

Range Structure
A range is the longest window that meets the consolidation conditions, searched between N and N × “Max. range length searched” bars. It starts at the first test of an edge.
The range edges are:
• Top — the second-highest swing high,
• Bottom — the second-lowest swing low.
The highest or lowest wick therefore does not by itself define the whole range. It can lie beyond the edge and be read as a sweep.

Range Detection
Min. edge-to-edge swings sets how many times price must travel from one edge to the other before the move is treated as a consolidation.
A higher value requires more mature ranges, limits the number of consolidations found, and filters out weaker structures. A lower value finds more ranges, but raises the risk that a short move is treated as a consolidation.
Edge zone sets how close to an edge a swing must get to count as a test of that side of the range. The value is given as a percentage of the range height.
Min. range height (x ATR) rejects very narrow ranges. The height between the edges must be at least the set multiple of ATR.
Max. drift inside range rejects apparent consolidations that are really a trend with pullbacks. The indicator fits a regression line to the closes and rejects the window if that line moves by more than the set percentage of the range height.
A window is not treated as a range if, inside it, price has already broken out in a way that would have counted as a successful breakout live, or if a breakout is still in progress on the last bar.

Range Window N
The minimum length of a range depends on the timeframe. N can be set separately for:
• 1W and higher,
• 1D – <1W,
• 4h – <1D,
• 1h – <4h,
• 15m – <1h,
• below 15m.
N is also the unit for settings marked “x window” and “% of window”. Changing N therefore affects not only the minimum range length, but also the search reach, the maximum range duration, the time allowed to confirm a sweep, and the failed-breakout window.

Pivot Structure
Swing highs and swing lows are detected using up to three pivot lengths. A pivot needs a set number of bars on both sides before it is confirmed. The results of all active lengths are merged into one alternating high–low–high sequence, on which the edge-to-edge crossings are counted.
A shorter length finds more small swings and makes ranges easier to find. A longer length keeps only clear swings and gives a more selective structure. A swing is known only after as many bars as its length have passed.

Price Source
Price source sets whether edges and sweeps are calculated from:
• High/Low (wick) — the full candle range, including wicks,
• Close — closing prices only.
High/Low (wick) is the recommended setting, because a stop hunt usually shows up as a wick beyond the range.

Sweep — Spring / UTAD
A sweep starts as a candidate. A candidate forms when price moves beyond an edge but the candle closes back inside the range:
• below Bottom → a Spring candidate,
• above Top → a UTAD candidate.
The extreme of a failed breakout also becomes a candidate.
A return into the range is not enough by itself. Confirmation sets how far back price must move:
• Spring: Close ≥ Bottom + X% of the range height,
• UTAD: Close ≤ Top − X% of the range height.
Only then does the sweep set the bias:
• Spring → bullish bias, expected breakout up,
• UTAD → bearish bias, expected breakout down.
If both sides confirm on the same bar, the later sweep sets the bias. A candidate that is not confirmed within the set time (Candidate lifetime) expires.

Seed Sweeps
Optionally, the indicator detects sweeps that have already happened inside a newly found range. This matters when a classic Spring or UTAD was one of the moves that formed the range itself.
Only an extreme that occurred after the given edge was formed counts. An extreme from before the edge was formed is the start of the structure, for example a climax, not a sweep of that range. The extreme must also stay within Real breakout distance. A deeper move is treated as a breakout, and no range forms around it.
If such a sweep already meets the confirmation condition, it sets the bias of the new range immediately. If it does not yet, it stays a candidate and waits for confirmation like a live sweep.

Breakout
A breakout occurs when a candle closes far enough beyond an edge:
• up — Close > Top + ATR × Buffer,
• down — Close < Bottom − ATR × Buffer.
The buffer limits breakouts that are only a small step beyond the level.
The breakout is then compared with the most recent confirmed sweep:
• Spring → breakout up → SOS,
• UTAD → breakout down → SOW,
• no confirmed sweep → BO,
• breakout against the bias → no signal by default.
The behaviour in the last two cases can be changed in the Signals group: a breakout without a sweep can give a BO or nothing, and a breakout against the sweep can give nothing or a BO. No signal does not keep the range open. Once the breakout is confirmed, the range is drawn in the neutral colour.

Failed Breakout
A breakout is not treated as final straight away. The indicator checks whether price returns to the range within the set window (Failed breakout window).
If it returns:
• a ✖ mark appears,
• the original signal label stays on the chart,
• the range stays active,
• the extreme of the failed breakout becomes a sweep candidate on that side.
If price does not return, the breakout is confirmed and the range is closed and drawn.
In Wyckoff mode the cross carries the name of the original signal (✖ SOS, ✖ SOW or ✖ BO). In Plain mode it is ✖ Failed. A breakout that gave no signal fails silently: there is no ✖ and no alert, but the range stays active and the extreme still becomes a sweep candidate.

Real Breakout Distance
Real breakout distance sets how far price must move away from the edge for the breakout to be confirmed immediately, without waiting until the end of the failed-breakout window.
The same threshold is used when searching for ranges: a window in which price has already moved this far beyond an edge is not treated as a consolidation.

Range Duration
Every range has a maximum duration, given as a multiple of N. If no confirmed breakout occurs in that time, the range expires.
An expired range stays on the chart, is drawn in the neutral colour, has a dotted border, and gets a ⌛ symbol. Sweeps from an expired range no longer affect new signals.

Active Range
A range in progress is shown as a dashed box with a status description:
• whether there is a confirmed sweep and which direction it points to,
• whether there is a candidate waiting for confirmation,
• whether a breakout is waiting for confirmation,
• how long the range has lasted.
The active-range box is therefore not just an area on the chart. It shows the current state of the indicator logic.

Zigzag
The optional zigzag connects the swings inside a completed range. It does not generate signals. It only shows how price moved between the edges and what structure formed the range.

Wyckoff Terminology
Labels can use Wyckoff terminology or plain descriptive names.
Wyckoff mode:
• Spring — a sweep below the range,
• UTAD — a sweep above the range,
• SOS — a breakout up after a Spring,
• SOW — a breakout down after a UTAD,
• BO — a breakout with no prior sweep.
Plain mode:
• Low sweep, High sweep, BO+, BO, ✖ Failed.

The terms describe price behaviour within the indicator logic, not a full classification of a Wyckoff structure.

█ FEATURES
• Automatic detection of consolidations from repeated price crossings between the edges.
• Edges set by the second-highest swing high and the second-lowest swing low.
• High/Low or Close as the price source.
• Minimum range-height filter relative to ATR.
• Drift filter rejecting trends with pullbacks.
• A separate window N for each timeframe band.
• Detection of sweeps below and above the range.
• Confirmation of Spring / UTAD after a set return of price into the range.
• Optional detection of sweeps that have already happened inside a found range.
• Bias set by the most recent confirmed sweep.
• Breakouts with a configurable ATR buffer.
• SOS / SOW distinguished from a plain BO.
• Configurable signals for breakouts without a sweep and breakouts against the sweep.
• Detection of failed breakouts and their conversion into sweep candidates.
• Expiry of ranges that last too long without a breakout.
• Optional zigzag showing price movement between the edges.
• Active-range box with a description of the current state.
• Labels in Wyckoff terminology or in plain names.
• Extension of the broken level to the right for watching a retest.
• Configurable bullish, bearish and neutral colours.
• Alerts: Spring, UTAD, breakout, failed breakout and confirmed breakout.
• Hidden plots for backtests and use in strategies.

█ APPLICATIONS
Range Analysis
The indicator is mainly for automatically finding consolidations in which price repeatedly moves between the same levels. Not every sideways move is treated as a range. It needs enough crossings, enough height, no excessive drift, and no successful breakout in the period under review.

Breakout Analysis
A breakout can be judged in the context of an earlier sweep. The most characteristic sequences are:
Spring → breakout up → SOS
UTAD → breakout down → SOW
The indicator also shows a plain BO when there was no confirmed sweep beforehand.

Failed Breakout Analysis
A failed breakout is not treated only as a wrong signal. Its extreme can become the next sweep, which makes it possible to follow the sequence:
breakout → return into the range → sweep → confirmation → next breakout.

Example of Use
An active range is best treated as an area of balance, not as an automatic entry signal. Before reacting to a breakout it is worth taking into account:
• the side of the breakout,
• the most recent confirmed sweep and the direction that follows from it,
• where the breakout sits relative to the whole structure,
• volume behaviour, where volume is available — rising volume on the breakout is often read as confirmation,
• momentum and the context from a higher timeframe.

The box, the wick, a Spring, a UTAD or a breakout label is not by itself a sufficient reason to take a trade.

█ NOTES
• The indicator is not a full implementation of the Wyckoff method and does not use volume or order-flow data.
• Signals, alerts and hidden plots are produced after the bar closes, on the bar where the event becomes known — with no look-ahead.
• A range is detected with a delay: swings are known only after several bars, and the box starts in the past. Spring / UTAD labels are placed retroactively on the wick bar, at the moment the sweep is confirmed or the range is found. The alert arrives at confirmation, not when the wick forms.
• A completed range is drawn only after a confirmed breakout or after expiry. Until then the dashed box of the active range is visible.
• Default signal settings: a breakout without a sweep gives a BO, a breakout against the sweep gives no signal. Both behaviours can be changed. No signal means a grey range, not the absence of a range.
• Indicator signals do not replace independent market analysis or risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Range Sweep Breakout (Wyckoff-inspired)", "RSB", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=100, max_bars_back=5000)

// HOW IT WORKS
// Range → stop hunt (sweep) on one side → breakout on the other side. The direction is never assumed in advance.
//
// 1. Range      The longest window of N … (N × max. length) bars in which price crossed from one edge to the
//               other at least K times. Edges are the 2nd highest swing high and the 2nd lowest swing low,
//               i.e. levels tested at least twice; the single most extreme high / low may lie beyond them.
//               The box, the breakout buffer and sweep detection are all measured from these edges.
//               A window is rejected if it contains a move beyond an edge that would count as a real
//               breakout under the live rules (too deep, or closes beyond the edge for longer than the
//               failed-breakout window), if a breakout is still in progress on the last bar, or if the
//               regression line of closes drifts too far (a trend with pullbacks). The range starts at
//               the first edge test.
//               Optionally, the extreme beyond an edge that came after the edge was set is treated as a
//               sweep that already happened inside the range.
// 2. Sweep      A wick beyond an edge with the close back inside, or a failed breakout.
// 3. Confirmed  A sweep counts only after price moves back into the range by X % of its height:
//               low sweep → Spring (bias up), high sweep → UTAD (bias down).
//               The most recent confirmed sweep sets the bias.
// 4. Breakout   First close beyond an edge (plus buffer):
//               in the direction of the bias     → ▲ SOS / ▼ SOW
//               no confirmed sweep               → ▲ BO / ▼ BO (or no signal, see inputs)
//               against the bias                 → no signal (or BO, see inputs)
// 5. Failure    A close back inside within M bars marks the breakout as failed (✖). The signal label
//               stays on the chart, the range stays active and the failed breakout becomes a sweep
//               candidate on that side.
// 6. Drawing    A range is drawn once, when it ends: after a confirmed breakout (box up to the breakout
//               bar) or after expiry (grey, dotted, ⌛).

// INPUTS

// Signals
gS = "Signals"
counterMode  = input.string("No signal", "Breakout against the last sweep", options=["No signal", "Signal (BO)"], group=gS,
     tooltip="What to do when price breaks out in the OPPOSITE direction to the last confirmed stop hunt.\nExample: price ran the stops above the range and turned back down (UTAD, which points down), but then broke out upward anyway.\n\nNo signal: no label and no alert; the range is drawn in grey.\nSignal (BO): a regular ▲ BO / ▼ BO breakout signal.")
noSweepMode  = input.string("Signal (BO)", "Breakout without a confirmed sweep", options=["Signal (BO)", "No signal"], group=gS,
     tooltip="What to do with a plain breakout that was NOT preceded by a stop hunt on the other side (no confirmed Spring or UTAD).\n\nSignal (BO): a ▲ BO / ▼ BO signal.\nNo signal: grey box only, no label and no alert. The indicator then shows only SOS / SOW, i.e. breakouts that follow a stop hunt.")

// Range detection
gB = "Range Detection"
pivotSource  = input.string("High/Low (wick)", "Price source", options=["High/Low (wick)", "Close"], group=gB,
     tooltip="Which prices are used to define the range edges and to detect stop hunts.\n\nHigh/Low (wick): full candles including wicks. Recommended, because a stop hunt usually shows up as a wick.\nClose: closing prices only. Wicks are ignored, edges are tighter and fewer stop hunts are detected.")
minCross     = input.int(3, "Min. edge-to-edge swings", minval=2, group=gB,
     tooltip="How many times price must travel from one edge of the range to the other before the move is treated as a range rather than a trend.\nExample for 3: bottom → top → bottom → top.\n\nHigher = only mature ranges, tested repeatedly from both sides.\nLower = more ranges, but weaker ones.\n\nA period in which price has already clearly left the range (e.g. a sharp V-shaped drop and recovery) is never treated as a range.")
touchPct     = input.float(25.0, "Edge zone (% of range height)", minval=1.0, maxval=50.0, step=5.0, group=gB,
     tooltip="How close to an edge price must get for it to count as a test of that edge, as a % of the range height.\nExample: range 100–200, setting 25% → any swing low up to 125 counts as a test of the bottom, any swing high from 175 as a test of the top.\n\nAn edge is a level tested at least twice. A single highest high or lowest low does not define the edge, because it may be a stop hunt.\n\nHigher = ranges are easier to find, but less clean.")
minHeightATR = input.float(2.0, "Min. range height (x ATR)", minval=0.0, step=0.5, group=gB,
     tooltip="Minimum height of the range, in multiples of the average candle size (ATR).\nExample: 2 = the range must be at least twice as tall as a typical candle.\n\nFilters out very narrow ranges where any breakout is just noise.\n0 = no filter.")
maxDriftPct  = input.float(50.0, "Max. drift inside range (% of height)", minval=0.0, maxval=100.0, step=5.0, group=gB,
     tooltip="Rejects a trend that only looks like a range, e.g. an uptrend with pullbacks where price swings between highs and lows but keeps moving higher.\n\nThe indicator measures how far the average price (a trend line fitted to the closes) moves from the start to the end of the range. If it moves more than X% of the range height, it is a trend, not a range.\n\nLower = only flat ranges.\n100 = filter off.")
maxLookMult  = input.float(4.0, "Max. range length searched (x window)", minval=1.0, step=0.5, group=gB,
     tooltip="How far back to search for a range, as a multiple of window N (set per timeframe in the Range Window group).\nExample: N = 40, setting 4 → periods of 40 to 160 bars are checked and the longest one that qualifies is used.\n\nHigher = longer ranges, but slower calculation.")
maxDurMult   = input.float(10.0, "Max. range duration (x window)", minval=1.0, step=1.0, group=gB,
     tooltip="How long a range may last without a successful breakout, as a multiple of window N.\nExample: N = 40, setting 10 → 400 bars.\n\nAfter that the range expires: it stays on the chart as a grey box with a dotted border and a ⌛ icon, and the indicator starts looking for a new one.\nThe time is counted from the start of the range; failed breakouts do not reset it.")
atrLen       = input.int(200, "ATR length", minval=1, group=gB,
     tooltip="Number of bars used to calculate the average candle size (ATR). A long period such as 200 gives a stable value that a single large candle does not distort.\n\nATR is used for three things only: the minimum range height, the breakout buffer and the label offset from price. All other thresholds are a % of the range height.")

// Range window per timeframe
gW = "Range Window N (bars) by Timeframe"
winTip = "N = the shortest range (in bars) the indicator will accept on this timeframe.\n\nN is also the unit for settings marked “x window” / “% of window”: how far back to search for a range, how long it may last, how long a stop hunt has to confirm and how many bars a breakout has to return into the range.\n\nTimeframes between thresholds use the lower one, e.g. 2h → the “1h – <4h” setting."
winW   = input.int(20,  "1W and higher", minval=5, maxval=1500, group=gW, tooltip=winTip)
winD   = input.int(40,  "1D – <1W",      minval=5, maxval=1500, group=gW, tooltip=winTip)
win4h  = input.int(60,  "4h – <1D",      minval=5, maxval=1500, group=gW, tooltip=winTip)
win1h  = input.int(80,  "1h – <4h",      minval=5, maxval=1500, group=gW, tooltip=winTip)
win15  = input.int(100, "15m – <1h",     minval=5, maxval=1500, group=gW, tooltip=winTip)
winLow = input.int(100, "Below 15m",     minval=5, maxval=1500, group=gW, tooltip=winTip)

// Sweep (Spring / UTAD)
gX = "Sweep (Spring / UTAD)"
confPct      = input.float(50.0, "Confirmation: move back into the range (% of height)", minval=0.0, maxval=100.0, step=5.0, group=gX,
     tooltip="When a stop hunt counts as confirmed.\n\nA wick beyond a range edge (or a breakout that quickly returned inside) is only a candidate. It becomes a Spring (below the range) or a UTAD (above the range) once a candle closes far enough back inside: X% of the range height away from that edge.\nExample: 50% = a close beyond the middle of the range.\n\nOnly confirmed stop hunts set the expected breakout direction. A mere touch of an edge changes nothing.")
sweepLifeMult = input.float(1.0, "Candidate lifetime (x window)", minval=0.1, step=0.25, group=gX,
     tooltip="How long a stop hunt candidate has to confirm, as a multiple of window N.\nExample: N = 40, setting 1 → 40 bars.\n\nIf price does not move far enough back into the range within that time, the candidate is discarded.")
seedSweeps   = input.bool(true, "Detect sweeps already inside the range", group=gX,
     tooltip="When a new range is found, the indicator checks whether a stop hunt has already happened inside it: the lowest low below the bottom edge (or the highest high above the top edge) that came AFTER that edge was formed. Such a wick is treated as a Spring / UTAD, with the same confirmation rule.\n\nWithout this option, a classic Spring that itself forms the bottom of the range would never be recognised. The wick must stay within the Real breakout distance; a deeper one counts as a breakout, and no range is detected around it.\nAn extreme that came BEFORE the edge was formed marks the start of the range (e.g. a climax), not a stop hunt.")

// Breakout
gO = "Breakout"
breakBufATR  = input.float(1.0, "Buffer beyond edge (x ATR)", minval=0.0, step=0.05, group=gO,
     tooltip="How far beyond a range edge a candle must close to count as a breakout, in multiples of the average candle size (ATR).\nExample: 1 = a close at least one average candle beyond the edge.\n0 = any close outside the range.\n\nHigher = fewer false breakouts, but the signal comes later and further from the edge.")
failPct      = input.float(25.0, "Failed breakout window (% of window)", minval=0.0, step=5.0, group=gO,
     tooltip="For how many bars after a breakout a return into the range marks it as failed, as a % of window N (minimum 2 bars).\nExample: N = 40, setting 25% → 10 bars.\n\nIf a candle closes back inside the range within that time:\n• a ✖ appears,\n• the signal label stays on the chart,\n• the range stays active,\n• the failed breakout becomes a stop hunt candidate on that side.\nOtherwise the breakout is confirmed.")
deepPct      = input.float(25.0, "Real breakout distance (% of height)", minval=1.0, step=5.0, group=gO,
     tooltip="How far from the edge price must move after a breakout for it to be confirmed immediately, without waiting. As a % of the range height.\nExample: range 100–200, setting 25% → an upside breakout is confirmed once price reaches 225.\n\nThe same threshold is used when searching for a range: a period in which price has already moved this far beyond an edge is not treated as a range.")

// Pivots
gP = "Pivots (Zigzag)"
pivTip = "The indicator finds local swing highs and lows. Length = how many bars on each side must be lower (for a high) or higher (for a low).\nThe results of all three lengths are merged into one high–low–high line, which is used to count edge-to-edge moves.\n\nShorter = more small swings, ranges are easier to find.\nLonger = only clear swings.\n\nNote: a swing high/low is known only after as many bars as its length."
enablePivot1 = input.bool(true, "Pivot 1", inline="p1", group=gP)
pivotLen1    = input.int(5,  "length", minval=2, inline="p1", group=gP, tooltip=pivTip)
enablePivot2 = input.bool(true, "Pivot 2", inline="p2", group=gP)
pivotLen2    = input.int(10, "length", minval=2, inline="p2", group=gP, tooltip=pivTip)
enablePivot3 = input.bool(true, "Pivot 3", inline="p3", group=gP)
pivotLen3    = input.int(20, "length", minval=2, inline="p3", group=gP, tooltip=pivTip)
maxPivotsMerged = input.int(500, "Max. pivots kept in history", minval=50, maxval=1500, group=gP,
     tooltip="How many recent swing highs and lows the indicator keeps in memory. It must cover the longest period searched (N × “Max. range length searched”).\nIf ranges look cut off on the left, increase it.\n\nHigher = slower calculation.")

// Display
gD = "Display"
labelStyle     = input.string("Wyckoff", "Label style", options=["Wyckoff", "Plain"], group=gD,
     tooltip="Wyckoff: Wyckoff terms — Spring, UTAD, SOS, SOW.\nPlain: descriptive names — Low sweep, High sweep, BO+, ✖ Failed.\n\nIn both modes, hovering over a label shows an explanation.")
showSignal     = input.bool(true, "Show breakout signal", group=gD,
     tooltip="Label on the breakout candle:\n\n▲ SOS / ▼ SOW (Plain: BO+) — a breakout after price ran the stops on the opposite side: Spring below the range → breakout up, UTAD above the range → breakout down.\n▲ BO / ▼ BO — a plain breakout with no stop hunt before it.\n\nThe label stays on the chart even if the breakout later fails.")
showLabels     = input.bool(true, "Show sweep and ✖ labels", group=gD,
     tooltip="Labels for confirmed stop hunts (Spring / UTAD, or Low / High sweep in Plain mode) and ✖ on failed breakouts.")
showBox        = input.bool(true, "Show range box", group=gD,
     tooltip="Box of a completed range, in the signal colour (grey = no signal).\nDrawn only when the range ends:\n• after a confirmed breakout — extends to the breakout candle,\n• after expiry — grey, with a dotted border and a ⌛ icon.\nUntil then, the active range is shown as a dashed box.")
showZigzag     = input.bool(true, "Show zigzag", group=gD,
     tooltip="A line connecting the swing highs and lows inside the range, showing how price moved from edge to edge.")
showForming    = input.bool(true, "Show range that is still forming", group=gD,
     tooltip="Dashed box of the active range with a status label: whether stops have been run, the expected breakout direction, whether a breakout is awaiting confirmation and how many bars the range has lasted.")
extendBars     = input.int(20, "Extend broken level (bars)", minval=0, group=gD,
     tooltip="How many bars to extend the broken edge to the right after a breakout. Helps judge whether price comes back to retest the level.")
labelSizeInput = input.string("Small", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=gD,
     tooltip="Size of all labels.")
sigOffsetMult  = input.float(0.5, "Label offset from price (x ATR)", minval=0.0, step=0.1, group=gD,
     tooltip="Distance between a label and the candle wick, in multiples of the average candle size (ATR), so labels do not cover price.")
fillTransp     = input.int(88, "Box fill transparency (%)", minval=0, maxval=100, group=gD,
     tooltip="Fill transparency of a completed range box. 100 = border only, no fill.")

// Colors
gK = "Colors"
bullColor      = input.color(color.new(#26a69a, 0), "Bullish", inline="col1", group=gK)
bearColor      = input.color(color.new(#ef5350, 0), "Bearish", inline="col1", group=gK,
     tooltip="Bullish: upside signals and confirmed Springs.\nBearish: downside signals and confirmed UTADs.")
neutralColor   = input.color(color.new(#9e9e9e, 0), "Neutral", inline="col2", group=gK)
labelTextColor = input.color(color.white, "Label text", inline="col2", group=gK,
     tooltip="Neutral: breakouts without a signal, expired ranges, ✖ labels and level lines.\nLabel text: colour of the text on all labels.")

labelSizeVal = switch labelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

plain = labelStyle == "Plain"

// SETTINGS DERIVED FROM INPUTS

tfSec     = timeframe.in_seconds()
winLen    = tfSec >= 604800 ? winW : tfSec >= 86400 ? winD : tfSec >= 14400 ? win4h : tfSec >= 3600 ? win1h : tfSec >= 900 ? win15 : winLow
maxDur    = int(math.round(winLen * maxDurMult))
failBars  = math.max(2, int(math.round(winLen * failPct / 100.0)))
sweepLife = math.max(2, int(math.round(winLen * sweepLifeMult)))
counterGrey = counterMode == "No signal"
noSweepGrey = noSweepMode == "No signal"

atrVal = ta.atr(atrLen)
srcHi  = pivotSource == "Close" ? close : high
srcLo  = pivotSource == "Close" ? close : low

ph1 = ta.pivothigh(srcHi, pivotLen1, pivotLen1)
pl1 = ta.pivotlow(srcLo, pivotLen1, pivotLen1)
ph2 = ta.pivothigh(srcHi, pivotLen2, pivotLen2)
pl2 = ta.pivotlow(srcLo, pivotLen2, pivotLen2)
ph3 = ta.pivothigh(srcHi, pivotLen3, pivotLen3)
pl3 = ta.pivotlow(srcLo, pivotLen3, pivotLen3)

// ZIGZAG
// Pivots of all enabled lengths merged into one history, sorted by bar and strictly alternating H/L.

var mPrice = array.new<float>()
var mBar   = array.new<int>()
var mType  = array.new<string>()

mergeInsert(float price, int bar, string ptype) =>
    n = mBar.size()
    idx = n
    if n > 0
        for i = n - 1 to 0
            if bar >= mBar.get(i)
                break
            idx := i
    mPrice.insert(idx, price)
    mBar.insert(idx, bar)
    mType.insert(idx, ptype)
    j = 1
    while j < mType.size()
        if mType.get(j) == mType.get(j - 1)
            pPrev = mPrice.get(j - 1)
            pCurr = mPrice.get(j)
            removeIdx = mType.get(j) == "H" ? (pCurr >= pPrev ? j - 1 : j) : (pCurr <= pPrev ? j - 1 : j)
            mPrice.remove(removeIdx)
            mBar.remove(removeIdx)
            mType.remove(removeIdx)
            j := math.max(j - 1, 1)
        else
            j += 1
    while mType.size() > maxPivotsMerged
        mPrice.shift()
        mBar.shift()
        mType.shift()
    true

addPivots(float ph, float pl, int len, bool en) =>
    added = false
    if en and not na(ph)
        mergeInsert(ph, bar_index - len, "H")
        added := true
    if en and not na(pl)
        mergeInsert(pl, bar_index - len, "L")
        added := true
    added

// Index of the first merged pivot after a given bar (size() if none)
firstAfter(int b) =>
    n = mBar.size()
    start = n
    if n > 0
        for i = n - 1 to 0
            if mBar.get(i) <= b
                break
            start := i
    start

// Edges of a window and edge-to-edge swings.
// Top / bottom edge = the 2nd highest swing high / 2nd lowest swing low since fromBar, i.e. a level
// tested at least twice (the single most extreme swing may be a sweep beyond it).
// A crossing is counted each time the edge zone changes (top → bottom or bottom → top).
// Also returns the bars of the swings that define the edges.
scanWindow(int fromBar, float zonePct) =>
    float h1 = na
    float h2 = na
    float l1 = na
    float l2 = na
    int h1B = na
    int h2B = na
    int l1B = na
    int l2B = na
    n = mBar.size()
    start = firstAfter(fromBar - 1)
    if start < n
        for i = start to n - 1
            p = mPrice.get(i)
            b = mBar.get(i)
            if mType.get(i) == "H"
                if na(h1) or p > h1
                    h2  := h1
                    h2B := h1B
                    h1  := p
                    h1B := b
                else if na(h2) or p > h2
                    h2  := p
                    h2B := b
            else
                if na(l1) or p < l1
                    l2  := l1
                    l2B := l1B
                    l1  := p
                    l1B := b
                else if na(l2) or p < l2
                    l2  := p
                    l2B := b
    int cross  = 0
    int firstB = na
    if not na(h2) and not na(l2) and h2 > l2 and start < n
        z = zonePct / 100.0 * (h2 - l2)
        int last = 0
        for i = start to n - 1
            p = mPrice.get(i)
            t = mType.get(i)
            int zz = t == "H" and p >= h2 - z ? 1 : t == "L" and p <= l2 + z ? -1 : 0
            if zz != 0
                if na(firstB)
                    firstB := mBar.get(i)
                if last != 0 and zz != last
                    cross += 1
                last := zz
    [h2, l2, cross, firstB, h2B, l2B]

// LABELS

mkLabel(int b, float p, string txt, bool below, color col, string tip) =>
    off = nz(atrVal) * sigOffsetMult
    label.new(b, below ? p - off : p + off, txt, style=below ? label.style_label_up : label.style_label_down, color=col, textcolor=labelTextColor, size=labelSizeVal, tooltip=tip)

sweepTxt(bool bottom) =>
    bottom ? (plain ? "Low sweep" : "Spring") : (plain ? "High sweep" : "UTAD")

sweepTip(bool bottom) =>
    bottom ? "Low sweep (Wyckoff: Spring)\nPrice dipped below the bottom of the range, triggering the stops there, then closed back inside and recovered at least " + str.tostring(confPct) + "% of the range height.\nExpected breakout: UP." : "High sweep (Wyckoff: UTAD, Upthrust After Distribution)\nPrice spiked above the top of the range, triggering the stops there, then closed back inside and fell at least " + str.tostring(confPct) + "% of the range height.\nExpected breakout: DOWN."

sigTxt(int dir, bool withSweep) =>
    dir == 1 ? (withSweep ? (plain ? "▲ BO+" : "▲ SOS") : "▲ BO") : (withSweep ? (plain ? "▼ BO+" : "▼ SOW") : "▼ BO")

sigTip(int dir, bool withSweep) =>
    dir == 1 ? (withSweep ? "Breakout UP after a low sweep (Wyckoff: SOS, Sign of Strength after a Spring).\nPrice first ran the stops below the range, then closed above the range." : "Breakout UP: price closed above the range. No stop hunt below the range came before it.") : (withSweep ? "Breakout DOWN after a high sweep (Wyckoff: SOW, Sign of Weakness after a UTAD).\nPrice first ran the stops above the range, then closed below the range." : "Breakout DOWN: price closed below the range. No stop hunt above the range came before it.")

failTip(int dir) =>
    (dir == 1 ? "Failed breakout UP" : "Failed breakout DOWN") + ": price closed back inside the range within " + str.tostring(failBars) + " bars.\nThe original signal stays on the chart. The " + (dir == 1 ? "high" : "low") + " of this move may now count as a stop hunt " + (dir == 1 ? "above the range (possible UTAD)" : "below the range (possible Spring)") + " once price moves far enough back in."

// STATE (one range at a time)

var bool  bxOn    = false
var int   bxStart = na
var float bxTop   = na
var float bxBot   = na
var int   bias    = 0          // +1 after a confirmed Spring, -1 after a confirmed UTAD
var int   spBar   = na         // confirmed Spring
var float spPx    = na
var int   utBar   = na         // confirmed UTAD
var float utPx    = na
var int   cBotBar = na         // low sweep candidate
var float cBotPx  = na
var int   cTopBar = na         // high sweep candidate
var float cTopPx  = na
var bool  pdOn    = false      // breakout awaiting confirmation
var bool  pdGrey  = false
var int   pdDir   = 0
var int   pdBar   = na
var int   pdUntil = na
var float pdExt   = na
var int   pdExtBar = na
var int   lastEnd = na

// Draws a completed range once, when it ends: after a confirmed breakout (box up to the breakout bar)
// or after expiry without a breakout (dir = 0). Failed breakouts draw nothing, so drawings are never
// deleted and every range stays visible in history.
drawStructure(int dir, bool grey, int endBar) =>
    expired = dir == 0
    col = expired or grey ? neutralColor : dir == 1 ? bullColor : bearColor
    if showBox
        box.new(bxStart, bxTop, endBar, bxBot, border_color=color.new(col, 50), border_style=expired ? line.style_dotted : line.style_solid, bgcolor=color.new(col, expired ? math.min(100, fillTransp + 6) : fillTransp))
    if showZigzag
        pts = array.new<chart.point>()
        n = mBar.size()
        start = firstAfter(bxStart - 1)
        if start < n
            for i = start to n - 1
                if mBar.get(i) > endBar
                    break
                pts.push(chart.point.from_index(mBar.get(i), mPrice.get(i)))
        pts.push(chart.point.from_index(endBar, close[bar_index - endBar]))
        if pts.size() >= 2
            polyline.new(pts, curved=false, closed=false, xloc=xloc.bar_index, line_color=expired ? color.new(col, 40) : col, line_width=expired ? 1 : 2)
    if expired
        line.new(bxStart, bxTop, endBar, bxTop, color=neutralColor, width=1, style=line.style_dotted)
        line.new(bxStart, bxBot, endBar, bxBot, color=neutralColor, width=1, style=line.style_dotted)
        if showLabels
            label.new(endBar, bxTop, "⌛", style=label.style_label_lower_left, color=color.new(neutralColor, 30), textcolor=labelTextColor, size=size.tiny,
                 tooltip="Range expired: no breakout within " + str.tostring(maxDur) + " bars (setting: Max. range duration).\nStop hunts from this range no longer count.")
    else
        brk = dir == 1 ? bxTop : bxBot
        oth = dir == 1 ? bxBot : bxTop
        line.new(bxStart, brk, endBar + extendBars, brk, color=neutralColor, width=1, style=line.style_dashed)
        line.new(bxStart, oth, endBar, oth, color=neutralColor, width=1, style=line.style_dotted)
    if showLabels
        if not na(spBar)
            mkLabel(spBar, spPx, sweepTxt(true), true, col, sweepTip(true))
        if not na(utBar)
            mkLabel(utBar, utPx, sweepTxt(false), false, col, sweepTip(false))
    true

// MAIN

a1 = addPivots(ph1, pl1, pivotLen1, enablePivot1)
a2 = addPivots(ph2, pl2, pivotLen2, enablePivot2)
a3 = addPivots(ph3, pl3, pivotLen3, enablePivot3)

int  sigDir  = 0
bool failNow = false
bool confNow = false

// Active range
if barstate.isconfirmed and bxOn and not na(atrVal)
    h = bxTop - bxBot
    if pdOn
        if pdDir == 1 and srcHi > pdExt
            pdExt    := srcHi
            pdExtBar := bar_index
        if pdDir == -1 and srcLo < pdExt
            pdExt    := srcLo
            pdExtBar := bar_index
        back = pdDir == 1 ? close <= bxTop : close >= bxBot
        deep = pdDir == 1 ? pdExt - bxTop > deepPct / 100.0 * h : bxBot - pdExt > deepPct / 100.0 * h
        if back and not deep
            if not pdGrey
                if showLabels
                    mkLabel(bar_index, pdDir == 1 ? high : low, plain ? "✖ Failed" : pdDir == 1 ? "✖ " + (bias == 1 ? "SOS" : "BO") : "✖ " + (bias == -1 ? "SOW" : "BO"), pdDir == -1, neutralColor, failTip(pdDir))
                alert(pdDir == 1 ? "RSB — failed breakout up, price back in the range (possible UTAD)" : "RSB — failed breakdown, price back in the range (possible Spring)", alert.freq_once_per_bar)
                failNow := true
            // The failed breakout becomes a sweep candidate on that side
            if pdDir == 1
                if na(cTopPx) or pdExt > cTopPx
                    cTopPx  := pdExt
                    cTopBar := pdExtBar
            else
                if na(cBotPx) or pdExt < cBotPx
                    cBotPx  := pdExt
                    cBotBar := pdExtBar
            pdOn   := false
            pdGrey := false
        else if deep or bar_index >= pdUntil
            if not pdGrey
                confNow := true
            drawStructure(pdDir, pdGrey, pdBar)
            pdOn    := false
            pdGrey  := false
            bxOn    := false
            lastEnd := bar_index
    else
        // Sweep candidates: wick beyond an edge, close back inside
        if srcHi > bxTop and close <= bxTop and (na(cTopPx) or srcHi > cTopPx)
            cTopPx  := srcHi
            cTopBar := bar_index
        if srcLo < bxBot and close >= bxBot and (na(cBotPx) or srcLo < cBotPx)
            cBotPx  := srcLo
            cBotBar := bar_index
        // Unconfirmed candidates expire
        if not na(cTopBar) and bar_index - cTopBar > sweepLife
            cTopBar := na
            cTopPx  := na
        if not na(cBotBar) and bar_index - cBotBar > sweepLife
            cBotBar := na
            cBotPx  := na
        // Confirmation: price moved back into the range far enough.
        // If both sides confirm on the same bar, the more recent sweep sets the bias.
        okBot = not na(cBotBar) and close >= bxBot + confPct / 100.0 * h
        okTop = not na(cTopBar) and close <= bxTop - confPct / 100.0 * h
        if okBot or okTop
            bias := okBot and okTop ? (cBotBar >= cTopBar ? 1 : -1) : okBot ? 1 : -1
        if okBot
            spBar   := cBotBar
            spPx    := cBotPx
            cBotBar := na
            cBotPx  := na
            alert("RSB Spring confirmed", alert.freq_once_per_bar)
        if okTop
            utBar   := cTopBar
            utPx    := cTopPx
            cTopBar := na
            cTopPx  := na
            alert("RSB UTAD confirmed", alert.freq_once_per_bar)
        // Breakout
        buf = breakBufATR * atrVal
        int dir = close > bxTop + buf ? 1 : close < bxBot - buf ? -1 : 0
        if dir != 0
            grey = bias == -dir ? counterGrey : bias == 0 ? noSweepGrey : false
            // The signal label is permanent: it stays even if the breakout fails later
            if showSignal and not grey
                ws = bias == dir
                mkLabel(bar_index, dir == 1 ? low : high, sigTxt(dir, ws), dir == 1, dir == 1 ? bullColor : bearColor, sigTip(dir, ws))
            if not grey
                msg = dir == 1 ? (bias == 1 ? "RSB SOS — breakout up after a Spring" : "RSB — range breakout up") : (bias == -1 ? "RSB SOW — breakdown after a UTAD" : "RSB — range breakdown")
                alert(msg, alert.freq_once_per_bar)
                sigDir := dir
            pdOn     := true
            pdGrey   := grey
            pdDir    := dir
            pdBar    := bar_index
            pdUntil  := bar_index + failBars
            pdExt    := dir == 1 ? srcHi : srcLo
            pdExtBar := bar_index
        else if bar_index - bxStart > maxDur
            drawStructure(0, true, bar_index)
            bxOn    := false
            lastEnd := bar_index

// New range: the longest window (N … maxLook bars) in which price crossed from edge to edge
// at least minCross times
if barstate.isconfirmed and not bxOn and not pdOn and not na(atrVal) and bar_index >= winLen
    maxLook = math.min(int(math.round(winLen * maxLookMult)), 4990)
    step    = math.max(1, int(math.floor(winLen / 10.0)))
    float runHi = na
    float runLo = na
    int   runHiBar = na
    int   runLoBar = na
    float bestTop   = na       // edges: 2nd highest swing high / 2nd lowest swing low
    float bestBot   = na
    int   bestTopB  = na       // bars of the swings that define the edges
    int   bestBotB  = na
    float bestHi    = na       // absolute extremes of the window (possible sweeps beyond the edges)
    float bestLo    = na
    int   bestHiBar = na
    int   bestLoBar = na
    int   bestStart = na
    for i = 0 to maxLook - 1
        if i > bar_index or (not na(lastEnd) and bar_index - i <= lastEnd)
            break
        vh = srcHi[i]
        vl = srcLo[i]
        if na(runHi) or vh > runHi
            runHi    := vh
            runHiBar := bar_index - i
        if na(runLo) or vl < runLo
            runLo    := vl
            runLoBar := bar_index - i
        wl = i + 1
        // The full window height is an upper bound for the edge height, so it is a cheap pre-filter
        if wl >= winLen and ((wl - winLen) % step == 0 or i == maxLook - 1) and runHi - runLo >= minHeightATR * atrVal and runHi > runLo
            [cTop, cBot, cr, fb, cTopB, cBotB] = scanWindow(bar_index - i, touchPct)
            if cr >= minCross and not na(fb)
                hc = cTop - cBot
                // Minimum height, measured between the edges
                bool ok = hc >= minHeightATR * atrVal
                // No real breakout inside the window, judged by the same rules as a live breakout:
                // no excursion beyond the edges deeper than the real breakout distance
                // and no run of closes beyond them longer than the failed-breakout window.
                if ok
                    ok := runHi - cTop <= deepPct / 100.0 * hc and cBot - runLo <= deepPct / 100.0 * hc
                if ok
                    // A run mirrors a live breakout: it starts with a close beyond the edge plus the
                    // buffer and lasts until a close back inside the edge
                    bufW = breakBufATR * atrVal
                    int runUp = 0
                    int runDn = 0
                    float sx  = 0.0
                    float sy  = 0.0
                    float sxy = 0.0
                    float sxx = 0.0
                    for k = i to 0
                        c = close[k]
                        runUp := runUp > 0 ? (c > cTop ? runUp + 1 : 0) : (c > cTop + bufW ? 1 : 0)
                        runDn := runDn > 0 ? (c < cBot ? runDn + 1 : 0) : (c < cBot - bufW ? 1 : 0)
                        if runUp > failBars or runDn > failBars
                            ok := false
                            break
                        t = i - k
                        sx  += t
                        sy  += c
                        sxy += t * c
                        sxx += t * t
                    // No range while a breakout is still in progress on the last bar, so a newly
                    // detected range never inherits a breakout that has already started
                    if ok and (runUp > 0 or runDn > 0)
                        ok := false
                    // No trend disguised as a range: the regression line of closes may not
                    // drift across the window by more than maxDriftPct of the range height
                    if ok and maxDriftPct < 100.0 and i > 0
                        nW  = i + 1
                        den = nW * sxx - sx * sx
                        slope = den != 0 ? (nW * sxy - sx * sy) / den : 0.0
                        if math.abs(slope) * i > maxDriftPct / 100.0 * hc
                            ok := false
                if ok
                    bestTop   := cTop
                    bestBot   := cBot
                    bestTopB  := cTopB
                    bestBotB  := cBotB
                    bestHi    := runHi
                    bestLo    := runLo
                    bestHiBar := runHiBar
                    bestLoBar := runLoBar
                    bestStart := fb
    if not na(bestStart)
        bxOn    := true
        bxStart := bestStart
        bxTop   := bestTop
        bxBot   := bestBot
        bias    := 0
        spBar   := na
        spPx    := na
        utBar   := na
        utPx    := na
        cTopBar := na
        cTopPx  := na
        cBotBar := na
        cBotPx  := na
        // Sweeps already inside the window: the extreme beyond an edge that came AFTER
        // the swing defining that edge (an extreme before it is a climax, not a sweep).
        // Confirmation uses the same rule as a live sweep: a close X % of the range height inside the edge.
        if seedSweeps
            h0 = bestTop - bestBot
            int sConf = na
            int uConf = na
            if bestLo < bestBot and not na(bestBotB) and bestLoBar > bestBotB
                for k = bar_index - bestLoBar to 0
                    if close[k] >= bestBot + confPct / 100.0 * h0
                        sConf := bar_index - k
                        break
                if na(sConf)
                    cBotBar := bestLoBar
                    cBotPx  := bestLo
                else
                    spBar := bestLoBar
                    spPx  := bestLo
            if bestHi > bestTop and not na(bestTopB) and bestHiBar > bestTopB
                for k = bar_index - bestHiBar to 0
                    if close[k] <= bestTop - confPct / 100.0 * h0
                        uConf := bar_index - k
                        break
                if na(uConf)
                    cTopBar := bestHiBar
                    cTopPx  := bestHi
                else
                    utBar := bestHiBar
                    utPx  := bestHi
            // The later confirmation sets the bias; if both confirmed on the same bar, the later
            // sweep wins (same rule as for live sweeps)
            bias := not na(sConf) and not na(uConf) ? (sConf != uConf ? (sConf > uConf ? 1 : -1) : bestLoBar >= bestHiBar ? 1 : -1) : not na(sConf) ? 1 : not na(uConf) ? -1 : 0
            // A seeded sweep confirmed on this very bar is a fresh event, so it alerts like a live one
            if not na(sConf) and sConf == bar_index
                alert("RSB Spring confirmed", alert.freq_once_per_bar)
            if not na(uConf) and uConf == bar_index
                alert("RSB UTAD confirmed", alert.freq_once_per_bar)

// Active range, redrawn on the last bar
var fBox = array.new<box>()
var fLbl = array.new<label>()

if barstate.islast
    for b in fBox
        b.delete()
    for l in fLbl
        l.delete()
    fBox.clear()
    fLbl.clear()
    if showForming and bxOn
        col = bias == 1 ? bullColor : bias == -1 ? bearColor : neutralColor
        fBox.push(box.new(bxStart, bxTop, bar_index + 5, bxBot, border_color=col, border_style=line.style_dashed, bgcolor=color.new(col, 94)))
        if showLabels
            if not na(spBar)
                fLbl.push(mkLabel(spBar, spPx, sweepTxt(true), true, col, sweepTip(true)))
            if not na(utBar)
                fLbl.push(mkLabel(utBar, utPx, sweepTxt(false), false, col, sweepTip(false)))
        hyp = bias == 1 ? (plain ? "low swept ✔ → bias ▲" : "Spring ✔ → expecting ▲") : bias == -1 ? (plain ? "high swept ✔ → bias ▼" : "UTAD ✔ → expecting ▼") : "no confirmed sweep yet"
        cand = (na(cBotBar) ? "" : "\nsweep ↓ — awaiting confirmation") + (na(cTopBar) ? "" : "\nsweep ↑ — awaiting confirmation")
        st = pdOn ? (pdGrey ? "\n⏳ breakout against the sweep — no signal" : "\n⏳ breakout — awaiting confirmation") : ""
        txt = "Range — " + hyp + cand + "\n" + str.tostring(bar_index - bxStart) + " bars" + st
        fLbl.push(label.new(bar_index + 5, bxTop, txt, style=label.style_label_left, color=color.new(col, 20), textcolor=labelTextColor, size=labelSizeVal, tooltip="Active range (dashed box), still waiting for a breakout.\n\nA wick beyond the top or bottom that closes back inside may be a stop hunt. It counts once price moves " + str.tostring(confPct) + "% of the range height back in.\nThe most recent confirmed stop hunt sets the expected breakout direction: below the range → up, above the range → down."))

buySig  = sigDir == 1
sellSig = sigDir == -1

// Hidden plots for backtesting / strategy use. Each fires on the bar where the event becomes known (no look-ahead).
plot(buySig  ? 1 : na, "backtest_buy",  display=display.none)
plot(sellSig ? 1 : na, "backtest_sell", display=display.none)
plot(failNow ? 1 : na, "bt_failed_breakout", display=display.none)
plot(confNow ? 1 : na, "bt_breakout_confirmed", display=display.none)

// Alerts
alertcondition(buySig,            title="RSB breakout up (SOS / BO)",   message="RSB breakout up on {{ticker}} at {{close}}")
alertcondition(sellSig,           title="RSB breakdown (SOW / BO)",     message="RSB breakdown on {{ticker}} at {{close}}")
alertcondition(buySig or sellSig, title="RSB signal (any)",             message="RSB signal on {{ticker}} at {{close}}")
alertcondition(failNow,           title="RSB failed breakout",          message="RSB failed breakout, price back in the range on {{ticker}} at {{close}}")
alertcondition(confNow,           title="RSB breakout confirmed",       message="RSB breakout confirmed on {{ticker}} at {{close}}")
````
