# Sloping Channels and Grid Drag/Drop

- url: https://www.tradingview.com/script/Z9PEdFrX-Sloping-Channels-and-Grid-Drag-Drop/
- type: indicator
- pine_id: PUB;44f473d8a8a4409283f2e2d9e350f77d
- version: 1.0

## Description

[b]Sloping Channels and Grid Drag/Drop[/b]
This indicator plots a set of parallel, sloped projection lines anchored to a single point in time that you choose. Instead of the usual flat horizontal channel, the lines slope forward at a rate you define — either as a fixed percentage per day or a custom slope — so the channel tracks a directional bias rather than a static range.
How it works

Pick an anchor point with the time input. The script locks onto the price at that bar and builds everything from there.
Choose a slope (0–1, with a flip-to-negative option) to set the angle of the projection.
Set a band type — Percent, ATR, or Fixed value — to control the spacing between the base line and the outer bands. Five bands are plotted on each side.
Optionally enable Grid mode to overlay a second, mirrored set of lines (opposite slope) shifted by a multiple of the band width. This is particularly useful for visualizing symmetry between uptrend and downtrend structure around the same anchor.
A vertical marker line highlights your anchor point, and a small info table in the corner shows current band width and active slope.

[b]Why sloped lines instead of flat channels[/b]
Flat horizontal channels don't account for underlying drift. Forex pairs in particular tend to respond well to predetermined, consistent slope angles rather than freshly-fitted trendlines — a fixed daily-rate slope often tracks price behavior more reliably than manually redrawing a channel each session. By anchoring a slope to a chosen reference point, this tool lets you project that directional expectation forward and see, in real time, how price behaves relative to it.

[b]Suggested slope settings[/b]
For forex, slope values around 0.15, 0.5, and 1 (% per day) tend to work well as starting points. Stocks typically require different values given their different volatility and drift characteristics — treat the presets as a forex-tuned starting point, not a universal default.
Easier than a standard channel
Most channel tools require you to set three points (two to define the trendline, one for the offset) and manually redraw as price evolves. This indicator only needs one anchor point — the slope, spacing, and projection are handled automatically from there.
Notes

Lines are drawn using line.new() with extend.both, so once anchored, they persist and project infinitely in both directions — no repainting from redraws each bar.
Designed for intraday use but the timeframe multiplier scales the slope correctly across timeframes.
Grid shift factor lets you offset the secondary set by up to 2x the band width, without needing a second anchor.

## Source Code

````pine
//@version=6
indicator("Sloping Channels and Grid Drag/Drop", overlay=true, max_lines_count=500)

// ───────────── Inputs ─────────────
input_time     = input.time(timestamp("2025-09-10T00:00:00"), "Select Time", confirm=true)


// ───────────── Slope Settings ─────────────
slope1_input   = input.float(1, "Slope 1 (% per day)", step=0.1, group="Slope Settings")
slope2_input   = input.float(0.5, "Slope 2 (% per day)", step=0.1, group="Slope Settings")
slope3_input   = input.float(0.15, "Slope 3 (% per day)", step=0.01, group="Slope Settings")
slope_selector = input.string("Slope 1", "Select Active Slope", 
     options=["Slope 0", "Slope 1", "Slope 2", "Slope 3"], group="Slope Settings")
slope_minus    = input.bool(false, "Flip to negative slope", group="Slope Settings")
grid         = input.bool(false,"Show(Grid)")
gridshift    = input.int(0,"Grid shiftfactor -2 to 2",minval=-2,maxval=2,step=1)
// ───────────── Band Settings ─────────────
Ctype        = input.string("Fixed", title="Band Type", options=["Perc","ATR","Fixed"], group="Band Settings")
perc         = input.float(0.1, title="Percent", group="Band Settings")
fix          = input.float(20, "Fixed Value", group="Band Settings")
atr_length   = input.int(200, "ATR Length", minval=1, group="Band Settings")
atr_multiple = input.float(2.0, "ATR Multiple", minval=0, step=1, group="Band Settings")
tfatr        = input.timeframe("5", "Timeframe for ATR", group="Band Settings")

// ───────────── Timeframe Multiplier ─────────────
getTimeframeMultiplier() =>
    tf = timeframe.period
    tf_minutes = if str.contains(tf, "D")
        str.tonumber(str.replace(tf, "D", "")) * 1440
    else if str.contains(tf, "W")
        str.tonumber(str.replace(tf, "W", "")) * 10080
    else if str.contains(tf, "M")
        str.tonumber(str.replace(tf, "M", "")) * 43200
    else if str.contains(tf, "H") or str.contains(tf, "h")
        str.tonumber(str.replace(str.replace(tf, "H", ""), "h", "")) * 60
    else if str.contains(tf, "m")
        str.tonumber(str.replace(tf, "m", ""))
    else
        str.tonumber(tf)
    bars_per_day = 1440 / tf_minutes
    1 / bars_per_day

tf_multiplier = getTimeframeMultiplier()

// ───────────── Anchor Price & Bar ─────────────

