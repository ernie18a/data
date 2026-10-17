# Manual PO3 + FVG Trading Assistant

- url: https://www.tradingview.com/script/s44iHobP-Manual-PO3-FVG-Trading-Assistant/
- type: indicator
- pine_id: PUB;d72cc35655fd42b5a0653a59c9b60343
- version: 1.0

## Description

FVG BOS PO3
NIKHO
XAU/USD 
Can be used on different time frames
change inputs as you wish

## Source Code

````pine
//@version=6
indicator("Manual PO3 + FVG Trading Assistant", overlay=true, max_boxes_count=50, max_labels_count=100)

// ===== INPUTS =====
rangeBars    = input.int(20, "Accumulation Range Bars", minval=5)
sweepBuffer  = input.float(0.0, "Sweep Buffer Points")
bosLookback  = input.int(10, "BOS Lookback", minval=3)
atrMult      = input.float(0.4, "Displacement ATR Multiplier", step=0.1)
showFVG      = input.bool(true, "Show FVG Zones")
showRange    = input.bool(true, "Show Accumulation Range")
useSession   = input.bool(false, "Use Session Filter")
sessionInput = input.session("0700-2000", "Trading Session")

// ===== SESSION =====
inSession = not useSession or not na(time(timeframe.period, sessionInput))

// ===== ACCUMULATION RANGE =====
rangeHigh = ta.highest(high, rangeBars)
rangeLow  = ta.lowest(low, rangeBars)

// Draw current range only
var box rangeBox = na

if showRange and barstate.islast
    if not na(rangeBox)
        box.delete(rangeBox)
    rangeBox := box.new(
        left=bar_index - rangeBars,
        right=bar_index,
        top=rangeHigh,
        bottom=rangeLow,
        bgcolor=color.new(color.gray, 88),
        border_color=color.new(color.gray, 40)
    )

// ===== SWEEPS / MANIPULATION =====
sellSideSweep = low < rangeLow[1] - sweepBuffer and close > rangeLow[1]
buySideSweep  = high > rangeHigh[1] + sweepBuffer and close < rangeHigh[1]

// ===== BOS =====
bosHigh = ta.highest(high, bosLookback)[1]
bosLow  = ta.lowest(low, bosLookback)[1]

bullBOS = close > bosHigh
bearBOS = close < bosLow

// ===== DISPLACEMENT =====
body = math.abs(close - open)
atrValue = ta.atr(14)

bullDisplacement = close > open and body > atrValue * atrMult
bearDisplacement = close < open and body > atrValue * atrMult

// ===== FAIR VALUE GAP =====
bullFVG = low > high[2]
bearFVG = high < low[2]

bullFVGTop = low
bullFVGBot = high[2]

bearFVGTop = low[2]
bearFVGBot = high

// ===== SETUP LOGIC =====
buySetup  = inSession and sellSideSweep[1] and bullBOS and bullDisplacement and bullFVG
sellSetup = inSession and buySideSweep[1] and bearBOS and bearDisplacement and bearFVG

// ===== DRAW FVG BOXES =====
if showFVG and buySetup
    box.new(
        left=bar_index - 2,
        right=bar_index + 20,
        top=bullFVGTop,
        bottom=bullFVGBot,
        bgcolor=color.new(color.green, 82),
        border_color=color.green
    )

if showFVG and sellSetup
    box.new(
        left=bar_index - 2,
        right=bar_index + 20,
        top=bearFVGTop,
        bottom=bearFVGBot,
        bgcolor=color.new(color.red, 82),
        border_color=color.red
    )

// ===== LABELS =====
if buySetup
    label.new(
        bar_index,
        low,
        "BUY PO3\nSweep + BOS + FVG",
        style=label.style_label_up,
        textcolor=color.white,
        color=color.green
    )

if sellSetup
    label.new(
        bar_index,
        high,
        "SELL PO3\nSweep + BOS + FVG",
        style=label.style_label_down,
        textcolor=color.white,
        color=color.red
    )

// ===== ALERTS =====
alertcondition(buySetup, title="BUY PO3 Setup", message="BUY PO3 setup detected: sell-side sweep, bullish BOS, displacement and bullish FVG")
alertcondition(sellSetup, title="SELL PO3 Setup", message="SELL PO3 setup detected: buy-side sweep, bearish BOS, displacement and bearish FVG")
````
