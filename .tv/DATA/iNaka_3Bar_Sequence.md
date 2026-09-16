<!-- tradingview-pine-id: PUB;054659844cf7408e8f78528c26461111 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# iNaka 3-Bar Sequence

Source: https://www.tradingview.com/script/yBnTRfmR-iNaka-3-Bar-Sequence/

## Description

iNaka 3-Bar Sequence marks every place a three-bar candlestick sequence that YOU define completes. You set what the 1st, 2nd and 3rd bar must each be - Bull Bar, Bear Bar, Hammer, Shooting Star, Doji, or Any Bar for "I do not care what shape this one is" - and the script marks the bar that finishes that sequence. Around it sit six optional gates that decide whether a completed sequence counts here.

Two things here are uncommon, and they are the reason it exists. The sequence is defined ACROSS ALL THREE POSITIONS independently, with an Any Bar wildcard on each, so the same script expresses a two-bar pair, a three-bar reversal or a single candlestick without changing anything but the dropdowns. And the RSI test is a SEPARATE BAND PER POSITION rather than one reading at the signal bar - momentum is checked as a shape running through the sequence, not as a threshold at the end of it.

WHY THIS IS ONE TOOL AND NOT A PILE OF INDICATORS
The three-bar sequence is the only thing the six gates can fire. Bollinger Bands, the two moving averages, RSI, the price window and the time window produce no signal of their own: none of them plots a cross, an arrow or an alert, and none of them can trigger anything by itself. They are AND-gates on the same event, and each answers a different question about the SAME three bars:
- RSI, read separately at each of the three bar positions: what momentum was doing THROUGH the sequence. This is not "RSI is overbought" - it is a band per bar, so you can say "already extended two bars ago, more extended one bar ago, still up here" and reject the same candlestick shape when it appears with flat momentum.
- Bollinger band width: was the market wide enough for a three-bar sequence to mean anything. The same three candles inside a dead flat band are noise.
- Bollinger band touch: did the sequence complete AT an extreme rather than in the middle of the range.
- Fast and slow moving average: did it complete with the prevailing trend or against it.
- Price window: is price in the area you are willing to trade at all.
- Time window: is the bar inside the date range you are testing.
Every gate is off by default, so the script starts as a plain pattern detector and you add context one gate at a time. That is the design: a candlestick shape is not a setup until you have said where and when it counts, and each gate is one clause of that sentence.

WHAT IT DRAWS
- A red triangle above every bar that completes the sequence, plus a green background tint on that bar.
- A green numbered label above the bar each time an alert is allowed through. The number is a running count of alerts on the chart. With Silent Minutes left at 0 every detection is numbered.
- A red numbered label below the bar where a Silent-Minutes mute window ended, carrying the number of the alert that started it - so a muted stretch reads as a matched green/red pair.
- Optionally the Bollinger Bands, the two moving averages, and the New High / New Low lines. All three are off by default. Drawing the bands or the moving averages changes nothing at all; the New High / New Low toggle also arms that pair of alerts, which is described in its own section below.

