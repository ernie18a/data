# ES Breakout Toolkit Consolidation Range Detector Free

- url: https://www.tradingview.com/script/Opw1tJhh-ES-Breakout-Toolkit-Consolidation-Range-Detector-Free/
- type: indicator
- pine_id: PUB;0c0a2f78e2714c36b5be2fa97aa29aa5
- version: 1.0

## Description

=== PART OF THE ES BREAKOUT TOOLKIT ===
This is one of several free, standalone indicators that make up the ES Breakout Toolkit series. Each indicator isolates a single component used in the full ES London Breakout Pro strategy. They are designed to be useful on their own and educational for traders studying consolidation and breakout mechanics on ES futures.

=== WHAT THIS INDICATOR DOES ===
The Consolidation Range Detector identifies periods where price is compressing into a defined range that meets specific quality criteria. It draws a box around the consolidation zone when the range is tight relative to its recent average and falls within acceptable ATR bounds — not too small to be noise, not too large to be a trend already in motion.

When price exits a valid consolidation range, the indicator marks the breakout direction with an arrow. A label at the end of each range shows the range size in points and as a multiple of ATR, giving you context on the quality of the setup.

=== HOW TO USE IT ===
Apply this to an ES futures chart on a 5-minute timeframe. The indicator will automatically detect and draw consolidation boxes when conditions are met. You can adjust the range lookback period, tightness filter, and ATR bounds in the inputs to match your preference.

The key readings to watch are the Range/ATR ratio and the Range vs Average ratio in the dashboard. A range that is small relative to ATR and below its own recent average is a higher-quality consolidation — it means price is compressing more than usual, which often precedes a directional move.

An optional session filter limits detection to the London session (12AM-6AM PT) if you only want to see consolidations during that window.

=== KEY FEATURES ===
- Automatic consolidation zone detection with visual boxes
- Tightness filter comparing current range to rolling average
- ATR-based minimum and maximum range bounds
- Breakout direction arrows when price exits a valid range
- Range size labels in points and ATR multiples
- Optional London session filter
- Dashboard with real-time range quality metrics
- Alerts for consolidation detection and breakout events

=== ABOUT THE ES BREAKOUT TOOLKIT ===
This indicator is part of a free series that breaks down the building blocks of a London session ES futures breakout strategy. Other free indicators in the series cover session highlighting, ADX regime filtering, breakout candle scanning, and momentum close analysis. Each is published separately on my profile.

The full ES London Breakout Pro indicator combines all of these components into a unified strategy with additional proprietary features including advanced risk management, trade qualification, and data tracking. It is available as an invite-only script on my profile. Use the access request instructions on that script's page if you are interested.

=== DISCLAIMER ===
This indicator is provided for educational and informational purposes only. It is NOT financial advice. It does not constitute a recommendation to buy, sell, or hold any financial instrument. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial advisor before making any trading decisions. You are solely responsible for your own trading activity.

## Source Code

````pine
//@version=6
indicator("[ES Breakout Toolkit] Consolidation Range Detector — Free", overlay=true)

// ==================== INPUTS ====================
rangeBars = input.int(10, "Range Lookback (bars)", minval=3, maxval=50)
tightnessMultiple = input.float(1.5, "Tightness Filter (x Avg Range)", minval=1.0, step=0.1)
minATRMultiple = input.float(0.25, "Min Range (x ATR)", minval=0.1, step=0.05)
maxATRMultiple = input.float(3.4, "Max Range (x ATR)", minval=1.0, step=0.1)
avgRangeLookback = input.int(12, "Avg Range Lookback", minval=5, maxval=50)
showBox = input.bool(true, "Show Range Box")
showLabel = input.bool(true, "Show Range Size Label")
validBoxColor = input.color(color.new(color.teal, 80), "Valid Range Color")
invalidBoxColor = input.color(color.new(color.gray, 90), "Invalid Range Color")
sessionFilterOn = input.bool(false, "Limit to London Session (12AM-6AM PT)")

// ==================== INDICATORS ====================
atr = ta.atr(20)

