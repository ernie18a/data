# CVD Pro: Delta, Divergence & Signals | Delta Ratio

- url: https://www.tradingview.com/script/XTFRmOw9-CVD-Pro-Delta-Divergence-Signals-Delta-Ratio/
- type: indicator
- pine_id: PUB;ae035b354e2e4660b321ed997b6464fb
- version: 1.0

## Description

CVD Pro — Delta, Divergence & Signals | Delta Ratio

A professional Cumulative Volume Delta (CVD) indicator that tracks real-time buying vs selling pressure by aggregating 1-minute delta data. Built for traders who want to see order flow divergence before price confirms it.

What It Shows
Plot	Description
CVD (thin teal/red)	Cumulative delta — running total of (buy volume − sell volume) within each session. Resets daily or weekly.
Delta Ratio (thick teal/red)	CVD ÷ total cumulative volume, scaled ×1000. Normalises delta so you can compare relative pressure across instruments and sessions.
EMA of CVD (21-period, lime/red)	Smoothed CVD trend. Colour indicates slope — rising or falling.
WMA of CVD (14-period, aqua/orange)	Faster-moving average for earlier trend shifts.
Bullish/Bearish Divergence Arrows	Detects when CVD makes a higher low while price makes a lower low (bullish), or CVD makes a lower high while price makes a higher high (bearish).
How Divergence Works
The indicator uses ta.pivotlow() and ta.pivothigh() with a configurable lookback (default 3) to identify CVD swing points, then compares the direction of consecutive CVD pivots against price at those same bars:

Bullish signal — CVD trough is rising (higher low) but price at the CVD trough is falling (lower low). Smart money accumulating into weakness.
Bearish signal — CVD peak is falling (lower high) but price at the CVD peak is rising (higher high). Smart money distributing into strength.
Divergences are plotted as arrows at the bottom (bullish) or top (bearish) of the pane, and can be configured as Trading View alerts.

Key Settings
Group	Setting	Default	Purpose
Core	Session Reset	Daily	When the CVD counter resets to zero
EMA	Period / Thickness / Colours	21	Trend filter
WMA	Length / Thickness / Colours	14	Early-trend detection
Divergence	Pivot Lookback	3	Sensitivity — lower = more signals, higher = fewer but stronger
Visual	Delta Ratio Scale	1000	Adjusts ratio magnitude for readability
Visual	Show/Hide toggles	All on	Turn off individual plots
Usage Tips
Divergence is most reliable at session extremes. Look for bullish divergence near session lows, bearish divergence near session highs.
Delta Ratio trending above zero while CVD rises = sustained buying absorption. Ratio falling but CVD flat/rising = selling into strength (potential distribution).
EMA & WMA cross. When WMA crosses above EMA while CVD is positive, momentum is accelerating. When they cross below, momentum is fading.
Combine with price structure. Divergence arrows are early signals — wait for a structural trigger (CHoCH, breakout of a prior swing) before entering.
Works on any timeframe. The CVD always builds from 1-minute data regardless of the chart timeframe, so you get the same delta foundation whether you're on a 15M, 1H, or 4H chart.
Alerts
Three built-in alert conditions:

Bull Divergence (CVD) — fires when a new bullish divergence pivot is detected
Bear Divergence (CVD) — fires when a new bearish divergence pivot is detected
New Session Reset — fires when CVD resets at the start of a new daily/weekly session
Version: 1.0
Pine Script: v6

## Source Code

````pine
//@version=6
indicator('CVD Pro: Delta, Divergence & Signals | Delta Ratio', overlay = false)

// ═══════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════
grpCore = 'Core Settings'
grpEma  = 'EMA Settings'
grpWma  = 'WMA Settings'
grpDiv  = 'Divergence Settings'
grpVis  = 'Visual Settings'

resetMode    = input.string('Daily', 'Session Reset', options = ['Daily', 'Weekly'], group = grpCore)
deltaScale   = input.float(1000.0, 'Delta Ratio Scale Multiplier', minval = 1.0, group = grpVis)

emaPeriod    = input.int(21,    'EMA Period',        minval = 1,             group = grpEma)
emaThickness = input.int(2,     'EMA Thickness',     minval = 1, maxval = 4, group = grpEma)
emaUpColor   = input.color(color.lime,               'EMA Rising Color',     group = grpEma)
emaDnColor   = input.color(color.red,                'EMA Falling Color',    group = grpEma)
showEma      = input.bool(true, 'Show EMA',                                  group = grpEma)

wmaLength    = input.int(14,    'WMA Length',        minval = 1,             group = grpWma)
wmaThickness = input.int(2,     'WMA Thickness',     minval = 1, maxval = 4, group = grpWma)
wmaUpColor   = input.color(color.aqua,               'WMA Rising Color',     group = grpWma)
wmaDnColor   = input.color(color.orange,             'WMA Falling Color',    group = grpWma)
showWma      = input.bool(true, 'Show WMA',                                  group = grpWma)

pivotLen     = input.int(3,     'Pivot Lookback',    minval = 2, maxval = 20, group = grpDiv)
showDiv      = input.bool(true, 'Show Divergence',                            group = grpDiv)

