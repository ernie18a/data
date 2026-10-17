# ATC 1.1 -

- url: https://www.tradingview.com/script/Byb6eVZn-ATC-1-1/
- type: indicator
- pine_id: PUB;ebadf03d59594308a671b4cea179086e
- version: 1.0

## Description

auto trend continuation  works well with s/r logic

## Source Code

````pine
//@version=5
indicator("ATC 1.1 - Auto Trend Confirmation", overlay=true, max_labels_count=50)

// ===== INPUTS =====
swingLen = input.int(5, "Swing Length", minval=2)
validBars = input.int(20, "Sweep Valid For Next Candles", minval=1)

// ===== SWINGS =====
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ===== SWEEP LOGIC =====
buySideSweep = not na(lastHigh) and high > lastHigh and close < lastHigh
sellSideSweep = not na(lastLow) and low < lastLow and close > lastLow

// ===== BOS LOGIC =====
bullBOS = not na(lastHigh) and close > lastHigh
bearBOS = not na(lastLow) and close < lastLow

// ===== MEMORY =====
var int lastBuySideSweepBar = na
var int lastSellSideSweepBar = na

if buySideSweep
    lastBuySideSweepBar := bar_index

if sellSideSweep
    lastSellSideSweepBar := bar_index

buySideSweepValid = not na(lastBuySideSweepBar) and bar_index - lastBuySideSweepBar <= validBars
sellSideSweepValid = not na(lastSellSideSweepBar) and bar_index - lastSellSideSweepBar <= validBars

// ===== FINAL SIGNAL ONLY =====
atcBuy = sellSideSweepValid and bullBOS
atcSell = buySideSweepValid and bearBOS

// Reset after signal so it does not repeat too much
if atcBuy
    lastSellSideSweepBar := na

if atcSell
    lastBuySideSweepBar := na

// ===== PLOT ONLY MAIN SIGNALS =====
plotshape(atcBuy, title="ATC BUY", text="ATC BUY", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.normal)
plotshape(atcSell, title="ATC SELL", text="ATC SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

// ===== ALERTS =====
alertcondition(atcBuy, title="ATC BUY", message="ATC BUY: Sell-side liquidity sweep + bullish BOS")
alertcondition(atcSell, title="ATC SELL", message="ATC SELL: Buy-side liquidity sweep + bearish BOS")
````
