# AlligatorFlex Reversal Engine 

- url: https://www.tradingview.com/script/qymFAp1u-AlligatorFlex-Reversal-Engine/
- type: indicator
- pine_id: PUB;1abab387acdd44fea582e633cf980e6e
- version: 2.0

## Description

[image]https://www.tradingview.com/x/aYO7Bkzl/[/image]
AlligatorFlex Reversal Engine detects potential early trend-shift conditions using modified Alligator structure, line slope, volume expansion, and range confirmation.

 [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] 
[b]AlligatorFlex Reversal Engine[/b] is a modified Alligator-style indicator designed to identify potential early trend-shift conditions using slope, volume, and price-range validation.

Unlike a traditional Alligator indicator that only plots trend structure, AlligatorFlex adds confirmation filters to highlight moments where the market may be transitioning from one directional state to another.

The indicator uses three EMA-based Alligator lines:

- Jaw: slower structure line
- Teeth: medium structure line
- Lips: faster structure line

Each line changes color based on its current slope, allowing traders to quickly visualize whether the internal structure is pushing upward or downward.

Signal validation includes:

- All three Alligator lines must show directional slope.
- Current volume must exceed the average volume by a user-defined multiplier.
- The recent price range must expand beyond its average range.
- Line structure must meet the required alignment condition.

A LONG signal appears when the Alligator structure is still positioned in a bearish alignment, but all three lines are rising with strong volume and range expansion. This can suggest a possible bullish reversal or early recovery attempt.

A SHORT signal appears when the structure is still positioned in a bullish alignment, but all three lines are falling with strong volume and range expansion. This can suggest a possible bearish reversal or early rejection.

This makes the indicator useful for traders looking for possible transition zones, reversal pressure, momentum shifts, and early directional expansion.

Best used with:

- Higher timeframe trend context
- VWAP
- Support and resistance
- Market structure
- Volume analysis
- Breakout or reclaim setups

AlligatorFlex Reversal Engine helps traders detect potential early market shifts by combining a modified Alligator structure with slope, volume, and range expansion filters.

Instead of only showing moving average lines, the indicator evaluates whether the market is showing enough directional pressure to justify a possible transition signal.

It highlights moments where:

- Alligator lines begin to slope in the same direction
- Volume expands above average
- Price range expands beyond normal conditions
- Structure suggests a possible reversal or directional shift

LONG and SHORT labels are plotted directly on the chart when all confirmation layers align.

The goal of AlligatorFlex is to help traders spot possible early reversal pressure before a fully developed trend becomes obvious.

Jaw Length:
Controls the slowest Alligator structure line.

Teeth Length:
Controls the medium Alligator structure line.

Lips Length:
Controls the fastest Alligator structure line.

Volume Length:
Defines the lookback period used to calculate average volume.

Range Length:
Defines the lookback period used to calculate recent price-range expansion.

Slope Threshold:
Minimum slope required from each Alligator line before a signal can be considered valid.

Volume Multiplier:
Requires current volume to be greater than average volume by the selected multiplier.

Range Multiplier:
Requires the recent price range to expand beyond its average range by the selected multiplier.

Limitations:

- This is a modified Alligator-style indicator, not the classic Williams Alligator.
- Signals are designed for potential early shifts, not confirmed trend continuation.
- Volume filters may behave differently across markets with unreliable or synthetic volume.
- Range expansion can trigger late signals after a move has already started.
- Choppy markets can still produce false signals.
- The indicator does not include stop loss, take profit, or position sizing logic.

Important:
This indicator is not a standalone trading system and does not predict future price movement. It is designed as a visual confirmation tool for identifying potential directional shifts. Signals may fail during choppy, low-liquidity, or range-bound conditions.

## Source Code

````pine
//@version=5
indicator("AlligatorFlex Reversal Engine", overlay=true)
// Version 1.1
// © 2026 Ty_Yanse
// Built for traders who use structure, slope, range, and volume confirmation.
// This version includes community-requested improvements.
// Feedback is welcome.

// ==========================
// Inputs
// ==========================
jawLength   = input.int(13, minval=5, maxval=100, title="Jaw Length")
teethLength = input.int(8, minval=5, maxval=100, title="Teeth Length")
lipsLength  = input.int(5, minval=5, maxval=100, title="Lips Length")

signalMode = input.string( "Sensitive", title="Signal Mode",  options=["Sensitive", "Balanced", "Strict"],  tooltip="Sensitive shows more signals. Balanced applies moderate filtering. Strict requires stronger volume, range, and slope confirmation.")