// ==================== SESSION ====================
ptHour = hour(time, "America/Los_Angeles")
inSession = not sessionFilterOn or (ptHour >= 0 and ptHour < 6)

// ==================== RANGE DETECTION ====================
rangeHigh = ta.highest(high, rangeBars)
rangeLow = ta.lowest(low, rangeBars)
rangeSize = rangeHigh - rangeLow
avgRange = ta.sma(rangeSize, avgRangeLookback)
isTightRange = rangeSize <= avgRange * tightnessMultiple
minRange = atr * minATRMultiple
maxRange = atr * maxATRMultiple
validRange = rangeSize >= minRange and rangeSize <= maxRange and isTightRange and inSession

// ==================== RANGE STATE TRACKING ====================
var bool wasValid = false
var int boxStart = 0
var float boxHigh = na
var float boxLow = na

rangeJustValid = validRange and not wasValid
rangeJustInvalid = not validRange and wasValid

if rangeJustValid
    boxStart := bar_index
    boxHigh := rangeHigh
    boxLow := rangeLow

if validRange
    boxHigh := rangeHigh
    boxLow := rangeLow

// ==================== DRAW RANGE BOXES ====================
var box currBox = na

if rangeJustValid
    currBox := box.new(bar_index - rangeBars, rangeHigh, bar_index, rangeLow, border_color=color.teal, bgcolor=validBoxColor, border_width=1)

if validRange and not na(currBox)
    box.set_right(currBox, bar_index)
    box.set_top(currBox, rangeHigh)
    box.set_bottom(currBox, rangeLow)

if rangeJustInvalid and not na(currBox) and showLabel
    label.new(bar_index, rangeHigh, str.tostring(rangeSize, "#.##") + "pts\n" + str.tostring(rangeSize / atr, "#.#") + "xATR", style=label.style_label_down, color=color.new(color.teal, 60), textcolor=color.white, size=size.tiny)

wasValid := validRange

// ==================== BREAKOUT MARKERS ====================
breakoutUp = validRange[1] and not validRange and close > rangeHigh[1]
breakoutDown = validRange[1] and not validRange and close < rangeLow[1]

plotshape(breakoutUp, title="Range Break Up", style=shape.arrowup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(breakoutDown, title="Range Break Down", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.small)

// ==================== BACKGROUND ====================
bgcolor(validRange ? validBoxColor : na, title="Valid Range BG")

// ==================== DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 10), border_width=1)
table.cell(dash, 0, 0, "Range Detector", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 1, 0, "Status", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 0, 1, "Range", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 1, validRange ? "CONSOLIDATING" : "NO RANGE", text_color=validRange ? color.lime : color.gray, text_size=size.small)
table.cell(dash, 0, 2, "Range Size", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 2, str.tostring(rangeSize, "#.##") + " pts", text_color=color.white, text_size=size.small)
table.cell(dash, 0, 3, "vs ATR", text_color=color.gray, text_size=size.small)
ratioATR = atr > 0 ? rangeSize / atr : 0
table.cell(dash, 1, 3, str.tostring(ratioATR, "#.##") + "x", text_color=ratioATR <= 1.5 ? color.lime : ratioATR <= 2.5 ? color.yellow : color.red, text_size=size.small)
table.cell(dash, 0, 4, "vs Avg", text_color=color.gray, text_size=size.small)
ratioAvg = avgRange > 0 ? rangeSize / avgRange : 0
table.cell(dash, 1, 4, str.tostring(ratioAvg, "#.##") + "x", text_color=ratioAvg <= 1.0 ? color.lime : ratioAvg <= 1.5 ? color.yellow : color.red, text_size=size.small)
table.cell(dash, 0, 5, "ATR(20)", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 5, str.tostring(atr, "#.##"), text_color=color.white, text_size=size.small)

// ==================== ALERTS ====================
alertcondition(rangeJustValid, "Consolidation Detected", "Price entering consolidation range")
alertcondition(breakoutUp, "Breakout Up", "Price broke above consolidation range")
alertcondition(breakoutDown, "Breakout Down", "Price broke below consolidation range")
````
