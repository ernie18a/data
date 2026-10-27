# QYRO Adaptive Regime

- url: https://www.tradingview.com/script/fFHY8uCo-QYRO-Adaptive-Regime/
- type: indicator
- pine_id: PUB;b540d5f2ebba43dea0858f863a910cf7
- version: 1.0

## Description

Qyro Adaptive Regime classifies every bar into one of five market regimes and scores the strength of the current direction from 0 to 100. It is built to answer one question clearly and consistently: is this market trending, and how cleanly?

The regime is held with hysteresis and a minimum duration, so it stays stable instead of flipping on every small move, and a built-in dashboard shows the same reading for three other timeframes at once. Qyro is a context tool for your own analysis. It does not generate entry or exit signals.


KEY FEATURES

- Composite 0-100 score built from six market readings
- Five regimes: Strong Uptrend, Moderate Uptrend, Range / Low Directionality, Moderate Downtrend, Strong Downtrend
- Hysteresis and a 3-bar minimum hold for stable, readable labels
- Multi-timeframe dashboard (15m, 1H and 1D by default) calculated from completed bars
- Adaptive trend line on the price chart and score history in its own pane
- Six alerts for regime and volatility changes, with optional JSON output for webhooks
- Built-in status checks for warmup, missing volume data and timeframe settings


HOW THE SCORE IS BUILT

Each reading is converted to a 0-100 scale, where 50 is neutral. The six readings are then combined with fixed weights.

1. Path efficiency (25%)
How directly price has travelled over the last 20 bars: the net move divided by the total distance covered, signed by direction. A straight rise reads 100, a straight decline reads 0, and choppy sideways movement reads 50.
Reading: 50 + 50 × efficiency ratio × direction of the net move.

2. Adaptive trend slope (25%)
The one-bar change of a Kaufman Adaptive Moving Average (fast 2, slow 30), measured in ATR(14) units. The average speeds up when price moves efficiently and slows down in chop, so its slope reflects the quality of the trend as well as its direction.
Reading: 50 + 220 × (change in the average / ATR), limited to 0-100.

3. Price location (22%)
Where the close sits relative to the adaptive average, measured in ATR units.
Reading: 50 + 25 × ((close - average) / ATR), limited to 0-100.

4. Volatility state (13%)
ATR(14) compared with its own 56-bar average. Above 1.25 times that average the state is Expanded, below 0.85 times it is Contracted, and otherwise it is Normal.
Reading: 68 when volatility expands with price above a rising average, 32 when it expands with price below a falling average, 45 when it expands without a clear trend, 58 in normal conditions and 52 when contracted.

5. Relative volume (7%)
Current volume compared with its 20-bar average.
Reading: 40 + 20 × relative volume, limited to 0-100. Neutral (50) when the symbol has no volume data.

6. Higher-timeframe alignment (8%)
The previous completed bar of a higher timeframe (daily by default).
Reading: 75 if it closed above its own adaptive average with that average rising, 25 if it closed below with the average falling, and 50 otherwise.


HOW THE REGIME IS DETERMINED

- Uptrend begins when the score reaches 58 and ends only when it falls below 54.
- Downtrend begins when the score reaches 42 and ends only when it rises above 46.
- Strong labels apply at 75 and 25, with the same 4-point margin.
- Range / Low Directionality covers everything in between.
- Every regime must hold for at least 3 bars before it can change.

The gap between the entry and exit levels (hysteresis) keeps the label from flickering when the score hovers near a threshold. The indicator needs 69 bars of history before it displays a reading; until then, the dashboard shows how many bars remain.


WHY COMBINE THESE READINGS

Each reading answers a different question about the same move: how clean the path is (efficiency), where price is heading and where it sits (slope and location), whether the move is expanding (volatility), whether participation supports it (volume) and whether the larger timeframe agrees (higher-timeframe alignment). On its own, each answers only one of these questions. Qyro combines them into a single weighted score, stabilizes the result with hysteresis and a minimum hold, and reads every higher timeframe from completed bars only. The source code is open, so every calculation can be reviewed.


MULTI-TIMEFRAME DASHBOARD

Three configurable rows (15 minutes, 1 hour and 1 day by default) show the regime and the number of bars it has held on each timeframe, using the same formula, hysteresis and minimum hold. Each row reflects the last completed bar of its timeframe, which is what that timeframe's own chart showed one bar earlier. A row set to a timeframe at or below the chart's timeframe is marked as such.


ALERTS

Six alert conditions fire once per bar close: the regime changing to Uptrend, Downtrend or Range, and volatility changing to Expanded, Contracted or Normal. These are state changes, not trade signals.

With "Any alert() function call", the same events can be sent as plain text or, with Alert Payload Format set to JSON, as a single-line JSON object containing the event, ticker, interval, regime, score, bars held, higher-timeframe state, volatility state and bar time (UTC).


HOW TO USE IT

- Use it as market context alongside your own method, not as an entry trigger.
- Check whether the 15-minute, 1-hour and daily regimes agree before forming a directional view.
- The measurements below are for regular trading hours. On extended-session charts, expect more frequent regime changes.
- On daily charts, set Higher Timeframe to W. With the default D, that component stays neutral, and the dashboard says so.


MEASURED BEHAVIOR

