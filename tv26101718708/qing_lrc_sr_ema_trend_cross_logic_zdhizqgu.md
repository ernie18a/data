# Qing LRC + S/R + EMA (Trend Cross Logic)

- url: https://www.tradingview.com/script/ZDhizQgu-Qing-LRC-S-R-EMA-Trend-Cross-Logic/
- type: strategy
- pine_id: PUB;6f4c8e00015c405a914bccf61397de23
- version: 1.0

## Description

The Strategy Concept
The Qing LRC + S/R + EMA strategy is designed to find "Gold Chances" where price is undervalued relative to its current trend. Instead of chasing breakouts, this logic looks for price to touch the lower boundaries of a statistical corridor (LRC) or horizontal support levels, provided the overall trend (LRC Upper vs. EMA 20) remains intact.

Key Technical Components
LRC vs. EMA 20 Trend Logic: A unique trend filter. When the LRC Upper Channel is above the EMA 20, the market is considered "Bullish." This is visually represented by a dynamic green background fill.

Linear Regression Value Zones: The script plots an upper and lower channel based on price standard deviation. It looks for "reversion to the mean" opportunities when price hits the lower red channel.

Pivot S/R Confirmation: Automatically identifies and plots significant Pivot Highs (Resistance) and Pivot Lows (Support). Entry signals are strengthened when price hits the Lower LRC Channel and a Support level simultaneously.

Trend Weakness Exit: Unlike fixed targets, the script monitors trend health. If the LRC Lower Channel crosses below the EMA 20, it signals a potential trend shift, triggering an early exit to protect capital.

How to Trade
Identify the Bias: Ensure the background is Green (LRC Upper > EMA 20), indicating a healthy upward bias.

The Entry (Value Zone): Look for a "Long" entry when the price dips to touch either the Red Lower Channel or a marked "S" (Support) label.

The Exit (Statistical Extreme): The primary target is the Blue Upper Channel. If the trend weakens (LRC Lower crosses EMA 20), the strategy closes the position to avoid major drawdowns.

## Source Code

````pine
//@version=6
strategy("Qing LRC + S/R + EMA (Trend Cross Logic)", overlay=true, 
     initial_capital=1000, 
     default_qty_type=strategy.cash, 
     default_qty_value=1000, 
     commission_type=strategy.commission.percent, 
     commission_value=1.0, process_orders_on_close = true,calc_on_every_tick = true) 

// ────────────────────────────────────────────────
// 1. LRC Calculations
// ────────────────────────────────────────────────
lrcLen    = input.int(20, "LRC Length", group="LRC Settings")
lrcUpper  = input.float(1.618, "Upper Multiplier", group="LRC Settings")
lrcLower  = input.float(1.618, "Lower Multiplier", group="LRC Settings")

lrcMid = ta.linreg(close, lrcLen, 0)
lrcDev = ta.stdev(close, lrcLen)

upperChannel = lrcMid + (lrcUpper * lrcDev)
lowerChannel = lrcMid - (lrcLower * lrcDev)

// ────────────────────────────────────────────────
// 2. EMA 20 & Trend Filter Logic
// ────────────────────────────────────────────────
ema20 = ta.ema(close, 20)
plot(ema20, color=color.new(color.yellow, 30), linewidth=2, title="Trend EMA")

// TAUGHT LOGIC: LRC Upper vs EMA 20
lrcUpperAboveEma = upperChannel > ema20
lrcLowerBelowEma = lowerChannel < ema20

// LRC Direction for Visuals
lrcSlope = lrcMid - lrcMid[1]
isUp     = lrcSlope > 0
lrcColor = lrcUpperAboveEma ? color.new(color.blue, 0) : color.new(color.red, 0)

// Plot LRC
plot(lrcMid, color=color.new(color.white, 70), title="LRC Mid")
p1 = plot(upperChannel, color=color.blue, linewidth=1, title="LRC Upper")
p2 = plot(lowerChannel, color=color.red, linewidth=1, title="LRC Lower")
fill(p1, p2, color=lrcUpperAboveEma ? color.new(color.blue, 95) : color.new(color.red, 95))

// ────────────────────────────────────────────────
// 3. Support & Resistance Tags (Confirmation)
// ────────────────────────────────────────────────
leftB   = input.int(5, "Pivot Left Bars")
rightB  = input.int(5, "Pivot Right Bars")

ph = ta.pivothigh(high, leftB, rightB)
pl = ta.pivotlow(low, leftB, rightB)

var float lastS = na
if not na(pl)
    lastS := pl

// Display Labels (Ideal Display)
if not na(ph)
    label.new(bar_index[rightB], ph, "R", style=label.style_label_down, color=color.new(color.red, 40), textcolor=color.white, size=size.small)
    line.new(bar_index[rightB], ph, bar_index + 30, ph, color=color.new(color.red, 70), width=1, extend=extend.right)

if not na(pl)
    label.new(bar_index[rightB], pl, "S", style=label.style_label_up, color=color.new(color.green, 40), textcolor=color.white, size=size.small)
    line.new(bar_index[rightB], pl, bar_index + 30, pl, color=color.new(color.green, 70), width=1, extend=extend.right)

// ────────────────────────────────────────────────
// 4. Refined Buy & Sell Logic
// ────────────────────────────────────────────────

// BUY RULE: 
// 1. LRC Upper is above or crossing above EMA 20
// 2. Price is hitting the value zone (Lower LRC or Support)
nearSupport = low <= lastS * 1.02
buyCondition = lrcUpperAboveEma and (low <= lowerChannel or nearSupport) and close > open

if (buyCondition and strategy.opentrades == 0)
    strategy.entry("Long", strategy.long, comment="LRC Upper > EMA")

// SELL/EXIT RULE:
// 1. LRC Lower is below or stays below EMA 20 (Trend Weakness)
// 2. OR Price hits the Upper Channel (Target Reached)
exitCondition = lrcLowerBelowEma or high >= upperChannel

if (exitCondition and strategy.position_size > 0)
    strategy.close("Long", comment="Trend Exit")

// ────────────────────────────────────────────────
// 5. Visual Polish
// ────────────────────────────────────────────────
bgcolor(lrcUpperAboveEma ? color.new(color.green, 98) : color.new(color.red, 98))

// Directional Arrow on the EMA/LRC Cross
plotshape(ta.crossover(upperChannel, ema20), "Trend Bullish Cross", shape.triangleup, location.belowbar, color.blue, size=size.tiny)
plotshape(ta.crossunder(lowerChannel, ema20), "Trend Bearish Cross", shape.triangledown, location.abovebar, color.red, size=size.tiny)
````
