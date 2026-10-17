# ATC 1.2- Auto Trend Confirmation Clean

- url: https://www.tradingview.com/script/jDzB8q6g-ATC-1-2-Auto-Trend-Confirmation-Clean/
- type: indicator
- pine_id: PUB;681c7076b32947e7bbf3ac4e3a6a3e79
- version: 1.0

## Description

ATC 1.2- Auto Trend Confirmation Clean
 break of structure
add on S/R logic for better performance

## Source Code

````pine
//@version=5
indicator("ATC 1.1 - Auto Trend Confirmation Clean", overlay=true, max_labels_count=200)

// ===== INPUTS =====
swingLen = input.int(5, "Swing Length", minval=2)
showSweeps = input.bool(true, "Show Sweep Labels")
showBOS = input.bool(true, "Show BOS Labels")
showATC = input.bool(true, "Show ATC Signals")

// ===== SWINGS =====
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ===== LIQUIDITY SWEEPS =====
// Buy-side sweep = price takes previous high, then closes back below it
buySideSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

// Sell-side sweep = price takes previous low, then closes back above it
sellSideSweep = not na(lastLow) and low < lastLow and close > lastLow

// ===== BOS =====
// Bullish BOS = close breaks previous swing high
bullBOS = not na(lastHigh) and close > lastHigh

// Bearish BOS = close breaks previous swing low
bearBOS = not na(lastLow) and close < lastLow

// ===== MEMORY =====
var bool recentBuySideSweep = false
var bool recentSellSideSweep = false

if buySideSweep
    recentBuySideSweep := true

if sellSideSweep
    recentSellSideSweep := true

// ===== FINAL ATC SIGNALS =====
// Sell = buy-side liquidity taken + bearish BOS
atcSell = recentBuySideSweep and bearBOS

// Buy = sell-side liquidity taken + bullish BOS
atcBuy = recentSellSideSweep and bullBOS

if atcSell
    recentBuySideSweep := false

if atcBuy
    recentSellSideSweep := false

// ===== LABELS =====
if showSweeps and buySideSweep
    label.new(bar_index, high, "BSL Sweep", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.tiny)

if showSweeps and sellSideSweep
    label.new(bar_index, low, "SSL Sweep", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

if showBOS and bullBOS
    label.new(bar_index, low, "BOS ↑", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

if showBOS and bearBOS
    label.new(bar_index, high, "BOS ↓", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

if showATC and atcBuy
    label.new(bar_index, low, "ATC BUY\nSSL + BOS ↑", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.normal)

if showATC and atcSell
    label.new(bar_index, high, "ATC SELL\nBSL + BOS ↓", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

// ===== ALERTS =====
alertcondition(atcBuy, title="ATC BUY", message="ATC BUY: Sell-side liquidity sweep + bullish BOS")
alertcondition(atcSell, title="ATC SELL", message="ATC SELL: Buy-side liquidity sweep + bearish BOS")// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shivams0121
````
