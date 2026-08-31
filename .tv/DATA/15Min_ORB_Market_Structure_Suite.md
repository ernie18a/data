<!-- tradingview-pine-id: PUB;24f08e096e6d4461aefd510948d26f14 -->
<!-- tradingviewscripts-format: 1 -->
# 15-Min ORB + Market Structure Suite

Source: https://www.tradingview.com/script/9CubFMp6-15-Min-ORB-Market-Structure-Suite/

## Description

What Has Been Included
Moving Averages: 7 SMA plotted in solid white and 20 SMA plotted in solid yellow.

VWAP: Session VWAP displayed as a dotted white line.

Pivot Points: Auto-calculated Daily Pivot Points (Main Pivot in orange, R1 in red, S1 in green).

Smoothed Heikin-Ashi: Smoothed HA calculated in the background to color your standard chart candle bodies (Emerald for bullish trends, Maroon for bearish trends) so you keep clean price action while receiving smoothed trend context.

BOS & Reversal Signals: Triangles appear under/above candles when a Break of Structure (BOS) occurs or when the 7/20 SMA crosses alongside Smoothed HA agreement.

Stop Loss & Take Profit Projection: Short dashed visual projection lines drawn dynamically at recent structural highs/lows (Green for Take Profit target, Red for Stop Loss level).

Alerts Configured: Pre-built alertcondition() triggers ready to connect to popup notifications or webhooks.

---

## Source Code

````pine
//@version=6
indicator("15-Min ORB + Market Structure Suite", overlay=true, max_lines_count=500, max_labels_count=500)

// --- INPUTS & PARAMETERS ---
grp_orb   = "15-Min ORB Sessions"
useLondon = input.bool(true, "London Session ORB (08:00 UTC)", group=grp_orb)
useNY     = input.bool(true, "New York Session ORB (13:30 UTC)", group=grp_orb)

grp_ma    = "Moving Averages"
sma7Len   = input.int(7, "7 SMA Length", group=grp_ma)
sma20Len  = input.int(20, "20 SMA Length", group=grp_ma)

grp_sha   = "Smoothed Heikin-Ashi Settings"
shaLen    = input.int(10, "Smoothing Length", group=grp_sha)

// --- MOVING AVERAGES ---
sma7  = ta.sma(close, sma7Len)
sma20 = ta.sma(close, sma20Len)

plot(sma7, title="7 SMA", color=color.white, linewidth=2)
plot(sma20, title="20 SMA", color=color.yellow, linewidth=2)

// --- ANCHORED DOTTED VWAP (Session-Based) ---
vwapVal = ta.vwap(close)
plot(vwapVal, title="Dotted White VWAP", color=color.white, linewidth=2, linestyle=plot.linestyle_dotted)

// --- AUTO ANCHORED PIVOT POINTS (Daily Pivots) ---
[pPivot, r1, s1, r2, s2] = request.security(syminfo.tickerid, "D", [hlc3[1], (2 * hlc3[1]) - low[1], (2 * hlc3[1]) - high[1], hlc3[1] + (high[1] - low[1]), hlc3[1] - (high[1] - low[1])])
plot(pPivot, title="Pivot Point", color=color.new(color.orange, 30), style=plot.style_circles)
plot(r1, title="R1 Pivot", color=color.new(color.red, 40), style=plot.style_circles)
plot(s1, title="S1 Pivot", color=color.new(color.green, 40), style=plot.style_circles)

// --- SMOOTHED HEIKIN-ASHI CALCULATION ---
oSmooth = ta.ema(open, shaLen)
hSmooth = ta.ema(high, shaLen)
lSmooth = ta.ema(low, shaLen)
cSmooth = ta.ema(close, shaLen)

var float haOpen = na
haClose = (oSmooth + hSmooth + lSmooth + cSmooth) / 4
haOpen  := na(haOpen[1]) ? (oSmooth + cSmooth) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh  = math.max(hSmooth, math.max(haOpen, haClose))
haLow   = math.min(lSmooth, math.min(haOpen, haClose))

// --- CANDLE COLORING ---
shaBullish = haClose > haOpen
candleColor = shaBullish ? color.green : color.maroon
barcolor(candleColor, title="Smoothed HA Candle Colors")

// --- REVERSAL & BREAK OF STRUCTURE (BOS) ALERTS ---
pivotHigh = ta.pivothigh(high, 3, 3)
pivotLow  = ta.pivotlow(low, 3, 3)

var float lastPivotHigh = na
var float lastPivotLow  = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh
if not na(pivotLow)
    lastPivotLow := pivotLow

// Market Structure Break (BOS)
bullBOS = ta.crossover(close, lastPivotHigh)
bearBOS = ta.crossunder(close, lastPivotLow)

// Reversal Condition (SMA Cross + HA Shift)
bullReversal = ta.crossover(sma7, sma20) and shaBullish
bearReversal = ta.crossunder(sma7, sma20) and not shaBullish

bullSignal = bullBOS or bullReversal
bearSignal = bearBOS or bearReversal

// --- SIGNALS & TARGET LINES ---
plotshape(bullSignal, title="Bullish Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(bearSignal, title="Bearish Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

if bullSignal
    line.new(bar_index, low[1], bar_index + 5, low[1], color=color.red, width=2, style=line.style_dashed)
    line.new(bar_index, not na(lastPivotHigh) ? lastPivotHigh : high * 1.01, bar_index + 5, not na(lastPivotHigh) ? lastPivotHigh : high * 1.01, color=color.green, width=2, style=line.style_dashed)

if bearSignal
    line.new(bar_index, high[1], bar_index + 5, high[1], color=color.red, width=2, style=line.style_dashed)
    line.new(bar_index, not na(lastPivotLow) ? lastPivotLow : low * 0.99, bar_index + 5, not na(lastPivotLow) ? lastPivotLow : low * 0.99, color=color.green, width=2, style=line.style_dashed)

// --- ALERT CONDITIONS ---
alertcondition(bullSignal, title="Bullish Reversal / BOS Alert", message="15m ORB: Bullish Reversal or Break of Structure confirmed!")
alertcondition(bearSignal, title="Bearish Reversal / BOS Alert", message="15m ORB: Bearish Reversal or Break of Structure confirmed!")
````
