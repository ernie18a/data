# SuperTrend Lite

- url: https://www.tradingview.com/script/WabfqLAz-SuperTrend-Lite/
- type: indicator
- pine_id: PUB;037769d6c8e947d9ba7082c902c9151f
- version: 1.0

## Description

Classic SuperTrend overlay with trend-based coloring and BUY/SELL entry labels.

▲ BUY = SuperTrend flipped bullish (go long)
▼ SELL = SuperTrend flipped bearish (go short / exit)
Green fill = bullish zone. Red fill = bearish zone.

Fixed settings: ATR(10), multiplier 3.0 — the most commonly used SuperTrend parameters.


This is the Lite version. The Pro version adds:

• ATR Trailing Stop with ratchet mechanism — dynamic stop-loss that never moves against you
• Stop-hit & re-entry detection — know when your stop is taken and when to get back in
• Real-time info table (trend direction, stop distance %, ATR value)
• Phone push alerts — 4 alert conditions (entry, stop-hit, re-entry, trend change)
• Adjustable ATR periods, multipliers, line styles, display modes
• 2-bar confirmation filter to reduce whipsaws

→ Read the full review at theindicatorlab.com/reviews/supertrend-atr-trailing-stop/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © glycdigital

//@version=6
// ═══════════════════════════════════════════════════
// SuperTrend Lite v1.0 — FREE
// Built by The Indicator Lab
// ═══════════════════════════════════════════════════
//
// Classic SuperTrend with trend-based coloring and
// entry labels. Lite version — no trailing stop,
// no alerts, no info table.
//
// ╔═════════════════════════════════════════════════════════════════════╗
// ║  READ THE PRO VERSION REVIEW:                                       ║
// ║  https://theindicatorlab.com/reviews/supertrend-atr-trailing-stop/  ║
// ║                                                                     ║
// ║  • ATR Trailing Stop with ratchet mechanism                         ║
// ║  • Stop-hit & re-entry detection                                    ║
// ║  • Phone push alerts via TradingView                                ║
// ║  • Real-time info table (trend, stop dist %)                        ║
// ║  • Full customization (ATR, multipliers, styles)                    ║
// ║  • $15 one-time • Lifetime access                                   ║
// ╚═════════════════════════════════════════════════════════════════════╝
//
// How to use:
// 1. Add to chart (overlay mode)
// 2. ▲ BUY = SuperTrend flipped bullish → go long
// 3. ▼ SELL = SuperTrend flipped bearish → go short / exit
// 4. Green fill = bullish zone, Red fill = bearish zone

indicator("SuperTrend Lite", "ST Lite", true, format=format.price, max_bars_back=500)

// ═══════════════════════════════════════════════════
// CONSTANTS (fixed — upgrade to Pro for customization)
// ═══════════════════════════════════════════════════
//
// (Pro: adjustable ATR period, multiplier, line style,
//  ATR Trailing Stop with independent settings,
//  confirmation filter, re-entry detection)

int   stPeriod     = 10
float stMult       = 3.0
color stBullColor  = #00bcd4
color stBearColor  = #e91e63

// ═══════════════════════════════════════════════════
// SUPERTREND CALCULATION
// ═══════════════════════════════════════════════════

float stATR = ta.atr(stPeriod)
float stSrc = hl2

float stUpperBand = stSrc + stMult * stATR
float stLowerBand = stSrc - stMult * stATR

var float stUpper = na
var float stLower = na
var bool  stTrendUp = true

// Track previous band levels
stUpper := close[1] > stUpper[1] ? math.max(stUpperBand, stUpper[1]) : stUpperBand
stLower := close[1] < stLower[1] ? math.min(stLowerBand, stLower[1]) : stLowerBand

// Determine trend
stTrendUp := close > stLower[1] ? true : close < stUpper[1] ? false : stTrendUp[1]

// SuperTrend line value
float stLine = stTrendUp ? stLower : stUpper

// Trend flip detection
bool flippedUp   = stTrendUp and not stTrendUp[1]
bool flippedDown = not stTrendUp and stTrendUp[1]

// ═══════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════

// SuperTrend Line
color stColor = stTrendUp ? stBullColor : stBearColor
plot(stLine, "SuperTrend", color=stColor, linewidth=2)

// Fill Bands (SuperTrend to close price)
color fillBull = color.new(stBullColor, 85)
color fillBear = color.new(stBearColor, 85)
stPlot   = plot(stLine, display=display.none)
clsPlot  = plot(close, display=display.none)
fill(stPlot, clsPlot, stTrendUp ? fillBull : fillBear, "Trend Fill", true)

// Entry Labels
plotshape(flippedUp,   "Buy",  style=shape.labelup,   location=location.belowbar,
     color=color.new(#00e676, 30), textcolor=#00e676, text="▲ BUY", size=size.small)
plotshape(flippedDown, "Sell", style=shape.labeldown, location=location.abovebar,
     color=color.new(#ff1744, 30), textcolor=#ff1744, text="▼ SELL", size=size.small)

// ═══════════════════════════════════════════════════
// ║  theindicatorlab.com/lab-originals
// ║  Upgrade for ATR Trailing Stop + alerts + info table
// ═══════════════════════════════════════════════════
````
