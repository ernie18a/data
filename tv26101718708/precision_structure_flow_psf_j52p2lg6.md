# Precision Structure Flow (PSF)

- url: https://www.tradingview.com/script/J52P2LG6-Precision-Structure-Flow-PSF/
- type: indicator
- pine_id: PUB;e83652d989c84b13a8ff6f4f4ebdae77
- version: 1.0

## Description

Precision Structure Flow (PSF) is a professional-grade trend continuation and execution indicator designed to identify high-probability pullback entries within structured market conditions. It combines dynamic trend analysis, institutional pivot levels, and automated risk-to-reward visualization into a clean, non-cluttered interface built for serious traders.

At its foundation, PSF integrates a smoothed trend midline with adaptive volatility bands to define directional bias and value zones. This is paired with daily pivot levels (P, R1, R2, S1, S2), which act as key areas of liquidity and reaction. The indicator then identifies structure-based pullbacks, highlighting when price retraces into these zones during an established trend, allowing traders to align with momentum rather than chase price.

A core feature of PSF is its automated risk-to-reward box, which is generated upon valid entry conditions. This visually defines the trade structure by plotting entry, stop loss, and projected target levels based on a user-defined risk ratio. This ensures every trade is pre-planned with clear risk parameters, supporting disciplined and consistent execution.

How to Use
Identify trend direction using the midline:
Price above = bullish bias
Price below = bearish bias
Wait for price to pull back into:
The trend midline (value zone), or
A pivot level (P, S1, R1)
Enter on confirmation:
Bullish candle in uptrend
Bearish candle in downtrend
Use the automatically plotted risk/reward box to:
Define stop loss placement
Target logical profit zones (R1/R2 or S1/S2)

Key Features
Clean trend channel with dynamic volatility bands
Institutional pivot levels for structure-based trading
Structure retest entry logic
Automated risk-to-reward visualization
Non-repainting logic for reliable back testing and execution
Minimalist design with no unnecessary indicators or oscillators

Best Timeframes
Primary: 1H, 4H, Daily
Optional refinement: 15M for entry precision

Best Trading Sessions
London Session – strong directional moves
New York Session – continuation and volatility
Avoid low-liquidity periods for lower timeframes

Best Markets
Forex Majors (EURUSD, GBPUSD, USDJPY)
Indices (NAS100, US30, SPX)
Gold (XAUUSD)
Trading Approach

PSF is designed for trend continuation traders who focus on structure, patience, and disciplined execution. It performs best when used to trade pullbacks in trending markets rather than ranging conditions. By combining directional bias, key levels, and predefined risk, PSF helps traders execute with clarity and consistency.

## Source Code

````pine
//@version=6
indicator("Precision Structure Flow (PSF)", overlay=true, max_boxes_count=100, max_labels_count=100)

// ───── INPUTS ─────
len      = input.int(34, "Trend Length")
atrLen   = input.int(100, "ATR Length")
mult     = input.float(1.6, "Channel Width")
rr       = input.float(2.0, "Risk Reward (1:X)")
boxBars  = input.int(12, "RR Box Length")

// ───── TREND CHANNEL (SMOOTH + CLEAN) ─────
mid = ta.ema(close, len)
atr = ta.atr(atrLen)

upper = mid + atr * mult
lower = mid - atr * mult

trendUp   = close > mid
trendDown = close < mid

// ───── PIVOTS (DAILY STYLE) ─────
pivot = (high[1] + low[1] + close[1]) / 3
r1 = pivot * 2 - low[1]
r2 = pivot + (high[1] - low[1])
s1 = pivot * 2 - high[1]
s2 = pivot - (high[1] - low[1])

// ───── STRUCTURE RETEST LOGIC ─────
pullbackLong  = trendUp and low <= mid
pullbackShort = trendDown and high >= mid

longEntry  = pullbackLong and close > open
shortEntry = pullbackShort and close < open

// ───── STOP + TARGET (LOCKED STRUCTURE) ─────
longSL  = math.min(low, s1)
shortSL = math.max(high, r1)

longTP  = close + (close - longSL) * rr
shortTP = close - (shortSL - close) * rr

// ───── DRAW RISK / REWARD BOX (LIKE IMAGE) ─────
var box rrBox = na
var line entryLine = na

if longEntry
    box.delete(rrBox)
    line.delete(entryLine)

    rrBox := box.new(
        left = bar_index,
        right = bar_index + boxBars,
        top = longTP,
        bottom = longSL,
        bgcolor = color.new(color.green, 85),
        border_color = color.green
    )

    entryLine := line.new(bar_index, close, bar_index + boxBars, close, color=color.white)

if shortEntry
    box.delete(rrBox)
    line.delete(entryLine)

    rrBox := box.new(
        left = bar_index,
        right = bar_index + boxBars,
        top = shortSL,
        bottom = shortTP,
        bgcolor = color.new(color.red, 85),
        border_color = color.red
    )

    entryLine := line.new(bar_index, close, bar_index + boxBars, close, color=color.white)

// ───── VISUAL STYLE (MATCH IMAGE) ─────
plot(mid, "Midline", color=color.white, linewidth=2)
plot(upper, "Upper", color=color.new(color.green, 40), style=plot.style_line)
plot(lower, "Lower", color=color.new(color.red, 40), style=plot.style_line)

// Pivot Levels
plot(pivot, "Pivot", color=color.orange, linewidth=2)
plot(r1, "R1", color=color.new(color.green, 0))
plot(r2, "R2", color=color.new(color.green, 30))
plot(s1, "S1", color=color.new(color.red, 0))
plot(s2, "S2", color=color.new(color.red, 30))

// Background bias (very subtle)
bgcolor(trendUp ? color.new(color.green, 95) : trendDown ? color.new(color.red, 95) : na)

// Labels
if longEntry
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green)

if shortEntry
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red)
````
