# ICT Venom Core - Simple NY Setup

- url: https://www.tradingview.com/script/f4KJrGDx-ICT-Venom-Core-Simple-NY-Setup/
- type: indicator
- pine_id: PUB;de5809c79af54eabbd34662fa3fa4dda
- version: 1.0

## Description

ICT Venom Core - Simple NY Setup

This indicator is designed to simplify the ICT Venom trading model by focusing only on the most important New York session levels.

Features:
• Marks the 8:00 AM, 9:30 AM, and 11:30 AM New York session times.
• Automatically tracks the High and Low of the 8:00–9:30 AM range.
• Extends the range High and Low levels until 11:30 AM.
• Identifies Balance Price Range (BPR) opportunities during the 9:30–11:30 AM trading window.
• Optimized for 1-minute, 3-minute, and 5-minute charts.
• Clean and lightweight design with no unnecessary signals or distractions.

This tool is intended to help traders focus on key liquidity levels and BPR-based setups during the New York morning session.

## Source Code

````pine
//@version=6
indicator("ICT Venom Core - Simple NY Setup", overlay=true, max_boxes_count=20, max_lines_count=20, max_labels_count=20)

//=====================================================
// TIME / TF FILTER
//=====================================================
nyTz    = "America/New_York"
validTF  = timeframe.isminutes and (timeframe.multiplier == 1 or timeframe.multiplier == 3 or timeframe.multiplier == 5)

inRange  = validTF and not na(time(timeframe.period, "0800-0930", nyTz))   // 8:00 to 9:30
inEntry  = validTF and not na(time(timeframe.period, "0930-1130", nyTz))   // 9:30 to 11:30

is0800   = validTF and hour(time, nyTz) == 8  and minute(time, nyTz) == 0
is0930   = validTF and hour(time, nyTz) == 9  and minute(time, nyTz) == 30
is1130   = validTF and hour(time, nyTz) == 11 and minute(time, nyTz) == 30

//=====================================================
// SESSION MARKER LINES
//=====================================================
if is0800
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=color.gray, style=line.style_dashed, width=1)
    label.new(bar_index, high, "8:00", style=label.style_label_down, color=color.gray, textcolor=color.white)

if is0930
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=color.blue, style=line.style_dashed, width=1)
    label.new(bar_index, high, "9:30", style=label.style_label_down, color=color.blue, textcolor=color.white)

if is1130
    line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=color.orange, style=line.style_dashed, width=1)
    label.new(bar_index, high, "11:30", style=label.style_label_down, color=color.orange, textcolor=color.white)

//=====================================================
// 8:00 TO 9:30 RANGE HIGH / LOW
//=====================================================
var float rangeHigh = na
var float rangeLow  = na
var box   rangeBox  = na
var line  highLine  = na
var line  lowLine   = na

newRange = inRange and not inRange[1]

if newRange
    rangeHigh := high
    rangeLow  := low
    rangeBox  := box.new(left=bar_index, top=high, right=bar_index, bottom=low,
         bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 30))
    highLine := line.new(bar_index, high, bar_index, high, xloc=xloc.bar_index, color=color.lime, width=2)
    lowLine  := line.new(bar_index, low,  bar_index, low,  xloc=xloc.bar_index, color=color.red,  width=2)

if inRange
    rangeHigh := math.max(nz(rangeHigh, high), high)
    rangeLow  := math.min(nz(rangeLow, low), low)

    if not na(rangeBox)
        box.set_right(rangeBox, bar_index)
        box.set_top(rangeBox, rangeHigh)
        box.set_bottom(rangeBox, rangeLow)

    if not na(highLine)
        line.set_x2(highLine, bar_index)
        line.set_y1(highLine, rangeHigh)
        line.set_y2(highLine, rangeHigh)

    if not na(lowLine)
        line.set_x2(lowLine, bar_index)
        line.set_y1(lowLine, rangeLow)
        line.set_y2(lowLine, rangeLow)

// keep the lines running until 11:30
if inEntry
    if not na(highLine)
        line.set_x2(highLine, bar_index)
    if not na(lowLine)
        line.set_x2(lowLine, bar_index)

//=====================================================
// SIMPLE BPR (ONLY 9:30 TO 11:30)
// BPR = overlap of latest bullish FVG and bearish FVG
//=====================================================
bullFVG = inEntry and low > high[2]
bearFVG = inEntry and high < low[2]

var float bullTop = na
var float bullBottom = na
var float bearTop = na
var float bearBottom = na
var box   bprBox = na

if bullFVG
    bullTop := low
    bullBottom := high[2]

if bearFVG
    bearTop := low[2]
    bearBottom := high

bprExists = inEntry and not na(bullTop) and not na(bullBottom) and not na(bearTop) and not na(bearBottom) and math.max(bullBottom, bearBottom) < math.min(bullTop, bearTop)

bprTop = math.min(bullTop, bearTop)
bprBot = math.max(bullBottom, bearBottom)

if bprExists
    if na(bprBox)
        bprBox := box.new(left=bar_index, top=bprTop, right=bar_index, bottom=bprBot,
             bgcolor=color.new(color.yellow, 85), border_color=color.yellow)
        label.new(bar_index, bprTop, "BPR", style=label.style_label_down, color=color.yellow, textcolor=color.black)
    else
        box.set_right(bprBox, bar_index)
        box.set_top(bprBox, bprTop)
        box.set_bottom(bprBox, bprBot)

//=====================================================
// STOP WORKING OUTSIDE THE SETUP WINDOW
//=====================================================
````
