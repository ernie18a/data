# Dead Simple Reversal

- url: https://www.tradingview.com/script/j3DOB7FB-Dead-Simple-Reversal/
- type: indicator
- pine_id: PUB;39edc132eb264000a9f2b6c7f4b9cc64
- version: 1.0

## Description

This is the Pine Script port of the open source indicator [i]Dead Simple Reversal[/i] by [b]paidtofade[/b], originally created for Tradovate. All logic and settings are exactly the same as the original version. 

[b]─── How It Works ───[/b]

The indicator identifies potential reversal bars using three conditions checked on the prior and current candle, compared against rolling high/low windows at two lookback periods.

[b]Buy Signal[/b]
[list]
[*] Prior bar closed bearish; current bar closes bullish
[*] Current close is above the prior bar's open
[*] Any of the last 4 long-term lows is greater than the current near-term low
[/list]

[b]Sell Signal[/b]
[list]
[*] Prior bar closed bullish; current bar closes bearish
[*] Current close is below the prior bar's open
[*] Any of the last 4 long-term highs is less than the current near-term high
[/list]

The third condition in each case uses a 4-bar history window of the long-term rolling high/low to detect when the longer lookback has shifted compared to the shorter one.

[b]─── Settings ───[/b]
[list]
[*] [b]Near Term Period[/b] — Lookback for near-term high/low (default: 3)
[*] [b]Long Term Period[/b] — Lookback for long-term high/low (default: 50)
[*] [b]Up Color[/b] — Color for buy signals (default: cyan)
[*] [b]Down Color[/b] — Color for sell signals (default: cyan)
[*] [b]Opacity[/b] — Signal marker opacity, 0–100 (default: 100)
[/list]

## Source Code

````pine
// This source code is subject to the terms of the GNU General Public License v3.0
// © Converted from p2f - Dead Simple Reversal by @paidtofade (2020)
// Original concept: Dead Simple Reversal Points by BenTen at useThinkScript.com

//@version=6
indicator("Dead Simple Reversal", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
nearTerm  = input.int(3,   "Near Term Period",  minval=1)
longTerm  = input.int(50,  "Long Term Period",  minval=1)
upColor   = input.color(#00BCD4, "Up Color")
downColor = input.color(#00BCD4, "Down Color")
opacity   = input.int(100, "Opacity",           minval=0, maxval=100)

// ─── ATR (100-period Wilder / MMA) ────────────────────────────────────────────
atr = ta.rma(ta.tr(true), 100)

// ─── Near / Long Term Highs & Lows ────────────────────────────────────────────
nearHigh = ta.highest(high, nearTerm)
nearLow  = ta.lowest (low,  nearTerm)
longHigh = ta.highest(high, longTerm)
longLow  = ta.lowest (low,  longTerm)

// ─── Long-term High/Low history window (last 4 bars) ──────────────────────────
// Equivalent to longHighHistory / longLowHistory arrays of length 4
longHighH1 = longHigh[1]
longHighH2 = longHigh[2]
longHighH3 = longHigh[3]
longHighH4 = longHigh[4]

longLowH1 = longLow[1]
longLowH2 = longLow[2]
longLowH3 = longLow[3]
longLowH4 = longLow[4]

// ─── Conditions ───────────────────────────────────────────────────────────────
// Buy conditions
c1 = close[1] < open[1] and close > open          // prior bearish, current bullish
c2 = close > open[1]                               // close above prior open
// Any of the last-4-bar longLow values > nearLow  (long low "dropped", so near term has room)
c3 = longLowH1 > nearLow or longLowH2 > nearLow or longLowH3 > nearLow or longLowH4 > nearLow
buy = c1 and c2 and c3

// Sell conditions
c4 = close[1] > open[1] and close < open          // prior bullish, current bearish
c5 = close < open[1]                              // close below prior open
// Any of the last-4-bar longHigh values < nearHigh
c6 = longHighH1 < nearHigh or longHighH2 < nearHigh or longHighH3 < nearHigh or longHighH4 < nearHigh
sell = c4 and c5 and c6

// ─── Signal prices ─────────────────────────────────────────────────────────────
buyPrice  = buy  ? low  : na
sellPrice = sell ? high : na

// ─── Plot shapes (triangles above/below bar) ───────────────────────────────────
// The original draws a custom triangle using canvas API. In Pine Script the
// closest native equivalent is plotshape with triangle markers.

plotshape(
     buyPrice,
     title     = "Buy Signal",
     location  = location.belowbar,
     style     = shape.triangleup,
     color     = color.new(upColor, 100 - opacity),
     size      = size.small)

plotshape(
     sellPrice,
     title     = "Sell Signal",
     location  = location.abovebar,
     style     = shape.triangledown,
     color     = color.new(downColor, 100 - opacity),
     size      = size.small)

// ─── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy Signal",  "Dead Simple Reversal — Buy")
alertcondition(sell, "Sell Signal", "Dead Simple Reversal — Sell")
````
