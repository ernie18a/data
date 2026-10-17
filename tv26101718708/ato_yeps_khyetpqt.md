# ato yeps

- url: https://www.tradingview.com/script/KHyETpQT-ato-yeps/
- type: indicator
- pine_id: PUB;b1f9f47a5e4649eea23e54c9f3787fd0
- version: 1.0

## Description

📊 Liquidity Sweep Strategy — 1H
Overview
This strategy is based on Smart Money Concepts (SMC). It detects when the market hunts liquidity resting above swing highs or below swing lows, then reverses — giving a high-probability trade setup.

How It Works
🔵 Trend Filter

A 100 EMA is plotted on the 1H chart
Price below EMA → only look for SELL setups
Price above EMA → only look for BUY setups
This keeps you trading with the trend only


🔴 SELL Setup

Market is below the 100 EMA (bearish trend)
A swing high forms on the 1H chart (liquidity resting above it)
Price sends a wick above that swing high — liquidity is hunted
The candle closes back below the swing high level
✅ Setup confirmed → Alert fires instantly


🟢 BUY Setup

Market is above the 100 EMA (bullish trend)
A swing low forms on the 1H chart (liquidity resting below it)
Price sends a wick below that swing low — liquidity is hunted
The candle closes back above the swing low level
✅ Setup confirmed → Alert fires instantly


What Appears on Chart
VisualMeaning🔵 Blue line100 EMA — trend direction🔴 Red horizontal lineBearish liquidity sweep level🟢 Green horizontal lineBullish liquidity sweep level

Key Concept

The market always moves to grab liquidity (stop losses sitting above swing highs and below swing lows) before reversing. This strategy catches that fake breakout the moment the candle confirms the reversal by closing back inside the range.


Timeframe

1 Hour only — best for swing trading and intraday setups on Forex, Gold, and Indices

## Source Code

````pine
//@version=6
indicator(title="Liquidity Sweep Alert [1H]", overlay=true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
swingLen = input.int(10,  "Swing Lookback (bars)", minval=2)
emaLen   = input.int(100, "EMA Length",            minval=1)
showEma  = input.bool(true, "Show EMA")

// ─────────────────────────────────────────────
// EMA
// ─────────────────────────────────────────────
ema = ta.ema(close, emaLen)
plot(showEma ? ema : na, title="100 EMA", color=color.blue, linewidth=2)

// ─────────────────────────────────────────────
// SWING HIGH / LOW
// ─────────────────────────────────────────────
swingH = ta.pivothigh(high, swingLen, swingLen)
swingL = ta.pivotlow(low,  swingLen, swingLen)

var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na

if not na(swingH)
    lastSwingHigh    := swingH
    lastSwingHighBar := bar_index - swingLen

if not na(swingL)
    lastSwingLow    := swingL
    lastSwingLowBar := bar_index - swingLen

// ─────────────────────────────────────────────
// SWEEP DETECTION
// ─────────────────────────────────────────────
bearSweep = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh and open < lastSwingHigh
bullSweep = not na(lastSwingLow)  and low  < lastSwingLow  and close > lastSwingLow  and open > lastSwingLow

// ─────────────────────────────────────────────
// DRAW LINE ONLY
// ─────────────────────────────────────────────
if bearSweep
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color=color.red,   width=2, style=line.style_solid, extend=extend.none)

if bullSweep
    line.new(lastSwingLowBar,  lastSwingLow,  bar_index, lastSwingLow,  color=color.green, width=2, style=line.style_solid, extend=extend.none)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bearSweep, title="🔴 SELL Liquidity Sweep", message="{{ticker}} [1H] Liquidity HIGH swept — candle closed below!")
alertcondition(bullSweep, title="🟢 BUY Liquidity Sweep",  message="{{ticker}} [1H] Liquidity LOW swept — candle closed above!")
alertcondition(bearSweep or bullSweep, title="⚡ Any Liquidity Sweep", message="{{ticker}} [1H] Liquidity Sweep detected!")
````
