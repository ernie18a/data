# AMIN'S Master Layout - 9:31 EL DR Lock

- url: https://www.tradingview.com/script/Rr4KZFUN-AMIN-S-Master-Layout-9-31-EL-DR-Lock/
- type: indicator
- pine_id: PUB;3d9fb6db5d8448319adc06a8c0a220ba
- version: 1.0

## Description

Daily open from midnight NY time, London high/low, and NY silver pullet. This indicator makes it easier to read these important levels without the manual work

## Source Code

````pine
//@version=5
indicator("ICT Master Layout - 9:31 EL DR Lock", overlay=true, max_lines_count=500)

// --- 1. UNIFORM TIME LABELS ---
colorTime = color.new(color.black, 20)
colorYellow = color.yellow

vline(h, m, txt, col, isBullet) =>
    t = timestamp("America/New_York", year, month, dayofmonth, h, m)
    if time == t
        line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=isBullet ? colorYellow : col, style=line.style_dashed, width=1)
        if txt != ""
            label.new(bar_index, high, txt, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_none, textcolor=isBullet ? color.orange : col, size=size.small)

vline(0, 0,  "MIDNIGHT", colorTime, false) 
vline(6, 0,  "06:00", colorTime, false)  
vline(8, 30, "8:30", colorTime, false)
vline(9, 30, "EQUITY OPEN", colorTime, false) 
vline(10, 0, "BULLET", colorTime, true) 
vline(11, 0, "11:00", colorTime, false) 
vline(11, 45, "LUNCH", colorTime, false)

// --- 2. OPENING PRICE D1 & EQ D1 (MIDNIGHT TO 17:00) ---
var float midnightOpen = na
if hour(time, "America/New_York") == 0 and minute(time, "America/New_York") == 0
    midnightOpen := open

showD1 = hour(time, "America/New_York") < 17 or (hour(time, "America/New_York") == 17 and minute(time, "America/New_York") == 0)

plot(showD1 ? midnightOpen : na, "OPENING PRICE D1", color=color.blue, style=plot.style_linebr)

var float liveHi = na
var float liveLo = na
if hour(time, "America/New_York") == 0 and minute(time, "America/New_York") == 0
    liveHi := high
    liveLo := low
else if showD1
    liveHi := math.max(high, nz(liveHi, high))
    liveLo := math.min(low, nz(liveLo, low))

plot(showD1 ? (liveHi + liveLo)/2 : na, "EQ D1", color=color.gray, style=plot.style_linebr)

// FIXED: Only one label for Opening and EQ to prevent overlapping text
var label lblOpen = na
var label lblEqD1 = na
if barstate.islast and showD1
    label.delete(lblOpen)
    label.delete(lblEqD1)
    lblOpen := label.new(bar_index, midnightOpen, "OPENING PRICE D1", style=label.style_none, textcolor=color.blue, size=size.small)
    lblEqD1 := label.new(bar_index, (liveHi + liveLo)/2, "EQ D1", style=label.style_none, textcolor=color.gray, size=size.small)

// --- 3. LONDON HI/LO (TEXT IN LINE) ---
var float lonHi = na
var float lonLo = na
var int lonStart = na
if hour(time, "America/New_York") == 2 and minute(time, "America/New_York") == 0
    lonHi := high
    lonLo := low
    lonStart := bar_index
else if hour(time, "America/New_York") >= 2 and hour(time, "America/New_York") < 5
    lonHi := math.max(high, lonHi)
    lonLo := math.min(low, lonLo)

if hour(time, "America/New_York") == 6 and minute(time, "America/New_York") == 0
    line.new(lonStart, lonHi, bar_index, lonHi, color=color.black)
    line.new(lonStart, lonLo, bar_index, lonLo, color=color.black)
    label.new(math.round(math.avg(lonStart, bar_index)), lonHi, "London High", textcolor=color.black, style=label.style_none, size=size.tiny, yloc=yloc.price)
    label.new(math.round(math.avg(lonStart, bar_index)), lonLo, "London Low", textcolor=color.black, style=label.style_none, size=size.tiny, yloc=yloc.price)

// --- 4. THE DEALING RANGE (8:30-11:00) ---
var float drHi = na
var float drLo = na
var int drStartBar = na

// Capture High/Low from 8:30 to 9:30
if hour(time, "America/New_York") == 8 and minute(time, "America/New_York") == 30
    drHi := high
    drLo := low
    drStartBar := bar_index
else if (hour(time, "America/New_York") == 8 and minute(time, "America/New_York") > 30) or (hour(time, "America/New_York") == 9 and minute(time, "America/New_York") <= 30)
    drHi := math.max(high, nz(drHi, high))
    drLo := math.min(low, nz(drLo, low))

// At 9:31, Draw the DARK GRAY Rectangle and the STRAIGHT 50% line to 11:00
if hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 31
    float drEL = (drHi + drLo) / 2
    t_start = timestamp("America/New_York", year, month, dayofmonth, 8, 30)
    t_end   = timestamp("America/New_York", year, month, dayofmonth, 11, 0)
    t_930   = timestamp("America/New_York", year, month, dayofmonth, 9, 30)
    
    // Create the Box (Darker Gray)
    box.new(t_start, drHi, t_930, drLo, xloc=xloc.bar_time, bgcolor=color.new(color.gray, 20), border_color=na)
    
    // Create the Straight Line from 8:30 to 11:00
    line.new(t_start, drEL, t_end, drEL, xloc=xloc.bar_time, color=color.black, width=1)
    
    // Label the Line "EL DR"
    label.new(t_end, drEL, "EL DR", xloc=xloc.bar_time, style=label.style_none, textcolor=color.black, size=size.small, textalign=text.align_left)
````
