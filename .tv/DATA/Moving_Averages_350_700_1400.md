<!-- tradingview-pine-id: PUB;8e90664757954db2a15400e83e04db45 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Averages (350, 700, 1400)

Source: https://www.tradingview.com/script/ULTjY0oh-Moving-Averages-350-700-1400/

## Description

====================================================================
Universal Macro Moving Averages (350, 700, 1400)

A lightweight, clutter-free indicator designed to identify multi-year 
macro trends, structural support/resistance, and market cycle floors.

KEY FEATURES:
- Clean UI: Simple toggle switch and color selector per line.
- SMA/EMA Toggle: Switch between Simple and Exponential MAs.
- Macro Focus: Tracks 350, 700, and 1400 period lengths.

PERIOD LOGIC (1 Week = 5 Daily Trading Days):
- 350 Period  (70 Weeks / ~1.4 Years): Primary trend direction.
- 700 Period  (140 Weeks / ~2.8 Years): Major market cycle value zone.
- 1400 Period (280 Weeks / ~5.5 Years): Generational macro floor.
====================================================================

---

## Source Code

````pine
//@version=6
indicator("Moving Averages (350, 700, 1400)", overlay = true, timeframe = "", timeframe_gaps = true)

// ==========================================
// SETTINGS UI (Clean: Toggle + Color per MA)
// ==========================================
maType = input.string("SMA", "MA Type", options = ["SMA", "EMA"])

// MA 1 Toggle & Color (350)
show1  = input.bool(true, "MA 1 (350)", inline = "ma1")
col1   = input.color(#2196F3, "", inline = "ma1")

// MA 2 Toggle & Color (700)
show2  = input.bool(true, "MA 2 (700)", inline = "ma2")
col2   = input.color(#E91E63, "", inline = "ma2")

// MA 3 Toggle & Color (1400)
show3  = input.bool(true, "MA 3 (1400)", inline = "ma3")
col3   = input.color(#9C27B0, "", inline = "ma3")

// ==========================================
// UNIVERSAL HARDCODED LENGTHS
// ==========================================
int len1 = 350
int len2 = 700
int len3 = 1400

// ==========================================
// CALCULATIONS & PLOTS
// ==========================================
f_ma(source, length, type) =>
    type == "EMA" ? ta.ema(source, length) : ta.sma(source, length)

ma1 = f_ma(close, len1, maType)
ma2 = f_ma(close, len2, maType)
ma3 = f_ma(close, len3, maType)

plot(show1 ? ma1 : na, title = "MA 350",  color = col1, linewidth = 2)
plot(show2 ? ma2 : na, title = "MA 700",  color = col2, linewidth = 2)
plot(show3 ? ma3 : na, title = "MA 1400", color = col3, linewidth = 2)
````
