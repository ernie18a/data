# Ghost Mitigation Strategy

- url: https://www.tradingview.com/script/ZPAjijMJ-Ghost-Mitigation-Strategy/
- type: indicator
- pine_id: PUB;abbde392814541efbda5840159eceeda
- version: 1.0

## Description

simple indigator works in strong trend made with chat gpt just for testing test your on before ude

## Source Code

````pine
//@version=5
indicator("Ghost Mitigation Strategy", overlay=true)

// --- Settings ---
lookback = input.int(10, "Structure Lookback")
show_ghost_zones = input.bool(true, "Show Unmitigated Ghost Zones")

// --- Ghost Logic (Market Structure) ---
hi = ta.highest(high, lookback)
lo = ta.lowest(low, lookback)

var float ghost_top = na
var float ghost_bot = na
var bool active_ghost = false

// Detect Bullish Market Structure Break (MSB)
bool msb_bull = ta.crossover(close, hi[1])
// Detect Bearish Market Structure Break (MSB)
bool msb_bear = ta.crossunder(close, lo[1])

// --- Zone Identification ---
// A "Ghost" is created at the previous low/high that led to a break
if msb_bull
    ghost_top := lo[1]
    ghost_bot := lo[lookback]
    active_ghost := true

if msb_bear
    ghost_top := hi[lookback]
    ghost_bot := hi[1]
    active_ghost := true

// --- Plotting the Ghost Zones ---
// These boxes will stay on the chart until the price "mitigates" (touches) them
var box ghost_box = na
if (msb_bull or msb_bear) and show_ghost_zones
    ghost_box := box.new(left=bar_index, top=ghost_top, right=bar_index + 20, bottom=ghost_bot, 
             bgcolor=msb_bull ? color.new(color.blue, 85) : color.new(color.orange, 85), 
             border_color=na, extend=extend.right)

// Remove box once price returns to the "Ghost" area (Mitigation)
if low <= ghost_top and high >= ghost_bot
    active_ghost := false

// --- Visual Signals ---
plotshape(msb_bull, "BOS Bullish", shape.triangleup, location.belowbar, color.green, size=size.small, text="GHOST UP")
plotshape(msb_bear, "BOS Bearish", shape.triangledown, location.abovebar, color.red, size=size.small, text="GHOST DOWN")
````
