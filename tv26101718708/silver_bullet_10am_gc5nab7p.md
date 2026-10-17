# Silver Bullet 10AM

- url: https://www.tradingview.com/script/Gc5Nab7p-Silver-Bullet-10AM/
- type: indicator
- pine_id: PUB;f81c369dcdc54978b7f4880162a04498
- version: 1.0

## Description

You're working with ICT session concepts here, so I'm reading "this" as a list of intraday chart reference lines/zones built around the AM Silver Bullet. Here's a fuller set that pairs with the 10 AM SB window and your 10:00 open line:
Opening price lines (bias references)

Midnight open (00:00 EST) — daily directional bias; above = bullish lean, below = bearish
8:30 AM open — news/data release reference
9:30 AM open — equities/index cash open
10:00 AM open — your Silver Bullet anchor line

Silver Bullet windows (other two)

London SB: 3:00–4:00 AM EST
AM SB: 10:00–11:00 AM EST (your area)
PM SB: 2:00–3:00 PM EST

Macro windows (the tighter algo runs)

9:50–10:10 AM (overlaps your SB entry zone)
10:50–11:10 AM
Useful for spotting the FVG/expansion inside the SB hour

Liquidity & range levels

Previous Day High/Low (PDH / PDL)
Previous Week High/Low (PWH / PWL)
Asian range high/low
London range high/low
Session equilibrium (50% of the dealing range)

Gaps

New Day Opening Gap (NDOG)
New Week Opening Gap (NWOG)
Open FVGs inside the SB window — your actual entry trigger

A couple of things would let me tailor this better. Is this for an MNQ chart specifically, and what exactly are you adding to?

A written trading-plan / notes doc
A TradingView Pine Script indicator (drawing these lines automatically)
A checklist for your SB setups

If it's the Pine Script route, I can write you an indicator that auto-plots the 10 AM open, shades the SB window, and marks the macros. Just point me at which one.

## Source Code

````pine
//@version=6
indicator("10AM Open Michael Has Big Lips", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------- Inputs -----------------
hourTarget   = input.int(10, "Target hour (24h clock)", minval = 0, maxval = 23, group = "Time")
minuteTarget = input.int(0,  "Target minute",           minval = 0, maxval = 59, group = "Time")
tz           = input.string("America/New_York", "Timezone", group = "Time", tooltip = "The line marks the candle open at this time, in this timezone. America/New_York = US market time.")
lookback     = input.int(10, "Trading days to show", minval = 1, maxval = 60, group = "Time")

currentCol = input.color(color.green, "Current day line color", group = "Style")
pastCol    = input.color(color.red,   "Past day line color",    group = "Style")
wid        = input.int(1, "Line width", minval = 1, maxval = 5, group = "Style")
styleStr   = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = "Style")
showLbl    = input.bool(true, "Show price labels", group = "Style")
extendNow  = input.bool(true, "Extend every line to the current bar", group = "Style", tooltip = "On: all lines run to the present. Off: each line stops at the next day's 10 AM (one day wide).")

lnStyle = styleStr == "Dashed" ? line.style_dashed : styleStr == "Dotted" ? line.style_dotted : line.style_solid

// ----------------- Detect the 10 AM candle -----------------
// True on the first bar at or after the target time each session.
// The not-na guard keeps the bool from going na on the first bar (required in v6).
mins      = hour(time, tz) * 60 + minute(time, tz)
targetMin = hourTarget * 60 + minuteTarget
isTarget  = not na(mins[1]) and mins >= targetMin and mins[1] < targetMin

// Date identifier (in the chosen timezone) used to tell "today" from past days.
dayId = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

// ----------------- Storage -----------------
var array<line>  lines    = array.new<line>()
var array<label> labels   = array.new<label>()
var array<int>   lineDays = array.new<int>()

// ----------------- Build lines -----------------
if isTarget
    // If not extending to now, freeze the previous line here so it spans exactly one day.
    if not extendNow and array.size(lines) > 0
        line.set_x2(array.last(lines), bar_index)

    newLine = line.new(bar_index, open, bar_index, open, color = pastCol, width = wid, style = lnStyle)
    array.push(lines, newLine)
    array.push(lineDays, dayId)

    if showLbl
        newLbl = label.new(bar_index, open, text = str.tostring(open, format.mintick), style = label.style_label_left, color = color.new(pastCol, 80), textcolor = pastCol, size = size.small)
        array.push(labels, newLbl)

    // Keep only the most recent `lookback` days.
    if array.size(lines) > lookback
        line.delete(array.shift(lines))
        array.shift(lineDays)
        if showLbl and array.size(labels) > 0
            label.delete(array.shift(labels))

// ----------------- Color + extend on the last bar -----------------
if barstate.islast and array.size(lines) > 0
    todayId = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
    for i = 0 to array.size(lines) - 1
        ln = array.get(lines, i)
        isCurrent = array.get(lineDays, i) == todayId
        c = isCurrent ? currentCol : pastCol
        line.set_color(ln, c)
        if extendNow or i == array.size(lines) - 1
            line.set_x2(ln, bar_index)
        if showLbl and array.size(labels) == array.size(lines)
            lb = array.get(labels, i)
            label.set_color(lb, color.new(c, 80))
            label.set_textcolor(lb, c)

// ----------------- Reminder if used on the wrong timeframe -----------------
if barstate.islast and not timeframe.isintraday
    label.new(bar_index, high, text = "Use an intraday timeframe (e.g. 1-15 min)", style = label.style_label_down, color = color.red, textcolor = color.white, size = size.normal)
````
