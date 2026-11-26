# First Candle Zones PRO+

- url: https://www.tradingview.com/script/vsIN2Ey3-First-Candle-Zones-PRO/
- type: indicator
- pine_id: PUB;83952b3ad3b34b6dad7a96f07b953457
- version: 1.0

## Description

This script uses the **first candle of the selected timeframe** as the market’s opening reference range.
It calculates:

\text{Range} = \text{High} - \text{Low}

Then it divides that range into:

* 0
* 0.25
* 0.50
* 0.75
* 1.00 levels

These levels represent:

* support/resistance,
* equilibrium,
* momentum zones,
* and liquidity areas.

The script creates:

* **Main Box** → Opening battle zone between buyers and sellers
* **Upper Box** → Bullish expansion target
* **Lower Box** → Bearish expansion target

Psychologically:

* Inside main box = indecision/balance
* Above first high = bullish acceptance
* Below first low = bearish weakness

The midpoint (0.50) acts as fair value:

Midpoint = High+Low/2

Professional traders use this type of structure to identify:

* opening range behavior,
* breakout strength,
* liquidity traps,
* and volatility expansion.

In simple terms, the script converts the first candle into a full intraday market map.

## Source Code

````pine
//@version=5
indicator("First Candle Zones PRO+", overlay = true, max_boxes_count = 50)

// ===== INPUT =====
tfOption = input.string("5", "First Candle Timeframe",
 options = ["1", "5", "15", "30", "60", "240", "D"])

// ===== TOGGLES =====
showUpper = input.bool(true, "Show Upper Box")
showLower = input.bool(true, "Show Lower Box")

// ===== BOX COLORS =====
mainBoxColor  = input.color(color.new(color.blue, 85),  "Main Box Fill")
upperBoxColor = input.color(color.new(color.green, 85), "Upper Box Fill")
lowerBoxColor = input.color(color.new(color.red, 85),   "Lower Box Fill")

borderMain  = input.color(color.blue,  "Main Border")
borderUpper = input.color(color.green, "Upper Border")
borderLower = input.color(color.red,   "Lower Border")

// ===== MAIN LEVEL COLORS =====
m100 = input.color(color.red,    "Main 1")
m75  = input.color(color.orange, "Main 0.75")
m50  = input.color(color.yellow, "Main 0.5")
m25  = input.color(color.green,  "Main 0.25")
m0   = input.color(color.blue,   "Main 0")

// ===== UPPER LEVEL COLORS =====
u100 = input.color(color.red,    "Upper 1")
u75  = input.color(color.orange, "Upper 0.75")
u50  = input.color(color.yellow, "Upper 0.5")
u25  = input.color(color.green,  "Upper 0.25")
u0   = input.color(color.blue,   "Upper 0")

// ===== LOWER LEVEL COLORS =====
l100 = input.color(color.red,    "Lower 1")
l75  = input.color(color.orange, "Lower 0.75")
l50  = input.color(color.yellow, "Lower 0.5")
l25  = input.color(color.green,  "Lower 0.25")
l0   = input.color(color.blue,   "Lower 0")

// ===== VAR =====
var bool drawn = false

// ===== RESET DAILY =====
if ta.change(time("D"))
    drawn := false

// ===== FIRST CANDLE DATA =====
firstHigh = request.security(syminfo.tickerid, tfOption, high, lookahead=barmerge.lookahead_on)
firstLow  = request.security(syminfo.tickerid, tfOption, low,  lookahead=barmerge.lookahead_on)
firstTime = request.security(syminfo.tickerid, tfOption, time, lookahead=barmerge.lookahead_on)

isFirstBar = ta.change(firstTime)

if isFirstBar and not drawn

    rng = firstHigh - firstLow
    endTime = timestamp(year, month, dayofmonth, 15, 30)

    // ================= MAIN BOX =================
    box.new(firstTime, firstHigh, endTime, firstLow,
         xloc=xloc.bar_time, bgcolor=mainBoxColor, border_color=borderMain)

    ml0   = firstLow
    ml25  = firstLow + rng * 0.25
    ml50  = firstLow + rng * 0.50
    ml75  = firstLow + rng * 0.75
    ml100 = firstHigh

    line.new(firstTime, ml100, endTime, ml100, xloc=xloc.bar_time, color=m100)
    line.new(firstTime, ml75,  endTime, ml75,  xloc=xloc.bar_time, color=m75)
    line.new(firstTime, ml50,  endTime, ml50,  xloc=xloc.bar_time, color=m50)
    line.new(firstTime, ml25,  endTime, ml25,  xloc=xloc.bar_time, color=m25)
    line.new(firstTime, ml0,   endTime, ml0,   xloc=xloc.bar_time, color=m0)

    // ================= UPPER BOX =================
    if showUpper
        upperLow  = firstHigh
        upperHigh = firstHigh + rng

        box.new(firstTime, upperHigh, endTime, upperLow,
             xloc=xloc.bar_time, bgcolor=upperBoxColor, border_color=borderUpper)

        ul0   = upperLow
        ul25  = upperLow + rng * 0.25
        ul50  = upperLow + rng * 0.50
        ul75  = upperLow + rng * 0.75
        ul100 = upperHigh

        line.new(firstTime, ul100, endTime, ul100, xloc=xloc.bar_time, color=u100)
        line.new(firstTime, ul75,  endTime, ul75,  xloc=xloc.bar_time, color=u75)
        line.new(firstTime, ul50,  endTime, ul50,  xloc=xloc.bar_time, color=u50)
        line.new(firstTime, ul25,  endTime, ul25,  xloc=xloc.bar_time, color=u25)
        line.new(firstTime, ul0,   endTime, ul0,   xloc=xloc.bar_time, color=u0)

    // ================= LOWER BOX =================
    if showLower
        lowerHigh = firstLow
        lowerLow  = firstLow - rng

        box.new(firstTime, lowerHigh, endTime, lowerLow,
             xloc=xloc.bar_time, bgcolor=lowerBoxColor, border_color=borderLower)

        ll0   = lowerLow
        ll25  = lowerLow + rng * 0.25
        ll50  = lowerLow + rng * 0.50
        ll75  = lowerLow + rng * 0.75
        ll100 = lowerHigh

        line.new(firstTime, ll100, endTime, ll100, xloc=xloc.bar_time, color=l100)
        line.new(firstTime, ll75,  endTime, ll75,  xloc=xloc.bar_time, color=l75)
        line.new(firstTime, ll50,  endTime, ll50,  xloc=xloc.bar_time, color=l50)
        line.new(firstTime, ll25,  endTime, ll25,  xloc=xloc.bar_time, color=l25)
        line.new(firstTime, ll0,   endTime, ll0,   xloc=xloc.bar_time, color=l0)

    drawn := true
````
