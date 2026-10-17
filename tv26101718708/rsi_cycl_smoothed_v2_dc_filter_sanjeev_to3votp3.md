# RSI Cycl Smoothed V2 -DC Filter SANJEEV

- url: https://www.tradingview.com/script/To3VOTp3-RSI-Cycl-Smoothed-V2-DC-Filter-SANJEEV/
- type: indicator
- pine_id: PUB;e8b6b4693c1d45df91640c6524e7aee5
- version: 2.0

## Description

*Script Title*
`RSI Cyclic Smoothed V2 - DC Filter | Adaptive RSI with Ehlers Dominance Cycle`

*Short Description - 250 chars*
Adaptive RSI that auto-adjusts length using Ehlers Dominance Cycle. Avoids chop with DC filter. 3-speed RSI: Fast/Normal/Slow. Built for 5min-15min NIFTY/BANKNIFTY. Shows DC status, No-Trade zones, Buy/Sell arrows. Open Source v6.

*Full Description for Publishing*
**RSI Cyclic Smoothed V2 - DC Filter**
An adaptive RSI indicator that changes its speed based on market cycle length. Open Source.

**The Problem:**
Regular RSI uses fixed length. It’s too slow in fast trends and too noisy in chop. 
This script solves that by using John Ehlers Dominance Cycle to detect market speed and auto-switch RSI length.

**How It Works:**
1.  **Dominance Cycle Detection**: Calculates the dominant cycle of price. Tells you if market is Fast, Normal, or Slow.
2.  **Adaptive RSI**: 
    - Fast Market DC < 16  -> RSI Length = 6
    - Normal Market DC 16-28 -> RSI Length = 10  
    - Slow Market DC > 28 -> RSI Length = 16
    RSI is then smoothed with EMA for cleaner signals.
3.  **DC Filter**: When DC > 30, background turns RED = No Trade Zone. Avoids false signals in sideways markets.

**How To Use - 5min / 15min:**
- **Trade Only When**: Top-right panel shows "Fast" or "Normal". Red background = Stay Out
- **Long**: RSI crosses UP from 30 while DC is in trade zone
- **Short**: RSI crosses DOWN from 70 while DC is in trade zone
- **Best For**: NIFTY, BANKNIFTY, Stocks on 5min and 15min timeframes

**Inputs You Can Tune:**
- `Ehlers DC Length`: Base cycle detection. Default 10
- `Max DC to Trade`: Blocks trades above this DC. Default 30
- `Fast/Normal/Slow RSI Length`: The 3 RSI speeds the script switches between
- `RSI Smoothing`: Extra smoothing to reduce noise. Default 3

**Features:**
- Real-time DC Status + Current RSI Length
- Visual No-Trade Zone to avoid chop  
- Buy/Sell Arrows with Alerts
- No Repaint. v6 Pine Script
- Fully Open Source - Modify and learn

**Why Open Source?**
I believe traders should understand how their indicators work. Feel free to fork, improve, and share. 
If you make it better, please credit and share back.

Made for traders who want to trade with the cycle, not against it.
*Tags to use*
`rsi, adaptive rsi, dominance cycle, ehlers, cyclic, smoothed, nifty, banknifty, intraday, 5min, 15min, filter, momentum, open source`

*Category*
`Indicators > Momentum`

*License / Notes Section*
`License: MIT - Free to use, modify, and distribute. For educational purposes only. Not financial advice.`

## Source Code

````pine
//@version=6
indicator("RSI Cyclic Smoothed V2 - DC Filter", overlay=false, max_labels_count=500, max_lines_count=500)

// === INPUTS ===
grp1 = "Dominance Cycle Settings"
dcLen = input.int(10, "Ehlers DC Length", minval=5, group=grp1)
dcFilter = input.int(30, "Max DC to Trade", minval=10, group=grp1)
useDCFilter = input.bool(true, "Use DC Filter", group=grp1)

grp2 = "RSI Settings"
rsiFast = input.int(6, "Fast RSI Length", minval=2, group=grp2)
rsiNormal = input.int(10, "Normal RSI Length", minval=2, group=grp2)
rsiSlow = input.int(16, "Slow RSI Length", minval=2, group=grp2)
rsiSmooth = input.int(3, "RSI Smoothing", minval=1, group=grp2)

grp3 = "Levels"
ob = input.int(70, "OverBought", group=grp3)
os = input.int(30, "OverSold", group=grp3)

// === DOMINANCE CYCLE CALCULATION - EHLERS ===
var float hp = na
src = hl2
alpha = 0.707 * math.sin(2 * math.pi / dcLen)
hp := alpha * src * src + (1 - alpha) * nz(hp[1]) - math.pow(alpha, 2) * nz(hp[2])
hp := math.max(0.1, hp)
dc = math.min(80.0, math.max(8.0, math.sqrt(hp)))

// === ADAPTIVE RSI - NO DYNAMIC LENGTH ERROR ===
rsi_f = ta.rsi(src, rsiFast)
rsi_n = ta.rsi(src, rsiNormal)
rsi_s = ta.rsi(src, rsiSlow)

// Choose RSI based on DC zone. This avoids CE10123
rsi_raw = dc < 16? rsi_f : dc < 28? rsi_n : rsi_s
rsi = ta.ema(rsi_raw, rsiSmooth) // Smooth the RSI

// === PLOTS - FIXES CE10246 ===
plot(rsi, "Cyclic RSI", color=color.new(color.aqua, 0), linewidth=2)
hline(ob, "OB", color=color.red)
hline(50, "Mid", color=color.gray)
hline(os, "OS", color=color.green)
bgcolor(useDCFilter and dc > dcFilter? color.new(color.red, 90) : na, title="No Trade Zone")

// === SIGNALS ===
tradeAllowed = not useDCFilter or dc < dcFilter
longCond = ta.crossover(rsi, os) and rsi < 50 and tradeAllowed
shortCond = ta.crossunder(rsi, ob) and rsi > 50 and tradeAllowed

plotshape(longCond, "Buy", shape.triangleup, location.bottom, color.lime, size=size.small, text="BUY")
plotshape(shortCond, "Sell", shape.triangledown, location.top, color.red, size=size.small, text="SELL")

// === ALERTS ===
alertcondition(longCond, "RSI DC Buy", "RSI DC Buy: {{ticker}} {{interval}} DC:{{plot_1}}")
alertcondition(shortCond, "RSI DC Sell", "RSI DC Sell: {{ticker}} {{interval}} DC:{{plot_1}}")

// === INFO PANEL ===
var table info = table.new(position.top_right, 1, 1, border_width=1)
if barstate.islastconfirmedhistory
    dcStatus = dc < 16? "Fast - RSI:" + str.tostring(rsiFast) : dc < 28? "Normal - RSI:" + str.tostring(rsiNormal) : "Slow - RSI:" + str.tostring(rsiSlow)
    txt = "DC: " + str.tostring(dc, "#.##") + " bars\n" + "Mode: " + dcStatus
    table.cell(info, 0, 0, txt, text_color=color.white, bgcolor=color.new(color.black, 70))
````
