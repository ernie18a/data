# Sweep Detector V2

- url: https://www.tradingview.com/script/ol66fjHd-Sweep-Detector-V2/
- type: indicator
- pine_id: PUB;0f33d9ba5b2343f799cd8238d056a5ee
- version: 1.0

## Description

---

**Sweep Detector**

Identifies liquidity sweeps — candles where price wicks above a swing high or below a swing low but closes back inside the range, signaling a failed breakout and potential reversal.

**How it works:**
The script scans back across a configurable lookback window to find the most recent confirmed swing high and swing low using only closed bars (no repainting). A sweep is detected when:
- **High Sweep (Bearish):** The wick breaks above the swing high but the candle closes back below it
- **Low Sweep (Bullish):** The wick breaks below the swing low but the candle closes back above it

A horizontal line is drawn from the swing point to the sweep candle to visualize the level that was taken out. Labels mark the sweep candle directly on the chart.

**Settings:**
- **Swing Lookback** — how many bars back to search for swing highs and lows (default: 10). Higher values find stronger, less frequent swings; lower values are more reactive.

**Alerts included:**
- Bearish Sweep detected
- Bullish Sweep detected
- Any Sweep detected (Bullish or Bearish)

Works on all symbols and timeframes.

## Source Code

````pine
//@version=5
indicator("Sweep Detector V2", overlay=true, max_lines_count=500)

lookback = input.int(10, "Swing Lookback", minval=3, maxval=50)

// Scan from bar[2] so only past bars used — no repainting
findSwingHigh(len) =>
    val = float(na)
    idx = int(na)
    for i = 2 to len
        if high[i] > high[i + 1] and high[i] > high[i - 1]
            val := high[i]
            idx := bar_index - i
            break
    [val, idx]

findSwingLow(len) =>
    val = float(na)
    idx = int(na)
    for i = 2 to len
        if low[i] < low[i + 1] and low[i] < low[i - 1]
            val := low[i]
            idx := bar_index - i
            break
    [val, idx]

[swHigh, swHighBar] = findSwingHigh(lookback)
[swLow,  swLowBar]  = findSwingLow(lookback)

var float prevHigh         = na
var float prevLow          = na
var int   prevHighBar      = na
var int   prevLowBar       = na
var int   lastSweptHighBar = -1  // -1 sentinel avoids na comparison bug
var int   lastSweptLowBar  = -1

if not na(swHigh)
    prevHigh    := swHigh
    prevHighBar := swHighBar

if not na(swLow)
    prevLow    := swLow
    prevLowBar := swLowBar

// Guard with not na(prevHighBar) before the int comparison
highSweep = not na(prevHigh) and not na(prevHighBar) and
     high > prevHigh and close < prevHigh and
     prevHighBar != lastSweptHighBar

lowSweep = not na(prevLow) and not na(prevLowBar) and
     low < prevLow and close > prevLow and
     prevLowBar != lastSweptLowBar

if highSweep
    lastSweptHighBar := prevHighBar
    line.new(prevHighBar, prevHigh, bar_index, prevHigh, width=2, color=color.red)

if lowSweep
    lastSweptLowBar := prevLowBar
    line.new(prevLowBar, prevLow, bar_index, prevLow, width=2, color=color.green)

plotshape(highSweep, location=location.abovebar, color=color.red,   style=shape.labeldown, title="High Sweep", text="Sweep")
plotshape(lowSweep,  location=location.belowbar, color=color.green, style=shape.labelup,   title="Low Sweep",  text="Sweep")

alertcondition(highSweep,             title="Bearish Sweep",      message="Bearish Sweep detected!")
alertcondition(lowSweep,              title="Bullish Sweep",       message="Bullish Sweep detected!")
alertcondition(highSweep or lowSweep, title="Bullish and Bearish", message="Sweep detected (Bullish or Bearish)!")
````
