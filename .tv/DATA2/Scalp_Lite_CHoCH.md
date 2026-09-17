<!-- tradingview-pine-id: PUB;948d95665e9b46feb705f990628e7d07 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Scalp Lite + CHoCH

Source: https://www.tradingview.com/script/NFJfISiw-Scalp-Lite-CHoCH/

## Description

SCALP LITE + CHoCH
 
WHAT THIS IS
 
Two independent trade engines running on one chart, sharing a single dashboard.
One trades moving-average crosses with volatility-scaled risk. The other trades
breaks of market structure with structure-scaled risk. They are not blended into
a combined signal - they run side by side and are allowed to disagree, because
the disagreement is the most useful thing the script produces.
 
 
ENGINE 1 - SCALP LITE (EMA 9 / EMA 50)
 
The trigger is EMA9 crossing EMA50, filtered by any combination of VWAP side,
above-average volume, a trading session window, and a cooldown between signals.
 
The part worth explaining is the deferred cross, because it fixes a failure mode
that is easy to miss. A crossover is a single-bar event, and ta.crossover() never
fires again while the two averages stay on the same side of each other. A naive
implementation requires every filter to pass on that exact bar - so a cross that
happens premarket, on thin volume, or outside your session window is discarded
permanently, and the script shows nothing while price trends all day.
 
Here, a cross ARMS a direction instead of consuming it. The signal fires on the
first later bar where every enabled filter passes AND the averages still agree
with the armed direction. Nothing is bypassed; the filters simply no longer have
to pass simultaneously on one specific bar. An opposite cross overwrites the
pending direction, so a stale arm cannot survive a reversal. The dashboard shows
which filter is currently blocking an armed signal.
 
Levels are ATR multiples from the entry close: stop at 0.75 x ATR, TP1 at 1 x
ATR, TP2 at 2 x ATR, all adjustable. A separate warning fires when EMA9 crosses
the 20-period SMA against an open position, which flattens the signal state.
 
 
ENGINE 2 - CHoCH (CHANGE OF CHARACTER)
 
Swing highs and lows are located with pivots. The left-bar setting is a
significance filter and costs nothing; the right-bar setting is confirmation lag
and is the only real cost, since a swing is not confirmed until that many bars
have printed after it.
 
A structure break requires a CLOSE beyond the swing by a minimum ATR distance,
not merely a wick through it. That break arms the engine. With pullback mode on
(default), entry then waits for price to trade back to within a small ATR buffer
of the broken level and close back on the correct side of it - a retest, not a
chase. If that does not happen within a set number of bars, the arm expires
unused. Filters for EMA agreement, VWAP side, volume and session apply on top.
 
Risk is structural, not volatility-based. The stop goes just beyond the swing
that defined the structure, because that is where the trade thesis is actually
wrong. R is the distance from entry to that stop, and both targets are multiples
of R. Optional breakeven move after TP1.
 
Structure direction is held in a latch that survives until something changes it.
Two guards keep that latch honest: it resets to neutral the moment price closes
back through the level it broke - a break price has closed back inside is a
failed break, not structure - and the dashboard shows how many bars old the
surviving break is, greying out the agreement mark once it passes a staleness
threshold. Without those, a latch reads as confidently bullish an hour after the
break that set it has stopped mattering.
 
 
WHY THESE TWO TOGETHER
 
They fail in opposite conditions, and each one's failure is the other's normal
operating range.
 
A moving-average cross system is structurally late at turns and comfortable in
trends. A structure-break system is early at turns and gets cut up in range-bound
conditions. Running one of them tells you what it thinks. Running both tells you
whether the answer is worth much: when a late-but-reliable method and an
early-but-noisy method point the same way, that is a different situation from
either one agreeing with itself.
 
The second reason is risk framing. The two engines size stops on incompatible
principles - one steps back a fixed volatility multiple, the other steps behind
the structure. When those two stops land near each other, volatility and
structure agree and the setup is clean. When they are far apart, the structure
was built during a fast move and the trade genuinely needs a wider stop than a
scalp framework would suggest. You cannot see that from either engine alone, and
it is not something a combined signal could express - which is why they are kept
separate rather than merged.
 
The BIAS row is the product of that design. It is not a third signal; it is an
agreement meter with an age stamp on the structural half.
 
 
RUNNER MODE
 
By default, price tagging TP2 does not end the trade. The whole level set rolls
forward one leg: the stop ratchets up to the target just cleared, old TP2 becomes
the new TP1, and a fresh TP2 is set one full leg further out. This repeats for as
long as the move runs, so the levels stay near live price instead of sitting
behind it. A leg counter on the dashboard shows how many rolls have occurred.
The ratchet can follow the prior target, the fast EMA, an ATR trail, or be
disabled.
 
 
CONTEXT LAYERS
 
Fair value gaps (three-bar imbalances, drawn as zones, removed when filled),
opening range with breakout state, previous day high/low, daily pivots, confirmed
and pending trendlines, higher-timeframe trend on two timeframes, RSI on the
chart timeframe and a higher one, VWAP, and a 200 EMA.
 
Every forward-drawn line is redrawn each bar starting at the current candle and
projected a fixed distance right, rather than painted back across history. Scalp
Lite's levels are dashed and CHoCH's are solid so the two sets are never
confused when both engines are in a trade at once.
 
 
DASHBOARD
 
Twelve rows: agreement bias with structure age, each engine's state, entry, stop,
targets with leg counter, RSI on two timeframes, volume and ATR, higher-timeframe
trend, nearest unfilled gaps, opening range state, and warnings. Position is
adjustable to any of nine anchors, with text size and a compact single-column
mode for smaller panes.
 
 
HOW TO USE IT
 
Intraday timeframes; the defaults are tuned for 1 to 5 minute charts.
 
Read the BIAS row first. Both engines agreeing with a fresh structure break is
the highest-quality condition the script identifies. Disagreement is a reason to
size down or stand aside, not a signal to fade. Check the opening range row - an
INSIDE reading is the chop regime where structure breaks fail most often.
 
If CHoCH's targets look impractically far away, that is the structural stop
telling you the nearest confirmed swing is a long way from price. Reducing the
pivot left-bars finds nearer structure and shrinks R honestly. There is also an
optional cap on stop distance, off by default, which shrinks R by moving the stop
somewhere structure does not justify - it makes the chart tidier and the logic
worse, which is why it ships disabled.
 
 
BEHAVIOUR AND LIMITATIONS
 
Swings require confirmation bars before they are recognised, so structure appears
after the fact by design. This is inherent lag, not repainting: a confirmed swing
never moves afterwards.
 
Scalp Lite signals evaluate on bar close. CHoCH conditions evaluate on the
current bar and can therefore change state intrabar until that bar closes; treat
an intrabar CHoCH signal as provisional.
 
Alerts are provided for both engines' entries, the exit warning, opening range
breaks, and structure breaks.
 
This is a decision-support tool. It reports what price, structure, volatility and
participation are doing - it does not forecast, and neither the signals nor the
targets are predictions. Defaults are starting points, not recommendations, and
will need adjusting per instrument and timeframe. Position sizing and the
decision to take or skip any setup remain entirely with the user. Nothing here is
financial advice.

---

## Source Code

````pine
//@version=6
// max_bars_back=500 is required, not optional. ta.crossover(close, orbHigh) and
// ta.crossunder(close, orbLow) reference `var` floats that are only ever
// assigned inside if-blocks, so Pine cannot statically determine how much
// history to buffer for them and bails with "cannot determine referencing
// length", naming the crossover calls. Stating the buffer explicitly settles it.
// 500 comfortably covers the longest lookback in the script (the 200 EMA).
//
// Declaration ceilings, since they are easy to overshoot: max_bars_back tops
// out at 5000, max_lines_count and max_boxes_count at 500 each, and
// max_labels_count at 500. Line budget here: ~220 BB dash segments + 48 FVG
// stripes + 18 for trendlines, pivots, SL/TP and ORB = ~286, inside 500.
indicator("Scalp Lite + CHoCH", shorttitle="SL+CHoCH", overlay=true, max_bars_back=500, max_labels_count=300, max_lines_count=500, max_boxes_count=500)

// ============================================================
// Scalp Lite — the minimum needed to scalp effectively, nothing more.
//
// Max7 has ~20 dashboard rows, FVGs, EQH/EQL, market structure, live
// trendlines, double top/bottom tracking, and eight candle-pattern
// types. That's genuinely useful for *reading the tape*, but almost
// none of it is required to *generate a decent scalp entry*. This
// strips it down to the handful of things that actually move the
// needle on signal quality, based on everything that got tested
// building Max6/Max7:
//
//   1. EMA9/EMA50 CROSS — the trigger. Your own stated core
//      framework. One cross, one direction call.
//   2. VWAP FILTER — only take the cross in VWAP's direction.
//      Cheap, and it's the single biggest false-signal filter for
//      a directional bias check.
//   3. VOLUME FILTER — require above-average volume. This was, by
//      a wide margin, the gate that did the most work in Max6 —
//      more signals get killed by low volume than by anything else,
//      and for good reason: a cross on dead volume is noise.
//   4. ATR-BASED SL/TP1/TP2 — stops and two targets that scale with
//      current volatility instead of a fixed dollar amount.
//   5. BAR-CLOSE CONFIRMATION — no repainting triangles.
//   6. COOLDOWN — blocks immediate back-to-back opposite signals
//      (the classic whipsaw-on-chop failure mode).
//   7. MARKET HOURS — a configurable trading window. As of v38 this
//      defaults to 09:30–15:30 with the morning open OPEN; the old
//      version hardcoded a second 10:00–15:30 gate on top, so nothing
//      could fire in the first half hour regardless of settings.
//
// v2 additions (still minimal, but requested):
//   8. SIGNAL CANDLE COLOR — the bar that fires a signal is
//      recolored purple so it's unmistakable on the chart.
//   9. TP1 + TP2 — a second, farther ATR-based target line.
//  10. BOLLINGER BANDS — dashed white 1-wide center line, faint
//      white background fill between the bands (2% opacity as of
//      v34, adjustable via the BB Cloud Opacity % input).
//  11. RSI — shown on the dashboard (can't be a separate oscillator
//      pane in the same script as the overlay plots — Pine ties
//      overlay to the whole indicator, not per-plot — so it's a
//      dashboard number instead of a sub-chart line).
//  12. STALE SIGNAL RESET — the original only cleared a signal when
//      price closed back through the SL. If price instead ran well
//      past TP2 without ever falling back to the SL, the dashboard
//      kept showing that old trade indefinitely (seen live: ENTRY
//      120.86 while price was at 125.24, 3.5+ points past TP2).
//      Now resets when price clears TP2 by 1.5x ATR, or at the
//      start of each new trading day.
//
// v32 addition:
//  13. EMA9/EMA50 CROSS MARKER — the cross was always the engine of
//      this script, but it was invisible on its own: you only saw it
//      indirectly, via a signal triangle that may or may not have
//      fired. VWAP/volume/cooldown filters, the 09:30–10:00 and
//      15:30–16:00 session blocks, and the bar-close requirement can
//      all swallow a cross silently, so a real cross could go by with
//      nothing drawn on the chart at all. Now every raw cross gets a
//      9▲50 / 9▼50 label dropped at the crossover, whether or not it
//      passed the filters — small and faded when it was filtered out,
//      full-size and solid when it produced a signal. Same real-label
//      technique as the BB-mid marker, so old ones auto-delete rather
//      than piling up. Plus a tinted fill between
//      the two EMAs (green when 9 is above 50, red when below) so the
//      current side is readable at a glance instead of comparing two
//      lines. Nothing here changes the signal logic; it's purely
//      visual.
//
// v35 addition:
//  14. 200 EMA — solid white slow-trend line. Context only: it does
//      not filter, gate, or reset anything. The EMA9/EMA50 cross is
//      still the sole trigger. It's here so you can see at a glance
//      whether a cross is happening with the larger trend or against
//      it, which is usually the difference between a cross that runs
//      and one that chops.
//
// v36 addition:
// v37 fix (the important one):
//  16. DEFERRED CROSS — a cross is a single-bar event, and the old
//      code demanded every gate be open on that exact bar. A 9/50
//      cross that happened premarket hit the session filter and was
//      thrown away permanently, because ta.crossover() will not fire
//      again while the EMAs stay on the same side. Seen live on TSLA:
//      crossed up before the open, held above the 50 all session,
//      script showed nothing all day. Now a cross ARMS a pending
//      direction and fires on the first bar where the gates open and
//      the EMAs still agree. Filters are not bypassed — they just no
//      longer have to all line up on one specific bar. An ARMED row
//      on the dashboard shows what's holding a pending signal up.
//
// v41 addition:
//  18. PENDING TRENDLINES — the solid trendlines are accurate but
//      late. A pivot needs trendLookback bars on each side to
//      confirm, so on a 1m chart with the default 10 you learn about
//      a level ten minutes after it formed. These dashed lines run
//      from the last confirmed pivot to the running extreme since
//      then — the exact point that becomes the next confirmed pivot
//      if it survives another trendLookback bars. In other words,
//      where the solid line is going to land. They move when price
//      makes a new extreme, which is the signal, not noise.
//      v42: constrained. As first written they drew with no limit on
//      geometry — right after a pivot confirms the candidate sits a
//      couple of bars from the anchor, so a small price difference
//      became a near-vertical slope and extend.right sent the line
//      through the candles. Now requires a minimum bar separation
//      between the two anchors and hides any projection landing more
//      than N ATRs from price.
//
// v45 change:
//  19. FASTER SOLID TRENDLINES — the pivot's two sides are now
//      separate inputs. Left bars = significance (is this high real).
//      Right bars = confirmation delay (how late the line draws).
//      They were locked together at 10, so you paid a 10-bar lag for
//      significance the left side was already providing. Now 10/3:
//      same quality filter, line lands 3 bars after the pivot instead
//      of 10. Note trPHx1/trPLx1 now index off the RIGHT bars, since
//      that is where the pivot actually sits relative to confirmation.
//
// v47 addition:
//  20. FAIR VALUE GAPS — the one SMC concept earned its way back in.
//      A 3-candle imbalance where candle 1 and candle 3 do not
//      overlap leaves a band that traded in no auction, and price
//      revisits those bands often enough to be worth marking. Zones
//      auto-delete when filled, so the chart never accumulates.
//      The min-size filter is what makes this usable at all: on a 1m
//      chart nearly every 3-bar run leaves some imbalance, and
//      without an ATR floor you get hundreds of boxes and no signal.
//      v48: three zone styles. Pine cannot hatch — a box takes one
//      solid colour and a border, full stop — so STRIPED draws evenly
//      lines inside the zone instead, spaced a fixed distance apart
//      so the stripe COUNT reads the zone size. As close to a
//      hatch as is actually drawable, and OUTLINE drops the fill
//      entirely so candles stay fully readable.
//
// Otherwise still no score system, no market structure, no candle
// pattern tracking. If you want those, use Max7 — this stays the
// "just tell me when to look" version.
// ============================================================