showDeltaRatio = input.bool(true, 'Show Delta Ratio', group = grpVis)
showZero       = input.bool(true, 'Show Zero Line',   group = grpVis)

// ═══════════════════════════════════════════════════════
// 1-MINUTE DATA
// ═══════════════════════════════════════════════════════
[delta_1m, vol_1m] = request.security(
     syminfo.tickerid, '1',
     [close > open ? volume : close < open ? -volume : 0.0, volume],
     lookahead = barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════
// SESSION RESET
// ═══════════════════════════════════════════════════════
isNewSession = switch resetMode
    'Daily'  => ta.change(time('D')) != 0
    'Weekly' => ta.change(time('W')) != 0

// ═══════════════════════════════════════════════════════
// CVD
// ═══════════════════════════════════════════════════════
var float cvd = 0.0
cvd := isNewSession ? delta_1m : cvd + delta_1m

// ═══════════════════════════════════════════════════════
// CUMULATIVE VOLUME & DELTA RATIO
// ═══════════════════════════════════════════════════════
var float cumVol = 0.0

if isNewSession
    cumVol := math.abs(vol_1m)
else
    cumVol += math.abs(vol_1m)

deltaRatio = cumVol != 0.0 ? (cvd / cumVol) * deltaScale : na

// ═══════════════════════════════════════════════════════
// EMA & WMA
// ═══════════════════════════════════════════════════════
cvd_ema = ta.ema(cvd, emaPeriod)
cvd_wma = ta.wma(cvd, wmaLength)

// ═══════════════════════════════════════════════════════
// SLOPE COLOURS
// ═══════════════════════════════════════════════════════
emaColor = cvd_ema > cvd_ema[1] ? emaUpColor : emaDnColor
wmaColor = cvd_wma > cvd_wma[1] ? wmaUpColor : wmaDnColor

// ═══════════════════════════════════════════════════════
// DIVERGENCE
// ═══════════════════════════════════════════════════════
var float cvdLow1         = na
var float cvdLow2         = na
var float priceAtCvdLow1  = na
var float priceAtCvdLow2  = na
var float cvdHigh1        = na
var float cvdHigh2        = na
var float priceAtCvdHigh1 = na
var float priceAtCvdHigh2 = na

pivotCvdLow  = ta.pivotlow(cvd,  pivotLen, pivotLen)
pivotCvdHigh = ta.pivothigh(cvd, pivotLen, pivotLen)

newLowPivot  = not na(pivotCvdLow)
newHighPivot = not na(pivotCvdHigh)

if newLowPivot
    cvdLow2        := cvdLow1
    priceAtCvdLow2 := priceAtCvdLow1
    cvdLow1        := pivotCvdLow
    priceAtCvdLow1 := close[pivotLen]

if newHighPivot
    cvdHigh2        := cvdHigh1
    priceAtCvdHigh2 := priceAtCvdHigh1
    cvdHigh1        := pivotCvdHigh
    priceAtCvdHigh1 := close[pivotLen]

bullDiv = not na(cvdLow1) and not na(cvdLow2) and
          cvdLow1 > cvdLow2 and priceAtCvdLow1 < priceAtCvdLow2

bearDiv = not na(cvdHigh1) and not na(cvdHigh2) and
          cvdHigh1 < cvdHigh2 and priceAtCvdHigh1 > priceAtCvdHigh2

bullDivSignal = showDiv and bullDiv and newLowPivot
bearDivSignal = showDiv and bearDiv and newHighPivot

// ═══════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════
plot(showZero ? 0.0 : na,
     title     = 'Zero Line',
     color     = color.new(color.gray, 50),
     linewidth = 1,
     style     = plot.style_line)

plot(showDeltaRatio ? deltaRatio : na,
     title     = 'Delta Ratio (CVD / Cumulative Volume)',
     color     = deltaRatio >= 0 ? color.new(color.teal, 20) : color.new(color.red, 20),
     linewidth = 2)

plot(cvd,
     title     = 'CVD',
     color     = cvd >= 0.0 ? color.new(color.teal, 20) : color.new(color.red, 20),
     linewidth = 1)

plot(showEma ? cvd_ema : na,
     title     = 'EMA of CVD',
     color     = emaColor,
     linewidth = math.max(1, emaThickness))

plot(showWma ? cvd_wma : na,
     title     = 'WMA of CVD',
     color     = wmaColor,
     linewidth = math.max(1, wmaThickness))

plotshape(bullDivSignal,
     title    = 'Bull Divergence',
     style    = shape.arrowup,
     location = location.bottom,
     color    = color.lime,
     size     = size.small)

plotshape(bearDivSignal,
     title    = 'Bear Divergence',
     style    = shape.arrowdown,
     location = location.top,
     color    = color.red,
     size     = size.small)

// ═══════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════
alertcondition(bullDivSignal,
     title   = 'Bull Divergence (CVD)',
     message = '🟢 Bullish CVD Divergence — CVD higher low, price lower low')

alertcondition(bearDivSignal,
     title   = 'Bear Divergence (CVD)',
     message = '🔴 Bearish CVD Divergence — CVD lower high, price higher high')

alertcondition(isNewSession,
     title   = 'New Session Reset',
     message = '🔄 CVD session reset')
````
