# 10:00 AM opening 

- url: https://www.tradingview.com/script/4ItDmoat/
- type: indicator
- pine_id: PUB;bd72507a8ca44d3eb4d78cc199861d0d
- version: 1.0

## Description

his indicator automatically plots two critical institutional key levels for every trading day, based on the opening prices of the 00:00 (midnight) and 10:00 New York candles. These levels are widely used by institutional traders and price-action strategists to identify daily structure, potential support/resistance, and breakout targets.

Features:
00:00 NY Open Level — Horizontal Ray starting at the midnight New York candle open
10:00 NY Open Level — Horizontal Ray starting at the 10:00 AM New York candle open
Both rays extend to the right, remaining visible for the entire session
Fully customizable colors, line width, line style, and labels
Optional text labels for quick visual identification
Lightweight and performant — ideal for all timeframes
Why these levels matter: The midnight NY open marks the true start of the institutional trading day, while the 10:00 NY open represents the moment when major liquidity and volatility enter the market. Together, these two prices form a foundational range that many professional traders use to gauge bias, set entries, and manage risk.

Best used on: Forex, Indices, Futures, and any market with significant New York session influence.

## Source Code

````pine
//@version=6
// =============================================================================
// Powell / Jaxon Blocks & Ranges – Key Levels (00:00 & 10:00 New York)
// =============================================================================
indicator("open Ranges Kirill", overlay = true, max_lines_count = 500)

g_l1 = "Level 1 – 00:00 New York"
g_l2 = "Level 2 – 10:00 New York"

// ---------- 00:00 NY ----------------------------------------------------------
show00     = input.bool(true,  "00:00-Linie anzeigen",  group = g_l1)
col00      = input.color(color.new(color.aqua, 0), "Farbe", group = g_l1)
width00    = input.int(2,      "Breite", minval = 1, maxval = 5, group = g_l1)
style00    = input.string("solid", "Stil", options = ["solid", "dashed", "dotted"], group = g_l1)

// ---------- 10:00 NY ----------------------------------------------------------
show10     = input.bool(true,  "10:00-Linie anzeigen",  group = g_l2)
col10      = input.color(color.new(color.orange, 0), "Farbe", group = g_l2)
width10    = input.int(2,      "Breite", minval = 1, maxval = 5, group = g_l2)
style10    = input.string("solid", "Stil", options = ["solid", "dashed", "dotted"], group = g_l2)

// ---------- Helper ------------------------------------------------------------
toStyle(_s) =>
    _s == "dashed" ? line.style_dashed : _s == "dotted" ? line.style_dotted : line.style_solid

// ---------- Persistente Referenzen -------------------------------------------
var line ray00      = na
var line ray10      = na
var int  currentDay = na

// ---------- New Yorker Zeit ---------------------------------------------------
nyYear  = year(time,       "America/New_York")
nyMonth = month(time,      "America/New_York")
nyDay   = dayofmonth(time, "America/New_York")
nyHour  = hour(time,       "America/New_York")
nyMin   = minute(time,     "America/New_York")
dayKey  = nyYear * 10000 + nyMonth * 100 + nyDay

// ---------- Neuer Tag → alte Linien löschen ----------------------------------
if na(currentDay) or dayKey != currentDay
    if not na(ray00)
        line.delete(ray00)
        ray00 := na
    if not na(ray10)
        line.delete(ray10)
        ray10 := na
    currentDay := dayKey

// ---------- 00:00 NY ----------------------------------------------------------
if show00 and nyHour == 0 and nyMin == 0 and na(ray00)
    ray00 := line.new(
         x1     = bar_index,
         y1     = open,
         x2     = bar_index + 1,
         y2     = open,
         extend = extend.right,
         color  = col00,
         width  = width00,
         style  = toStyle(style00))

// ---------- 10:00 NY ----------------------------------------------------------
if show10 and nyHour == 10 and nyMin == 0 and na(ray10)
    ray10 := line.new(
         x1     = bar_index,
         y1     = open,
         x2     = bar_index + 1,
         y2     = open,
         extend = extend.right,
         color  = col10,
         width  = width10,
         style  = toStyle(style10))
````