// ================== INPUTS ==================
ema9Len  = input.int(9,  "Fast EMA", group="Trend")
ema50Len = input.int(50, "Slow EMA", group="Trend")

showEMA200   = input.bool(true, "Show 200 EMA", group="Trend",
                tooltip="Slow trend reference only — it does NOT gate signals. The EMA9/EMA50 cross is still the sole trigger; this just shows you which side of the big trend that cross is happening on.")
ema200Len    = input.int(200, "Trend EMA", minval=2, group="Trend")
ema200Width  = input.int(2, "200 EMA Width", minval=1, maxval=5, group="Trend")

volLen      = input.int(20,  "Volume MA Length",        group="Volume")
volMinMult  = input.float(1.0, "Volume Multiplier (× avg)", minval=0.1, step=0.1, group="Volume",
                tooltip="Volume must exceed this multiple of its own average for a signal to fire. 1.0 = genuinely above average.")

atrLen     = input.int(14,   "ATR Length",          group="Risk")
atrSLMult  = input.float(0.75, "SL (× ATR)",        minval=0.1, step=0.05, group="Risk")
atrTP1Mult = input.float(1.0,  "TP1 (× ATR)",       minval=0.1, step=0.05, group="Risk")
atrTP2Mult = input.float(2.0,  "TP2 (× ATR)",       minval=0.1, step=0.05, group="Risk")

cooldownBars = input.int(5, "Cooldown Bars Between Signals", minval=0, maxval=100, group="Risk",
                tooltip="Blocks a new signal for N bars after the last one — stops immediate opposite-direction whipsaw on chop.")

useMarketHours  = input.bool(true, "Restrict signals to a trading window", group="Session",
                tooltip="OFF = signals can fire on any bar the chart shows, premarket and after hours included.")
tradeSession    = input.session("0930-1530", "Trading Window", group="Session",
                tooltip="Signals only fire inside this window. Starts at 09:30 now — the old hardcoded logic ALSO blocked 09:30-10:00 on top of this, so in practice nothing could fire before 10:00. Set 0930-1600 if you want the closing half hour back.")
useOpenBlackout = input.bool(false, "Blackout an early window", group="Session",
                tooltip="OFF by default. This is the old 09:30-10:00 open skip — now optional and adjustable rather than hardcoded. Turn it back on if a given instrument's open is too noisy for you.")
openBlackout    = input.session("0930-1000", "Blackout Window", group="Session",
                tooltip="Only applies when 'Blackout an early window' is on.")

keepClearOfDash = input.bool(true, "Keep ALL drawings clear of the dashboard", group="Dashboard",
                tooltip="ON: every forward-running line — SL/TP, CHoCH stop and targets, ORB, previous-day high/low, pivots, trendlines and the price line — is cut off a fixed distance right of the live candle instead of running under the dashboard, and the blank margin below automatically widens to cover that distance. OFF: lines extend to the right edge of the chart the way they used to and the table sits on top of them.")
// The dashboard is a TABLE. A table floats in the pane corner and is sized in
// PIXELS by how much text it holds — it has no idea what bar it is sitting on
// and there is no way to tell it to dodge. The blank margin below is measured
// in BARS. So whether they collide depends on your zoom: 20 bars of margin is
// plenty when 60 bars are on screen and nothing at all when 400 are. Two ways
// to fix a collision, and they work together — make the margin wider, or make
// the table narrower. The three settings here do the second.
dashTextIn  = input.string("Normal", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Dashboard",
                tooltip="Normal is the original size and the default again. Small takes roughly a third off the width, Tiny about half — only reach for those if you want a physically smaller dashboard, not as a way to fix overlap. Overlap is now handled by the Dashboard Width setting below.")
dashCompact = input.bool(false, "Compact — one column instead of two", group="Dashboard",
                tooltip="Merges each row's label and value into a single cell. Roughly halves the table's width. Turn this on together with Tiny text if the dashboard is still in the way.")
dashOpaque  = input.bool(true, "Solid dashboard background", group="Dashboard",
                tooltip="ON: the table is fully opaque, so anything drawn behind it is completely hidden rather than bleeding through. The cells used to sit at 5-10% transparency, which is why lines were faintly visible through the dashboard.")
dashSpacerBars = input.int(30, "Dashboard Width (bars) — tune until lines meet the dashboard", minval=0, maxval=500, group="Dashboard",
                tooltip="THIS IS THE ALIGNMENT DIAL. The chart's blank right margin is set to this number PLUS the SL/TP line length, and the level lines stop after the line length — so the leftover gap between where the lines end and the right edge of the chart is exactly this many bars. Set this to roughly how wide the dashboard is in bars and the line ends land flush against its left edge. Too small and the lines run under the table; too large and there is a gap. Nudge it up or down by 5 until it looks right at the zoom you actually trade at, then leave it.")

lvlExtendBars = input.int(8, "SL/TP Line Length (bars right of current candle)", minval=1, maxval=200, group="Dashboard",
                tooltip="Entry, stop and target lines are redrawn every bar starting AT the current candle and running this many bars into the future. They no longer paint back across old bars, so the chart stays clean and the level always sits next to live price.")
slLineStyleIn = input.string("Dashed", "Scalp Lite Level Line Style", options=["Dashed", "Dotted", "Solid"], group="Dashboard",
                tooltip="Both engines can be in a trade at the same time, which puts two full sets of stop and target lines on the chart at once. The dashboard only shows one of them — CHoCH wins that row when it has a position — so the line styles are what tell them apart. Scalp Lite dashed, CHoCH solid, by default.")
chStopStyleIn = input.string("Circles", "CHoCH Stop Line Style", options=["Circles", "Solid", "Dashed", "Dotted"], group="Dashboard",
                tooltip="Circles draws the stop as a row of red dots instead of a continuous line, so it never gets mistaken for one of the target lines. Pine has no circle style for line objects, so these are tiny circle LABELS placed one per bar across the projection — same forward-only behaviour as the lines, no painting back across the trade. The other three options draw it as a normal line in that style.")
chLineStyleIn = input.string("Solid", "CHoCH Target Line Style", options=["Solid", "Dashed", "Dotted"], group="Dashboard",
                tooltip="Kept solid so CHoCH reads as the heavier, structure-based set. Change it if you would rather have the styles the other way round.")
lvlBackBars   = input.int(0, "SL/TP Line Bars BEHIND current candle", minval=0, maxval=50, group="Dashboard",
                tooltip="0 = the line starts exactly at the current candle (cleanest). Raise it if you want a short stub trailing to the left so the level is easier to grab with the cursor.")

// ================== RESET / RUNNER ==================
// Pine cannot draw a clickable button on the chart — there is no such object
// in the language. What it CAN do is give you a knob in the settings panel
// that behaves like one. Both of these live in the "Reset" group: change the
// number, the script recalculates, the state clears at that point and re-arms
// from live price. That is a reset button in everything but appearance.
resetBarsAgo = input.int(0, "RESET — clear levels N bars back (0 = off)", minval=0, maxval=500, group="Reset",
                tooltip="THE QUICK BUTTON. Type 1 and click OK: the engine wipes entry/SL/TP one bar back, re-arms in whatever direction the EMAs are pointing, and stamps a fresh set of levels off current price. Type 0 to go back to normal. Bump it to 2, 3, 5 to reset a little further back. Use this when price has run past TP2 and the old levels are just clutter.")
resetUseTime = input.bool(false, "Also reset at a specific time", group="Reset",
                tooltip="For a surgical reset at a known bar instead of counting back from the live candle. Turn this on and set the date/time below.")
resetTime    = input.time(timestamp("01 Jan 2020 00:00 -0500"), "Reset At", group="Reset",
                tooltip="Only used when the box above is checked. State clears on the first bar at or after this timestamp and rebuilds forward from there.")

autoLadder  = input.bool(true, "Runner mode — roll targets forward past TP2", group="Reset",
                tooltip="ON (recommended): when price tags TP2 and keeps going, the levels ROLL instead of going stale. SL ratchets up to the old TP1, old TP2 becomes the new TP1, and a new TP2 is set one full leg further out. Repeats for as long as the trend runs, so the lines always sit around live price instead of buried below it. OFF: targets stay where they were first stamped.")
ladderStop  = input.string("Prior TP1", "Stop After Each Roll", options=["Prior TP1", "EMA 9", "ATR trail", "Leave alone"], group="Reset",
                tooltip="Where the stop goes each time the targets roll. 'Prior TP1' is the tightest ratchet and locks in the leg you just made. 'EMA 9' trails the fast average and gives a trending move more room. 'ATR trail' keeps your original ATR distance from current price. 'Leave alone' rolls the targets but never moves the stop.")
maxRollsPerBar = input.int(5, "Max Rolls Per Bar", minval=1, maxval=20, group="Reset",
                tooltip="A gap or a single huge candle can clear several legs at once. This caps how many rolls one bar can produce so a runaway print can't spin the ladder off the chart.")

useVWAPFilter = input.bool(false, "Require VWAP agreement", group="Signal",
                tooltip="OFF = fire on every EMA9/EMA50 cross regardless of VWAP side. ON = only take crosses in VWAP's direction.")
useVolFilter  = input.bool(false, "Require above-average volume", group="Signal",
                tooltip="OFF = fire on every cross regardless of volume. ON = requires volume above the multiplier set in the Volume group.")
useCooldown   = input.bool(false, "Enforce cooldown between signals", group="Signal",
                tooltip="OFF = a new signal can fire immediately on the very next opposite cross, no waiting. ON = blocks a new signal for Cooldown Bars after the last one.")
useDeferredSignal = input.bool(true, "Remember a cross until the filters allow it", group="Signal",
                tooltip="ON (recommended): a 9/50 cross ARMS a signal that fires on the first bar where every filter passes and the EMAs still agree. Fixes crosses that happen premarket, on low volume, during the 9:30-10:00 block, or inside a cooldown — the old behavior threw those away permanently, since a cross never re-fires while the EMAs stay on the same side. OFF: original behavior, cross must clear every gate on its own bar or it's lost.")
maxCautionMarkers = input.int(1, "Max Caution Markers Shown", minval=1, maxval=50, group="Signal",
                tooltip="Keeps only the most recent N caution markers on the chart — older ones are deleted automatically as new ones appear.")
maxBBCrossMarkers = input.int(4, "Max Exit-Cross Markers Shown", minval=1, maxval=50, group="Signal",
                tooltip="Keeps only the most recent N exit-cross markers on the chart.")

vwapWidth = input.int(2, "VWAP Line Width", minval=1, maxval=5, group="Trend",
                tooltip="Was 4, which drew a heavy cross-hatch band that buried the candles it crossed. 2 keeps VWAP readable without dominating the chart; 1 is thinner still.")

showCrossMarkers = input.bool(true, "Show EMA9/EMA50 cross markers", group="EMA Cross Marker",
                tooltip="Drops a 9▲50 / 9▼50 label at the point where EMA9 crosses EMA50 — every cross, including the ones the VWAP/volume/cooldown/session filters block. Full-size solid label = the cross also fired a signal. Smaller faded label = the cross happened but was filtered out.")
maxCrossMarkers = input.int(6, "Max Cross Markers Shown", minval=1, maxval=50, group="EMA Cross Marker",
                tooltip="Keeps only the most recent N cross markers on the chart — older ones are deleted automatically as new ones appear, same as the caution and BB markers.")

showEMAFill  = input.bool(true, "Shade the EMA9/EMA50 gap", group="EMA Cross Marker",
                tooltip="Tints the area between the two EMAs — green while EMA9 is above EMA50, red while below — so which side you're on reads at a glance.")
emaFillTrans = input.int(88, "EMA Fill Transparency", minval=0, maxval=100, step=1, group="EMA Cross Marker",
                tooltip="0 = solid, 100 = invisible. The BB fill sits at 86, so keep this near it or higher to avoid a muddy overlap.")

// Bollinger Bands are gone — bands, cloud and dashed centre line all removed.
// What survives is the EXIT RULE that used to hang off them: EMA9 crossing the
// 20-period SMA against your position closed the trade. That was never a
// drawing, it was signal logic, so deleting the visuals would have silently
// changed how your signals behave. It is now an explicit toggle instead of an
// invisible side effect of an indicator you removed.
useMidExit = input.bool(true, "Exit when EMA9 crosses the 20 SMA against you", group="Signal",
                tooltip="This is the old 'BB MID / GET OUT' rule. It resets an active signal to Neutral when EMA9 crosses back through the 20-period SMA against your position. Kept ON so your signals behave exactly as before; turn it off if you would rather only the 9/50 cross close a trade.")
midLen = input.int(20, "Exit MA Length", minval=2, group="Signal")

pdLineWidth = input.int(3, "PDH / PDL Line Width", minval=1, maxval=5, group="Levels",
                tooltip="Previous-day high and low. Started at 1, went to 2, now 3 — matching the weight of the S1/S2/R1/R2 pivot lines, which are the levels PDH/PDL compete with visually.")

rsiLen = input.int(14, "RSI Length", group="RSI")

// ================== CHoCH ==================
// Change of Character: price closing beyond the opposing swing, against the
// prevailing structure. Deliberately kept as a SECOND, independent engine —
// the 9/50 cross reads a moving-average relationship, CHoCH reads price
// breaking structure. When they agree you have real confluence; when they
// disagree that is information too. Merging them into one signal would throw
// that away.
//
// All shared maths (ATR, EMAs, VWAP, volume average, session window) is reused
// from Scalp Lite above rather than recalculated. Only the genuinely different
// settings live here.
chEnable      = input.bool(true, "Enable CHoCH engine", group="CHoCH")
chPivotLeft   = input.int(3, "CHoCH Pivot Left Bars", minval=2, maxval=50, group="CHoCH",
                tooltip="Significance filter — how many bars before a candidate must be lower for a high to count as a real swing. Costs nothing in speed.")
chPivotRight  = input.int(2, "CHoCH Pivot Right Bars", minval=1, maxval=50, group="CHoCH",
                tooltip="THIS is the CHoCH lag — the swing level is not known until this many bars after it forms. Separate from the trendline pivot settings on purpose, so the two systems can be tuned independently.")
chMinBreakATR = input.float(0.15, "Min Break Distance (× ATR)", minval=0.0, maxval=3.0, step=0.05, group="CHoCH",
                tooltip="Your noise dial. Price must close this far BEYOND the swing to count. Without it a one-tick poke fires a signal. Raise it if you get too many.")
chUsePullback = input.bool(true, "Wait for pullback to the broken level", group="CHoCH",
                tooltip="OFF: enter on the CHoCH candle. ON: the break only ARMS it and entry waits for the retest. Fewer trades, better fills, misses the runners.")