Tested with default settings on MES futures, regular trading hours, 2019-2023:

- Regime changes: about 8 per session on 5-minute charts, 2.6 on 15-minute charts and 0.7 on 1-hour charts. A regime lasts a median of 5-6 bars; one in ten lasts 22-23 bars or longer.
- Stability: hysteresis and the minimum hold remove about 40% of the changes a simple threshold would produce. Widening the exit margin to 8 or 12 points reduces 5-minute changes to 6.1 or 4.5 per session.
- Responsiveness: after the 20-bar return changes direction, the matching regime appears a median of 7-8 bars later. Under the same rules, that is slower than an EMA(20) slope (6 bars) and faster than an ADX(14) filter (32 bars). Qyro changes regime less often than the EMA slope (7.8 vs 10.1 per 5-minute session) and more often than the ADX filter (3.2).
- Consistency: across 2019-2023, including the volatile years 2020 and 2022, regime changes per session varied by less than 9% between the calmest and the most volatile year on every timeframe.
- Not predictive: the regime's direction matched the direction of the next 20 bars 51-53% of the time, close to an EMA(20) slope (50.5-52%) and to ADX(14) with DI direction (50-51%). No regime label was followed by a statistically reliable return in its own direction, and in that rising market, bars labelled Downtrend were followed by average gains in almost every case.


OTHER MARKETS

Tested with default settings, without any tuning, on daily and hourly data for SPY, QQQ, AAPL, TSLA, ES, gold, crude oil, EURUSD, USDJPY, BTC and ETH:

- 9.6-11.4 regime changes per 100 bars on all 22 symbol and timeframe combinations, between an EMA(20) slope (11.5-14.2) and an ADX(14) filter (3.8-5.7).
- The matching regime appeared a median of 6-10 bars after the 20-bar return changed direction.
- Directional agreement with the next 20 bars ranged from 46% to 58%, in line with both benchmarks.
- On forex symbols without volume data, the volume component switches to neutral automatically.


SETTINGS

Every input has a tooltip. Defaults:

- Efficiency length 20; adaptive average fast 2 and slow 30; ATR 14; volatility expansion threshold 1.25
- Volume length 20; higher timeframe D
- Uptrend enter/exit 58/54; downtrend enter/exit 42/46; minimum hold 3 bars
- Dashboard rows 15, 60 and D; alert payload Text; background tint off
- Signed efficiency on (turn it off for the classic, directionless efficiency ratio)

Invalid combinations are corrected automatically and reported in the dashboard's status row: a slow length at or below the fast length is raised to fast + 1, and exit levels outside the entry levels are clamped to them.


LIMITATIONS

- Qyro describes the current market. It does not forecast it, and it is not a trading system.
- The measurements come from regular-hours MES data and public daily and hourly data. Other sessions and data feeds will behave differently.
- On 1-hour charts, the delay in confirming a new direction varies with volatility: its average rose from 12.5 bars in 2019 to 22.3 bars in 2020.
- No reading is shown for the first 69 bars.
- On Heikin Ashi, Renko and other synthetic chart types, the status row reports that the score is not meaningful.
- The slope and price-location components sit at their 0 or 100 limits on 10-34% of bars, depending on the symbol and the component.


This script is for market analysis and education. It is not financial advice.

## Source Code

