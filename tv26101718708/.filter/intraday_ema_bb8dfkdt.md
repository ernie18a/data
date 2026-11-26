# Intraday EMA

- url: https://www.tradingview.com/script/bB8dFKDT-Intraday-EMA/
- type: indicator
- pine_id: PUB;ac0cf91c888349ab826d3b74e57bd28c
- version: 2.0

## Description

Short Description

Dynamic EMA Envelope based on recent hourly high/low structure with optional single EMA mode.

Full Publishing Description
Intraday EMA Envelope

Intraday EMA Envelope is a lightweight trend-following indicator designed for intraday traders who want adaptive EMA-based structure visualization.

The script derives EMA reference lengths from recent hourly market behavior using highest and lowest price offsets over a configurable lookback period.

Features

• Adaptive EMA logic based on hourly market structure
• Optional Single EMA mode
• EMA Envelope visualization with fill zone
• Smooth EMA calculations for cleaner trend tracking
• Real-time EMA length display table
• Mutually exclusive display modes for clean chart appearance

How It Works

The indicator scans hourly candles over the selected lookback period and calculates:

Highest high offset
Lowest low offset

These offsets are converted into dynamic EMA reference lengths.

Two smoothed EMAs are then plotted:

Upper EMA
Lower EMA

Users can choose between:

Single EMA mode
EMA Envelope mode

Both modes are intentionally made mutually exclusive to avoid chart clutter.

Inputs

• Lookback Days
Controls the hourly historical range used for EMA calculations.

• Show Single EMA
Displays only one smoothed EMA.

• Show EMA Envelope
Displays the EMA channel/envelope with fill.

Best Usage

This indicator works best for:

Intraday trend identification
Pullback trading
Dynamic support/resistance tracking
Trend continuation setups

## Source Code

````pine
//@version=6
indicator("Intraday EMA", overlay=true)

//====================================================
// INPUTS
//====================================================
show_single_ema  = input.bool(false, "Show Single EMA")
show_ema_envelop = input.bool(true, "Show EMA Envelope")

// Make both mutually exclusive
singleEMA  = show_single_ema and not show_ema_envelop
emaEnvelop = show_ema_envelop and not show_single_ema

//====================================================
// SETTINGS
//====================================================
lookbackDays = input.int(3, "Lookback Days")

//====================================================
// HOURLY DATA
//====================================================
hourlyHighOffset = request.security(
     syminfo.tickerid,
     "60",
     ta.highestbars(high, lookbackDays * 24))

hourlyLowOffset = request.security(
     syminfo.tickerid,
     "60",
     ta.lowestbars(low, lookbackDays * 24))

hourlyHighestPrice = request.security(
     syminfo.tickerid,
     "60",
     ta.highest(high, lookbackDays * 24))

hourlyLowestPrice = request.security(
     syminfo.tickerid,
     "60",
     ta.lowest(low, lookbackDays * 24))

//====================================================
// LENGTHS
//====================================================
length1 = math.max(math.abs(hourlyHighOffset), 1)
length2 = math.max(math.abs(hourlyLowOffset), 1)

//====================================================
// MAXIMUM LENGTH
//====================================================
maxLen = math.max(length1, length2)

//====================================================
// EMA INPUTS
//====================================================
emaLen1 = input.int(59, "EMA Length1")
emaLen2 = input.int(59, "EMA Length2")

//====================================================
// EMA CALCULATIONS
//====================================================
emaPlot1 = ta.ema(close, emaLen1)
emaPlot2 = ta.ema(close, emaLen2)

smoothEMA1 = ta.ema(emaPlot1, 33)
smoothEMA2 = ta.ema(emaPlot2, 33)

colE = color.rgb(100, 70, 151, 51)

//====================================================
// SINGLE EMA
//====================================================
plot(singleEMA ? smoothEMA1 : na,
     color=color.blue,
     linewidth=2,
     title="Single EMA")

//====================================================
// EMA ENVELOPE
//====================================================
p1 = plot(emaEnvelop ? smoothEMA1 : na,
     color=colE,
     linewidth=1,
     title="EMA Envelope Upper")

p2 = plot(emaEnvelop ? smoothEMA2 : na,
     color=colE,
     linewidth=1,
     title="EMA Envelope Lower")

fill(p1, p2, color=colE)

//====================================================

// two ema confluence =====================================


//────────────────────────────────────
// INPUTS
//────────────────────────────────────
cycle1    = emaLen1
cycle2    = emaLen2
tolerance = input.int(1, "Near Match Tolerance", minval=0)

//────────────────────────────────────
// GCD FUNCTION
//────────────────────────────────────
gcd_func(a, b) =>
    int x = a
    int y = b
    while y != 0
        temp = y
        y := x % y
        x := temp
    x

//────────────────────────────────────
// LCM FUNCTION
//────────────────────────────────────
lcm_func(a, b) =>
    int((a * b) / gcd_func(a, b))

//────────────────────────────────────
// CALCULATE LCM
//────────────────────────────────────
lcm12 = lcm_func(cycle1, cycle2)

//────────────────────────────────────
// RESET BAR COUNT AT START OF MONTH
//────────────────────────────────────
isNewMonth = ta.change(month(time)) != 0

var int barCount = 0
barCount := isNewMonth ? 0 : barCount + 1

//────────────────────────────────────
// REMAINDERS
//────────────────────────────────────
r1 = barCount % cycle1
r2 = barCount % cycle2

//────────────────────────────────────
// EXACT MATCH
//────────────────────────────────────
exactMatch = barCount > 0 and (barCount % lcm12 == 0)

//────────────────────────────────────
// NEAR MATCH
//────────────────────────────────────
maxR = math.max(r1, r2)
minR = math.min(r1, r2)

nearMatch = not exactMatch and ((maxR - minR) <= tolerance)

//────────────────────────────────────
// STORE ONLY LATEST VERTICAL LINE
//────────────────────────────────────
var line lastCycleLine = na
var line lastCycleLine1 = na

if exactMatch
    if not na(lastCycleLine)
        line.delete(lastCycleLine)

    lastCycleLine := line.new(
         bar_index,
         high ,
         last_bar_index+1,
         high ,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.blue,
         width = 1)

     

if exactMatch
    if not na(lastCycleLine1)
        line.delete(lastCycleLine1)

    lastCycleLine1 := line.new(
         bar_index,
         low ,
         last_bar_index+1,
         low ,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.blue,
         width = 1)


//====================================================
var table t = table.new(position.top_center, 3, 4, border_width=1)
colC = color.rgb(33, 58, 168)
if barstate.islast
    table.cell(t, 0, 0, "Set EMA Length1",
         bgcolor=color.rgb(0, 0, 0),
         text_color=colC)

    table.cell(t, 1, 0, str.tostring(length1),
         bgcolor=color.rgb(0, 0, 0),
         text_color=colC)

    table.cell(t, 0, 1, "Set EMA Length2",
         bgcolor=color.rgb(0, 0, 0),
         text_color=colC)

    table.cell(t, 1, 1, str.tostring(length2),
         bgcolor=color.rgb(0, 0, 0),
         text_color=colC)
    //table.cell(t, 0, 2, "Exact Match",
    //     bgcolor=color.rgb(0, 0, 0),
    //     text_color=colC)

    //table.cell(t, 1, 2, exactMatch ? "YES" : "NO",
    //     bgcolor=color.rgb(0, 0, 0),
    //     text_color=colC)
````
