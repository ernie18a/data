#  SMC + Liquidity Sweep PRO

- url: https://www.tradingview.com/script/Gdf7mN9w-SMC-Liquidity-Sweep-PRO/
- type: indicator
- pine_id: PUB;01434e7bc0514018bb8e2fe3ac827b28
- version: 1.0

## Description

SMC + Liquidity Sweep PRO

A clean professional Smart Money Concepts (SMC) indicator built for traders who want high-quality institutional structure without chart clutter.

This script focuses only on the most important market behavior:

🟥 Major Liquidity Sweeps

Identifies strong stop hunts above key highs and below key lows where institutions often grab liquidity before reversing price direction.

🟨 Strong Break of Structure (BOS)

Detects powerful institutional breaks of major swing highs and lows, helping traders confirm true market direction instead of weak fake breakouts.

⚡ Clean Chart Design

No unnecessary FVG spam, no excessive signals, and no messy overlapping zones — only high-probability structure levels that matter.

🔍 Institutional Logic

Built using:

Major swing highs & lows
ATR-based strength filtering
Strong rejection confirmation
Clear structural break validation

This helps filter weak moves and focuses only on meaningful price action.

📈 Best Used For
Gold (XAUUSD)
Forex pairs
Indices (NAS100, US30)
Crypto
Intraday & Swing Trading
🎯 Ideal For Traders Who Want
Cleaner entries
Better liquidity understanding
Stronger market structure confirmation
Professional SMC analysis without indicator overload

This is not a signal-spamming indicator — it is designed for serious traders who value precision over quantity.

## Source Code

````pine
//@version=6
indicator(" SMC + Liquidity Sweep PRO", overlay=true, max_boxes_count=200, max_lines_count=200)

// =====================================================
// CLEAN VERSION
// Only:
// 🟥 Red = Major Liquidity Sweep
// 🟨 Yellow = Strong BOS
// No FVG
// Clean professional chart
// =====================================================

// ---------------- SETTINGS ----------------
showLiquidity = input.bool(true, "Show Major Liquidity Sweep")
showBOS       = input.bool(true, "Show Strong BOS")

swingLength   = input.int(10, "Major Swing Length", minval=5)
extendBars    = input.int(20, "Zone Extension", minval=5)

liqColor      = input.color(color.new(color.red, 82), "Liquidity Sweep Color")
bosColor      = input.color(color.yellow, "BOS Line Color")

atr = ta.atr(14)

// =====================================================
// MAJOR SWINGS ONLY
// =====================================================
ph = ta.pivothigh(high, swingLength, swingLength)
pl = ta.pivotlow(low, swingLength, swingLength)

var float majorHigh = na
var float majorLow  = na

if not na(ph)
    majorHigh := ph

if not na(pl)
    majorLow := pl

// =====================================================
// STRONG BOS ONLY
// Only clear institutional breaks
// =====================================================
strongBullBOS = not na(majorHigh) and close > majorHigh and (close - majorHigh) > atr * 0.30
strongBearBOS = not na(majorLow) and close < majorLow and (majorLow - close) > atr * 0.30

if showBOS and strongBullBOS
    line.new(
         x1 = bar_index - 2,
         y1 = majorHigh,
         x2 = bar_index + 5,
         y2 = majorHigh,
         color = bosColor,
         width = 2
     )

if showBOS and strongBearBOS
    line.new(
         x1 = bar_index - 2,
         y1 = majorLow,
         x2 = bar_index + 5,
         y2 = majorLow,
         color = bosColor,
         width = 2
     )

// =====================================================
// MAJOR LIQUIDITY SWEEP ONLY
// Only strong stop hunts
// =====================================================
highSweep = not na(majorHigh) and high > majorHigh and close < majorHigh and (high - majorHigh) > atr * 0.20
lowSweep  = not na(majorLow) and low < majorLow and close > majorLow and (majorLow - low) > atr * 0.20

if showLiquidity and highSweep
    box.new(
         left = bar_index - 1,
         right = bar_index + extendBars,
         top = high,
         bottom = majorHigh,
         bgcolor = liqColor,
         border_color = color.rgb(196, 20, 20, 15),
         border_width = 1
     )

if showLiquidity and lowSweep
    box.new(
         left = bar_index - 1,
         right = bar_index + extendBars,
         top = majorLow,
         bottom = low,
         bgcolor = liqColor,
         border_color = color.red,
         border_width = 1
     )
````
