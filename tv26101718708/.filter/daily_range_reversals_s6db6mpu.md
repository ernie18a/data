# Daily Range Reversals

- url: https://www.tradingview.com/script/S6DB6mPu-Daily-Range-Reversals/
- type: indicator
- pine_id: PUB;41cbb5e4ef5341f1a3e343781272a379
- version: 1.0

## Description

Key Features of "Daily Range Reversals"

    Continuous Daily Box: The purple range box now starts at the beginning of the trading day and extends seamlessly through the price action all the way to the right-side PO3 visualization. It automatically tracks the previous day's High-Low range with a dashed midpoint line.
    Reversal Pattern Detection:
        Engulfing: Identifies when a candle body completely "swallows" the previous candle's body.
        Hammers & Shooting Stars: Detects single-bar rejections with long wicks (at least 2x the body size).
    Strategic Filtering:
        35% Zone Check: Signals only trigger if the candle closes within the upper 35% or lower 35% of the previous day's range. This ensures you only see high-probability reversals at the extremities.
        High-Volume Requirement: A signal only appears if the volume of the reversal bar is significantly higher than its 20-period average (adjustable via the "Volume Multiplier").
        Signal Cooldown: To keep the chart clean, the script waits for 3 bars (default) after a signal before allowing another one to prevent clustering.
    PO3 Side-by-Side Visualization: To the right of the price, you can see the completed Previous Daily Candle next to the Active Daily Candle updating in real-time. This helps you visualize how the current day is expanding relative to yesterday's range.
    Replay Optimized: I used persistent objects that update only on the last bar, which fixes the "ghosting" issue you experienced in Bar Replay.

How to use it:

    Monitor the Zone: Watch for price to enter the top or bottom 35% of the purple daily box.
    Confirm the Pattern: Look for a triangle signal (Bullish below, Bearish above). These will only appear on a candle close that confirms both the pattern and the high-volume criteria.
    Entry: These signals are designed to capture reversals back toward the daily midpoint or the opposite side of the range.

## Source Code