chPullbackBars= input.int(10, "Max Bars to Wait for Retest", minval=1, maxval=100, group="CHoCH")
chRetestBuf   = input.float(0.10, "Retest Buffer (× ATR)", minval=0.0, maxval=2.0, step=0.05, group="CHoCH")
chUseEMA      = input.bool(true,  "CHoCH: require EMA9/50 agreement", group="CHoCH")
chUseVWAP     = input.bool(true,  "CHoCH: require VWAP agreement", group="CHoCH")
chUseVol      = input.bool(true,  "CHoCH: require above-average volume", group="CHoCH",
                tooltip="ON by default, unlike the 9/50 engine. A structure break on thin volume is the most common false CHoCH.")
chSlBufATR    = input.float(0.25, "CHoCH Stop Buffer beyond structure (× ATR)", minval=0.0, step=0.05, group="CHoCH")
chMaxStopATR  = input.float(0.0, "Cap Stop Distance (× ATR, 0 = no cap)", minval=0.0, maxval=50.0, step=0.5, group="CHoCH",
                tooltip="OFF by default (0). CHoCH puts its stop at the swing that defined the structure, NOT at a fixed volatility distance — so after a big fast move the nearest confirmed swing can be ten or more ATRs away, and TP1/TP2 (multiples of that distance) end up far off the chart. Set this to something like 3 and the stop is pulled no further than 3 ATR from entry, which shrinks R and brings the targets in with it. Understand the trade-off: a tighter stop is no longer where the structure is actually invalidated, so it will get hit by noise that the structural stop would have survived.")
chTp1R        = input.float(1.0, "CHoCH TP1 (R multiple)", minval=0.1, step=0.1, group="CHoCH",
                tooltip="R multiples, not ATR — reward tied to the risk actually taken on THIS trade.")
chTp2R        = input.float(2.0, "CHoCH TP2 (R multiple)", minval=0.1, step=0.1, group="CHoCH")
chUseBE       = input.bool(true, "CHoCH: move stop to breakeven after TP1", group="CHoCH")
chSwingWidth  = input.int(2, "CHoCH Swing Line Width", minval=1, maxval=5, group="CHoCH")
chSwingTop    = input.bool(true, "Draw CHoCH swing lines on top of everything", group="CHoCH",
                tooltip="Pine renders in fixed layers: background fills at the bottom, then plot() output, then drawing objects (lines, boxes, labels) on top. Plotted swing lines therefore sit UNDER every trendline, FVG zone, pivot and level line on the chart. ON draws them as line objects rebuilt at the very end of each bar, which makes them the newest drawings and therefore the topmost. OFF uses the plot version instead.")
chRiserBars   = input.int(2, "Swing Step Slope (bars)", minval=0, maxval=20, group="CHoCH",
                tooltip="How many bars the transition between two swing levels is spread across. 0 draws a dead-vertical jump. 2 or 3 angles it, which is closer to how the old plot version looked and reads better on a busy chart. If two swings are closer together than this, the slope is automatically shortened to fit rather than overrunning the level before it.")
chSwingSegs   = input.int(30, "Max Swing Segments Kept", minval=5, maxval=80, group="CHoCH",
                tooltip="How many past swing levels stay drawn per side. Each level costs two line objects (the flat part and the riser up to it), so 30 a side is about 118 lines out of the 500 the script may use. Lower it if you ever hit the line ceiling with a lot of FVG zones open.")
chInvalidate  = input.bool(true, "Kill the CHoCH bias when price reclaims the broken level", group="CHoCH",
                tooltip="ON: the structure latch resets to neutral the moment price CLOSES back through the swing level it broke. Without this the bias stays pinned in the break direction until an opposite break happens, so it can read bullish for an hour while price quietly rolls over — the break is dead, the flag just never came down. OFF: original latch behavior.")
chStaleBars   = input.int(20, "Bars Before the CHoCH Bias Counts as Stale", minval=1, maxval=500, group="CHoCH",
                tooltip="The BIAS row shows how many bars have passed since the structure break. Past this count the agreement mark turns grey and drops from a check to a warning — the two engines still point the same way, but the CHoCH half of that is old news and should not be carrying much weight.")