var int A_BarIndex=na
var float A_Price=na
A_BarIndex:=na(A_BarIndex) and time == input_time? bar_index:A_BarIndex
A_Price    := na(A_Price) and time == input_time? close : A_Price


// ───────────── Selected Slope ─────────────
sign = slope_minus ? -1 : 1
selected_slope = switch slope_selector
    "Slope 1" => sign * slope1_input * A_Price * tf_multiplier / 100
    "Slope 2" => sign * slope2_input * A_Price * tf_multiplier / 100
    "Slope 3" => sign * slope3_input * A_Price * tf_multiplier / 100
    "Slope 0" => 0
    => 0

// ───────────── ATR / Band Value ─────────────
var float atr_value =na
atr_value := na(atr_value)?Ctype == "Perc" and time == input_time? close * perc / 100 :
             Ctype == "ATR" and time == input_time ? request.security(syminfo.tickerid, tfatr, ta.atr(atr_length)) * atr_multiple :
             Ctype == "Fixed" and time == input_time ?fix * syminfo.mintick * 10:
             Ctype == "STDev" and time == input_time ?ta.stdev(close,atr_length) * atr_multiple:
             atr_value: atr_value

// ───────────── Compute bars since anchor ─────────────

// Only draw after anchor and within lookback
draw_line = bar_index>= A_BarIndex

// ───────────── Base Line ─────────────
base_line =  A_Price+ (-A_BarIndex+bar_index) * selected_slope 

// ───────────── Upper / Lower Bands ─────────────
upper1 =  base_line + atr_value * 1 
lower1 =  base_line - atr_value * 1 

upper2 =  base_line + atr_value * 2 
lower2 =  base_line - atr_value * 2 

upper3 =  base_line + atr_value * 3 
lower3 =  base_line - atr_value * 3 

upper4 =  base_line + atr_value * 4 
lower4 =  base_line - atr_value * 4 

upper5 =  base_line + atr_value * 5 
lower5 =  base_line - atr_value * 5 


// ───────────── Line Objects: Base & Bands (replaces plot) ─────────────
// Each line is created once at the anchor, then only its far endpoint (x2,y2)
// is updated every bar. extend=extend.both projects the same slope
// infinitely in both directions.

var line baseLine  = na
var line upperLine1 = na
var line lowerLine1 = na
var line upperLine2 = na
var line lowerLine2 = na
var line upperLine3 = na
var line lowerLine3 = na
var line upperLine4 = na
var line lowerLine4 = na
var line upperLine5 = na
var line lowerLine5 = na

if draw_line and not na(A_Price)
    // anchor-side values (base_line == A_Price at the anchor bar)
    if na(baseLine)
        baseLine   := line.new(A_BarIndex, A_Price,                bar_index, base_line, extend=extend.both, color=color.black, width=2)
        upperLine1 := line.new(A_BarIndex, A_Price + atr_value*1,  bar_index, upper1,    extend=extend.both, color=color.purple, width=1)
        lowerLine1 := line.new(A_BarIndex, A_Price - atr_value*1,  bar_index, lower1,    extend=extend.both, color=color.purple, width=1)
        upperLine2 := line.new(A_BarIndex, A_Price + atr_value*2,  bar_index, upper2,    extend=extend.both, color=color.red,    width=1)
        lowerLine2 := line.new(A_BarIndex, A_Price - atr_value*2,  bar_index, lower2,    extend=extend.both, color=color.red,    width=1)
        upperLine3 := line.new(A_BarIndex, A_Price + atr_value*3,  bar_index, upper3,    extend=extend.both, color=color.green,  width=1)
        lowerLine3 := line.new(A_BarIndex, A_Price - atr_value*3,  bar_index, lower3,    extend=extend.both, color=color.green,  width=1)
        upperLine4 := line.new(A_BarIndex, A_Price + atr_value*4,  bar_index, upper4,    extend=extend.both, color=color.gray,   width=1)
        lowerLine4 := line.new(A_BarIndex, A_Price - atr_value*4,  bar_index, lower4,    extend=extend.both, color=color.gray,   width=1)
        upperLine5 := line.new(A_BarIndex, A_Price + atr_value*5,  bar_index, upper5,    extend=extend.both, color=color.maroon, width=1)
        lowerLine5 := line.new(A_BarIndex, A_Price - atr_value*5,  bar_index, lower5,    extend=extend.both, color=color.maroon, width=1)
    else
        line.set_xy2(baseLine,   bar_index, base_line)
        line.set_xy2(upperLine1, bar_index, upper1)
        line.set_xy2(lowerLine1, bar_index, lower1)
        line.set_xy2(upperLine2, bar_index, upper2)
        line.set_xy2(lowerLine2, bar_index, lower2)
        line.set_xy2(upperLine3, bar_index, upper3)
        line.set_xy2(lowerLine3, bar_index, lower3)
        line.set_xy2(upperLine4, bar_index, upper4)
        line.set_xy2(lowerLine4, bar_index, lower4)
        line.set_xy2(upperLine5, bar_index, upper5)
        line.set_xy2(lowerLine5, bar_index, lower5)