````pine
//@version=6
indicator("Daily Range Reversals", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Inputs ---
groupVisual = "Visual Settings"
boxColor    = input.color(color.new(#9c27b0, 0), "Daily Box Color", group = groupVisual)
midLineColor = input.color(color.new(#9c27b0, 50), "Midpoint Line Color", group = groupVisual)
offset      = input.int(20, "Visual Offset (Bars)", minval = 0, group = groupVisual)
displaySize = input.int(30, "Display Width", minval = 10, group = groupVisual)

groupSignal = "Signal Logic & Filtering"
threshold   = input.float(35.0, "Zone Threshold %", minval = 1.0, maxval = 50.0, tooltip = "Signals must close within this % of the high/low range", group = groupSignal) / 100
volMA       = input.int(20, "Volume Average Length", minval = 1, group = groupSignal)
volMult     = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1, tooltip = "Signal volume must be this many times the average volume", group = groupSignal)
cooldown    = input.int(3, "Signal Cooldown (Bars)", minval = 1, group = groupSignal)
bullColor   = input.color(#089981, "Bullish Signal Color", group = groupSignal)
bearColor   = input.color(#f23645, "Bearish Signal Color", group = groupSignal)

// --- Data Fetching ---
[prevHigh, prevLow, prevOpen, prevClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], open[1], close[1]], lookahead = barmerge.lookahead_on)
[currOpen, currHigh, currLow, currClose] = request.security(syminfo.tickerid, "D", [open, high, low, close])

// --- Logic ---
float rangeDaily = prevHigh - prevLow
float upperThreshold = prevHigh - rangeDaily * threshold
float lowerThreshold = prevLow + rangeDaily * threshold
float midLevel       = prevLow + rangeDaily * 0.5

// Volume Logic
avgVol  = ta.sma(volume, volMA)
highVol = volume > (avgVol * volMult)

// Detect Daily Start
bool isNewDay = ta.change(time("D")) != 0

// --- Pattern Detection ---
bodySize   = math.abs(close - open)
upperWick  = high - math.max(open, close)
lowerWick  = low - math.min(open, close)

// 1. Engulfing
bool isEngulfingBull = close > open and close[1] < open[1] and open <= close[1] and close >= open[1]
bool isEngulfingBear = close < open and close[1] > open[1] and open >= close[1] and close <= open[1]

// 2. Hammers & Shooting Stars
bool isHammer = lowerWick > bodySize * 2 and upperWick < lowerWick * 0.3
bool isStar   = upperWick > bodySize * 2 and lowerWick < upperWick * 0.3

// Cooldown logic
var int lastSignalBar = 0
bool cooldownActive = (bar_index - lastSignalBar) < cooldown

// Combine Signals with Zone (at close) and Volume
bool bullSignal = (isEngulfingBull or isHammer) and close <= lowerThreshold and highVol and not cooldownActive
bool bearSignal = (isEngulfingBear or isStar) and close >= upperThreshold and highVol and not cooldownActive

if bullSignal or bearSignal
    lastSignalBar := bar_index

// --- Visuals ---
var box overlayBox = na
var line overlayMid = na

if isNewDay
    overlayBox := box.new(bar_index, prevHigh, bar_index, prevLow, border_color = boxColor, border_width = 1, bgcolor = color.new(boxColor, 95))
    overlayMid := line.new(bar_index, midLevel, bar_index, midLevel, color = midLineColor, width = 1, style = line.style_dashed)

// Persistent PO3 Objects (Prevents ghosting in replay)
var line pWick = line.new(na, na, na, na, width = 2)
var box  pBody = box.new(na, na, na, na)
var line cWick = line.new(na, na, na, na, width = 2)
var box  cBody = box.new(na, na, na, na)

if barstate.islast
    int rLeft  = bar_index + offset
    int rRight = rLeft + displaySize
    int pX     = rLeft + math.round(displaySize * 0.3)
    int cX     = rLeft + math.round(displaySize * 0.7)
    
    if not na(overlayBox)
        box.set_right(overlayBox, rRight)
        line.set_x2(overlayMid, rRight)
    
    // Previous Day Candle
    color pColor = prevClose >= prevOpen ? #089981 : #f23645
    line.set_xy1(pWick, pX, prevHigh)
    line.set_xy2(pWick, pX, prevLow)
    line.set_color(pWick, pColor)
    box.set_lefttop(pBody, pX - 2, math.max(prevOpen, prevClose))
    box.set_rightbottom(pBody, pX + 2, math.min(prevOpen, prevClose))
    box.set_bgcolor(pBody, pColor)
    box.set_border_color(pBody, pColor)

    // Current Day Candle
    color currColor = currClose >= currOpen ? #089981 : #f23645
    line.set_xy1(cWick, cX, currHigh)
    line.set_xy2(cWick, cX, currLow)
    line.set_color(cWick, currColor)
    box.set_lefttop(cBody, cX - 2, math.max(currOpen, currClose))
    box.set_rightbottom(cBody, cX + 2, math.min(currOpen, currClose))
    box.set_bgcolor(cBody, currColor)
    box.set_border_color(cBody, currColor)
else
    if not na(overlayBox)
        box.set_right(overlayBox, bar_index)
        line.set_x2(overlayMid, bar_index)
    // Hide objects on historical bars for clean replay
    line.set_xy1(pWick, na, na), line.set_xy2(pWick, na, na), box.set_lefttop(pBody, na, na)
    line.set_xy1(cWick, na, na), line.set_xy2(cWick, na, na), box.set_lefttop(cBody, na, na)

// --- Signals ---
plotshape(bullSignal, "Bullish Reversal", shape.triangleup, location.belowbar, bullColor, size = size.small)
plotshape(bearSignal, "Bearish Reversal", shape.triangledown, location.abovebar, bearColor, size = size.small)
````