chHiColor     = input.color(color.new(#ffea00, 0), "CHoCH Swing High Color", group="CHoCH",
                tooltip="Vivid yellow and cyan on purpose — every other hue on this chart is already spent by the EMAs, pivots, trendlines and FVG zones.")
chLoColor     = input.color(color.new(#00e5ff, 0), "CHoCH Swing Low Color", group="CHoCH")

dashPosIn = input.string("Top Right", "Dashboard Position", group="Dashboard",
                options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"],
                tooltip="All nine anchors a Pine table can use. TradingView puts its own pane controls — the collapse chevrons and the move-pane arrows — in the TOP RIGHT of every pane, and they sit ABOVE anything a script draws, so a top-right dashboard will always be partly under them once you add a second pane. Bottom Right is the usual fix. Bottom Center works too and stays clear of the price scale.")

showPriceLine  = input.bool(true, "Show price line", group="Price Line")
priceLineFull  = input.bool(true, "Run the price line all the way to the right edge", group="Price Line",
                tooltip="ON: the price line ignores the dashboard cut-off and extends to the right edge of the chart, passing behind the table. It is a single reference line rather than clutter, so running it full width is usually easier to read. OFF: it stops with everything else at the SL/TP line length.")
priceLineColor = input.color(color.new(#26c6da, 0), "Price Line Color", group="Price Line")
priceLineWidth = input.int(3, "Price Line Width", minval=1, maxval=5, group="Price Line")
priceLineStyle = input.string("Dotted", "Price Line Style", options=["Dotted","Dashed","Solid"], group="Price Line")
showPriceTag   = input.bool(true, "Show price tag", group="Price Line")
priceTagOffset = input.int(6, "Tag Offset (bars right)", minval=1, maxval=50, group="Price Line")

showFVG      = input.bool(true, "Show Fair Value Gaps", group="Fair Value Gaps",
                tooltip="A 3-candle imbalance: price moved far enough fast enough that candle 1 and candle 3 do not overlap, leaving a band nobody traded in. Those bands get revisited often enough to be worth marking.")
fvgMinATR    = input.float(0.25, "Min Gap Size (× ATR)", minval=0.0, maxval=5.0, step=0.05, group="Fair Value Gaps",
                tooltip="THE setting that decides whether this is useful or unusable. On a 1-minute chart almost every 3-bar sequence leaves a tiny imbalance; without a floor you get hundreds of boxes and no signal. 0.25 ATR keeps only gaps big enough to act as real zones. Raise it if the chart still looks busy.")
fvgFullFill  = input.bool(true, "Require FULL fill to remove", group="Fair Value Gaps",
                tooltip="ON: the zone stays until price closes the gap completely (through the far edge). OFF: the zone is removed the first time price touches it at all. ON keeps zones alive as targets; OFF treats first touch as the level being used up.")
maxFVGBoxes  = input.int(6, "Max Zones Per Side", minval=1, maxval=50, group="Fair Value Gaps",
                tooltip="Keeps the most recent N unfilled gaps on each side; older ones are deleted as new ones form.")
fvgBullColor = input.color(color.new(#00c853, 0), "Bullish Gap Color", group="Fair Value Gaps")
fvgBearColor = input.color(color.new(#ff4081, 0), "Bearish Gap Color", group="Fair Value Gaps",
                tooltip="Pink rather than red on purpose. The chart already spends red on the EMA50, the bear signal triangles and the R1/R2/R3 pivot lines — another red zone competes with all of them. Pink still reads as the bearish side while staying visually separate.")
fvgOpacity   = input.int(12, "Zone Opacity %", minval=0, maxval=100, group="Fair Value Gaps")
fvgBorder    = input.bool(false, "Draw zone borders", group="Fair Value Gaps")
fvgStyle     = input.string("Striped", "Zone Style", options=["Filled","Outline","Striped"], group="Fair Value Gaps",
                tooltip="Pine has no true hatch/pattern fill — a box takes one solid colour and a border, nothing else. FILLED is a flat tint. OUTLINE is a dashed border with no fill at all, so candles stay fully readable. STRIPED draws evenly spaced horizontal lines inside the zone, which is the closest thing to hatching that is actually drawable, and it reads as a zone without burying price.")
fvgStripeGap = input.float(0.08, "Stripe Spacing (× ATR)", minval=0.02, maxval=1.0, step=0.01, group="Fair Value Gaps",
                tooltip="Stripes are now spaced a FIXED distance apart instead of being divided evenly across each zone. Every zone therefore has identical texture, and the NUMBER of stripes tells you the size at a glance — 2 stripes is a thin gap, 6 is a big one. Smaller value = denser hatching.")
fvgMaxStripes = input.int(6, "Max Stripes Per Zone", minval=1, maxval=10, group="Fair Value Gaps",
                tooltip="Hard ceiling so a very tall zone cannot flood the chart. It also fixes the line budget: this many slots are reserved per zone, so 6 across 12 zones is 72 lines, comfortably inside Pine's 500 cap.")

trendLookback = input.int(10, "Pivot Left Bars (significance)", minval=2, maxval=50, group="Trendlines",
                tooltip="How many bars BEFORE a candidate must be lower (for a high) for it to count as a real swing. This is the quality filter — it decides whether a high is significant. Raising it makes the lines smoother and costs you NOTHING in speed, because confirmation delay is set separately below.")
trendRightBars = input.int(3, "Pivot Right Bars (confirmation delay)", minval=1, maxval=50, group="Trendlines",
                tooltip="How many bars AFTER a candidate must pass before the pivot is locked in. THIS is your lag — the solid line appears exactly this many bars late, no more. Was tied to the left bars at 10, which meant a 10-bar delay for no reason. At 3 the line lands 3 bars after the pivot forms. Lower is faster but produces more pivots that get superseded.")
trendWidth    = input.int(2, "Trendline Width", minval=1, maxval=5, group="Trendlines")
trendFullExtend = input.bool(true, "Run confirmed trendlines to the right edge", group="Trendlines",
                tooltip="ON: confirmed trendlines keep projecting forward past the dashboard cut-off, the same way the price line does. A trendline's whole job is to show you where support or resistance WILL be, so cutting it short throws away the useful part. OFF: they stop with the stop and target lines. Pending (dashed) trendlines are unaffected — they use their own projection length below.")
// Was #ffaa00 orange, which sat right next to the CHoCH swing-high yellow
// (#ffea00) and blended with it. Magenta is the one hue region nothing else on
// this chart occupies — the closest neighbour is VWAP's lavender (#bf80ff),
// and that is drawn as a cross-style plot rather than a solid line, so the two
// never read as the same object.
trendUpperColorIn = input.color(color.new(#e040fb, 0), "Upper Trendline Color", group="Trendlines")
// Was #00aaff blue, sitting right on top of the CHoCH swing-low cyan
// (#00e5ff). Orange is the direct complement of that cyan — no two colours on
// this chart separate more cleanly — and it is the slot the upper trendline
// just vacated. The only other orange is the PDL, which is dead horizontal and
// carries a text tag, so a sloped line never reads as the same thing.
trendLowerColorIn = input.color(color.new(#ff9100, 0), "Lower Trendline Color", group="Trendlines")

showPendingTL   = input.bool(true, "Show pending trendlines (dashed)", group="Trendlines",
                tooltip="A pivot needs Trendline Lookback bars on BOTH sides to confirm, so the solid lines are always that many bars stale — by the time one draws, price has already moved past it. The dashed line runs from the last CONFIRMED pivot to the current running extreme, showing where the next solid line will land if that extreme holds. It moves as price makes new extremes; that's the point of it.")
pendingTLWidth  = input.int(2, "Pending Trendline Width", minval=1, maxval=5, group="Trendlines")
pendingTLTransp = input.int(35, "Pending Trendline Transparency", minval=0, maxval=100, group="Trendlines",
                tooltip="Faded on purpose — this is a forecast, not a confirmed level, and it shouldn't read with the same weight as the solid line.")
pendingMinSep   = input.int(3, "Pending Line Min Bar Separation", minval=2, maxval=100, group="Trendlines",
                tooltip="Minimum bars between the confirmed anchor and the candidate. Only there to avoid a degenerate slope from two points sitting on top of each other — kept low on purpose. At 10 it suppressed the upper line entirely in an uptrend, because fresh swing highs keep confirming right next to the candidate.")
pendProjBars    = input.int(20, "Pending Line Projection (bars)", minval=2, maxval=200, group="Trendlines",
                tooltip="How far past the candidate the dashed line is drawn. These no longer extend infinitely to the right — that is what let a steep line run off through the candles. A bounded segment shows the direction without taking over the chart.")
pendingMaxATR   = input.float(4.0, "Pending Line Max Rise (× ATR)", minval=0.5, maxval=50.0, step=0.5, group="Trendlines",
                tooltip="Caps how far the projection may travel vertically from the candidate. A steep line gets TRUNCATED rather than hidden, so you always see it — it just stops before running off the chart.")

// ================== CORE CALCS ==================
ema9  = ta.ema(close, ema9Len)
ema50 = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)
vwapVal = ta.vwap(hlc3)
atrVal  = ta.atr(atrLen)
volMA   = ta.sma(volume, volLen)
rsiVal  = ta.rsi(close, rsiLen)

// ================== 5M / 15M CONTEXT ==================
// Shows the CURRENT (live, still-forming) bar's own direction on each
// timeframe — close vs. open on that bar — not a smoothed multi-bar EMA
// trend. Updates continuously in real time as that higher-timeframe candle
// builds, same real-time behavior as before, just now matching literally
// what color that candle is showing on its own chart at this exact moment.
// RSI on the 5-minute series. NOT the same indicator as the chart RSI slowed
// down — RSI(14) on 5m spans 70 minutes and only ever sees 5-minute closes, so
// every wiggle inside those bars is invisible to it. On a 1m chart the two
// routinely disagree by 6-9 points, and roughly half the time the 1m tags 70
// the 5m has not.
rsi5 = request.security(syminfo.tickerid, "5", ta.rsi(close, rsiLen), lookahead=barmerge.lookahead_off)

htf5_open  = request.security(syminfo.tickerid, "5",  open,  lookahead=barmerge.lookahead_off)
htf5_close = request.security(syminfo.tickerid, "5",  close, lookahead=barmerge.lookahead_off)
htf15_open  = request.security(syminfo.tickerid, "15", open,  lookahead=barmerge.lookahead_off)
htf15_close = request.security(syminfo.tickerid, "15", close, lookahead=barmerge.lookahead_off)

htf5_bull  = htf5_close  > htf5_open
htf5_bear  = htf5_close  < htf5_open
htf15_bull = htf15_close > htf15_open
htf15_bear = htf15_close < htf15_open

// ================== TREND AGREEMENT SUMMARY ==================
// tf1 (this chart) is still the actual EMA9/EMA50 cross — that's what
// drives your entry signal. 5m/15m are now the current-bar direction on
// those timeframes (see above), so this checks: does my entry direction
// agree with what those higher timeframes' candles are doing right now.
tf1_bull = ema9 > ema50
tf1_bear = ema9 < ema50

allBull = tf1_bull and htf5_bull and htf15_bull
allBear = tf1_bear and htf5_bear and htf15_bear


// ================== TRENDLINES ==================
// Auto-drawn trendline through the last two confirmed swing highs (upper)
// and the last two confirmed swing lows (lower).
//
// v45: the two sides of the pivot are now separate inputs, because they do
// different jobs. LEFT bars decide whether a high is significant. RIGHT bars
// are pure confirmation delay — they are the entire reason the solid line
// arrives late. Tying them together at 10 meant paying a 10-bar lag to buy
// significance you were already getting from the left side. Left 10 / right 3
// keeps the same quality filter and lands the line 3 bars after the pivot.
confirmedSwingHigh = ta.pivothigh(high, trendLookback, trendRightBars)
confirmedSwingLow  = ta.pivotlow(low,  trendLookback, trendRightBars)

var float trPH1  = na
var float trPH2  = na
var int   trPHx1 = na
var int   trPHx2 = na
var float trPL1  = na
var float trPL2  = na
var int   trPLx1 = na
var int   trPLx2 = na
var line  upperTrendLine = na
var line  lowerTrendLine = na

if not na(confirmedSwingHigh)
    trPH2  := trPH1
    trPHx2 := trPHx1
    trPH1  := confirmedSwingHigh
    trPHx1 := bar_index - trendRightBars
    if not na(trPH2)
        line.delete(upperTrendLine)
        upperTrendLine := line.new(trPHx2, trPH2, trPHx1, trPH1, color=trendUpperColorIn, width=trendWidth, style=line.style_solid, extend=extend.right)

if not na(confirmedSwingLow)
    trPL2  := trPL1
    trPLx2 := trPLx1
    trPL1  := confirmedSwingLow
    trPLx1 := bar_index - trendRightBars
    if not na(trPL2)
        line.delete(lowerTrendLine)
        lowerTrendLine := line.new(trPLx2, trPL2, trPLx1, trPL1, color=trendLowerColorIn, width=trendWidth, style=line.style_solid, extend=extend.right)

// ================== PENDING TRENDLINES ==================
// The solid lines are honest but late: ta.pivothigh needs trendLookback bars on
// BOTH sides, so a pivot is only recognised trendLookback bars after it happened
// and the line connecting it appears later still. On a 1m chart at the default
// 10, that's a ten-minute delay on a level you'd want to watch in advance.
//
// These dashed lines fill the gap: last CONFIRMED pivot -> the most likely NEXT
// pivot, which is the extreme of a recent window. If that extreme survives
// trendLookback more bars it becomes the next confirmed pivot, and the solid
// line lands exactly where the dashed one is now.
//
// v43 REWRITE. The first version tracked a running extreme "since the last
// confirmed pivot", seeded once and updated only on a new extreme. That freezes:
// when price moves away from the pivot — the normal case — the candidate stays
// parked a few bars past the anchor forever, so the anchor-to-candidate
// separation never grows and the minimum-separation check can never be
// satisfied at any setting. Nothing ever drew.
//
// The fix is to hold no state at all. The candidate is recomputed every bar as
// the extreme of a sliding recent window, so it always sits near the right edge
// and the separation from an ageing anchor grows naturally.
pendWinBars = trendLookback
candHigh  = ta.highest(high, pendWinBars)
candHighX = bar_index + ta.highestbars(high, pendWinBars)
candLow   = ta.lowest(low,  pendWinBars)
candLowX  = bar_index + ta.lowestbars(low,  pendWinBars)

var line pendUpperLine = line.new(na, na, na, na, style=line.style_dashed)
var line pendLowerLine = line.new(na, na, na, na, style=line.style_dashed)

pendUpSep = na(trPHx1) ? 0 : candHighX - trPHx1
pendDnSep = na(trPLx1) ? 0 : candLowX  - trPLx1

// ---- BOUNDED PROJECTION ----
// Projection is bounded rather than extend.right. An unbounded line whose
// value AT THE CURRENT BAR was too far from price. That check passes trivially
// (the candidate is a recent extreme, so it sits right next to price) while
// doing nothing about slope — the line still climbed away to the right, which
// is exactly what was seen going up through the candles.
//
// So: no infinite extension. Draw a bounded segment from the anchor, through
// the candidate, and pendProjBars beyond it. Then cap how far that segment may
// travel vertically: if the slope is steep enough to cover more than
// pendingMaxATR of price within the projection, shorten the segment instead of
// hiding it. The line always draws, and it can never run off the chart.
slopeUp = pendUpSep > 0 and not na(trPH1) ? (candHigh - trPH1) / pendUpSep : na
slopeDn = pendDnSep > 0 and not na(trPL1) ? (candLow  - trPL1) / pendDnSep : na
maxRise = na(atrVal) ? na : atrVal * pendingMaxATR

allowUpF = na(slopeUp) or na(maxRise) ? pendProjBars : math.abs(slopeUp) < 1e-10 ? pendProjBars : math.min(pendProjBars, maxRise / math.abs(slopeUp))
allowDnF = na(slopeDn) or na(maxRise) ? pendProjBars : math.abs(slopeDn) < 1e-10 ? pendProjBars : math.min(pendProjBars, maxRise / math.abs(slopeDn))

allowUp = int(math.max(1, math.floor(allowUpF)))
allowDn = int(math.max(1, math.floor(allowDnF)))

xEndUp = candHighX + allowUp
xEndDn = candLowX  + allowDn
yEndUp = na(slopeUp) ? na : candHigh + slopeUp * allowUp
yEndDn = na(slopeDn) ? na : candLow  + slopeDn * allowDn

drawPendUpper = showPendingTL and not na(trPH1) and not na(trPHx1) and pendUpSep >= pendingMinSep and not na(yEndUp)
drawPendLower = showPendingTL and not na(trPL1) and not na(trPLx1) and pendDnSep >= pendingMinSep and not na(yEndDn)

// Why a pending line is hidden — surfaced on the dashboard rather than left to
// guesswork, same reasoning as the ARMED row.
pendUpWhy = not showPendingTL ? "off" : na(trPH1) ? "no pivot" : pendUpSep < pendingMinSep ? "sep " + str.tostring(pendUpSep) : allowUp < pendProjBars ? "ok(cut)" : "ok"
pendDnWhy = not showPendingTL ? "off" : na(trPL1) ? "no pivot" : pendDnSep < pendingMinSep ? "sep " + str.tostring(pendDnSep) : allowDn < pendProjBars ? "ok(cut)" : "ok"

if drawPendUpper
    line.set_xy1(pendUpperLine, trPHx1, trPH1)
    line.set_xy2(pendUpperLine, xEndUp, yEndUp)
    line.set_color(pendUpperLine, color.new(trendUpperColorIn, pendingTLTransp))
    line.set_width(pendUpperLine, pendingTLWidth)
else
    line.set_xy1(pendUpperLine, na, na)
    line.set_xy2(pendUpperLine, na, na)

if drawPendLower
    line.set_xy1(pendLowerLine, trPLx1, trPL1)
    line.set_xy2(pendLowerLine, xEndDn, yEndDn)
    line.set_color(pendLowerLine, color.new(trendLowerColorIn, pendingTLTransp))
    line.set_width(pendLowerLine, pendingTLWidth)
else
    line.set_xy1(pendLowerLine, na, na)
    line.set_xy2(pendLowerLine, na, na)

// Two independent gates now, both driven by session inputs instead of the two
// hardcoded strings that used to live here. The old pair silently ANDed
// 0930-1530 with 1000-1530, so the real window was 10:00-15:30 and no amount of
// tuning the visible setting could open up the morning.
// ================== FAIR VALUE GAPS ==================
// A fair value gap is a 3-candle imbalance: price ran hard enough that candle 1
// and candle 3 never overlap, leaving a price band that traded in no auction.
//
//   BULLISH: low  >  high[2]   ->  zone from high[2] up to low
//   BEARISH: high <  low[2]    ->  zone from high   up to low[2]
//
// The middle candle is the displacement. The band it skipped is where resting
// orders never got filled, which is why price so often comes back to it.
//
// ORDER MATTERS BELOW: existing zones are checked for fill BEFORE new ones are
// created. A bull zone's top edge IS the creating bar's low, so testing it on
// its own bar would mark every zone filled the instant it appeared.

// Style resolution. STRIPED keeps the box as the invisible bounds-holder and
// draws the visible texture with lines; the box still owns the fill logic.
fvgIsFilled  = fvgStyle == "Filled"
fvgIsOutline = fvgStyle == "Outline"
fvgIsStriped = fvgStyle == "Striped"

// Resolved once at global scope rather than inside the if-block. Note the
// "invisible" cases use a fully transparent colour, not bare `na` — a ternary
// whose branches are color and na can fail type inference in Pine.
fvgBullFill = fvgIsFilled  ? color.new(fvgBullColor, 100 - fvgOpacity) :
   fvgIsStriped ? color.new(fvgBullColor, 100 - math.max(0, fvgOpacity - 8)) : color.new(fvgBullColor, 100)
fvgBearFill = fvgIsFilled  ? color.new(fvgBearColor, 100 - fvgOpacity) :
   fvgIsStriped ? color.new(fvgBearColor, 100 - math.max(0, fvgOpacity - 8)) : color.new(fvgBearColor, 100)
fvgBullEdge = (fvgIsOutline or fvgBorder) ? color.new(fvgBullColor, 25) : color.new(fvgBullColor, 100)
fvgBearEdge = (fvgIsOutline or fvgBorder) ? color.new(fvgBearColor, 25) : color.new(fvgBearColor, 100)
fvgEdgeStyle = fvgIsOutline ? line.style_dashed : line.style_solid

var box[] fvgBull = array.new<box>()
var box[] fvgBear = array.new<box>()
// Stripe lines, fvgMaxStripes per zone, kept in lockstep with the box arrays so
// zone i always owns lines [i*fvgMaxStripes .. i*fvgMaxStripes + fvgMaxStripes - 1].
var line[] fvgBullStripes = array.new<line>()
var line[] fvgBearStripes = array.new<line>()

// nearest unfilled zone above / below price, for the dashboard
float fvgAbove = na
float fvgBelow = na
bool  fvgInside = false

if showFVG
    // ---- maintain existing zones ----
    if array.size(fvgBull) > 0
        for i = array.size(fvgBull) - 1 to 0
            bx  = array.get(fvgBull, i)
            top = box.get_top(bx)
            bot = box.get_bottom(bx)
            gone = fvgFullFill ? low <= bot : low <= top
            if gone
                box.delete(bx)
                array.remove(fvgBull, i)
                if fvgIsStriped and array.size(fvgBullStripes) >= (i + 1) * fvgMaxStripes
                    for j = fvgMaxStripes - 1 to 0
                        line.delete(array.get(fvgBullStripes, i * fvgMaxStripes + j))
                        array.remove(fvgBullStripes, i * fvgMaxStripes + j)
            else
                box.set_right(bx, bar_index + 1)
                if fvgIsStriped and array.size(fvgBullStripes) >= (i + 1) * fvgMaxStripes
                    for j = 0 to fvgMaxStripes - 1
                        line.set_x2(array.get(fvgBullStripes, i * fvgMaxStripes + j), bar_index + 1)
                if top < close
                    fvgBelow := na(fvgBelow) ? top : math.max(fvgBelow, top)
                else if bot > close
                    fvgAbove := na(fvgAbove) ? bot : math.min(fvgAbove, bot)
                else
                    fvgInside := true

    if array.size(fvgBear) > 0
        for i = array.size(fvgBear) - 1 to 0
            bx  = array.get(fvgBear, i)
            top = box.get_top(bx)
            bot = box.get_bottom(bx)
            gone = fvgFullFill ? high >= top : high >= bot
            if gone
                box.delete(bx)
                array.remove(fvgBear, i)
                if fvgIsStriped and array.size(fvgBearStripes) >= (i + 1) * fvgMaxStripes
                    for j = fvgMaxStripes - 1 to 0
                        line.delete(array.get(fvgBearStripes, i * fvgMaxStripes + j))
                        array.remove(fvgBearStripes, i * fvgMaxStripes + j)
            else
                box.set_right(bx, bar_index + 1)
                if fvgIsStriped and array.size(fvgBearStripes) >= (i + 1) * fvgMaxStripes
                    for j = 0 to fvgMaxStripes - 1
                        line.set_x2(array.get(fvgBearStripes, i * fvgMaxStripes + j), bar_index + 1)
                if top < close
                    fvgBelow := na(fvgBelow) ? top : math.max(fvgBelow, top)
                else if bot > close
                    fvgAbove := na(fvgAbove) ? bot : math.min(fvgAbove, bot)
                else
                    fvgInside := true

    // ---- create new zones (only on confirmed bars, no repainting) ----
    minGap = na(atrVal) ? 0.0 : atrVal * fvgMinATR
    newBull = barstate.isconfirmed and low > high[2] and (low - high[2]) >= minGap
    newBear = barstate.isconfirmed and high < low[2] and (low[2] - high) >= minGap

    if newBull
        zTop = low
        zBot = high[2]
        zBox = box.new(bar_index - 2, zTop, bar_index + 1, zBot, border_color = fvgBullEdge,
             border_style = fvgEdgeStyle, bgcolor = fvgBullFill)
        array.push(fvgBull, zBox)
        if fvgIsStriped
            // Fixed SPACING, variable count. Always allocate fvgMaxStripes slots
            // so the index mapping (zone i owns i*fvgMaxStripes .. +N-1) stays
            // exact; slots beyond what the zone can hold are parked at the
            // bottom edge and made fully transparent.
            step = (na(atrVal) or fvgStripeGap <= 0) ? (zTop - zBot) / 4 : atrVal * fvgStripeGap
            want = step <= 0 ? 1 : math.min(fvgMaxStripes, math.max(1, int(math.floor((zTop - zBot) / step)) - 1))
            for j = 1 to fvgMaxStripes
                shown = j <= want
                y = shown ? zBot + step * j : zBot
                array.push(fvgBullStripes, line.new(bar_index - 2, y, bar_index + 1, y,
                     color = shown ? color.new(fvgBullColor, 30) : color.new(fvgBullColor, 100),
                     width = 1, style = line.style_solid))
        if array.size(fvgBull) > maxFVGBoxes
            box.delete(array.shift(fvgBull))
            if fvgIsStriped and array.size(fvgBullStripes) >= fvgMaxStripes
                for j = fvgMaxStripes - 1 to 0
                    line.delete(array.get(fvgBullStripes, j))
                    array.remove(fvgBullStripes, j)

    if newBear
        zTop = low[2]
        zBot = high
        zBox = box.new(bar_index - 2, zTop, bar_index + 1, zBot, border_color = fvgBearEdge,
             border_style = fvgEdgeStyle, bgcolor = fvgBearFill)
        array.push(fvgBear, zBox)
        if fvgIsStriped
            step = (na(atrVal) or fvgStripeGap <= 0) ? (zTop - zBot) / 4 : atrVal * fvgStripeGap
            want = step <= 0 ? 1 : math.min(fvgMaxStripes, math.max(1, int(math.floor((zTop - zBot) / step)) - 1))
            for j = 1 to fvgMaxStripes
                shown = j <= want
                y = shown ? zBot + step * j : zBot
                array.push(fvgBearStripes, line.new(bar_index - 2, y, bar_index + 1, y,
                     color = shown ? color.new(fvgBearColor, 30) : color.new(fvgBearColor, 100),
                     width = 1, style = line.style_solid))
        if array.size(fvgBear) > maxFVGBoxes
            box.delete(array.shift(fvgBear))
            if fvgIsStriped and array.size(fvgBearStripes) >= fvgMaxStripes
                for j = fvgMaxStripes - 1 to 0
                    line.delete(array.get(fvgBearStripes, j))
                    array.remove(fvgBearStripes, j)

inHours     = not useMarketHours or not na(time("1", tradeSession))
notBlacked  = not useOpenBlackout or na(time("1", openBlackout))
inSession   = inHours and notBlacked

isNewDay = ta.change(time("D")) != 0

// ================== SIGNAL STATE ==================
// Moved up from below: the deferred-cross logic needs to read currentSignal
// to decide whether a session-open re-sync is warranted.
var string currentSignal = "Neutral"
var float  entryPrice    = na
var float  slLevel       = na
var float  tp1Level      = na
var float  tp2Level      = na
var int    lvlLeg        = 0
var float  lvlRisk       = na

// Fresh day, fresh slate. This runs BEFORE the signal logic on purpose so the
// session-open re-sync below sees a cleared state and can re-arm. The old
// version did the opposite — it stamped a signal at the daily boundary bar,
// which on an extended-hours chart is 4:00 AM, so ENTRY/SL/TP got priced off a
// thin premarket bar hours before you'd ever trade it.
if isNewDay
    currentSignal := "Neutral"
    entryPrice    := na
    slLevel       := na
    tp1Level      := na
    tp2Level      := na
    lvlLeg        := 0
    lvlRisk       := na

// ================== SIGNAL LOGIC ==================
bullCross = ta.crossover(ema9, ema50)
bearCross = ta.crossunder(ema9, ema50)

trendOk_bull = not useVWAPFilter or close > vwapVal
trendOk_bear = not useVWAPFilter or close < vwapVal

volOk = not useVolFilter or volume > volMA * volMinMult
barOk = barstate.isconfirmed

var int lastSignalBar = na
cooldownOk = not useCooldown or na(lastSignalBar) or (bar_index - lastSignalBar) >= cooldownBars

gatesOpen_bull = trendOk_bull and volOk and barOk and cooldownOk and inSession
gatesOpen_bear = trendOk_bear and volOk and barOk and cooldownOk and inSession

// ---- DEFERRED CROSS ----
// WHY THIS EXISTS: a cross is a single-bar event. A naive implementation requires
// every gate to be open on that exact bar — VWAP, volume, cooldown, bar-close,
// AND the 10:00–15:30 session window. Miss any one of them and the cross was
// gone forever, because ta.crossover() never fires again while the EMAs stay
// on the same side. A 9/50 cross that happened premarket hit `inSession =
// false` and was discarded, and then price could trend all day with the script
// showing nothing.
//
// The fix is to remember the cross instead of consuming it. A raw cross ARMS a
// pending direction; the signal fires on the first later bar where every gate
// is open AND the EMAs still agree with the armed direction. Nothing is
// bypassed — the filters still have to pass, they just no longer have to pass
// on one specific bar. An opposite cross overwrites the pending, so a stale arm
// can't survive a reversal.
var int pendingDir = 0

if bullCross
    pendingDir := 1
if bearCross
    pendingDir := -1

// ---- MANUAL RESET ----
// Two triggers, either one fires it. resetBarsAgo counts back from the live
// candle, which makes it feel like a button: type a number, everything clears
// and re-arms. resetTime is the surgical version for a known bar.
resetByBars = resetBarsAgo > 0 and bar_index == (last_bar_index - resetBarsAgo)
resetByTime = resetUseTime and time >= resetTime and time[1] < resetTime
doReset     = resetByBars or resetByTime

if doReset
    currentSignal := "Neutral"
    entryPrice    := na
    slLevel       := na
    tp1Level      := na
    tp2Level      := na
    lvlLeg        := 0
    lvlRisk       := na
    lastSignalBar := na
    // Re-arm immediately in whatever direction the EMAs are actually pointing,
    // so the very next confirmed bar stamps a fresh set of levels off live
    // price instead of waiting for a cross that may be hours behind you.
    pendingDir := ema9 > ema50 ? 1 : ema9 < ema50 ? -1 : 0

// First bar of each day where the gates actually open (10:00 by default).
sessionOpenBar = inSession and (not inSession[1] or isNewDay)

// Belt-and-braces re-sync: if we reach the session open with nothing armed and
// the dashboard disagrees with what the EMAs plainly show, arm in the EMA's
// direction. Covers the case where the cross predates the loaded history
// entirely, or a gap-and-go day that never produces a crossover event at all.
if useDeferredSignal and sessionOpenBar and pendingDir == 0
    if ema9 > ema50 and currentSignal != "Bullish"
        pendingDir := 1
    else if ema9 < ema50 and currentSignal != "Bearish"
        pendingDir := -1

bullSignal = useDeferredSignal ? (pendingDir ==  1 and ema9 > ema50 and gatesOpen_bull)
                               : (bullCross and gatesOpen_bull)
bearSignal = useDeferredSignal ? (pendingDir == -1 and ema9 < ema50 and gatesOpen_bear)
                               : (bearCross and gatesOpen_bear)

if bullSignal or bearSignal
    lastSignalBar := bar_index
    pendingDir    := 0

// Why isn't it firing? Surfaced on the dashboard so a missing signal is a
// question you can answer in one glance instead of re-reading the source.
pendingBlockedBy = pendingDir == 0 ? "—" :
     not inSession ? "session" :
     not barOk ? "bar close" :
     (pendingDir == 1 and not trendOk_bull) or (pendingDir == -1 and not trendOk_bear) ? "VWAP" :
     not volOk ? "volume" :
     not cooldownOk ? "cooldown" :
     (pendingDir == 1 and ema9 <= ema50) or (pendingDir == -1 and ema9 >= ema50) ? "EMAs flipped" : "firing"

// ================== TRADE LEVELS (SL / TP1 / TP2) ==================
bullSL  = close - atrVal * atrSLMult
bullTP1 = close + atrVal * atrTP1Mult
bullTP2 = close + atrVal * atrTP2Mult
bearSL  = close + atrVal * atrSLMult
bearTP1 = close - atrVal * atrTP1Mult
bearTP2 = close - atrVal * atrTP2Mult

if bullSignal
    currentSignal := "Bullish"
    entryPrice    := close
    slLevel       := bullSL
    tp1Level      := bullTP1
    tp2Level      := bullTP2

if bearSignal
    currentSignal := "Bearish"
    entryPrice    := close
    slLevel       := bearSL
    tp1Level      := bearTP1
    tp2Level      := bearTP2

if bullSignal or bearSignal
    lvlLeg  := 1
    lvlRisk := math.abs(close - (bullSignal ? bullSL : bearSL))

// ---- RUNNER MODE ----
// The problem this solves: price tags TP2 and keeps going, and the levels are
// now sitting well behind the market doing nothing. Instead of leaving them
// there, roll the whole set forward one leg at a time — the stop ratchets up
// to the target you just cleared, TP2 becomes TP1, and a new TP2 goes one leg
// further out. Bounded by maxRollsPerBar so a gap can't run the ladder away.
if autoLadder and currentSignal == "Bullish" and not na(tp1Level) and not na(tp2Level)
    for i = 1 to maxRollsPerBar
        if high >= tp2Level
            lStep = math.max(tp2Level - tp1Level, syminfo.mintick)
            newStop = ladderStop == "Prior TP1" ? tp1Level : ladderStop == "EMA 9" ? ema9 : ladderStop == "ATR trail" ? close - atrVal * atrSLMult : slLevel
            slLevel  := newStop
            tp1Level := tp2Level
            tp2Level := tp2Level + lStep
            lvlLeg   := lvlLeg + 1
        else
            break

if autoLadder and currentSignal == "Bearish" and not na(tp1Level) and not na(tp2Level)
    for i = 1 to maxRollsPerBar
        if low <= tp2Level
            lStep = math.max(tp1Level - tp2Level, syminfo.mintick)
            newStop = ladderStop == "Prior TP1" ? tp1Level : ladderStop == "EMA 9" ? ema9 : ladderStop == "ATR trail" ? close + atrVal * atrSLMult : slLevel
            slLevel  := newStop
            tp1Level := tp2Level
            tp2Level := tp2Level - lStep
            lvlLeg   := lvlLeg + 1
        else
            break

// No SL-breach or TP2-exhaustion reset here on purpose — the signal now
// stays exactly as it fired until EMA9/EMA50 actually cross back the other
// way (bullSignal/bearSignal above already overwrite currentSignal the
// instant that happens), until a new trading day starts, or until EMA9
// crosses the BB middle against the position (added further below, right
// after bbWarnLong/bbWarnShort are computed).
//
// The new-day handling that used to live here has moved ABOVE the signal logic
// (see "Fresh day, fresh slate"). It no longer stamps a signal directly at the
// daily boundary — it clears state, and the session-open re-sync arms a pending
// that fires through the normal gates at a real in-session price.

// ================== OPENING RANGE (ORB) ==================
orbMinutesIn = input.string("15", "ORB Duration (minutes)", options=["5", "15", "30"], group="ORB",
                tooltip="15 is the classic ORB window and tends to filter out the noisiest first few minutes of the session. 5 fires earlier/more often but with more false breaks. 30 is slower and more established.")
orbSession = orbMinutesIn == "5" ? "0930-0935" : orbMinutesIn == "15" ? "0930-0945" : "0930-1000"

var float orbHigh   = na
var float orbLow    = na
var bool  orbDone   = false
var line  orbHiLine = na
var line  orbLoLine = na

isRegularSession = not na(time("1", orbSession))

if isNewDay
    orbHigh := na
    orbLow  := na
    orbDone := false
    line.delete(orbHiLine)
    line.delete(orbLoLine)

if isRegularSession and not orbDone
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

if not isRegularSession and not orbDone and not na(orbHigh)
    orbDone   := true
    orbHiLine := line.new(bar_index, orbHigh, bar_index + 1, orbHigh, color=color.new(color.green, 0), width=4, style=line.style_dotted, extend=extend.right)
    orbLoLine := line.new(bar_index, orbLow,  bar_index + 1, orbLow,  color=color.new(color.red,   0), width=4, style=line.style_dotted, extend=extend.right)

// Written out longhand rather than with ta.crossover/ta.crossunder. Identical
// logic, but it keeps a ta.* history request off a conditionally-assigned var,
// which is what pushed Pine into the max_bars_back error in the first place.
orbBreakUp   = orbDone and not na(orbHigh) and close > orbHigh and close[1] <= orbHigh
orbBreakDown = orbDone and not na(orbLow)  and close < orbLow  and close[1] >= orbLow

// ================== PREVIOUS DAY HIGH / LOW + DAILY PIVOTS ==================
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

dp  = (prevHigh + prevLow + prevClose) / 3
dr1 = 2 * dp - prevLow
ds1 = 2 * dp - prevHigh
dr2 = dp + (prevHigh - prevLow)
ds2 = dp - (prevHigh - prevLow)
dr3 = prevHigh + 2 * (dp - prevLow)
ds3 = prevLow  - 2 * (prevHigh - dp)

var line  pdHighLine = na
var line  pdLowLine  = na
var label pdHighLabel = na
var label pdLowLabel  = na
var line  pvP  = na
var line  pvR1 = na
var line  pvR2 = na
var line  pvR3 = na
var line  pvS1 = na
var line  pvS2 = na
var line  pvS3 = na
var label lbP  = na
var label lbR1 = na
var label lbR2 = na
var label lbR3 = na
var label lbS1 = na
var label lbS2 = na
var label lbS3 = na

if isNewDay
    line.delete(pdHighLine)
    line.delete(pdLowLine)
    label.delete(pdHighLabel)
    label.delete(pdLowLabel)
    pdHighLine  := line.new(bar_index, prevHigh, bar_index + 1, prevHigh, color=color.new(color.aqua,   0), width=pdLineWidth, style=line.style_solid, extend=extend.right)
    pdLowLine   := line.new(bar_index, prevLow,  bar_index + 1, prevLow,  color=color.new(color.orange, 0), width=pdLineWidth, style=line.style_solid, extend=extend.right)
    pdHighLabel := label.new(bar_index, prevHigh, "PDH " + str.tostring(prevHigh, "#.##"), color=color.new(color.aqua,   0), textcolor=color.black, style=label.style_label_right, size=size.normal)
    pdLowLabel  := label.new(bar_index, prevLow,  "PDL " + str.tostring(prevLow,  "#.##"), color=color.new(color.orange, 0), textcolor=color.black, style=label.style_label_right, size=size.normal)

    line.delete(pvP)
    line.delete(pvR1)
    line.delete(pvR2)
    line.delete(pvR3)
    line.delete(pvS1)
    line.delete(pvS2)
    line.delete(pvS3)
    label.delete(lbP)
    label.delete(lbR1)
    label.delete(lbR2)
    label.delete(lbR3)
    label.delete(lbS1)
    label.delete(lbS2)
    label.delete(lbS3)
    // Resistance = red (same as bearish/down elements throughout this
    // script), Support = green/lime (same as bullish/up elements).
    grn = color.new(color.lime, 0)
    rd  = color.new(color.red,  0)
    purp = color.new(#bf80ff, 0)
    pvP  := line.new(bar_index, dp,  bar_index + 1, dp,  color=purp, width=4, extend=extend.right)
    pvR1 := line.new(bar_index, dr1, bar_index + 1, dr1, color=rd,   width=3, extend=extend.right)
    pvR2 := line.new(bar_index, dr2, bar_index + 1, dr2, color=rd,   width=3, extend=extend.right)
    pvR3 := line.new(bar_index, dr3, bar_index + 1, dr3, color=rd,   width=3, extend=extend.right)
    pvS1 := line.new(bar_index, ds1, bar_index + 1, ds1, color=grn,  width=3, extend=extend.right)
    pvS2 := line.new(bar_index, ds2, bar_index + 1, ds2, color=grn,  width=3, extend=extend.right)
    pvS3 := line.new(bar_index, ds3, bar_index + 1, ds3, color=grn,  width=3, extend=extend.right)
    lbP  := label.new(bar_index, dp,  "P",  color=purp, textcolor=color.white, style=label.style_label_right, size=size.normal)
    lbR1 := label.new(bar_index, dr1, "R1", color=rd,   textcolor=color.white, style=label.style_label_right, size=size.normal)
    lbR2 := label.new(bar_index, dr2, "R2", color=rd,   textcolor=color.white, style=label.style_label_right, size=size.normal)
    lbR3 := label.new(bar_index, dr3, "R3", color=rd,   textcolor=color.white, style=label.style_label_right, size=size.normal)
    lbS1 := label.new(bar_index, ds1, "S1", color=grn,  textcolor=color.black, style=label.style_label_right, size=size.normal)
    lbS2 := label.new(bar_index, ds2, "S2", color=grn,  textcolor=color.black, style=label.style_label_right, size=size.normal)
    lbS3 := label.new(bar_index, ds3, "S3", color=grn,  textcolor=color.black, style=label.style_label_right, size=size.normal)

// Labels only get created once at the start of each day, at that day's
// bar_index — without this, they'd stay pinned there and scroll off the
// left edge as the session progresses while the lines themselves (extend
// = extend.right) keep going. This drags every label's x-position forward
// to the current bar, every bar, so they always stay visible on screen.
if not na(pdHighLabel)
    label.set_x(pdHighLabel, bar_index)
if not na(pdLowLabel)
    label.set_x(pdLowLabel, bar_index)
if not na(lbP)
    label.set_x(lbP, bar_index)
if not na(lbR1)
    label.set_x(lbR1, bar_index)
if not na(lbR2)
    label.set_x(lbR2, bar_index)
if not na(lbR3)
    label.set_x(lbR3, bar_index)
if not na(lbS1)
    label.set_x(lbS1, bar_index)
if not na(lbS2)
    label.set_x(lbS2, bar_index)
if not na(lbS3)
    label.set_x(lbS3, bar_index)

// ================== EMA9 CAUTION FLAG ==================
// Doesn't change SIGNAL or reset the trade — EMA9/EMA50 crossing back is
// still the only thing that does that. This just flags when a candle
// closes on the "wrong" side of the fast EMA while a signal is live, since
// that's an early warning worth seeing even if it isn't a full reversal.
caution_bull = currentSignal == "Bullish" and close < ema9
caution_bear = currentSignal == "Bearish" and close > ema9

// ================== EXIT MA (was Bollinger) ==================
// The bands, the cloud and the dashed centre line are all gone. This 20-period
// SMA is the only piece kept, because the "EMA9 crossed the middle against your
// position" rule was never a drawing — it closes trades. Removing the visuals
// without keeping this would have quietly changed how your signals behave.
bbBasis = ta.sma(close, midLen)

bbMidCrossDown = ta.crossunder(ema9, bbBasis)
bbMidCrossUp   = ta.crossover(ema9, bbBasis)

bbWarnLong  = useMidExit and currentSignal == "Bullish" and bbMidCrossDown
bbWarnShort = useMidExit and currentSignal == "Bearish" and bbMidCrossUp

// This genuinely removes the signal rather than just flagging it — EMA9
// crossing back through the 20 SMA against your position resets the trade to
// Neutral, same as the opposite EMA9/EMA50 cross does.
if bbWarnLong or bbWarnShort
    currentSignal := "Neutral"
    entryPrice    := na
    slLevel       := na
    tp1Level      := na
    tp2Level      := na

// ================== CHoCH ENGINE ==================
// Reuses atrVal, ema9, ema50, vwapVal, volMA and inSession from above. Own
// pivots, own state, own risk levels — a second opinion, not a second copy.
chPh = ta.pivothigh(high, chPivotLeft, chPivotRight)
chPl = ta.pivotlow(low,  chPivotLeft, chPivotRight)

var float chSwingHigh = na
var float chSwingLow  = na
if not na(chPh)
    chSwingHigh := chPh
if not na(chPl)
    chSwingLow := chPl

chMinBreak = na(atrVal) ? 0.0 : atrVal * chMinBreakATR
chUpLevel  = na(chSwingHigh) ? na : chSwingHigh + chMinBreak
chDnLevel  = na(chSwingLow)  ? na : chSwingLow  - chMinBreak

var int   chStructTrend = 0
var float chBreakLvl    = na
var int   chBreakBar    = na
chBrokeUp = not na(chUpLevel) and close > chUpLevel and close[1] <= chUpLevel
chBrokeDn = not na(chDnLevel) and close < chDnLevel and close[1] >= chDnLevel

chBull = chEnable and chStructTrend <= 0 and chBrokeUp
chBear = chEnable and chStructTrend >= 0 and chBrokeDn and not chBull

var int   chPos    = 0
var float chEntry  = na
var float chStop   = na
var float chTp1    = na
var float chTp2    = na
var bool  chTp1Hit = false
var int   chLeg    = 0

var bool  chArmedL = false
var bool  chArmedS = false
var float chLvlL   = na
var float chLvlS   = na
var int   chBarL   = na
var int   chBarS   = na

if chBull
    chStructTrend := 1
    chArmedL := true
    chArmedS := false
    chLvlL   := chSwingHigh
    chBarL   := bar_index
    // The SWING level, not the buffered trigger. Invalidation used to test
    // against chUpLevel (swing + 0.15 ATR), which is ABOVE the level the
    // pullback entry deliberately waits for — so the ordinary retest bar
    // tripped the invalidation and the BIAS row went neutral on the very bar
    // CHoCH was entering. Testing against the swing itself makes the two
    // rules agree: a pullback TO the level is structure holding; a close
    // BELOW it is structure failing.
    chBreakLvl := chSwingHigh
    chBreakBar := bar_index
if chBear
    chStructTrend := -1
    chArmedS := true
    chArmedL := false
    chLvlS   := chSwingLow
    chBarS   := bar_index
    chBreakLvl := chSwingLow
    chBreakBar := bar_index

// ---- STRUCTURE INVALIDATION ----
// chStructTrend is a latch: it flips on a break and then sits there until an
// opposite break flips it back. That is why the BIAS row could show a bullish
// CHoCH check while price was ten red candles into a rollover — the break was
// long dead, nothing had told the flag to come down.
//
// A break that price closes back THROUGH is not structure any more, it is a
// failed break. Reset to neutral and let it re-earn a direction.
if chInvalidate and chStructTrend == 1 and not na(chBreakLvl) and close < chBreakLvl
    chStructTrend := 0
    chBreakLvl    := na
    chBreakBar    := na
if chInvalidate and chStructTrend == -1 and not na(chBreakLvl) and close > chBreakLvl
    chStructTrend := 0
    chBreakLvl    := na
    chBreakBar    := na

// How old the surviving break is, in bars. Drives the age readout and the
// stale greying on the BIAS row.
chBreakAge = na(chBreakBar) ? na : bar_index - chBreakBar
chBiasStale = chStructTrend != 0 and not na(chBreakAge) and chBreakAge > chStaleBars

if chArmedL and not na(chBarL) and (bar_index - chBarL) > chPullbackBars
    chArmedL := false
if chArmedS and not na(chBarS) and (bar_index - chBarS) > chPullbackBars
    chArmedS := false

// bar_index > chBarL matters: without it the breaking candle's own low
// satisfies the retest and "wait for pullback" enters on the break anyway.
chRetestL = chArmedL and bar_index > chBarL and low  <= chLvlL + chRetestBuf * atrVal and close > chLvlL
chRetestS = chArmedS and bar_index > chBarS and high >= chLvlS - chRetestBuf * atrVal and close < chLvlS

chRawL = chUsePullback ? chRetestL : chBull
chRawS = chUsePullback ? chRetestS : chBear

chFemaL  = not chUseEMA  or ema9 > ema50
chFemaS  = not chUseEMA  or ema9 < ema50
chFvwapL = not chUseVWAP or close > vwapVal
chFvwapS = not chUseVWAP or close < vwapVal
chFvol   = not chUseVol  or volume > volMA * volMinMult

chGoLong  = chEnable and chRawL and chFemaL and chFvwapL and chFvol and inSession and chPos == 0
chGoShort = chEnable and chRawS and chFemaS and chFvwapS and chFvol and inSession and chPos == 0

// ---- CHoCH RUNNER MODE ----
// Same idea as the 9/50 ladder above. Without this, CHoCH simply closes the
// position the moment TP2 prints and you watch the rest of the move with no
// levels on the chart at all.
if autoLadder and chPos > 0 and not na(chTp1) and not na(chTp2)
    for i = 1 to maxRollsPerBar
        if high >= chTp2
            chStepL = math.max(chTp2 - chTp1, syminfo.mintick)
            chStop  := ladderStop == "Prior TP1" ? chTp1 : ladderStop == "EMA 9" ? ema9 : ladderStop == "ATR trail" ? close - atrVal * chSlBufATR * 4 : chStop
            chTp1   := chTp2
            chTp2   := chTp2 + chStepL
            chTp1Hit := true
            chLeg   := chLeg + 1
        else
            break

if autoLadder and chPos < 0 and not na(chTp1) and not na(chTp2)
    for i = 1 to maxRollsPerBar
        if low <= chTp2
            chStepS = math.max(chTp1 - chTp2, syminfo.mintick)
            chStop  := ladderStop == "Prior TP1" ? chTp1 : ladderStop == "EMA 9" ? ema9 : ladderStop == "ATR trail" ? close + atrVal * chSlBufATR * 4 : chStop
            chTp1   := chTp2
            chTp2   := chTp2 - chStepS
            chTp1Hit := true
            chLeg   := chLeg + 1
        else
            break

// Manual reset also flattens CHoCH, otherwise the reset would clear the 9/50
// levels and leave CHoCH's stop and targets hanging on the chart.
if doReset
    chPos    := 0
    chEntry  := na
    chStop   := na
    chTp1    := na
    chTp2    := na
    chTp1Hit := false
    chLeg    := 0
    chArmedL := false
    chArmedS := false
    chStructTrend := 0
    chBreakLvl    := na
    chBreakBar    := na

chLiveStop = (chUseBE and chTp1Hit and chLeg <= 1) ? chEntry : chStop

// With runner mode on, TP2 rolls the ladder instead of ending the trade, so
// only a stop touch closes the position.
chExitL = chPos > 0 and (low <= chLiveStop or (high >= chTp2 and not autoLadder))
chExitS = chPos < 0 and (high >= chLiveStop or (low <= chTp2 and not autoLadder))

if chPos > 0 and high >= chTp1
    chTp1Hit := true
if chPos < 0 and low <= chTp1
    chTp1Hit := true

if chExitL or chExitS
    chPos    := 0
    chEntry  := na
    chStop   := na
    chTp1    := na
    chTp2    := na
    chTp1Hit := false
    chLeg    := 0

if chGoLong
    e = close
    sl = not na(chSwingLow) ? chSwingLow - chSlBufATR * atrVal : e - atrVal
    // Optional clamp. The structural stop is the correct one in theory, but on
    // a fast day the swing that defines structure can sit 10+ ATR away, which
    // makes R — and therefore both targets — impractical for a 1-minute trade.
    if chMaxStopATR > 0 and not na(atrVal)
        sl := math.max(sl, e - chMaxStopATR * atrVal)
    r = math.max(e - sl, syminfo.mintick)
    chPos := 1
    chEntry := e
    chStop  := sl
    chTp1   := e + r * chTp1R
    chTp2   := e + r * chTp2R
    chTp1Hit := false
    chLeg    := 1
    chArmedL := false

if chGoShort
    e = close
    sl = not na(chSwingHigh) ? chSwingHigh + chSlBufATR * atrVal : e + atrVal
    if chMaxStopATR > 0 and not na(atrVal)
        sl := math.min(sl, e + chMaxStopATR * atrVal)
    r = math.max(sl - e, syminfo.mintick)
    chPos := -1
    chEntry := e
    chStop  := sl
    chTp1   := e - r * chTp1R
    chTp2   := e - r * chTp2R
    chTp1Hit := false
    chLeg    := 1
    chArmedS := false

// ================== PLOTS ==================
ema9Plot  = plot(ema9,  "EMA 9",  color=color.new(color.lime, 0),   linewidth=3)
ema50Plot = plot(ema50, "EMA 50", color=color.new(color.red, 0),    linewidth=2)

// Solid white slow-trend line. Deliberately plotted BEFORE the 9 and 50 above
// it in visual priority terms — it's context, not a trigger — and kept plain
// white so it reads as a different class of line from the lime/red signal
// EMAs. On a low timeframe it needs `ema200Len` bars of history before it
// starts drawing, so expect a gap at the very left edge of the chart.
plot(showEMA200 ? ema200 : na, "EMA 200", color=color.new(color.white, 0),
     linewidth=ema200Width, style=plot.style_line)

plot(vwapVal, "VWAP", color=color.new(#bf80ff, 0), linewidth=vwapWidth, style=plot.style_cross)

// ================== EMA9 / EMA50 GAP FILL ==================
// Green while EMA9 is above EMA50, red while below. The whole point of the
// script is which side of the 50 the 9 is on, so make that a block of color
// rather than something you read off two overlapping lines.
emaFillColor = not showEMAFill ? na : ema9 >= ema50 ? color.new(color.lime, emaFillTrans) : color.new(color.red, emaFillTrans)
fill(ema9Plot, ema50Plot, color=emaFillColor, title="EMA 9/50 Gap")

// ================== EMA9 / EMA50 CROSS DOTS ==================
// bullCross / bearCross are the RAW ta.crossover / ta.crossunder events from
// the signal section — no VWAP, volume, cooldown, session or bar-close gating.
// That's deliberate: this marker exists precisely to show you the crosses the
// filters ate, which the signal triangles by definition can never show.
//
// Plotted midway between the two EMAs on the crossing bar. The true geometric
// intersection falls *between* two bars, and plotted shapes can only sit at
// bar centers, so the midpoint on the cross bar is the honest approximation —
// the two EMAs are within a hair of each other there anyway.
crossY = (ema9 + ema50) / 2

// A cross that also cleared every filter and produced a signal.
bullCrossSignaled = bullCross and bullSignal
bearCrossSignaled = bearCross and bearSignal
// A cross that happened but got blocked somewhere downstream.
bullCrossFiltered = bullCross and not bullSignal
bearCrossFiltered = bearCross and not bearSignal

// Real label objects with text, exactly the technique the BB-mid marker uses —
// a labelled bubble anchored at the cross point rather than a plotted dot.
// Being real objects means old ones can be deleted, so the chart keeps only
// the most recent `maxCrossMarkers` instead of stacking up one per cross for
// the entire history.
//
// Bull crosses sit BELOW the cross point and bear crosses sit ABOVE it,
// matching the belowbar/abovebar convention the signal triangles already use.
var label[] crossLabels = array.new<label>()

f_addCrossMarker(cond, up, signaled) =>
    if cond
        txt    = up ? "9▲50" : "9▼50"
        lStyle = up ? label.style_label_up : label.style_label_down
        lCol   = up ? color.new(color.lime, signaled ? 0 : 50) : color.new(color.red, signaled ? 0 : 50)
        tCol   = up ? color.new(color.black, signaled ? 0 : 30) : color.new(color.white, signaled ? 0 : 30)
        lbl = label.new(bar_index, crossY, txt, style=lStyle, color=lCol,
             textcolor=tCol, size=signaled ? size.normal : size.small)
        array.push(crossLabels, lbl)
        if array.size(crossLabels) > maxCrossMarkers
            label.delete(array.shift(crossLabels))

if showCrossMarkers
    f_addCrossMarker(bullCrossSignaled, true,  true)
    f_addCrossMarker(bearCrossSignaled, false, true)
    f_addCrossMarker(bullCrossFiltered, true,  false)
    f_addCrossMarker(bearCrossFiltered, false, false)

// ================== SIGNAL CANDLE COLOR (purple) ==================
sigCandleColor = bullSignal or bearSignal ? color.new(#9333EA, 0) : na
plotcandle(bullSignal or bearSignal ? open : na, high, low, close,
     title="Signal Candle", color=sigCandleColor, wickcolor=sigCandleColor, bordercolor=sigCandleColor)
barcolor(sigCandleColor)

plotshape(bullSignal, style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.small, title="Bull Signal")
plotshape(bearSignal, style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0),  size=size.small, title="Bear Signal")

// Real label objects (not plotshape) so old markers can be deleted, keeping
// only the most recent `maxCautionMarkers` visible on the chart at once.
var label[] cautionLabels = array.new<label>()

f_addCautionLabel(cond, up) =>
    if cond
        yVal = up ? high : low
        lStyle = up ? label.style_label_down : label.style_label_up
        lbl = label.new(bar_index, yVal, "x", style=lStyle, color=color.new(color.orange, 0), textcolor=color.black, size=size.normal)
        array.push(cautionLabels, lbl)
        if array.size(cautionLabels) > maxCautionMarkers
            label.delete(array.shift(cautionLabels))

f_addCautionLabel(caution_bull, true)
f_addCautionLabel(caution_bear, false)

// Same capped-label technique, separate array so it has its own cap.
var label[] bbCrossLabels = array.new<label>()

f_addBBCrossLabel(cond, up) =>
    if cond
        yVal = up ? high : low
        lStyle = up ? label.style_label_down : label.style_label_up
        lbl = label.new(bar_index, yVal, "BB", style=lStyle, color=color.new(color.fuchsia, 0), textcolor=color.white, size=size.normal)
        array.push(bbCrossLabels, lbl)
        if array.size(bbCrossLabels) > maxBBCrossMarkers
            label.delete(array.shift(bbCrossLabels))

f_addBBCrossLabel(bbWarnLong,  true)
f_addBBCrossLabel(bbWarnShort, false)

// Scalp Lite's set is drawn in a different line style from CHoCH's so the two
// are distinguishable on a chart where both engines are long at once.
slLineStyle = slLineStyleIn == "Dotted" ? line.style_dotted : slLineStyleIn == "Solid" ? line.style_solid : line.style_dashed

var line slLine  = line.new(na, na, na, na, color=color.yellow, width=2, style=slLineStyle)
var line tp1Line = line.new(na, na, na, na, color=color.lime,   width=2, style=slLineStyle)
var line tp2Line = line.new(na, na, na, na, color=#00ff88,      width=2, style=slLineStyle)

// var means the objects are built once, so a style change would not otherwise
// take effect until the script reloads. Re-applying it each bar keeps the
// setting live.
line.set_style(slLine,  slLineStyle)
line.set_style(tp1Line, slLineStyle)
line.set_style(tp2Line, slLineStyle)

// Level lines are re-anchored EVERY bar at the current candle and projected a
// fixed number of bars forward. No extend.right, no left-side history: the
// segment travels with price instead of trailing back to the signal bar.
slActive = currentSignal != "Neutral" and not na(slLevel)

if slActive
    line.set_xy1(slLine,  bar_index - lvlBackBars, slLevel)
    line.set_xy2(slLine,  bar_index + lvlExtendBars, slLevel)
    line.set_xy1(tp1Line, bar_index - lvlBackBars, tp1Level)
    line.set_xy2(tp1Line, bar_index + lvlExtendBars, tp1Level)
    line.set_xy1(tp2Line, bar_index - lvlBackBars, tp2Level)
    line.set_xy2(tp2Line, bar_index + lvlExtendBars, tp2Level)
else
    line.set_xy1(slLine,  na, na)
    line.set_xy2(slLine,  na, na)
    line.set_xy1(tp1Line, na, na)
    line.set_xy2(tp1Line, na, na)
    line.set_xy1(tp2Line, na, na)
    line.set_xy2(tp2Line, na, na)

// Reserves blank space on the right so the dashboard doesn't sit on top of
// the most recent candles. Fully transparent (invisible) but still counted
// in the chart's visible range, which is what actually pushes the candles
// left away from the table.
// The spacer has to reserve room for the LINES, not just the candles. The
// level lines now run lvlExtendBars past the live candle, so if the margin only
// covered the candles the lines ran straight under the table. Adding the two
// together is what actually keeps everything clear of it.
spacerOffset = keepClearOfDash ? dashSpacerBars + lvlExtendBars : dashSpacerBars
plot(spacerOffset > 0 ? close : na, offset=spacerOffset, color=color.new(color.white, 100), title="Dashboard Right Margin Spacer")

// ================== CHoCH PLOTS ==================
// Kept so the values still show in the Data Window, but hidden on the chart
// when the top-layer line version is on — otherwise both would draw.
plot(chEnable and not chSwingTop and not na(chSwingHigh) ? chSwingHigh : na, "CHoCH Swing High", color=chHiColor, style=plot.style_linebr, linewidth=chSwingWidth)
plot(chEnable and not chSwingTop and not na(chSwingLow)  ? chSwingLow  : na, "CHoCH Swing Low",  color=chLoColor, style=plot.style_linebr, linewidth=chSwingWidth)

// ---- RECORD EACH DISTINCT SWING LEVEL ----
// The swing series is a step function, so it only needs one segment per level
// change rather than one point per bar. Recorded here, drawn at the very end
// of the script (see the top-layer block) so the segments are the last drawing
// objects created and therefore render above everything else.
var float[] chHiSegY = array.new<float>()
var int[]   chHiSegX = array.new<int>()
var float[] chLoSegY = array.new<float>()
var int[]   chLoSegX = array.new<int>()

if chSwingTop and chEnable and not na(chSwingHigh) and (na(chSwingHigh[1]) or chSwingHigh != chSwingHigh[1])
    array.push(chHiSegY, chSwingHigh)
    array.push(chHiSegX, bar_index)
    if array.size(chHiSegY) > chSwingSegs
        array.shift(chHiSegY)
        array.shift(chHiSegX)

if chSwingTop and chEnable and not na(chSwingLow) and (na(chSwingLow[1]) or chSwingLow != chSwingLow[1])
    array.push(chLoSegY, chSwingLow)
    array.push(chLoSegX, bar_index)
    if array.size(chLoSegY) > chSwingSegs
        array.shift(chLoSegY)
        array.shift(chLoSegX)

plotshape(chEnable and chUsePullback and chBull, title="CHoCH break (armed)", style=shape.circle, location=location.belowbar, color=color.new(#76ff03, 0), size=size.small)
plotshape(chEnable and chUsePullback and chBear, title="CHoCH break (armed)", style=shape.circle, location=location.abovebar, color=color.new(#ff1744, 0), size=size.small)
plotshape(chGoLong,  title="CHoCH Long Entry",  style=shape.labelup,   location=location.belowbar, color=color.new(#76ff03, 0), textcolor=color.black, text="CHoCH", size=size.normal)
plotshape(chGoShort, title="CHoCH Short Entry", style=shape.labeldown, location=location.abovebar, color=color.new(#ff1744, 0), textcolor=color.white, text="CHoCH", size=size.normal)

// CHoCH stop/targets as line objects rather than plot() calls. plot() paints a
// level across EVERY bar the trade has been open, which buries the chart in
// trailing history. These are rebuilt each bar at the current candle and run
// forward only.
chLineStyle = chLineStyleIn == "Dashed" ? line.style_dashed : chLineStyleIn == "Dotted" ? line.style_dotted : line.style_solid

chStopAsDots = chStopStyleIn == "Circles"
chStopStyle  = chStopStyleIn == "Dashed" ? line.style_dashed : chStopStyleIn == "Dotted" ? line.style_dotted : line.style_solid

var line chStopLine = line.new(na, na, na, na, color=color.new(#ff1744, 0), width=3, style=chStopStyle)
var line chTp1Line  = line.new(na, na, na, na, color=color.new(#76ff03, 0), width=2, style=chLineStyle)
var line chTp2Line  = line.new(na, na, na, na, color=color.new(#00e676, 0), width=2, style=chLineStyle)

line.set_style(chStopLine, chStopStyle)
line.set_style(chTp1Line,  chLineStyle)
line.set_style(chTp2Line,  chLineStyle)

// The Circles option must suppress ONLY the stop line, so the test lives
// inside this block rather than on the outer condition — putting it on the if
// would gate TP1 and TP2 on the stop style too.
if chPos != 0
    if chStopAsDots
        line.set_xy1(chStopLine, na, na)
        line.set_xy2(chStopLine, na, na)
    else
        line.set_xy1(chStopLine, bar_index - lvlBackBars, chLiveStop)
        line.set_xy2(chStopLine, bar_index + lvlExtendBars, chLiveStop)
    line.set_xy1(chTp1Line,  bar_index - lvlBackBars, chTp1)
    line.set_xy2(chTp1Line,  bar_index + lvlExtendBars, chTp1)
    line.set_xy1(chTp2Line,  bar_index - lvlBackBars, chTp2)
    line.set_xy2(chTp2Line,  bar_index + lvlExtendBars, chTp2)
else
    // All three cleared when flat. Clearing only the stop here would strand the
    // target lines at their last values when the stop style is switched.
    line.set_xy1(chStopLine, na, na)
    line.set_xy2(chStopLine, na, na)
    line.set_xy1(chTp1Line,  na, na)
    line.set_xy2(chTp1Line,  na, na)
    line.set_xy1(chTp2Line,  na, na)
    line.set_xy2(chTp2Line,  na, na)

// ---- CHoCH STOP AS CIRCLES ----
// line objects have no circle style, so the dotted stop is a small pool of
// circle LABELS repositioned each bar. Same forward-only behaviour as the
// lines: they sit from the live candle out to the projection length and are
// hidden (y = na) whenever CHoCH is flat.
chDotN = math.min(lvlExtendBars + 1, 25)
var label[] chStopDots = array.new<label>()

if barstate.isfirst
    for i = 0 to chDotN - 1
        array.push(chStopDots, label.new(bar_index, na, "", style=label.style_circle, color=color.new(#ff1744, 0), textcolor=color.new(color.white, 100), size=size.tiny))

if barstate.islast and array.size(chStopDots) == chDotN
    for i = 0 to chDotN - 1
        dot = array.get(chStopDots, i)
        if chStopAsDots and chPos != 0 and not na(chLiveStop)
            label.set_xy(dot, bar_index + int(math.round(i * lvlExtendBars / math.max(1, chDotN - 1))), chLiveStop)
        else
            label.set_xy(dot, bar_index, na)

// ================== PRICE LINE ==================
// A line object anchored at the last bar with extend.right, so it starts at the
// current candle and runs forward only. plot() would paint it back over every
// historical bar. Note a line cannot put a tag on the price axis — only plot()
// does that — so the tag is drawn on the chart instead.
var line  priceLine = line.new(na, na, na, na, extend=extend.right)
var label priceTag  = na
plStyle = priceLineStyle == "Dashed" ? line.style_dashed : priceLineStyle == "Solid" ? line.style_solid : line.style_dotted

if showPriceLine and barstate.islast
    line.set_xy1(priceLine, bar_index, close)
    line.set_xy2(priceLine, priceLineFull ? bar_index + 1 : bar_index + lvlExtendBars, close)
    line.set_color(priceLine, priceLineColor)
    line.set_width(priceLine, priceLineWidth)
    line.set_style(priceLine, plStyle)
    // extend.right runs it off the right edge, straight past the dashboard.
    // extend.none leaves it as the bounded stub every other level line uses.
    line.set_extend(priceLine, priceLineFull ? extend.right : extend.none)
else
    line.set_xy1(priceLine, na, na)
    line.set_xy2(priceLine, na, na)

if showPriceLine and showPriceTag and barstate.islast
    label.delete(priceTag)
    priceTag := label.new(bar_index + priceTagOffset, close, str.tostring(close, format.mintick),
         style = label.style_label_left, color = priceLineColor, textcolor = color.black, size = size.normal)

// ================== DASHBOARD ==================
// One panel for both engines, deliberately compressed. The old layout had 18
// rows and CHoCH would have pushed it past 21 — at which point you stop
// reading it and start scanning past it. Related numbers are paired into one
// cell instead: RSI is 1m/5m, VOL carries ATR, HTF carries both timeframes,
// and the three separate warning rows collapse into one that shows whichever
// is actually firing.
dashPos = dashPosIn == "Top Left" ? position.top_left : dashPosIn == "Top Center" ? position.top_center : dashPosIn == "Middle Right" ? position.middle_right : dashPosIn == "Middle Center" ? position.middle_center : dashPosIn == "Middle Left" ? position.middle_left : dashPosIn == "Bottom Right" ? position.bottom_right : dashPosIn == "Bottom Center" ? position.bottom_center : dashPosIn == "Bottom Left" ? position.bottom_left : position.top_right

dashTxtSize = dashTextIn == "Tiny" ? size.tiny : dashTextIn == "Normal" ? size.normal : dashTextIn == "Large" ? size.large : size.small
dashCellBg  = dashOpaque ? color.new(#0a0a0a, 0) : color.new(#0a0a0a, 5)
dashFrameBg = dashOpaque ? color.new(#0d0d0d, 0) : color.new(#0d0d0d, 10)

var table dash = table.new(dashPos, 2, 12,
     bgcolor=dashFrameBg, border_width=1,
     frame_color=color.new(color.gray, 40), border_color=color.new(color.gray, 60))

f_cell(r, k, v, kc, vc) =>
    if dashCompact
        table.cell(dash, 0, r, k + "  " + v, text_color=vc, text_size=dashTxtSize, bgcolor=dashCellBg)
    else
        table.cell(dash, 0, r, k, text_color=kc, text_size=dashTxtSize, bgcolor=dashCellBg)
        table.cell(dash, 1, r, v, text_color=vc, text_size=dashTxtSize, bgcolor=dashCellBg)

if barstate.islast
    // --- 0. BIAS: the two engines side by side. Agreement is the whole point
    //     of running both, so it gets the top row and its own verdict mark.
    b950     = ema9 > ema50 ? 1 : ema9 < ema50 ? -1 : 0
    agree    = b950 != 0 and b950 == chStructTrend
    // Age of the structure break, shown right after the CHoCH arrow. A check
    // only survives while the break is both agreeing AND still fresh; once it
    // ages past chStaleBars it greys out and drops to a warning, so a bias
    // riding on hour-old structure can't look as strong as one minutes old.
    ageTxt   = (chStructTrend != 0 and not na(chBreakAge)) ? " " + str.tostring(chBreakAge) : ""
    biasOk   = agree and not chBiasStale
    biasTxt  = (b950 > 0 ? "▲" : b950 < 0 ? "▼" : "•") + " 9/50    " + (chStructTrend > 0 ? "▲" : chStructTrend < 0 ? "▼" : "•") + " CHoCH" + ageTxt + (biasOk ? "  ✓" : "  ⚠")
    biasCol  = biasOk ? (b950 > 0 ? color.lime : color.red) : (agree and chBiasStale ? color.gray : color.yellow)
    f_cell(0, "BIAS", biasTxt, color.yellow, biasCol)

    // --- 1. 9/50 engine, with any deferred cross folded in
    sigTxt   = (currentSignal == "Bullish" ? "🟢 LONG" : currentSignal == "Bearish" ? "🔴 SHORT" : "⚪ WAIT") + (pendingDir == 1 ? "  ⏳L" : pendingDir == -1 ? "  ⏳S" : "")
    sigCol   = currentSignal == "Bullish" ? color.lime : currentSignal == "Bearish" ? color.red : color.gray
    f_cell(1, "9/50", sigTxt, color.yellow, sigCol)

    // --- 2. CHoCH engine
    chTxt    = chPos > 0 ? "🟢 LONG" : chPos < 0 ? "🔴 SHORT" : chArmedL ? "⏳ LONG armed" : chArmedS ? "⏳ SHORT armed" : "—"
    chCol    = chPos > 0 or chArmedL ? color.lime : chPos < 0 or chArmedS ? color.red : color.gray
    f_cell(2, "CHoCH", chTxt, color.new(#ffea00, 0), chCol)

    // --- 3/4. Trade numbers. CHoCH takes precedence when it is in a position,
    //     otherwise the 9/50 levels show.
    useCh    = chPos != 0
    tE       = useCh ? chEntry : entryPrice
    tS       = useCh ? chLiveStop : slLevel
    t1       = useCh ? chTp1 : tp1Level
    t2       = useCh ? chTp2 : tp2Level
    // Split off its own row so the stop can be red. Pine has no rich text
    // inside a table cell — one cell is one colour — so a two-tone
    // "ENTRY / SL" line is not possible; it has to be two cells.
    // Leg counter: how many times runner mode has rolled the targets forward.
    // L1 = original targets, L3 = two rolls past TP2 and still riding.
    // Declared before the stop row because the stop text reads it.
    tLeg     = useCh ? chLeg : lvlLeg
    legTxt   = (autoLadder and tLeg > 1) ? "   L" + str.tostring(tLeg) : ""
    entryTxt = na(tE) ? "—" : str.tostring(tE, "#.##")
    stopTxt  = na(tS) ? "—" : str.tostring(tS, "#.##") + (useCh and chTp1Hit and chUseBE and chLeg <= 1 ? "   BE" : "") + (autoLadder and tLeg > 1 ? "   trailing" : "")
    stopCol  = na(tS) ? color.gray : color.new(#ff1744, 0)
    tgtTxt   = na(t1) ? "—" : str.tostring(t1, "#.##") + "  /  " + (na(t2) ? "—" : str.tostring(t2, "#.##")) + legTxt
    f_cell(3, "ENTRY", entryTxt, color.white, color.white)
    f_cell(4, "SL",    stopTxt,  color.new(#ff1744, 0), stopCol)
    f_cell(5, "TP1 / TP2",  tgtTxt,   color.lime,  (autoLadder and tLeg > 1) ? color.yellow : color.new(#00ff88, 0))

    // --- 5. RSI, chart timeframe and 5m in one cell
    rsiTxt   = str.tostring(rsiVal, "#.#") + "  /  " + (na(rsi5) ? "—" : str.tostring(rsi5, "#.#"))
    rsiCol   = rsiVal > 75 or rsiVal < 25 ? color.yellow : color.white
    f_cell(6, "RSI 1m/5m", rsiTxt, color.aqua, rsiCol)

    // --- 6. Volume against its average, with ATR alongside
    volTxt   = str.tostring(volume / volMA, "#.#") + "x    ATR " + str.tostring(atrVal, "#.##")
    volCol   = volume / volMA >= 1.0 ? color.lime : color.red
    f_cell(7, "VOL / ATR", volTxt, color.orange, volCol)

    // --- 7. Higher timeframes
    htfTxt   = (htf5_bull ? "▲" : htf5_bear ? "▼" : "•") + " 5M     " + (htf15_bull ? "▲" : htf15_bear ? "▼" : "•") + " 15M"
    htfCol   = allBull ? color.lime : allBear ? color.red : color.yellow
    f_cell(8, "HTF", htfTxt, color.new(color.silver, 0), htfCol)

    // --- 8. Nearest unfilled fair value gaps
    fvgTxt   = not showFVG ? "off" : fvgInside ? "◆ IN ZONE" : (na(fvgAbove) and na(fvgBelow)) ? "—" : (na(fvgAbove) ? "▼" + str.tostring(close - fvgBelow, "#.##") : na(fvgBelow) ? "▲" + str.tostring(fvgAbove - close, "#.##") : "▲" + str.tostring(fvgAbove - close, "#.##") + "   ▼" + str.tostring(close - fvgBelow, "#.##"))
    fvgCol   = fvgInside ? color.yellow : color.new(color.silver, 0)
    f_cell(9, "FVG", fvgTxt, color.new(#00c853, 0), fvgCol)

    // --- 9. Opening range, back on its own row. Folding it into STATUS meant it
    //     only appeared when nothing else was firing, which is exactly when you
    //     stop noticing it.
    orbTxt   = not orbDone ? "⏳ BUILDING" : close > orbHigh ? "▲ ABOVE" : close < orbLow ? "▼ BELOW" : "↔ INSIDE"
    orbCol   = not orbDone ? color.gray : close > orbHigh ? color.lime : close < orbLow ? color.red : color.yellow
    f_cell(10, "ORB (" + orbMinutesIn + "m)", orbTxt, color.aqua, orbCol)

    // --- 10. Warnings only now that ORB has its own row. Loudest wins.
    warnTxt  = (bbWarnLong or bbWarnShort) ? "🚨 EMA9 crossed the 20 SMA" : (caution_bull or caution_bear) ? "⚠ closed wrong side of EMA9" : "—"
    warnCol  = (bbWarnLong or bbWarnShort) ? color.fuchsia : (caution_bull or caution_bear) ? color.orange : color.gray
    f_cell(11, "STATUS", warnTxt, color.orange, warnCol)

// ================== KEEP DRAWINGS CLEAR OF THE DASHBOARD ==================
// Every line below was built with extend=extend.right, which means it runs to
// the right edge of the chart forever — straight underneath the table, which
// floats in the pane corner and has no idea what bar it is sitting on. There
// is no way to tell a table to dodge, so the lines get cut instead: extend is
// switched off and x2 is pinned a fixed number of bars past the live candle.
//
// Sloped lines (the trendlines) need their y recomputed at the new x or the
// cut would flatten them, so the slope is derived from the two anchors first.
f_capLine(line ln, int xTarget) =>
    if not na(ln)
        x1 = line.get_x1(ln)
        y1 = line.get_y1(ln)
        x2 = line.get_x2(ln)
        y2 = line.get_y2(ln)
        newY = x2 == x1 ? y2 : y1 + ((y2 - y1) / (x2 - x1)) * (xTarget - x1)
        line.set_extend(ln, extend.none)
        line.set_xy2(ln, xTarget, newY)

if keepClearOfDash and barstate.islast
    capX = bar_index + lvlExtendBars
    // Trendlines are sloped and forward-looking — where the line WILL be is the
    // point of drawing it — so they get the same opt-out the price line has.
    if trendFullExtend
        if not na(upperTrendLine)
            line.set_extend(upperTrendLine, extend.right)
        if not na(lowerTrendLine)
            line.set_extend(lowerTrendLine, extend.right)
    else
        f_capLine(upperTrendLine, capX)
        f_capLine(lowerTrendLine, capX)
    f_capLine(orbHiLine,      capX)
    f_capLine(orbLoLine,      capX)
    f_capLine(pdHighLine,     capX)
    f_capLine(pdLowLine,      capX)
    f_capLine(pvP,            capX)
    f_capLine(pvR1,           capX)
    f_capLine(pvR2,           capX)
    f_capLine(pvR3,           capX)
    f_capLine(pvS1,           capX)
    f_capLine(pvS2,           capX)
    f_capLine(pvS3,           capX)
    // priceLine is deliberately NOT capped here — it manages its own extend
    // above so it can run the full width of the chart when you want it to.

// ================== CHoCH SWING LINES — TOP LAYER ==================
// Deliberately the LAST drawing code in the script. Pine has no z-index; among
// drawing objects the most recently created one wins, so rebuilding these here
// puts them above the trendlines, FVG zones, pivots and level lines that were
// created earlier in the bar.
//
// Rebuilt once per bar, not once per tick — the only thing that changes within
// a bar is the final segment's right edge, which is pinned to bar_index.
// Drawn as plain line objects — the flat part of each step AND the vertical
// connector that joins it to the previous level. Both are required: a step
// function drawn without its connectors is not a line, it is a scatter of
// disconnected horizontal ticks.
var line[] chSwLines = array.new<line>()
var int    chSegBar  = na

if chSwingTop and chEnable and barstate.islast and (na(chSegBar) or chSegBar != bar_index)
    chSegBar := bar_index

    // Size guard is mandatory: a Pine for loop does NOT skip when `to` is below
    // `from`, it counts DOWN — so "0 to size - 1" on an empty array runs with
    // i = 0 and throws an out-of-bounds error (RE10045).
    if array.size(chSwLines) > 0
        for i = 0 to array.size(chSwLines) - 1
            line.delete(array.get(chSwLines, i))
        array.clear(chSwLines)

    // Each level draws a flat run, then an angled connector into the next
    // level. The flat is cut short by chRiserBars so the slope has room to
    // live without overrunning the level it is leaving. rEff clamps the slope
    // when two swings land close together, so a 2-bar gap gets a 1-bar slope
    // instead of a connector that runs backwards through the previous step.
    nHi = array.size(chHiSegY)
    if nHi > 0
        for i = 0 to nHi - 1
            yv     = array.get(chHiSegY, i)
            x1     = array.get(chHiSegX, i)
            isEnd  = i == nHi - 1
            xNext  = isEnd ? bar_index : array.get(chHiSegX, i + 1)
            rEff   = isEnd ? 0 : math.min(chRiserBars, math.max(0, xNext - x1 - 1))
            xFlat  = xNext - rEff
            array.push(chSwLines, line.new(x1, yv, xFlat, yv, color=chHiColor, width=chSwingWidth, style=line.style_solid))
            if not isEnd
                array.push(chSwLines, line.new(xFlat, yv, xNext, array.get(chHiSegY, i + 1), color=chHiColor, width=chSwingWidth, style=line.style_solid))

    nLo = array.size(chLoSegY)
    if nLo > 0
        for i = 0 to nLo - 1
            yv     = array.get(chLoSegY, i)
            x1     = array.get(chLoSegX, i)
            isEnd  = i == nLo - 1
            xNext  = isEnd ? bar_index : array.get(chLoSegX, i + 1)
            rEff   = isEnd ? 0 : math.min(chRiserBars, math.max(0, xNext - x1 - 1))
            xFlat  = xNext - rEff
            array.push(chSwLines, line.new(x1, yv, xFlat, yv, color=chLoColor, width=chSwingWidth, style=line.style_solid))
            if not isEnd
                array.push(chSwLines, line.new(xFlat, yv, xNext, array.get(chLoSegY, i + 1), color=chLoColor, width=chSwingWidth, style=line.style_solid))

// ================== ALERTS ==================
alertcondition(bullSignal, title="🟢 Scalp Lite — Long",  message="ScalpLite — Long signal on {{ticker}} at {{close}}")
alertcondition(bearSignal, title="🔴 Scalp Lite — Short", message="ScalpLite — Short signal on {{ticker}} at {{close}}")
alertcondition(caution_bull, title="⚠ Closed Below EMA9", message="ScalpLite — {{ticker}} closed below EMA9 while long at {{close}} (no cross yet)")
alertcondition(caution_bear, title="⚠ Closed Above EMA9", message="ScalpLite — {{ticker}} closed above EMA9 while short at {{close}} (no cross yet)")
alertcondition(orbBreakUp,   title="🟢 ORB Breakout Up",   message="ScalpLite — {{ticker}} broke above the 15-min opening range high at {{close}}")
alertcondition(orbBreakDown, title="🔴 ORB Breakdown Down", message="ScalpLite — {{ticker}} broke below the 15-min opening range low at {{close}}")
alertcondition(bbWarnLong or bbWarnShort, title="🚨 GET OUT", message="🚨 ScalpLite+CHoCH — {{ticker}} EMA9 crossed the 20 SMA against your position at {{close}}. Trade thesis broken — consider exiting.")
alertcondition(chGoLong,  title="CHoCH Long Entry",  message="ScalpLite+CHoCH — CHoCH LONG on {{ticker}} at {{close}}")
alertcondition(chGoShort, title="CHoCH Short Entry", message="ScalpLite+CHoCH — CHoCH SHORT on {{ticker}} at {{close}}")
alertcondition(chBull, title="CHoCH Break Up",   message="ScalpLite+CHoCH — bullish structure break on {{ticker}} at {{close}} (armed)")
alertcondition(chBear, title="CHoCH Break Down", message="ScalpLite+CHoCH — bearish structure break on {{ticker}} at {{close}} (armed)")
````