volumeLength = input.int(14, minval=1, maxval=100, title="Volume Length")
rangeLength  = input.int(5, minval=1, maxval=100, title="Range Length")

customSlopeThreshold   = input.float(0.0005, title="Custom Slope Threshold", tooltip="Used only when Custom Filters is enabled.")
customVolumeMultiplier = input.float(0.5, title="Custom Volume Multiplier", tooltip="Used only when Custom Filters is enabled.")
customRangeMultiplier  = input.float(0.5, title="Custom Range Multiplier", tooltip="Used only when Custom Filters is enabled.")

useCustomFilters = input.bool(false, title="Use Custom Filters")

showLabels     = input.bool(true, title="Show Signal Labels")
showBackground = input.bool(true, title="Show Signal Background")
showAlertsInfo = input.bool(true, title="Enable Alert Conditions")

// ==========================
// Dynamic filter settings
// ==========================
slopeThreshold = useCustomFilters ? customSlopeThreshold :
     signalMode == "Sensitive" ? 0.0001 :
     signalMode == "Balanced"  ? 0.0005 :
     0.0010

volumeMultiplier = useCustomFilters ? customVolumeMultiplier :
     signalMode == "Sensitive" ? 0.5 :
     signalMode == "Balanced"  ? 1.0 :
     1.5

rangeMultiplier = useCustomFilters ? customRangeMultiplier :
     signalMode == "Sensitive" ? 0.5 :
     signalMode == "Balanced"  ? 1.0 :
     1.5

// ==========================
// Alligator lines
// ==========================
medianPrice = hl2

jaw   = ta.ema(medianPrice, jawLength)
teeth = ta.ema(medianPrice, teethLength)
lips  = ta.ema(medianPrice, lipsLength)

// ==========================
// Slopes
// ==========================
jawSlope   = jaw - jaw[1]
teethSlope = teeth - teeth[1]
lipsSlope  = lips - lips[1]

// ==========================
// Volume and range validation
// ==========================
avgVolume = ta.sma(volume, volumeLength)

rangeHigh  = ta.highest(high, rangeLength)
rangeLow   = ta.lowest(low, rangeLength)
priceRange = rangeHigh - rangeLow
avgRange   = ta.sma(priceRange, rangeLength)

validTrendRange = avgRange > 0 ? priceRange > avgRange * rangeMultiplier : false
highVolume      = avgVolume > 0 ? volume > avgVolume * volumeMultiplier : false

strongTrend = math.abs(jawSlope) > slopeThreshold and math.abs(teethSlope) > slopeThreshold and math.abs(lipsSlope) > slopeThreshold

validSignal = strongTrend and validTrendRange and highVolume

// ==========================
// Reversal / shift logic
// ==========================
// Bullish Shift:
// Lines still in bearish order, but all slopes are rising.
bullShift = validSignal and lips < teeth and teeth < jaw and jawSlope > 0 and teethSlope > 0 and lipsSlope > 0

// Bearish Shift:
// Lines still in bullish order, but all slopes are falling.
bearShift = validSignal and lips > teeth and teeth > jaw and jawSlope < 0 and teethSlope < 0 and lipsSlope < 0

// ==========================
// Line colors
// ==========================
jawColor   = jawSlope > 0 ? color.green : color.red
teethColor = teethSlope > 0 ? color.green : color.red
lipsColor  = lipsSlope > 0 ? color.green : color.red

plot(jaw, color=jawColor, title="Jaw")
plot(teeth, color=teethColor, title="Teeth")
plot(lips, color=lipsColor, title="Lips")

// ==========================
// Visuals
// ==========================
bgcolor(showBackground and bullShift ? color.new(color.green, 90) : na, title="Bullish Shift Highlight")
bgcolor(showBackground and bearShift ? color.new(color.red, 90) : na, title="Bearish Shift Highlight")

if showLabels and bullShift
    label.new(bar_index, low - 5 * syminfo.mintick, "BullSHift", size=size.small, style=label.style_label_up, color=color.green, textcolor=color.white)

if showLabels and bearShift
    label.new(bar_index, high + 5 * syminfo.mintick, "BearShift", size=size.small, style=label.style_label_down, color=color.red, textcolor=color.white)

// ==========================
// Alerts
// ==========================
alertcondition(bullShift, title="Bullish Shift", message="AlligatorFlex Bullish Shift detected.")
alertcondition(bearShift, title="Bearish Shift", message="AlligatorFlex Bearish Shift detected.")
````
