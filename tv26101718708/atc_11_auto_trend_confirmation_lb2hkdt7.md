# ATC 1.1 - Auto Trend Confirmation

- url: https://www.tradingview.com/script/lb2HKdt7-ATC-1-1-Auto-Trend-Confirmation/
- type: indicator
- pine_id: PUB;7254b756da854800926744883d498c44
- version: 1.0

## Description

Auto Trend Confirmation
Based on S/R logic
BOS COCH Trend

## Source Code

````pine
//@version=5
indicator("ATC 1.1 - Auto Trend Confirmation", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ================= INPUTS =================
swingLen      = input.int(5, "Swing Length", minval=2)
zoneLookback  = input.int(120, "S/R Lookback Candles", minval=30)
zoneTolerance = input.float(1.5, "Zone Tolerance $", step=0.1)
minTouches    = input.int(2, "Minimum Touches For Strong Zone", minval=2)
atrLen        = input.int(14, "ATR Length")
dispMult      = input.float(1.2, "Displacement Strength", step=0.1)
showZones     = input.bool(true, "Show Support / Resistance Zones")
showBOS       = input.bool(true, "Show BOS / CHoCH")
showSweeps    = input.bool(true, "Show Liquidity Sweeps")
showSignals   = input.bool(true, "Show ATC Buy / Sell Signals")

// ================= CORE =================
atr = ta.atr(atrLen)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow  = na
var int trend = 0
// 1 = bullish, -1 = bearish

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ================= BOS / CHOCH =================
bullBOS = not na(lastHigh) and close > lastHigh
bearBOS = not na(lastLow) and close < lastLow

bullCHoCH = bullBOS and trend == -1
bearCHoCH = bearBOS and trend == 1

if bullBOS
    trend := 1

if bearBOS
    trend := -1

if showBOS and bullBOS
    label.new(bar_index, low, bullCHoCH ? "CHoCH ↑" : "BOS ↑", style=label.style_label_up, textcolor=color.white, color=color.green, size=size.small)

if showBOS and bearBOS
    label.new(bar_index, high, bearCHoCH ? "CHoCH ↓" : "BOS ↓", style=label.style_label_down, textcolor=color.white, color=color.red, size=size.small)

// ================= LIQUIDITY SWEEP =================
equalHigh = not na(lastHigh) and math.abs(high - lastHigh) <= zoneTolerance
equalLow  = not na(lastLow) and math.abs(low - lastLow) <= zoneTolerance

buySideSweep  = not na(lastHigh) and high > lastHigh and close < lastHigh
sellSideSweep = not na(lastLow) and low < lastLow and close > lastLow

if showSweeps and buySideSweep
    label.new(bar_index, high, "Buy-side Sweep", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.tiny)

if showSweeps and sellSideSweep
    label.new(bar_index, low, "Sell-side Sweep", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

// ================= DISPLACEMENT =================
bullDisplacement = close > open and (close - open) > atr * dispMult
bearDisplacement = open > close and (open - close) > atr * dispMult

// ================= SUPPORT / RESISTANCE TOUCH COUNT =================
supportTouches = 0
resistTouches  = 0

for i = 1 to zoneLookback
    if not na(lastLow) and math.abs(low[i] - lastLow) <= zoneTolerance
        supportTouches += 1
    if not na(lastHigh) and math.abs(high[i] - lastHigh) <= zoneTolerance
        resistTouches += 1

strongSupport = supportTouches >= minTouches
strongResistance = resistTouches >= minTouches

// ================= ZONES =================
var box supportBox = na
var box resistBox = na

if showZones and strongSupport and not na(lastLow)
    box.delete(supportBox)
    supportBox := box.new(
         left=bar_index - zoneLookback,
         right=bar_index + 30,
         top=lastLow + zoneTolerance,
         bottom=lastLow - zoneTolerance,
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if showZones and strongResistance and not na(lastHigh)
    box.delete(resistBox)
    resistBox := box.new(
         left=bar_index - zoneLookback,
         right=bar_index + 30,
         top=lastHigh + zoneTolerance,
         bottom=lastHigh - zoneTolerance,
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

// ================= PULLBACK ENTRY LOGIC =================
nearSupport = not na(lastLow) and math.abs(close - lastLow) <= zoneTolerance * 2
nearResistance = not na(lastHigh) and math.abs(close - lastHigh) <= zoneTolerance * 2

atcBuy =
     trend == 1 and
     strongSupport and
     nearSupport and
     sellSideSweep[1] and
     bullDisplacement

atcSell =
     trend == -1 and
     strongResistance and
     nearResistance and
     buySideSweep[1] and
     bearDisplacement

// ================= SIGNALS =================
if showSignals and atcBuy
    label.new(bar_index, low, "ATC BUY", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.normal)

if showSignals and atcSell
    label.new(bar_index, high, "ATC SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

// ================= ALERTS =================
alertcondition(atcBuy, title="ATC BUY", message="ATC 1.1 BUY signal on {{ticker}}")
alertcondition(atcSell, title="ATC SELL", message="ATC 1.1 SELL signal on {{ticker}}")
alertcondition(bullBOS, title="Bullish BOS", message="Bullish BOS detected on {{ticker}}")
alertcondition(bearBOS, title="Bearish BOS", message="Bearish BOS detected on {{ticker}}")
alertcondition(buySideSweep, title="Buy-side Sweep", message="Buy-side liquidity sweep detected")
alertcondition(sellSideSweep, title="Sell-side Sweep", message="Sell-side liquidity sweep detected")// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shivams0121
````