HOW A BAR IS CLASSIFIED
- Bull Bar: close above open, with an optional minimum body size in POINTS (1 point = 1 tick, so the value follows the feed's precision: on a 2-decimal XAUUSD feed 100 points = $1.00, on a 3-decimal one 1000 points = $1.00). Bear Bar is the mirror.
- Hammer: lower shadow longer than Hammer Shadow % of the bar's high-low range, upper shadow no more than (1 - Hammer Body %) of it, and body no more than Hammer Body % of it.
- Shooting Star: the same test with the shadows swapped, using its own body and shadow percentages.
- Doji: body no more than Doji Body % of the range.
- Any Bar: no bar-type constraint at this position. Its RSI band and bar-comparison rule, if you enabled them, still apply.

HOW THE SEQUENCE IS TESTED
The 1st bar is two bars back, the 2nd is one bar back, and the 3rd is the current bar. All three are tested on every bar, so the sequence is reported the moment its last bar completes it. On top of the type test, two optional rules can be attached:
- Bar Comparison, separately for the 2nd and the 3rd bar: require that bar's close to be higher or lower than the open, high, low or close of a bar a chosen number of bars before it. This is how you turn "Bull, Bull, Shooting Star" into "Bull, Bull that closed above the bar before it, Shooting Star".
- The RSI band for that position, if RSI detection is on.

THREE THINGS THAT WILL SURPRISE YOU IF NOBODY SAYS THEM
1. Any Bar switches off the bar-TYPE test for that position and nothing else. Its RSI band and its Bar Comparison rule, if you enabled them, still apply. That is the point: "any shape here, but momentum had to be in this range" is a setup you can actually express.
2. If you tick both Near Upper BB and Near Lower BB, Near Upper wins and Near Lower is ignored. The same applies to Detect Above MA and Detect Below MA: ticking both is treated as Above.
3. Use MA Detection with NEITHER Above nor Below ticked blocks every signal. That is deliberate rather than an oversight - the gate is on and you have not told it which side - but it looks like the script has stopped working, so it is worth knowing.

SETTINGS
Sequence - the master switch and the three bar types. Bar Definitions - what each type means: minimum bull/bear body in points, and the body and shadow percentages for Hammer, Shooting Star and Doji. Bar Comparison - the optional higher/lower rules for the 2nd and 3rd bars. Momentum (RSI) - one RSI length, then a min/max band for each of the three positions. Bollinger Context - length, basis MA type, source, standard deviation; whether to draw the bands; the width filter in points; and the Near Upper / Near Lower band-touch gate. Trend (Moving Averages) - fast and slow type and length, which side to require, and whether to draw them. Price & Time Window - an absolute price range and a date range. Note the price range defaults to 0-100, which blocks everything on any instrument priced above 100, so set it before switching it on. New High / New Low - a separate pair of alerts, described below. Alerts & Display - the triangle and highlight toggles and their colours, Silent Minutes, and the numbered markers.

NEW HIGH / NEW LOW - READ WHAT IT ACTUALLY TESTS
This is an independent pair of alerts, not part of the sequence and not a gate on it. New High fires when the close is at or above the highest high of the last N bars including the current one. Because a bar's close can never exceed its own high, that can only be true when the bar closes exactly at its high AND that high is the highest of the window. It is therefore a good deal stricter than "price made a new high", and on most instruments it fires rarely. New Low is the mirror.

Why it ships in this script rather than as a separate one: the sequence engine describes SHAPES, and this is the one piece of context a shape cannot express - the moment price closes at the extreme of the last N bars. It shares the same Silent Minutes throttle and the same numbered labels, so one alert stream covers both, and a sequence alert on the same bar takes precedence over it. Leave Use New High / New Low switched off and it draws nothing and fires nothing.

SILENT MINUTES
After an alert is allowed through, all further alerts from the script are suppressed for this many minutes. Detection is never suppressed: the triangles and the highlight keep appearing, so the chart still shows you everything that happened while the alerts were muted. 0 disables it.

HOW TO USE IT
- Start with the pattern alone, every gate off, on the timeframe you actually trade. Find out how often your shape occurs before you start filtering it.
- Add ONE gate at a time and watch what it removes. If a gate removes nothing, it is not doing work; if it removes everything, it is the wrong gate for that market.
- Add the RSI bands last, and set them from what you observe on the chart rather than from the usual 70/30 habits. The three bands are a shape, not a threshold.
- If you use this for alerts on a fast timeframe, set Silent Minutes rather than tightening the pattern: you keep seeing every occurrence on the chart and stop getting told about each one.

LIMITATIONS, WHICH YOU SHOULD READ BEFORE USING IT
- The 3rd bar of the sequence is the CURRENT bar. The triangle, the background tint and the alert condition are evaluated on a bar that is still forming, so they can appear and disappear until it closes. Closed bars never change. Set every alert to "Once Per Bar Close". The numbered labels are drawn only on confirmed bars and never repaint. The New High / New Low lines, if you switch them on, also move while the current bar forms.
- Apart from the RSI bands, which are read at each bar's own position, the gates read the CURRENT bar's state. The band-touch gate compares all three bars against the current bar's Bollinger Bands, and the band-width, MA, price and time gates are all evaluated on the bar that completes the sequence.
- Candlestick classification is threshold arithmetic on one bar's four prices. It has no notion of context, and the same shape on a 1-minute chart and a daily chart is not the same event.
- Only the most recent 500 numbered labels are kept. Scroll back far enough and the older ones have been deleted; the triangles and the highlight are not affected and go back as far as the chart data.
- The default percentages for Hammer, Shooting Star and Doji are conventional starting values, not optimised or validated ones. Every instrument has its own shadow distribution and you should expect to change them.
- This is a detection tool. It does not generate entries or exits, does not size or manage a position, and makes no claim about profitability.

ALERTS
Three conditions: "3-Bar Sequence Detected", "New High" and "New Low". All three respect Silent Minutes. Set them to "Once Per Bar Close".

The chart above is not on default settings. The sequence is set to 1st Bar = Bear Bar, 2nd Bar = Bear Bar, 3rd Bar = Bull Bar. Use Bar Comparison for 3rd Bar is on, so the closing bar must also close above the OPEN of the first bar of the sequence (Comparison Type = Higher, Compare Against = Open, Lookback Period = 2). Use RSI Detection is on with a different band at each position - 1st Bar 1-30, 2nd Bar 1-40, 3rd Bar 1-50. Read together that is: two down bars completing from deeply oversold, reclaimed by an up bar that closes back above where the move began, with the momentum requirement widening one step at a time across the three bars. Everything else is at its default.

Published open-source under the Mozilla Public License 2.0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Inakatrader - iNaka 3-Bar Sequence
//
// A configurable THREE-BAR SEQUENCE detector. You describe the shape you trade — what the 1st, 2nd
// and 3rd bar must look like — and the script marks every place that exact sequence completes.
//
// WHY THE OTHER COMPONENTS ARE HERE (read this first)
//   This is one setup definition, not a stack of indicators. The three-bar sequence is the only thing
//   the six gates below can fire. Bollinger Bands, the two moving averages, RSI, the price window and
//   the time window never produce a signal of their own — none of them plots a cross, an arrow or an
//   alert, and none can trigger anything by itself. They are AND-gates on the same event, and each
//   answers a different question about the SAME three bars:
//     - RSI windows      : what momentum was doing AT EACH OF THE THREE BARS (per-position, not one
//                          reading) — this is how you say "exhaustion into the pattern" rather than
//                          "RSI is high".
//     - Bollinger width  : was the market wide enough for the sequence to mean anything (the same
//                          three bars inside a dead flat band are noise).
//     - Bollinger touch  : did the sequence complete AT an extreme rather than mid-range.
//     - Fast/Slow MA     : did it complete with the prevailing trend or against it.
//     - Price window     : is price in the area you are willing to trade at all.
//     - Time window      : is the date inside the range you are testing.
//   Every gate is off by default, so the script starts as a pure pattern detector and you add context
//   one gate at a time. Silent Minutes is not a gate: it throttles alerts and never changes what is
//   detected. New High / New Low is not a gate either — it is an independent alert pair, off by
//   default, and its own section below says why it ships in this script.
//
// WHAT IT DRAWS
//   - A red triangle above every bar that COMPLETES the sequence, plus a green background highlight.
//   - A green numbered label above the bar each time an ALERT is allowed through. The number is a
//     running count of alerts on the chart; with Silent Minutes = 0 every detection is numbered.
//   - A red numbered label below the bar where a Silent-Minutes window ENDS, carrying the number of
//     the alert that started it — so a muted stretch is visible as a matched green/red pair.
//   - Optional Highest / Lowest lines, Bollinger Bands and the two MAs, all off by default.
//
// HOW A BAR IS CLASSIFIED
//   Bull Bar / Bear Bar : body direction, with an optional minimum body size in POINTS.
//   Hammer              : lower shadow > Hammer Shadow % of the bar's range, body <= Hammer Body %.
//   Shooting Star       : upper shadow > Shooting Star Shadow % of the range, body <= its Body %.
//   Doji                : body <= Doji Body % of the range.
//   Any Bar             : no bar-type constraint at this position — see the note below.
//
// WHAT "ANY BAR" DOES AND DOES NOT SWITCH OFF
//   Any Bar drops the bar-TYPE test for that position and nothing else. Its RSI window still applies,
//   and so does its bar-comparison rule if you enabled one. This is what makes "any shape, but
//   momentum had to be here" expressible: the three gates on a position are independent, and you
//   switch off exactly the one you mean.
//
// NON-REPAINT NOTE
//   The 3rd bar of the sequence is the CURRENT bar, so the triangle, the highlight and the alert
//   condition are all evaluated on a bar that is still forming and can appear and disappear until it
//   closes. Closed bars never change. Set every alert to "Once Per Bar Close". The numbered labels are
//   drawn only on confirmed bars and therefore never repaint.
//
// DISTANCES ARE POINTS, NOT PIPS — 1 point = 1 syminfo.mintick, so a points value follows the
// feed's precision: on a 2-decimal XAUUSD feed 100 points = $1.00, on a 3-decimal one 1000 points = $1.00.
//
// v1 (2026-08-25) — first release.
//@version=6
indicator("iNaka 3-Bar Sequence", shorttitle="iNaka 3BS", overlay=true, max_labels_count=500)

// =====================================================================
// === SEQUENCE ===
// =====================================================================
SEQ_GROUP = "Sequence"

usePattern    = input.bool(true, "Detect 3-Bar Sequence", group=SEQ_GROUP, tooltip="Master switch for the pattern engine. Off = no triangles, no highlight and no pattern alerts; the New High / New Low alerts, if enabled, still work.")
firstBarType  = input.string("Bull Bar", "1st Bar Type", options=["Any Bar", "Bear Bar", "Bull Bar", "Hammer", "Shooting Star", "Doji"], group=SEQ_GROUP, tooltip="The OLDEST of the three bars (two bars back). Any Bar drops the bar-type test here; this position's RSI band and bar-comparison rule still apply.")
secondBarType = input.string("Bear Bar", "2nd Bar Type", options=["Any Bar", "Bear Bar", "Bull Bar", "Hammer", "Shooting Star", "Doji"], group=SEQ_GROUP, tooltip="The middle bar (one bar back).")
thirdBarType  = input.string("Any Bar",  "3rd Bar Type", options=["Any Bar", "Bear Bar", "Bull Bar", "Hammer", "Shooting Star", "Doji"], group=SEQ_GROUP, tooltip="The CURRENT bar — the one that completes the sequence. Left at Any Bar by default, which makes the default setup a two-bar Bull-then-Bear pair confirmed on the current bar.")

// =====================================================================
// === BAR DEFINITIONS ===
// What each bar type means. These apply to every position.
// =====================================================================
DEF_GROUP = "Bar Definitions"
bullBodyPts     = input.float(0.0, "Bull Bar Min Body (points)", minval=0, group=DEF_GROUP, tooltip="Minimum close-minus-open for a Bull Bar, in POINTS (1 point = 1 tick, so it follows the feed's precision: on a 2-decimal XAUUSD feed 100 points = $1.00, on a 3-decimal one 1000 points = $1.00). 0 = any bar closing above its open.")
bearBodyPts     = input.float(0.0, "Bear Bar Min Body (points)", minval=0, group=DEF_GROUP, tooltip="Minimum open-minus-close for a Bear Bar, in POINTS. 0 = any bar closing below its open.")
hammerBodyPct   = input.float(0.2, "Hammer Body Size (%)",           minval=0.0, maxval=1.0, step=0.01, group=DEF_GROUP, tooltip="Body may be at most this fraction of the bar's high-low range. 0.2 = 20%.")
hammerShadowPct = input.float(0.8, "Hammer Shadow Size (%)",         minval=0.0, maxval=1.0, step=0.01, group=DEF_GROUP, tooltip="Lower shadow must exceed this fraction of the bar's range, and the upper shadow must be at most (1 - Body Size).")
starBodyPct     = input.float(0.2, "Shooting Star Body Size (%)",    minval=0.0, maxval=1.0, step=0.01, group=DEF_GROUP, tooltip="Body may be at most this fraction of the bar's high-low range.")
starShadowPct   = input.float(0.8, "Shooting Star Shadow Size (%)",  minval=0.0, maxval=1.0, step=0.01, group=DEF_GROUP, tooltip="Upper shadow must exceed this fraction of the bar's range, and the lower shadow must be at most (1 - Body Size).")
dojiBodyPct     = input.float(0.02, "Doji Body Size (%)",            minval=0.0, maxval=1.0, step=0.01, group=DEF_GROUP, tooltip="Body may be at most this fraction of the bar's high-low range. 0.02 = 2%.")

// =====================================================================
// === BAR COMPARISON ===
// Optional "this bar must be higher/lower than a bar N back" rules.
// =====================================================================
CMP_GROUP = "Bar Comparison"
useCmp2nd  = input.bool(false, "Use Bar Comparison for 2nd Bar", group=CMP_GROUP, tooltip="Require the 2nd bar's close to be higher or lower than a chosen price of a bar further back. Applies even when the 2nd position is set to Any Bar.")
cmpType2nd = input.string("Higher", "2nd Bar Comparison Type", options=["Higher", "Lower"], group=CMP_GROUP)
cmpRef2nd  = input.string("Open",   "2nd Bar Compare Against", options=["Open", "High", "Low", "Close"], group=CMP_GROUP, tooltip="Which price of the older bar to compare the 2nd bar's CLOSE against.")
cmpBack2nd = input.int(1, "2nd Bar Lookback Period", minval=1, group=CMP_GROUP, tooltip="How many bars before the 2nd bar to take that price from. 1 = the bar immediately before it, i.e. the 1st bar of the sequence.")
useCmp3rd  = input.bool(false, "Use Bar Comparison for 3rd Bar", group=CMP_GROUP, tooltip="Same rule for the 3rd bar (the current bar). Applies even when the 3rd position is set to Any Bar.")
cmpType3rd = input.string("Higher", "3rd Bar Comparison Type", options=["Higher", "Lower"], group=CMP_GROUP)
cmpRef3rd  = input.string("Open",   "3rd Bar Compare Against", options=["Open", "High", "Low", "Close"], group=CMP_GROUP)
cmpBack3rd = input.int(1, "3rd Bar Lookback Period", minval=1, group=CMP_GROUP, tooltip="How many bars back from the CURRENT bar to take that price from. 1 = the 2nd bar of the sequence.")

// =====================================================================
// === MOMENTUM (RSI) ===
// One RSI, read at each of the three bar positions.
// =====================================================================
RSI_GROUP = "Momentum (RSI)"
useRSI    = input.bool(false, "Use RSI Detection", group=RSI_GROUP, tooltip="Require RSI to sit inside a given band AT EACH BAR of the sequence, including any position set to Any Bar. This is the shape of momentum across three bars, not a single reading.")
rsiLength = input.int(12, "RSI Length", minval=1, group=RSI_GROUP)
rsi1Min   = input.float(60.0, "1st Bar RSI Min", minval=0, maxval=100, group=RSI_GROUP, tooltip="Lower edge of the RSI band that must hold at the OLDEST bar of the sequence.")
rsi1Max   = input.float(99.0, "1st Bar RSI Max", minval=0, maxval=100, group=RSI_GROUP, tooltip="Upper edge of that band.")
rsi2Min   = input.float(70.0, "2nd Bar RSI Min", minval=0, maxval=100, group=RSI_GROUP, tooltip="Lower edge of the RSI band that must hold at the MIDDLE bar.")
rsi2Max   = input.float(99.0, "2nd Bar RSI Max", minval=0, maxval=100, group=RSI_GROUP, tooltip="Upper edge of that band.")
rsi3Min   = input.float(55.0, "3rd Bar RSI Min", minval=0, maxval=100, group=RSI_GROUP, tooltip="Lower edge of the RSI band that must hold at the CURRENT bar.")
rsi3Max   = input.float(99.0, "3rd Bar RSI Max", minval=0, maxval=100, group=RSI_GROUP, tooltip="Upper edge of that band.")

// =====================================================================
// === BOLLINGER CONTEXT ===
// Bands are always computed; they gate the sequence and are drawn only
// on request. They never signal on their own.
// =====================================================================
BB_GROUP = "Bollinger Context"
bbLength    = input.int(20, "BB Length", minval=1, group=BB_GROUP)
bbMaType    = input.string("EMA", "BB Basis MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=BB_GROUP)
bbSrc       = input.source(close, "BB Source", group=BB_GROUP)
bbMult      = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, group=BB_GROUP)
plotBB      = input.bool(false, "Plot Bollinger Bands", group=BB_GROUP, tooltip="Drawing the bands changes nothing about detection.")
useBBWidth  = input.bool(false, "Use BB Width Filter", group=BB_GROUP, tooltip="Only accept the sequence when the distance between the two bands is inside the range below — a volatility floor and ceiling.")
minWidthPts = input.float(50.0,  "Min BB Width (points)", minval=0, group=BB_GROUP, tooltip="POINTS, not pips. Upper band minus lower band, divided by one tick.")
maxWidthPts = input.float(150.0, "Max BB Width (points)", minval=0, group=BB_GROUP, tooltip="POINTS, not pips. Set well above Min unless you deliberately want to skip fast markets.")
nearUpperBB = input.bool(false, "Near Upper BB", group=BB_GROUP, tooltip="Only accept the sequence when at least one of the three bars reached the CURRENT upper band. If both this and Near Lower BB are ticked, Near Upper wins.")
nearLowerBB = input.bool(false, "Near Lower BB", group=BB_GROUP, tooltip="Only accept the sequence when at least one of the three bars reached the CURRENT lower band. Ignored while Near Upper BB is ticked.")

// =====================================================================
// === TREND (MOVING AVERAGES) ===
// =====================================================================
MA_GROUP = "Trend (Moving Averages)"
useMA      = input.bool(false, "Use MA Detection", group=MA_GROUP, tooltip="Only accept the sequence when price sits on the chosen side of BOTH moving averages and the two are stacked the same way. Tick at least one of the two boxes below or nothing will ever pass.")
aboveMA    = input.bool(false, "Detect Above MA", group=MA_GROUP, tooltip="Close above both MAs AND Fast above Slow.")
belowMA    = input.bool(false, "Detect Below MA", group=MA_GROUP, tooltip="Close below both MAs AND Fast below Slow. Ticking both boxes is treated as Above.")
fastMaType = input.string("EMA", "Fast MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=MA_GROUP)
fastMaLen  = input.int(50, "Fast MA Length", minval=1, group=MA_GROUP)
slowMaType = input.string("EMA", "Slow MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=MA_GROUP)
slowMaLen  = input.int(100, "Slow MA Length", minval=1, group=MA_GROUP)
plotMAs    = input.bool(false, "Plot Fast and Slow MAs", group=MA_GROUP, tooltip="Drawing the MAs changes nothing about detection.")

// =====================================================================
// === PRICE & TIME WINDOW ===
// =====================================================================
WIN_GROUP = "Price & Time Window"
usePriceWindow = input.bool(false, "Use Custom Price Level", group=WIN_GROUP, tooltip="Only accept the sequence while the current close sits between the two ABSOLUTE prices below. These are prices in the symbol's quote currency, not distances — the defaults (0 to 100) block everything on an instrument priced above 100, so set them before ticking this on.")
minPrice       = input.float(0.0,   "Min Custom Price", group=WIN_GROUP)
maxPrice       = input.float(100.0, "Max Custom Price", group=WIN_GROUP)
useTimeWindow  = input.bool(false, "Use Timestamp", group=WIN_GROUP, tooltip="Only accept the sequence between the two dates below, in the exchange's timezone. Useful for isolating a period while testing.")
startDay       = input.int(13,   "Start Day",   minval=1, maxval=31, group=WIN_GROUP)
startMonth     = input.int(1,    "Start Month", minval=1, maxval=12, group=WIN_GROUP)
startYear      = input.int(2022, "Start Year",  group=WIN_GROUP)
endDay         = input.int(13,   "End Day",     minval=1, maxval=31, group=WIN_GROUP)
endMonth       = input.int(12,   "End Month",   minval=1, maxval=12, group=WIN_GROUP)
endYear        = input.int(2090, "End Year",    group=WIN_GROUP)

// =====================================================================
// === NEW HIGH / NEW LOW ===
// A separate, independent alert — not part of the sequence and not a gate on it.
// It ships here because the sequence engine describes SHAPES, and this is the one
// piece of context a shape cannot express: price closing at the extreme of the last
// N bars. It shares the Silent-Minutes throttle and the label counter, and a
// sequence alert on the same bar outranks it.
// =====================================================================
HL_GROUP = "New High / New Low"
useHighLow = input.bool(false, "Use New High / New Low", group=HL_GROUP, tooltip="Independent of the sequence engine. Draws the two lines and enables the New High / New Low alerts. It does NOT gate the pattern.")
hlLookback = input.int(10, "New High/Low Lookback (bars)", minval=1, group=HL_GROUP, tooltip="How many bars, including the current one, the high and the low are measured over.")

// =====================================================================
// === ALERTS & DISPLAY ===
// =====================================================================
VIZ_GROUP = "Alerts & Display"
useSymbols       = input.bool(true, "Use Symbols", group=VIZ_GROUP, tooltip="Red triangle above every completed sequence.")
highlightEnabled = input.bool(true, "Highlight Enabled", group=VIZ_GROUP, tooltip="Background tint on every completed sequence.")
symbolColor      = input.color(color.red,   "Symbol Color",    group=VIZ_GROUP, inline="col")
highlightColor   = input.color(color.green, "Highlight Color", group=VIZ_GROUP, inline="col")
silentMinutes    = input.int(0, "Silent Minutes", minval=0, group=VIZ_GROUP, tooltip="After an alert is allowed through, suppress every further alert from this script for this many minutes. 0 = no suppression. Detection and the triangles are never suppressed — only the alerts and the numbered labels.")
showSilentMarks  = input.bool(true, "Show Silent Minute Number Markers", group=VIZ_GROUP, tooltip="Green numbered label above the bar where an alert fired, and a red label below the bar where its silent window ended.")

// =====================================================================
// === MOVING AVERAGE HELPER ===
// =====================================================================
ma(float source, simple int length, simple string maType) =>
    switch maType
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)
        => ta.ema(source, length)

// =====================================================================
// === CONTEXT SERIES (all computed unconditionally, every bar) ===
// A ta.* call must never sit inside a conditional block: its internal
// state desynchronises the moment the condition changes.
// =====================================================================
basis     = ma(bbSrc, bbLength, bbMaType)
dev       = bbMult * ta.stdev(bbSrc, bbLength)
upperBand = basis + dev
lowerBand = basis - dev

fastMA = ma(close, fastMaLen, fastMaType)
slowMA = ma(close, slowMaLen, slowMaType)

rsiSeries = ta.rsi(close, rsiLength)
rsiBar1   = rsiSeries[2]   // oldest bar of the sequence
rsiBar2   = rsiSeries[1]   // middle bar
rsiBar3   = rsiSeries      // current bar

highestN = ta.highest(high, hlLookback)
lowestN  = ta.lowest(low,  hlLookback)

// =====================================================================
// === BAR CLASSIFICATION ===
// =====================================================================
isBullBar(float o, float c) =>
    (c - o) > bullBodyPts * syminfo.mintick

isBearBar(float o, float c) =>
    (o - c) > bearBodyPts * syminfo.mintick

isHammer(float o, float c, float h, float l) =>
    rng         = h - l
    bodySize    = math.abs(c - o)
    upperShadow = h - math.max(c, o)
    lowerShadow = math.min(c, o) - l
    lowerShadow > hammerShadowPct * rng and upperShadow <= (1 - hammerBodyPct) * rng and bodySize <= hammerBodyPct * rng

isShootingStar(float o, float c, float h, float l) =>
    rng         = h - l
    bodySize    = math.abs(c - o)
    upperShadow = h - math.max(c, o)
    lowerShadow = math.min(c, o) - l
    upperShadow > starShadowPct * rng and lowerShadow <= (1 - starBodyPct) * rng and bodySize <= starBodyPct * rng

isDoji(float o, float c, float h, float l) =>
    math.abs(c - o) <= dojiBodyPct * (h - l)

// One dispatch for all three positions, so every position tests the type
// actually chosen for it.
barMatches(simple string wanted, float o, float c, float h, float l) =>
    switch wanted
        "Any Bar"       => true
        "Bull Bar"      => isBullBar(o, c)
        "Bear Bar"      => isBearBar(o, c)
        "Hammer"        => isHammer(o, c, h, l)
        "Shooting Star" => isShootingStar(o, c, h, l)
        "Doji"          => isDoji(o, c, h, l)
        => false

// Type test plus that position's RSI window. The two are independent: Any Bar drops the type
// constraint for this position but its RSI band still applies.
barStepOK(simple string wanted, float o, float c, float h, float l, float rsiVal, simple float rsiMin, simple float rsiMax) =>
    bool rsiOK = not useRSI or (rsiVal >= rsiMin and rsiVal <= rsiMax)
    barMatches(wanted, o, c, h, l) and rsiOK

// =====================================================================
// === CONTEXT GATES ===
// The six gates the header counts, plus refPrice() and the two Bar
// Comparison rules — those two belong to the sequence definition rather
// than to the context gates, and are ANDed onto their own bar's step.
// Each gate returns true when it is switched off, so an unused gate can
// never block the sequence.
// =====================================================================
refPrice(simple string ref, simple int idx) =>
    switch ref
        "Open"  => open[idx]
        "High"  => high[idx]
        "Low"   => low[idx]
        "Close" => close[idx]
        => close[idx]

// The 2nd bar's close against a bar cmpBack2nd bars before IT (hence +1).
cmpCondition2nd() =>
    if not useCmp2nd
        true
    else
        r = refPrice(cmpRef2nd, cmpBack2nd + 1)
        cmpType2nd == "Higher" ? close[1] > r : close[1] < r

cmpCondition3rd() =>
    if not useCmp3rd
        true
    else
        r = refPrice(cmpRef3rd, cmpBack3rd)
        cmpType3rd == "Higher" ? close > r : close < r

maGate() =>
    if not useMA
        true
    else if not (aboveMA or belowMA)
        false
    else if aboveMA
        close > fastMA and close > slowMA and fastMA > slowMA
    else
        close < fastMA and close < slowMA and fastMA < slowMA

bbWidthPoints() =>
    math.abs(upperBand - lowerBand) / syminfo.mintick

bbWidthGate() =>
    if not useBBWidth
        true
    else
        w = bbWidthPoints()
        w >= minWidthPts and w <= maxWidthPts

// All three bars are measured against the CURRENT bar's bands, which is
// what makes this "did the sequence reach today's extreme" rather than
// "did each bar reach its own band". A close beyond the band implies a
// high beyond it, so testing the highs alone above the upper band, and the
// lows alone below the lower band, is sufficient.
bbLocationGate() =>
    if nearUpperBB
        high[2] >= upperBand or high[1] >= upperBand or high >= upperBand
    else if nearLowerBB
        low[2] <= lowerBand or low[1] <= lowerBand or low <= lowerBand
    else
        true

priceWindowGate() =>
    not usePriceWindow or (close >= minPrice and close <= maxPrice)

timeWindowGate() =>
    if not useTimeWindow
        true
    else
        startTs = timestamp(startYear, startMonth, startDay, 0, 0)
        endTs   = timestamp(endYear, endMonth, endDay, 23, 59)
        time >= startTs and time <= endTs

// =====================================================================
// === THE SEQUENCE ===
// =====================================================================
sequenceDetected() =>
    bool step1 = barStepOK(firstBarType,  open[2], close[2], high[2], low[2], rsiBar1, rsi1Min, rsi1Max)
    bool step2 = barStepOK(secondBarType, open[1], close[1], high[1], low[1], rsiBar2, rsi2Min, rsi2Max) and cmpCondition2nd()
    bool step3 = barStepOK(thirdBarType,  open,    close,    high,    low,    rsiBar3, rsi3Min, rsi3Max) and cmpCondition3rd()
    step1 and step2 and step3 and bbLocationGate() and priceWindowGate() and timeWindowGate() and maGate() and bbWidthGate()

rawPatternSignal = usePattern and sequenceDetected()
rawNewHighSignal = useHighLow and close >= highestN
rawNewLowSignal  = useHighLow and close <= lowestN

// =====================================================================
// === SILENT-MINUTES ALERT THROTTLE ===
// Detection is never throttled — only the alerts and their labels.
// =====================================================================
silentMs = silentMinutes * 60 * 1000
var int  lastAlertTime              = na
var int  cooldownEndTime            = na
var int  silentSequenceNumber       = 0
var int  activeSilentSequenceNumber = na
var bool waitingForSilentEnd        = false

cooldownPassed = silentMinutes == 0 or na(lastAlertTime) or time_close >= lastAlertTime + silentMs

patternAlertSignal = rawPatternSignal and cooldownPassed
newHighAlertSignal = rawNewHighSignal and cooldownPassed and not patternAlertSignal
newLowAlertSignal  = rawNewLowSignal  and cooldownPassed and not patternAlertSignal and not newHighAlertSignal

alertTriggered    = patternAlertSignal or newHighAlertSignal or newLowAlertSignal
cooldownJustEnded = waitingForSilentEnd and not na(cooldownEndTime) and time_close >= cooldownEndTime and (na(time_close[1]) or time_close[1] < cooldownEndTime)

if barstate.isconfirmed
    if cooldownJustEnded
        endedNumber = activeSilentSequenceNumber
        if showSilentMarks and not na(endedNumber)
            label.new(bar_index, low, text=str.tostring(endedNumber), yloc=yloc.belowbar, style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
        waitingForSilentEnd        := false
        activeSilentSequenceNumber := na
        cooldownEndTime            := na

    if alertTriggered
        silentSequenceNumber += 1
        lastAlertTime := time_close

        if showSilentMarks
            label.new(bar_index, high, text=str.tostring(silentSequenceNumber), yloc=yloc.abovebar, style=label.style_label_down, color=color.green, textcolor=color.white, size=size.small)

        if silentMinutes > 0
            activeSilentSequenceNumber := silentSequenceNumber
            cooldownEndTime            := time_close + silentMs
            waitingForSilentEnd        := true
        else
            activeSilentSequenceNumber := na
            cooldownEndTime            := na
            waitingForSilentEnd        := false

// =====================================================================
// === PLOTS ===
// =====================================================================
plot(useHighLow ? highestN : na, "Highest", color=color.green)
plot(useHighLow ? lowestN  : na, "Lowest",  color=color.red)

plot(plotBB ? basis     : na, "BB Basis", color=#0099ff)
plot(plotBB ? upperBand : na, "BB Upper", color=#2962FF)
plot(plotBB ? lowerBand : na, "BB Lower", color=#2962FF)

plot(plotMAs ? fastMA : na, "Fast MA", color=color.blue)
plot(plotMAs ? slowMA : na, "Slow MA", color=color.red)

plotshape(useSymbols and rawPatternSignal, title="Sequence", style=shape.triangledown, location=location.abovebar, color=symbolColor, size=size.tiny)
bgcolor((highlightEnabled and rawPatternSignal) ? color.new(highlightColor, 90) : na, title="Sequence Highlight")

// =====================================================================
// === ALERTS ===
// Set every one of these to "Once Per Bar Close".
// =====================================================================
alertcondition(patternAlertSignal, title="3-Bar Sequence Detected", message="3-Bar Sequence detected on {{ticker}} {{interval}}")
alertcondition(newHighAlertSignal, title="New High", message="New High on {{ticker}} {{interval}}")
alertcondition(newLowAlertSignal,  title="New Low",  message="New Low on {{ticker}} {{interval}}")
````
