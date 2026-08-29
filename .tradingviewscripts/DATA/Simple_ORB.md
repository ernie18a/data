<!-- tradingview-pine-id: PUB;700c10c6424c4361b61221008e9a8f9c -->
<!-- tradingviewscripts-format: 1 -->
# Simple ORB

Source: https://www.tradingview.com/script/AjQPo79R-Simple-ORB/

## Description

Simple ORB

A clean and simple Opening Range Breakout indicator.

ORB Session: 09:30–09:45 New York time
Tracks the High & Low during the first 15 minutes of the US session
Lines update dynamically during the ORB period
At 09:45, the final High and Low are locked and extended horizontally
Show Previous Days: toggle historical ORB levels on/off
Fully customizable High/Low colors and line width
Automatically uses New York time (ET), including daylight saving time

No unnecessary features — just the 15-minute Opening Range High and Low.

---

## Source Code

````pine
//@version=6
indicator("Simple ORB", overlay=true, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

orbSession = input.session("0930-0945", "ORB Session")

showPreviousDays = input.bool(true, "Show Previous Days")

highColor = input.color(color.green, "ORB High Color")
lowColor  = input.color(color.red, "ORB Low Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

// US / New York time
string timezone = "America/New_York"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inORB = not na(time(timeframe.period, orbSession, timezone))

orbStarted  = inORB and not inORB[1]
orbFinished = not inORB and inORB[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float orbHigh = na
var float orbLow  = na

// Current day's lines
var line highLine = na
var line lowLine  = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09:30 — START ORB
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if orbStarted

    orbHigh := high
    orbLow  := low

    // If previous days are disabled,
    // delete the previous day's lines
    if not showPreviousDays

        if not na(highLine)
            line.delete(highLine)

        if not na(lowLine)
            line.delete(lowLine)

    // Create HIGH line
    highLine := line.new(
         x1=bar_index,
         y1=orbHigh,
         x2=bar_index,
         y2=orbHigh,
         color=highColor,
         width=lineWidth
         )

    // Create LOW line
    lowLine := line.new(
         x1=bar_index,
         y1=orbLow,
         x2=bar_index,
         y2=orbLow,
         color=lowColor,
         width=lineWidth
         )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09:30 → 09:45
// ORB IS STILL BUILDING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if inORB

    // Update High
    orbHigh := math.max(orbHigh, high)

    // Update Low
    orbLow := math.min(orbLow, low)

    // Move HIGH line
    if not na(highLine)
        line.set_y1(highLine, orbHigh)
        line.set_y2(highLine, orbHigh)
        line.set_x2(highLine, bar_index)

    // Move LOW line
    if not na(lowLine)
        line.set_y1(lowLine, orbLow)
        line.set_y2(lowLine, orbLow)
        line.set_x2(lowLine, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09:45 — ORB FINISHED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if orbFinished

    // Freeze final HIGH
    if not na(highLine)
        line.set_y1(highLine, orbHigh)
        line.set_y2(highLine, orbHigh)
        line.set_extend(highLine, extend.right)

    // Freeze final LOW
    if not na(lowLine)
        line.set_y1(lowLine, orbLow)
        line.set_y2(lowLine, orbLow)
        line.set_extend(lowLine, extend.right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LINE STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(highLine)
    line.set_color(highLine, highColor)
    line.set_width(highLine, lineWidth)

if not na(lowLine)
    line.set_color(lowLine, lowColor)
    line.set_width(lowLine, lineWidth)
````