// ───────────── Secondary (Shifted / Grid) Set ─────────────
var float shift=na
shift:= na(shift) and time == input_time? atr_value*5*gridshift:shift

Sbase_line = grid? A_Price+ (-A_BarIndex+bar_index) * -selected_slope +shift :na

Supper1 =  Sbase_line + atr_value * 1 
Slower1 =  Sbase_line - atr_value * 1 

Supper2 =  Sbase_line + atr_value * 2 
Slower2 =  Sbase_line - atr_value * 2 

Supper3 =  Sbase_line + atr_value * 3 
Slower3 =  Sbase_line - atr_value * 3 

Supper4 =  Sbase_line + atr_value * 4 
Slower4 =  Sbase_line - atr_value * 4 

Supper5 =  Sbase_line + atr_value * 5 
Slower5 =  Sbase_line - atr_value * 5 

var line SbaseLine   = na
var line SupperLine1 = na
var line SlowerLine1 = na
var line SupperLine2 = na
var line SlowerLine2 = na
var line SupperLine3 = na
var line SlowerLine3 = na
var line SupperLine4 = na
var line SlowerLine4 = na
var line SupperLine5 = na
var line SlowerLine5 = na

if grid and draw_line and not na(A_Price) and not na(Sbase_line)
    // anchor-side value for the shifted base is A_Price + shift (bars-since-anchor == 0 there)
    SA_base = A_Price + shift
    if na(SbaseLine)
        SbaseLine   := line.new(A_BarIndex, SA_base,               bar_index, Sbase_line, extend=extend.both, color=color.black, width=2)
        SupperLine1 := line.new(A_BarIndex, SA_base + atr_value*1, bar_index, Supper1,    extend=extend.both, color=color.purple, width=1)
        SlowerLine1 := line.new(A_BarIndex, SA_base - atr_value*1, bar_index, Slower1,    extend=extend.both, color=color.purple, width=1)
        SupperLine2 := line.new(A_BarIndex, SA_base + atr_value*2, bar_index, Supper2,    extend=extend.both, color=color.red,    width=1)
        SlowerLine2 := line.new(A_BarIndex, SA_base - atr_value*2, bar_index, Slower2,    extend=extend.both, color=color.red,    width=1)
        SupperLine3 := line.new(A_BarIndex, SA_base + atr_value*3, bar_index, Supper3,    extend=extend.both, color=color.green,  width=1)
        SlowerLine3 := line.new(A_BarIndex, SA_base - atr_value*3, bar_index, Slower3,    extend=extend.both, color=color.green,  width=1)
        SupperLine4 := line.new(A_BarIndex, SA_base + atr_value*4, bar_index, Supper4,    extend=extend.both, color=color.gray,   width=1)
        SlowerLine4 := line.new(A_BarIndex, SA_base - atr_value*4, bar_index, Slower4,    extend=extend.both, color=color.gray,   width=1)
        SupperLine5 := line.new(A_BarIndex, SA_base + atr_value*5, bar_index, Supper5,    extend=extend.both, color=color.maroon, width=1)
        SlowerLine5 := line.new(A_BarIndex, SA_base - atr_value*5, bar_index, Slower5,    extend=extend.both, color=color.maroon, width=1)
    else
        line.set_xy2(SbaseLine,   bar_index, Sbase_line)
        line.set_xy2(SupperLine1, bar_index, Supper1)
        line.set_xy2(SlowerLine1, bar_index, Slower1)
        line.set_xy2(SupperLine2, bar_index, Supper2)
        line.set_xy2(SlowerLine2, bar_index, Slower2)
        line.set_xy2(SupperLine3, bar_index, Supper3)
        line.set_xy2(SlowerLine3, bar_index, Slower3)
        line.set_xy2(SupperLine4, bar_index, Supper4)
        line.set_xy2(SlowerLine4, bar_index, Slower4)
        line.set_xy2(SupperLine5, bar_index, Supper5)
        line.set_xy2(SlowerLine5, bar_index, Slower5)


// ───────────── Vertical Marker ─────────────
var line tLine = na
if barstate.islast
    if na(tLine)
        tLine := line.new(x1=input_time, y1=low, x2=input_time, y2=high,
         xloc=xloc.bar_time, extend=extend.both, color=color.blue, style=line.style_solid, width=2)
    else
        line.set_xy1(tLine, input_time, low)
        line.set_xy2(tLine, input_time, high)

// ───────────── Info Table ─────────────
var table info_table = table.new(position.bottom_left, 1, 1,
     bgcolor=color.new(color.white, 80),
     border_width=1,
     border_color=color.new(color.gray, 50))

if barstate.islast and not na(A_Price)
    table.cell(info_table, 0, 0,
         text="Band width: "+str.tostring(atr_value,"#.####") + 
         " | Slope: " + slope_selector,
         text_color=color.black,
         text_size=size.normal)
````
