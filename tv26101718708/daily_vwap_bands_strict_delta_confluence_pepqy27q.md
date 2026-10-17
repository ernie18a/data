# Daily VWAP Bands + Strict Delta Confluence

- url: https://www.tradingview.com/script/pepQy27Q-Daily-VWAP-Bands-Strict-Delta-Confluence/
- type: indicator
- pine_id: PUB;fbd40503b03a49d58868706914f60938
- version: 1.0

## Description

This indicator plots:

Daily resetting VWAP (yellow line)
±1 SD and ±2 SD bands around VWAP (teal/red)

It also generates strict buy/sell signals (green "BUY" and red "SELL" labels) based on strong confluence:

Buy Signal: Price touches the lower 2nd SD band, rejects strongly (bullish candle), and Cumulative Delta is positive and holding/improving.
Sell Signal: Price touches the upper 2nd SD band, rejects strongly (bearish candle), and Cumulative Delta is negative and holding/improving.

The signals are designed to be infrequent and higher-probability by requiring both extreme price deviation from VWAP and supporting order flow (delta strength).
In short: A mean-reversion tool that only shows potential reversal zones when both VWAP bands and Cumulative Volume Delta agree.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Scottt8
//@version=5
indicator("Daily VWAP Bands + Strict Delta Confluence", shorttitle="VWAP + Strict CVD", overlay=true)

// ── VWAP & Bands Inputs ────────────────────────
showVWAP   = input.bool(true,  "Show VWAP", group="VWAP Bands")
show1SD    = input.bool(true,  "Show ±1 SD Bands", group="VWAP Bands")
show2SD    = input.bool(true,  "Show ±2 SD Bands", group="VWAP Bands")
useHLC3    = input.bool(false, "Use (H+L+C)/3 for VWAP", group="VWAP Bands")

// ── Delta Inputs ───────────────────────────────
useBodyWeight     = input.bool(true,  "Use Body-Weighted Delta", group="Delta Settings")
resetOnNewSession = input.bool(true,  "Reset Cumulative Delta Daily", group="Delta Settings")
showSignals       = input.bool(true,  "Show Strict Buy/Sell Signals", group="Signals")

// ── Daily VWAP Calculation (resets every day) ──
newDay = ta.change(time("D"))

var float sumPV   = 0.0
var float sumVol  = 0.0
var float sumP2V  = 0.0

src = useHLC3 ? (high + low + close)/3 : close

if newDay
    sumPV  := src * volume
    sumVol := volume
    sumP2V := src * src * volume
else
    sumPV  += src * volume
    sumVol += volume
    sumP2V += src * src * volume

vwapVal   = sumVol > 0 ? sumPV / sumVol : na
variance  = sumVol > 0 ? (sumP2V / sumVol) - (vwapVal * vwapVal) : na
stdev     = variance > 0 ? math.sqrt(variance) : na

upper1 = vwapVal + stdev
lower1 = vwapVal - stdev
upper2 = vwapVal + 2 * stdev
lower2 = vwapVal - 2 * stdev

// ── Delta Calculation ──────────────────────────
float buyVol  = na
float sellVol = na

if useBodyWeight
    rangeSize = high - low
    buyVol    := rangeSize > 0 ? volume * (close - low) / rangeSize : volume * 0.5
    sellVol   := volume - buyVol
else
    buyVol    := close >= open ? volume : 0.0
    sellVol   := close <  open ? volume : 0.0

delta = buyVol - sellVol

var float cumDelta = 0.0
if resetOnNewSession and newDay
    cumDelta := 0.0

cumDelta += delta

// ── Stricter Buy / Sell Signal Logic ───────────
buyTouch   = low <= lower2
buyReject  = buyTouch and close > lower2 and close > open
buyDelta   = cumDelta > 0 and (cumDelta >= cumDelta[1])   // positive and not weakening
buySignal  = showSignals and buyReject and buyDelta and ta.change(buyTouch)

sellTouch   = high >= upper2
sellReject  = sellTouch and close < upper2 and close < open
sellDelta   = cumDelta < 0 and (cumDelta <= cumDelta[1])   // negative and not weakening
sellSignal  = showSignals and sellReject and sellDelta and ta.change(sellTouch)

// ── Plots ──────────────────────────────────────
plot(showVWAP ? vwapVal : na, title="VWAP",        color=color.yellow, linewidth=2)
plot(show1SD  ? upper1   : na, title="Upper 1SD", color=color.new(#26A69A, 0), linewidth=1)
plot(show1SD  ? lower1   : na, title="Lower 1SD", color=color.new(#EF5350, 0), linewidth=1)
plot(show2SD  ? upper2   : na, title="Upper 2SD", color=color.new(#26A69A, 60), linewidth=1)
plot(show2SD  ? lower2   : na, title="Lower 2SD", color=color.new(#EF5350, 60), linewidth=1)

// Light fills for visual clarity
fill(plot(vwapVal), plot(upper1), color=color.new(#26A69A, 92))
fill(plot(vwapVal), plot(lower1), color=color.new(#EF5350, 92))

// ── Strict Signals ─────────────────────────────
plotshape(buySignal,  title="Strict BUY",  location=location.belowbar, color=color.new(color.green, 0), style=shape.labelup,   text="BUY",  textcolor=color.white, size=size.normal)
plotshape(sellSignal, title="Strict SELL", location=location.abovebar, color=color.new(color.red, 0),   style=shape.labeldown, text="SELL", textcolor=color.white, size=size.normal)
//@version=6
plot(close)
````
