# SMC Supply Demand Bot [4H + 15m]

- url: https://www.tradingview.com/script/7uyWOz7z-SMC-Supply-Demand-Bot-4H-15m/
- type: indicator
- pine_id: PUB;bef1813b9b4a4a079f980ce8a566402c
- version: 1.0

## Description

✔ Multi-Timeframe Trend Scanner
• 1 Day Trend
• 4 Hour Trend
• 1 Hour Trend
• 15 Minute Trend

✔ Institutional Trend Filter
• Uses 200 EMA for major trend direction.

✔ Smart 44 EMA Retest Entry
• Detects pullback rejection entries with trend confirmation.

✔ Volume Confirmation
• Filters weak and fake moves.

✔ Automatic Risk Management
• Dynamic Stop Loss
• TP1 / TP2 / TP3 Targets
• Risk : Reward based calculations

## Source Code

````pine
//@version=5
indicator("SMC Supply Demand Bot [4H + 15m]", overlay=true, max_boxes_count=50, max_labels_count=50)

// ======================================================
// SETTINGS
// ======================================================

htf_tf              = input.timeframe("240", "Higher Timeframe")
rr                  = input.float(3.0, "Risk Reward", step=0.5)

showSupply          = input.bool(true, "Show Supply Zones")
showDemand          = input.bool(true, "Show Demand Zones")

volumeFilter        = input.bool(true, "Use Volume Confirmation")
bosFilter           = input.bool(true, "Use BOS Confirmation")

// ======================================================
// HTF DATA
// ======================================================

htfHigh     = request.security(syminfo.tickerid, htf_tf, high)
htfLow      = request.security(syminfo.tickerid, htf_tf, low)
htfOpen     = request.security(syminfo.tickerid, htf_tf, open)
htfClose    = request.security(syminfo.tickerid, htf_tf, close)

htfBullish  = htfClose > htfOpen
htfBearish  = htfClose < htfOpen

// ======================================================
// SUPPLY / DEMAND LOGIC
// ======================================================

// Demand Zone
demandCondition =
     htfBullish and
     (htfClose - htfOpen) > ta.atr(14)

demandTop    = request.security(syminfo.tickerid, htf_tf, low[1])
demandBottom = request.security(syminfo.tickerid, htf_tf, low[2])

// Supply Zone
supplyCondition =
     htfBearish and
     (htfOpen - htfClose) > ta.atr(14)

supplyTop    = request.security(syminfo.tickerid, htf_tf, high[2])
supplyBottom = request.security(syminfo.tickerid, htf_tf, high[1])

// ======================================================
// DRAW ZONES
// ======================================================

var box demandBox = na
var box supplyBox = na

if demandCondition and showDemand
    box.delete(demandBox)

    demandBox := box.new(
         left=bar_index,
         right=bar_index + 50,
         top=demandTop,
         bottom=demandBottom,
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if supplyCondition and showSupply
    box.delete(supplyBox)

    supplyBox := box.new(
         left=bar_index,
         right=bar_index + 50,
         top=supplyTop,
         bottom=supplyBottom,
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

// ======================================================
// 15M EXECUTION LOGIC
// ======================================================

// Bullish Engulfing
bullishEngulf =
     close > open and
     close[1] < open[1] and
     close > high[1]

// Bearish Engulfing
bearishEngulf =
     close < open and
     close[1] > open[1] and
     close < low[1]

// BOS
bullishBOS = high > ta.highest(high, 10)[1]
bearishBOS = low < ta.lowest(low, 10)[1]

// Volume Confirmation
volConfirm = volume > ta.sma(volume, 20)

// ======================================================
// ZONE TOUCH
// ======================================================

inDemand =
     close >= demandBottom and
     close <= demandTop

inSupply =
     close <= supplyTop and
     close >= supplyBottom

// ======================================================
// FINAL CONDITIONS
// ======================================================

buyCondition =
     inDemand and
     bullishEngulf and
     (bosFilter ? bullishBOS : true) and
     (volumeFilter ? volConfirm : true)

sellCondition =
     inSupply and
     bearishEngulf and
     (bosFilter ? bearishBOS : true) and
     (volumeFilter ? volConfirm : true)

// ======================================================
// SL / TP
// ======================================================

buySL = ta.lowest(low, 5)
buyTP = close + ((close - buySL) * rr)

sellSL = ta.highest(high, 5)
sellTP = close - ((sellSL - close) * rr)

// ======================================================
// SIGNALS
// ======================================================

plotshape(
     buyCondition,
     title="BUY",
     style=shape.labelup,
     color=color.green,
     text="BUY",
     location=location.belowbar)

plotshape(
     sellCondition,
     title="SELL",
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     location=location.abovebar)

// ======================================================
// TP / SL LINES
// ======================================================

if buyCondition
    line.new(bar_index, buySL, bar_index + 20, buySL, color=color.red, width=2)
    line.new(bar_index, buyTP, bar_index + 20, buyTP, color=color.green, width=2)

if sellCondition
    line.new(bar_index, sellSL, bar_index + 20, sellSL, color=color.red, width=2)
    line.new(bar_index, sellTP, bar_index + 20, sellTP, color=color.green, width=2)

// ======================================================
// ALERTS
// ======================================================

alertcondition(buyCondition, title="BUY SIGNAL", message="BUY Signal Generated")
alertcondition(sellCondition, title="SELL SIGNAL", message="SELL Signal Generated")
````