````pine
//@version=6
// QYRO Adaptive Regime — market-structure analysis tool.
// Descriptive only: measures trend efficiency, direction, volatility state and
// participation. It does not generate entry, exit or position signals.
// Pane indicator: the 0-100 score and its levels live in this pane; the
// adaptive trend line, background and dashboard stay on the price chart via
// force_overlay (reference: plot, bgcolor, table.new).
// Version 1.0.0-rc3 (release candidate; every change is listed in CHANGELOG.md).
indicator("QYRO Adaptive Regime", shorttitle="QYRO", overlay=false, format=format.price, precision=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Input titles are part of the product: renaming one resets every user's setting.
string groupCore = "Core Engine"
erLength     = input.int(20, "Efficiency Lookback Length", minval=2, maxval=500, group=groupCore, tooltip="Bars in the efficiency ratio: the net move over the window divided by the sum of bar-to-bar moves (0 = pure chop, 1 = straight line). Also the lookback of the higher-timeframe trend. Larger = smoother and slower.")
fastLength   = input.int(2, "Fast Adaptive Length", minval=1, maxval=100, group=groupCore, tooltip="Fastest smoothing length of the adaptive trend line (KAMA), used when the recent path is efficient.")
slowLength   = input.int(30, "Slow Adaptive Length", minval=2, maxval=500, group=groupCore, tooltip="Slowest smoothing length of the adaptive trend line, used when the recent path is choppy. Must be larger than the fast length: a value at or below it is raised to fast + 1 (not swapped) and the Status row says so.")
atrLength    = input.int(14, "ATR Length", minval=1, maxval=200, group=groupCore, tooltip="Average true range length. ATR scales the slope and price-location components; four times this length is the volatility baseline. Warmup is 5x this length minus 1 bar.")
volThreshold = input.float(1.25, "Volatility Expansion Threshold", minval=0.9, maxval=5.0, step=0.05, group=groupCore, tooltip="ATR divided by its baseline above which volatility is 'Expanded'. Below 0.85 it is 'Contracted'; between the two it is 'Normal'. The minimum is 0.9 so that the threshold stays above the fixed 0.85 contraction level; at or below it the Contracted and Normal states could never appear.")
useSignedEfficiency = input.bool(true, "Signed Efficiency Term", group=groupCore, tooltip="On: the efficiency component carries the direction of the move it measures (50 + 50 x ratio x sign of the net move over the lookback), so chop reads 50 and an efficient decline reads low. Off: the original directionless form (100 x ratio), which pulls choppy markets toward the low end of the scale.")

string groupFilters = "Context"
useVolumeContext = input.bool(true, "Include Volume Context", group=groupFilters, tooltip="Use relative volume (this bar over its average) as the 7% volume component: 40 + 20 x ratio, clamped 0-100. Off, or on a symbol without volume, the component is neutral (50) and the dashboard says so.")
volumeLength     = input.int(20, "Relative Volume Length", minval=2, maxval=500, group=groupFilters, tooltip="Bars in the volume average.")
useHtfContext    = input.bool(true, "Include Higher-Timeframe Context", group=groupFilters, tooltip="Use the previous COMPLETED higher-timeframe bar: close above its adaptive trend gives 75, below gives 25 (8% weight). Values change once per higher-timeframe bar and never repaint.")
higherTimeframe  = input.timeframe("D", "Higher Timeframe", group=groupFilters, tooltip="Timeframe of the context bar. It must be higher than the chart's; otherwise the component is neutral and the dashboard shows 'HTF <= chart TF'.")

string groupRegime = "Regime State"
enterUp   = input.float(58.0, "Uptrend Enter Score", minval=50.0, maxval=100.0, step=0.5, group=groupRegime, tooltip="Score at or above which the state becomes Uptrend.")
exitUp    = input.float(54.0, "Uptrend Exit Score", minval=0.0, maxval=100.0, step=0.5, group=groupRegime, tooltip="Score below which an Uptrend state is left. Kept between the Downtrend Enter Score and the Uptrend Enter Score; a value outside that band is clamped to it and the Status row says so. Default: 4 points inside the enter score.")
enterDown = input.float(42.0, "Downtrend Enter Score", minval=0.0, maxval=50.0, step=0.5, group=groupRegime, tooltip="Score at or below which the state becomes Downtrend.")
exitDown  = input.float(46.0, "Downtrend Exit Score", minval=0.0, maxval=100.0, step=0.5, group=groupRegime, tooltip="Score above which a Downtrend state is left. Kept between the Downtrend Enter Score and the Uptrend Enter Score; a value outside that band is clamped to it and the Status row says so. Default: 4 points inside the enter score.")
minHold   = input.int(3, "Minimum Regime Hold", minval=1, maxval=100, group=groupRegime, tooltip="Bars a state must be held before it can change; 1 = no minimum. On the reference data a hold of 3 cut 5-minute state changes from 9.1 to 7.8 per session and raised the median lag from 7 to 8 bars.")

string groupDisplay = "Display"
showDashboard  = input.bool(true, "Show Dashboard", group=groupDisplay, tooltip="Table on the price chart with the score, regime, held-for count, each component's reading and a status line.")
dashboardPosition = input.string("Bottom right", "Dashboard Position", options=["Top left", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom right"], group=groupDisplay, tooltip="Corner or side of the price chart the dashboard is anchored to. Default Bottom right: the symbol and OHLC legend runs along the top of the price chart and can cover the first rows of a table anchored to a top position. Choose a top position only when that legend is hidden or the chart is wide enough.")
showBackground = input.bool(false, "Show Background", group=groupDisplay, tooltip="Tint the price-chart background by the latched regime state (three colours: Uptrend, Range, Downtrend). Off by default.")

string groupMtf = "Multi-Timeframe"
mtfRows = input.int(3, "Multi-Timeframe Rows", minval=0, maxval=3, group=groupMtf, tooltip="How many multi-timeframe rows the dashboard shows (0-3). Each row gives the latched regime label and Held For count of another timeframe, computed with the same formula, hysteresis and minimum hold from that timeframe's COMPLETED bars only, so it never repaints. A row whose timeframe is not higher than the chart's shows 'TF <= chart TF'.")
mtfTf1  = input.timeframe("15", "Multi-Timeframe Row 1", group=groupMtf, tooltip="Timeframe of the first row. Default 15 minutes.")
mtfTf2  = input.timeframe("60", "Multi-Timeframe Row 2", group=groupMtf, tooltip="Timeframe of the second row. Default 1 hour.")
mtfTf3  = input.timeframe("D", "Multi-Timeframe Row 3", group=groupMtf, tooltip="Timeframe of the third row. Default 1 day.")

string groupAlerts = "Alerts"
alertFormat = input.string("Text", "Alert Payload Format", options=["Text", "JSON"], group=groupAlerts, tooltip="Format of the message sent by the script's alert() calls (Create Alert, Condition: QYRO, 'Any alert() function call'). Text: the same sentence as the six named alert conditions, with the ticker and interval filled in. JSON: one single-line object with event, ticker, interval, regime, score, held_for, htf_state, volatility_state and the bar's open time in UTC, for webhooks. The six named conditions keep their fixed text messages in both modes.")

string groupColors = "Colors"
colorUp    = input.color(#26a69a, "Uptrend Color", group=groupColors, tooltip="Trend line, score plot, background and dashboard tint while the state is Uptrend. Defaults are readable on light and dark themes.")
colorDown  = input.color(#ef5350, "Downtrend Color", group=groupColors, tooltip="Same, while the state is Downtrend.")
colorRange = input.color(#787b86, "Range Color", group=groupColors, tooltip="Same, while the state is Range / Low Directionality.")
bgTransparency = input.int(85, "Background Transparency", minval=0, maxval=100, group=groupColors, tooltip="0 = opaque, 100 = invisible.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_efficiency_ratio(src, length) =>
    direction = math.abs(src - src[length])
    volatility = math.sum(math.abs(src - src[1]), length)
    volatility != 0.0 ? direction / volatility : 0.0

f_kama(src, er, fastLen, slowLen) =>
    fastSC = 2.0 / (fastLen + 1.0)
    slowSC = 2.0 / (slowLen + 1.0)
    smoothConst = math.pow(er * (fastSC - slowSC) + slowSC, 2.0)
    var float kama = na
    kama := na(kama[1]) ? src : kama[1] + smoothConst * (src - kama[1])
    kama

// Labels follow the hysteretic state, not the raw score, so they cannot
// flicker while the score oscillates around a threshold.
f_state_to_text(state, strong) =>
    state == 1  ? (strong ? "Strong Uptrend" : "Moderate Uptrend") :
     state == -1 ? (strong ? "Strong Downtrend" : "Moderate Downtrend") :
                   "Range / Low Directionality"

// Background follows the latched state only: three colours, no strength
// shading, so the tint changes exactly when the state does.
f_state_to_color(state) =>
    state == 1  ? color.new(colorUp, bgTransparency) :
     state == -1 ? color.new(colorDown, bgTransparency) :
                   color.new(colorRange, bgTransparency)

// Opaque mix of `ink` into `base` (share 0 = base, 1 = ink), built with
// color.rgb from the components color.r/g/b read (reference #fun_color.rgb:
// transp defaults to 0, opaque). The dashboard cell fills use it so that
// nothing drawn on the chart shows through a cell (manual check M4 on rc2).
f_mix(base, ink, share) =>
    float mixR = color.r(base) * (1.0 - share) + color.r(ink) * share
    float mixG = color.g(base) * (1.0 - share) + color.g(ink) * share
    float mixB = color.b(base) * (1.0 - share) + color.b(ink) * share
    color.rgb(mixR, mixG, mixB)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// The slow length must exceed the fast length (tooltip). An inverted pair is
// clamped to fast + 1 here, never swapped, and the Status row reports it.
// Every f_kama call (chart, HTF request, multi-timeframe requests) uses it.
int slowLengthEff = math.max(slowLength, fastLength + 1)
bool slowClamped = slowLengthEff != slowLength

er = f_efficiency_ratio(close, erLength)
adaptiveTrend = f_kama(close, er, fastLength, slowLengthEff)

atr = ta.atr(atrLength)
atrBaseline = ta.sma(atr, atrLength * 4)
atrRatio = atrBaseline != 0.0 ? atr / atrBaseline : 1.0

slopeRaw = adaptiveTrend - adaptiveTrend[1]
slopeAtrNormalized = atr != 0.0 ? slopeRaw / atr : 0.0
slopeScore = f_clamp(50.0 + slopeAtrNormalized * 220.0, 0.0, 100.0)

priceDistance = atr != 0.0 ? (close - adaptiveTrend) / atr : 0.0
priceLocationScore = f_clamp(50.0 + priceDistance * 25.0, 0.0, 100.0)

// Efficiency component. The ratio itself has no direction; placed on the
// 0-100 scale (0 = strong downtrend) it pulled choppy markets toward
// "Downtrend" and efficient declines toward the middle (audit finding P).
// Signed form: the sign of the net move the ratio already measures. nz()
// makes it 0 during warmup, so the component reads 50 there.
float erSign = nz(math.sign(close - close[erLength]))
efficiencyScore = useSignedEfficiency ? 50.0 + 50.0 * er * erSign : er * 100.0

volatilityExpanded = atrRatio > volThreshold
volatilityContracted = atrRatio < 0.85
volatilityState = volatilityExpanded ? "Expanded" : volatilityContracted ? "Contracted" : "Normal"

upsideMomentum = close > adaptiveTrend and slopeRaw > 0
downsideMomentum = close < adaptiveTrend and slopeRaw < 0

volatilityScore =
     volatilityExpanded and upsideMomentum ? 68.0 :
     volatilityExpanded and downsideMomentum ? 32.0 :
     volatilityExpanded ? 45.0 :
     volatilityContracted ? 52.0 :
     58.0

// Volume is na on many index and forex symbols and all-zero on some feeds.
// math.max(na, 1.0) is na, and one na component makes the whole score na; the
// label then falls through every comparison to "Strong Downtrend" (manual
// "Type system", na value). The component degrades to neutral (50) instead,
// and the dashboard says so. The same guard covers the first volumeLength-1
// bars, where the average does not exist yet.
volumeAvg = ta.sma(volume, volumeLength)
bool volumeAvailable = not na(volume) and not na(volumeAvg) and volumeAvg > 0.0
relativeVolume = volumeAvailable ? volume / math.max(volumeAvg, 1.0) : na
volumeScore = not useVolumeContext ? 50.0 : volumeAvailable ? f_clamp(40.0 + relativeVolume * 20.0, 0.0, 100.0) : 50.0
volumeText = not useVolumeContext ? "Off" : not volumeAvailable ? "No volume data (neutral)" : relativeVolume >= 1.0 ? "Above Average" : "Below Average"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Higher-Timeframe Context
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// One request returns three values from the last COMPLETED higher-timeframe bar.
// Why this cannot repaint: every element is offset by one HTF bar ([1], [2]) and
// the request uses barmerge.lookahead_on. That is the documented non-repainting
// pattern (manual: "Repainting", "Other timeframes and data"): on every chart
// bar of an HTF period the values are those of the previous completed HTF bar,
// so historical and realtime bars show the same thing and a reload changes
// nothing. `adaptiveTrend` is re-evaluated inside the HTF context with its own
// f_kama state (each written call has an independent history).
// The slope is computed between two consecutive HTF bars inside the request;
// comparing `htfTrend` with `htfTrend[1]` on the chart would compare chart bars.
[htfClose, htfTrend, htfSlope] = request.security(syminfo.tickerid, higherTimeframe,
     [close[1], adaptiveTrend[1], adaptiveTrend[1] - adaptiveTrend[2]],
     barmerge.gaps_off, barmerge.lookahead_on)

htfUp = htfClose > htfTrend and htfSlope > 0
htfDown = htfClose < htfTrend and htfSlope < 0

// The context is only a HIGHER timeframe if it is longer than the chart's.
// Equal: the request returns the chart's own series and would double-count
// the chart trend. Lower: the request returns one intrabar per chart bar
// (manual "Other timeframes and data", Lower timeframes). Both are disabled
// here and reported on the dashboard instead of raising a runtime error.
bool htfAllowed = useHtfContext and timeframe.in_seconds(higherTimeframe) > timeframe.in_seconds()

htfScore = not htfAllowed ? 50.0 : htfUp ? 75.0 : htfDown ? 25.0 : 50.0
htfText = not useHtfContext ? "Off" : not htfAllowed ? "HTF ≤ chart TF" : htfUp ? "Aligned Up" : htfDown ? "Aligned Down" : "Neutral"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Composite Score
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

baseScore =
     efficiencyScore * 0.25 +
     slopeScore * 0.25 +
     priceLocationScore * 0.22 +
     volatilityScore * 0.13 +
     volumeScore * 0.07 +
     htfScore * 0.08

compositeScore = f_clamp(baseScore, 0.0, 100.0)

// Warmup. The score is only fully defined once every component has its
// history: the efficiency ratio needs erLength+1 bars; ta.atr seeds over
// atrLength bars and its baseline SMA then needs atrLength*4 ATR values
// (5*atrLength-1 bars in total); the volume average needs volumeLength bars.
// Before that the components fall back to neutral values that look like
// real readings, so nothing is painted and the dashboard says "Warming up".
int warmupBars = math.max(erLength + 1, math.max(atrLength * 5 - 1, volumeLength))
bool isWarm = bar_index >= warmupBars - 1
int warmupLeft = math.max(warmupBars - 1 - bar_index, 0)

// Non-standard chart types (Heikin Ashi, Renko, Kagi, Line break, Point &
// figure, Range) synthesise their bars; efficiency and ATR of synthetic bars
// do not describe the market, and syminfo.tickerid carries the same chart
// modifiers into the HTF request. The score is still computed; the dashboard
// says it is not meaningful there.
bool chartIsStandard = chart.is_standard

// Regime state with hysteresis. A state is entered at its enter score and
// left only at its exit score (exit sits inside enter, 4 points by default),
// so a score oscillating around 58 or 42 cannot flip the state every bar.
// A state is also held for at least minHold bars before it can change.
// The same margin applies to the Strong/Moderate split at 75 and 25. Each
// exit level is clamped inside the enter band [enterDown, enterUp]: at or
// below its own enter level so the inputs cannot invert, and at or above the
// opposite enter level so no overlap can keep a state the score has left
// for the other side (audit finding AA). Clamped, never swapped; the Status
// row reports it.
float exitUpEff   = math.max(math.min(exitUp, enterUp), enterDown)
float exitDownEff = math.min(math.max(exitDown, enterDown), enterUp)
bool exitUpClamped   = exitUpEff != exitUp
bool exitDownClamped = exitDownEff != exitDown
float upMargin    = enterUp - exitUpEff
float downMargin  = exitDownEff - enterDown

var int  regimeState  = 0
var bool regimeStrong = false
var int  regimeBars   = 0        // bars the current state has been held (0 during warmup)
int nextState = regimeState
if not isWarm
    nextState := 0
else if regimeBars > 0 and regimeBars < minHold
    nextState := regimeState     // minimum hold: no change allowed yet
else if regimeState == 1
    nextState := compositeScore >= exitUpEff ? 1 : compositeScore <= enterDown ? -1 : 0
else if regimeState == -1
    nextState := compositeScore <= exitDownEff ? -1 : compositeScore >= enterUp ? 1 : 0
else
    nextState := compositeScore >= enterUp ? 1 : compositeScore <= enterDown ? -1 : 0
if nextState != regimeState
    regimeStrong := false
regimeState := nextState
regimeStrong :=
     regimeState == 1  ? (regimeStrong ? compositeScore >= 75.0 - upMargin : compositeScore >= 75.0) :
     regimeState == -1 ? (regimeStrong ? compositeScore <= 25.0 + downMargin : compositeScore <= 25.0) :
                         false

regime = f_state_to_text(regimeState, regimeStrong)

// Bars since the last confirmed state change (0 during warmup)
regimeBars := not isWarm ? 0 : regimeState == regimeState[1] ? regimeBars + 1 : 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Multi-Timeframe Regime Rows
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Each request evaluates the whole score and state machine above in the
// requested timeframe's own context (manual "Other timeframes and data": the
// call duplicates all preceding code that determines the expression). Pine v6
// requests are dynamic by default, so the HTF request inside that code is a
// permitted nested request and inherits the symbol. timeframe.period inside
// the expression is the requested timeframe (reference #var_timeframe.period),
// so the HTF guard, the warmup count and bar_index all evaluate for that
// timeframe, as they would on its own chart.
// Why these cannot repaint: every element is offset by one bar ([1]) and the
// request uses barmerge.lookahead_on, the documented non-repainting pattern
// (manual "Repainting"). On every chart bar inside a bar of the row's
// timeframe the values are those of the LAST COMPLETED bar of that timeframe,
// on historical and realtime bars alike; a chart of that timeframe shows the
// same state one bar earlier. Booleans travel as 0/1 so nz() can fill the
// bars before the first completed bar of the requested series.
// These requests come after every assignment to the state variables: a
// request only duplicates code that precedes it.
// A row is only a higher timeframe if it is longer than the chart's (same
// rule as the HTF context); equal or lower rows are reported, not shown.
// A row that is not allowed requests the chart's own timeframe instead of
// a lower one: a lower-timeframe request would pull one intrabar per chart
// bar through the plan's intrabar limit (manual "Limitations") for a row
// that only shows the guard text.
bool mtfAllowed1 = timeframe.in_seconds(mtfTf1) > timeframe.in_seconds()
bool mtfAllowed2 = timeframe.in_seconds(mtfTf2) > timeframe.in_seconds()
bool mtfAllowed3 = timeframe.in_seconds(mtfTf3) > timeframe.in_seconds()
string mtfReq1 = mtfAllowed1 ? mtfTf1 : timeframe.period
string mtfReq2 = mtfAllowed2 ? mtfTf2 : timeframe.period
string mtfReq3 = mtfAllowed3 ? mtfTf3 : timeframe.period

[mtfState1, mtfStrong1, mtfBars1, mtfWarm1] = request.security(syminfo.tickerid, mtfReq1,
     [regimeState[1], regimeStrong[1] ? 1 : 0, regimeBars[1], isWarm[1] ? 1 : 0],
     barmerge.gaps_off, barmerge.lookahead_on)
[mtfState2, mtfStrong2, mtfBars2, mtfWarm2] = request.security(syminfo.tickerid, mtfReq2,
     [regimeState[1], regimeStrong[1] ? 1 : 0, regimeBars[1], isWarm[1] ? 1 : 0],
     barmerge.gaps_off, barmerge.lookahead_on)
[mtfState3, mtfStrong3, mtfBars3, mtfWarm3] = request.security(syminfo.tickerid, mtfReq3,
     [regimeState[1], regimeStrong[1] ? 1 : 0, regimeBars[1], isWarm[1] ? 1 : 0],
     barmerge.gaps_off, barmerge.lookahead_on)

f_mtf_text(allowed, warm, state, strong, bars) =>
    not allowed ? "TF ≤ chart TF" :
     nz(warm) != 1 ? "Warming up" :
     f_state_to_text(nz(state), nz(strong) == 1) + " · " + str.tostring(nz(bars)) + " bars"

string mtfText1 = f_mtf_text(mtfAllowed1, mtfWarm1, mtfState1, mtfStrong1, mtfBars1)
string mtfText2 = f_mtf_text(mtfAllowed2, mtfWarm2, mtfState2, mtfStrong2, mtfBars2)
string mtfText3 = f_mtf_text(mtfAllowed3, mtfWarm3, mtfState3, mtfStrong3, mtfBars3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Regime Transitions (state changes, not trade calls)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Only after two warm bars, so the first defined state is not itself a "change".
// barstate.isconfirmed: true on every historical bar and on the closing update
// of a realtime bar, so with any alert frequency these fire once, at bar close.
bool canShift = isWarm and isWarm[1] and barstate.isconfirmed
shiftToUptrend   = canShift and regimeState == 1 and regimeState[1] != 1
shiftToDowntrend = canShift and regimeState == -1 and regimeState[1] != -1
shiftToRange     = canShift and regimeState == 0 and regimeState[1] != 0

// Volatility-state changes, same confirmation rule. The volatility state has
// no hysteresis, so these can fire on consecutive bars when the ATR ratio
// hovers at a threshold.
bool volShift = canShift and volatilityState != volatilityState[1]
shiftToExpanded   = volShift and volatilityExpanded
shiftToContracted = volShift and volatilityContracted
shiftToNormalVol  = volShift and not volatilityExpanded and not volatilityContracted

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendColor =
     regimeState == 1  ? colorUp :
     regimeState == -1 ? colorDown :
                         colorRange

// On the price chart
plot(isWarm ? adaptiveTrend : na, "Adaptive Trend Line", color=trendColor, linewidth=2, force_overlay=true)
bgcolor(showBackground and isWarm ? f_state_to_color(regimeState) : na, force_overlay=true)

// In this pane: score history with the label levels
plot(isWarm ? compositeScore : na, "Regime Score", color=trendColor, linewidth=2)
hline(75.0, "Strong Uptrend Level", color=color.new(color.gray, 50), linestyle=hline.style_dotted)
hUp   = hline(58.0, "Uptrend Enter Level", color=color.new(color.gray, 30), linestyle=hline.style_dashed)
hDown = hline(42.0, "Downtrend Enter Level", color=color.new(color.gray, 30), linestyle=hline.style_dashed)
hline(25.0, "Strong Downtrend Level", color=color.new(color.gray, 50), linestyle=hline.style_dotted)
fill(hUp, hDown, color=color.new(color.gray, 92), title="Range Band")

// Data-window / screener series
plot(isWarm ? er * 100.0 : na, "Efficiency %", display=display.data_window)
plot(isWarm ? atrRatio : na, "Volatility Ratio", display=display.data_window)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// The anchor comes from the Dashboard Position input, resolved to a
// position.* constant by a switch and passed to table.new, which takes a
// series string (reference #fun_table.new; manual "Tables", "Creating a
// display panel"). Every option has its own case, spelled exactly as in
// the input's options list (python/preflight_pine.py checks the two lists
// against each other); the bare default is the fallback a typed switch
// needs (#kw_switch: without one an unmatched value gives na) and cannot
// be reached from the input dialog. Default Bottom right: the symbol /
// OHLC legend occupies the top band of the price chart and covered the
// Score row of the top-anchored rc1 table (manual check M4, 2026-09-18).
string dashAnchor = switch dashboardPosition
    "Top left"     => position.top_left
    "Top right"    => position.top_right
    "Middle left"  => position.middle_left
    "Middle right" => position.middle_right
    "Bottom left"  => position.bottom_left
    "Bottom right" => position.bottom_right
    => position.bottom_right
// The table's own fill is the chart background (#fun_table.new, bgcolor:
// "the background color of the table"; the default is no colour), so the
// bars cannot show through any cell even if that cell's fill were lost.
// It is created once (var); the anchor is applied again on every last-bar
// update (#fun_table.set_position), so the table follows the input.
var table dash = table.new(dashAnchor, 2, 11, bgcolor=chart.bg_color, border_width=1, force_overlay=true)

// Theme-aware: chart.fg_color is the reference's "color providing optimal
// contrast with chart.bg_color" (#var_chart.fg_color). Every cell's text is
// that colour. Every cell fill is opaque: the chart background with a share
// of the foreground colour (15 % label cells, 7 % value cells) or of the
// state colour (35 %, the Score value cell) mixed in by f_mix. rc2 built
// the same shades as transparent tints, color.new(chart.fg_color, 85) and
// 93: at transparency 85 a fill is 15 % opaque (#fun_color.new: 100 =
// invisible), so a cell lying over bars showed them through it while a
// cell over the plain background looked filled. On a bottom-right table
// the Score label cell is the top-left cell, the one over the latest bars,
// and it was reported as unfilled next to a filled Regime cell built with
// the same arguments (manual check M4 on rc2, 2026-09-18). The shares
// reproduce rc2's look over a plain background exactly.
if showDashboard and barstate.islast
    table.set_position(dash, dashAnchor)
    color textColor = chart.fg_color
    color labelBg = f_mix(chart.bg_color, chart.fg_color, 0.15)
    color valueBg = f_mix(chart.bg_color, chart.fg_color, 0.07)
    color stateColor = regimeState == 1 ? colorUp : regimeState == -1 ? colorDown : colorRange
    color scoreBg = not isWarm ? valueBg : f_mix(chart.bg_color, stateColor, 0.35)
    string noValue = "—"
    string warmText = "Warming up (" + str.tostring(warmupLeft) + " bars left)"
    // Clamped inputs are reported here, appended to the usual status, so a
    // user who set an inverted pair sees which input was changed and to what.
    string inputNote = ""
    if slowClamped
        inputNote := "Slow Adaptive Length raised to " + str.tostring(slowLengthEff) + " (fast + 1)"
    if exitUpClamped
        inputNote := inputNote + (inputNote == "" ? "" : "; ") + "Uptrend Exit Score clamped to " + str.tostring(exitUpEff, "#.#")
    if exitDownClamped
        inputNote := inputNote + (inputNote == "" ? "" : "; ") + "Downtrend Exit Score clamped to " + str.tostring(exitDownEff, "#.#")
    string baseStatus = not chartIsStandard ? "Non-standard chart: score not meaningful" : isWarm ? "OK" : warmText
    string statusText = baseStatus + (inputNote == "" ? "" : " | " + inputNote)

    table.cell(dash, 0, 0, "Score", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 0, isWarm ? str.tostring(compositeScore, "#.0") : warmText, text_color=textColor, bgcolor=scoreBg)

    table.cell(dash, 0, 1, "Regime", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 1, isWarm ? regime : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 2, "Held For", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 2, isWarm ? str.tostring(regimeBars) + " bars" : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 3, "Efficiency", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 3, isWarm ? str.tostring(er * 100.0, "#.0") + "%" : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 4, "Volatility", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 4, isWarm ? volatilityState + " (" + str.tostring(atrRatio, "#.00") + "x)" : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 5, "HTF", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 5, isWarm ? htfText : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 6, "Volume", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 6, isWarm ? volumeText : noValue, text_color=textColor, bgcolor=valueBg)

    table.cell(dash, 0, 7, "Status", text_color=textColor, bgcolor=labelBg)
    table.cell(dash, 1, 7, statusText, text_color=textColor, bgcolor=valueBg)

    // Multi-timeframe rows: cells that are never populated are not drawn
    // (reference #fun_table.new), so unused rows leave no empty space.
    if mtfRows >= 1
        table.cell(dash, 0, 8, "MTF " + mtfTf1, text_color=textColor, bgcolor=labelBg)
        table.cell(dash, 1, 8, mtfText1, text_color=textColor, bgcolor=valueBg)
    if mtfRows >= 2
        table.cell(dash, 0, 9, "MTF " + mtfTf2, text_color=textColor, bgcolor=labelBg)
        table.cell(dash, 1, 9, mtfText2, text_color=textColor, bgcolor=valueBg)
    if mtfRows >= 3
        table.cell(dash, 0, 10, "MTF " + mtfTf3, text_color=textColor, bgcolor=labelBg)
        table.cell(dash, 1, 10, mtfText3, text_color=textColor, bgcolor=valueBg)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts (state changes only, never trade calls)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// alertcondition() messages must be constant strings; {{ticker}} and
// {{interval}} are filled in by the alert system (manual "Alerts", Placeholders).
// Each call counts as one plot (reference #fun_alertcondition).

alertcondition(shiftToUptrend, "Regime: Uptrend", "QYRO {{ticker}} {{interval}}: regime changed to Uptrend.")
alertcondition(shiftToDowntrend, "Regime: Downtrend", "QYRO {{ticker}} {{interval}}: regime changed to Downtrend.")
alertcondition(shiftToRange, "Regime: Range", "QYRO {{ticker}} {{interval}}: regime changed to Range / Low Directionality.")
alertcondition(shiftToExpanded, "Volatility: Expanded", "QYRO {{ticker}} {{interval}}: volatility state changed to Expanded.")
alertcondition(shiftToContracted, "Volatility: Contracted", "QYRO {{ticker}} {{interval}}: volatility state changed to Contracted.")
alertcondition(shiftToNormalVol, "Volatility: Normal", "QYRO {{ticker}} {{interval}}: volatility state changed to Normal.")

// alert() messages are "series string", so they can carry live values; the
// alertcondition() messages above must be constant and keep their
// placeholders. Text mode repeats the alertcondition sentence with
// syminfo.ticker and timeframe.period, which is what {{ticker}} and
// {{interval}} expand to. JSON is assembled by concatenation rather than
// str.format(), whose format strings give curly braces a meaning of their own.
// The five labels and the ticker contain no quotes or backslashes, so no
// escaping is needed. "score" uses the "0.00" pattern so a value below 1
// still starts with a digit (JSON numbers must). "time" is the open time of
// the bar whose close fired the alert, in the same form as the {{time}}
// placeholder, in UTC. The frequency is fixed at once per bar close, which
// matches the barstate.isconfirmed gate on every condition.
f_alert_message(event, sentence) =>
    string q = "\""
    alertFormat == "JSON" ?
         "{" + q + "event" + q + ":" + q + event + q +
         "," + q + "ticker" + q + ":" + q + syminfo.ticker + q +
         "," + q + "interval" + q + ":" + q + timeframe.period + q +
         "," + q + "regime" + q + ":" + q + regime + q +
         "," + q + "score" + q + ":" + str.tostring(compositeScore, "0.00") +
         "," + q + "held_for" + q + ":" + str.tostring(regimeBars) +
         "," + q + "htf_state" + q + ":" + q + htfText + q +
         "," + q + "volatility_state" + q + ":" + q + volatilityState + q +
         "," + q + "time" + q + ":" + q + str.format_time(time, "yyyy-MM-dd'T'HH:mm:ssZ", "UTC") + q + "}" :
         "QYRO " + syminfo.ticker + " " + timeframe.period + ": " + sentence

if shiftToUptrend
    alert(f_alert_message("regime_uptrend", "regime changed to Uptrend."), alert.freq_once_per_bar_close)
if shiftToDowntrend
    alert(f_alert_message("regime_downtrend", "regime changed to Downtrend."), alert.freq_once_per_bar_close)
if shiftToRange
    alert(f_alert_message("regime_range", "regime changed to Range / Low Directionality."), alert.freq_once_per_bar_close)
if shiftToExpanded
    alert(f_alert_message("volatility_expanded", "volatility state changed to Expanded."), alert.freq_once_per_bar_close)
if shiftToContracted
    alert(f_alert_message("volatility_contracted", "volatility state changed to Contracted."), alert.freq_once_per_bar_close)
if shiftToNormalVol
    alert(f_alert_message("volatility_normal", "volatility state changed to Normal."), alert.freq_once_per_bar_close)
````
