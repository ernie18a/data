# Kill Zone + Asia Session Range Indicator_by inner_peacefx

- url: https://www.tradingview.com/script/PWfU5dBE-Kill-Zone-Asia-Session-Range-Indicator-by-inner-peacefx/
- type: indicator
- pine_id: PUB;5b123e5ae3de4e9d881dece182e92962
- version: 1.0

## Description

The Kill Zone + Asia Session Range Indicator is designed for traders who focus on session-based price action, liquidity movements, and intraday volatility.

This indicator automatically marks key kill zones using vertical dotted lines at:

* 02:00
* 05:00
* 08:00
* 12:00
  (UTC-4 Timezone)

In addition, it highlights the full Asia Session range from 18:00 to 00:00 UTC-4 using a clean session box. After each session closes, the indicator automatically calculates and displays the total Asia Session range in pips directly below the session.

### Features

* Automatic Kill Zone Marking
* Asia Session Box Visualization
* Daily Asia Session Pip Range Calculation
* Clean and Lightweight Design
* Fully Customizable Colors and Line Width
* Works Across Multiple Timeframes
* Historical Session Marking for up to 1 Year

This tool is ideal for:

* ICT Traders
* SMC Traders
* Forex Scalpers
* Liquidity-Based Trading Strategies
* Session Range Analysis

The indicator helps traders quickly identify important intraday timing windows and measure Asia Session volatility for better trade planning and execution.

## Source Code

````pine
//@version=6
indicator("Kill Zone + Asia Session + Midnight Open", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ======================================================
// TIME ZONE SETTINGS
// ======================================================

timezoneInput = input.string("UTC-4", "Timezone",
 options = [
     "UTC-12","UTC-11","UTC-10","UTC-9","UTC-8",
     "UTC-7","UTC-6","UTC-5","UTC-4","UTC-3",
     "UTC-2","UTC-1","UTC+0","UTC+1","UTC+2",
     "UTC+3","UTC+4","UTC+5","UTC+6","UTC+7",
     "UTC+8","UTC+9","UTC+10","UTC+11","UTC+12"
 ])

// ======================================================
// KILL ZONE SETTINGS
// ======================================================

enableKillZones = input.bool(true, "Enable Kill Zones")

// USER EDITABLE KILL ZONE TIMES
killZone1 = input.int(2, "Kill Zone 1 Hour", minval=0, maxval=23)
killZone2 = input.int(5, "Kill Zone 2 Hour", minval=0, maxval=23)
killZone3 = input.int(8, "Kill Zone 3 Hour", minval=0, maxval=23)
killZone4 = input.int(12, "Kill Zone 4 Hour", minval=0, maxval=23)

// ENABLE/DISABLE EACH KILL ZONE
showKillZone1 = input.bool(true, "Show Kill Zone 1")
showKillZone2 = input.bool(true, "Show Kill Zone 2")
showKillZone3 = input.bool(true, "Show Kill Zone 3")
showKillZone4 = input.bool(true, "Show Kill Zone 4")

// KILL ZONE STYLE
killZoneColor = input.color(color.red, "Kill Zone Color")
killZoneWidth = input.int(1, "Kill Zone Width", minval=1, maxval=5)

// ======================================================
// MIDNIGHT OPEN LINE SETTINGS
// ======================================================

showMidnightLine = input.bool(true, "Show 00:00 Open Line")

midnightLineColor = input.color(color.red, "00:00 Open Line Color")
midnightLineWidth = input.int(1, "00:00 Open Line Width", minval=1, maxval=5)

// ======================================================
// ASIA SESSION SETTINGS
// ======================================================

showAsiaSession = input.bool(true, "Show Asia Session")
showAsiaPips = input.bool(true, "Show Asia Session Pips")

asiaBoxColor = input.color(color.new(color.blue, 88), "Asia Session Box")
asiaBorderColor = input.color(color.blue, "Asia Session Border")
asiaTextColor = input.color(color.white, "Asia Pip Text")

// ======================================================
// CURRENT TIME
// ======================================================

h = hour(time, timezoneInput)
m = minute(time, timezoneInput)

// ======================================================
// KILL ZONE CONDITIONS
// ======================================================

isKillZone1 = h == killZone1 and m == 0
isKillZone2 = h == killZone2 and m == 0
isKillZone3 = h == killZone3 and m == 0
isKillZone4 = h == killZone4 and m == 0

// ======================================================
// DRAW KILL ZONE LINE
// ======================================================

drawKillZoneLine() =>

    lineTop = high + (ta.atr(14) * 1.2)
    lineBottom = low - (ta.atr(14) * 1.2)

    line.new(
         x1=bar_index,
         y1=lineBottom,
         x2=bar_index,
         y2=lineTop,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=killZoneColor,
         width=killZoneWidth,
         style=line.style_dotted
     )

// ======================================================
// PLOT KILL ZONE LINES
// ======================================================

if enableKillZones

    if showKillZone1 and isKillZone1
        drawKillZoneLine()

    if showKillZone2 and isKillZone2
        drawKillZoneLine()

    if showKillZone3 and isKillZone3
        drawKillZoneLine()

    if showKillZone4 and isKillZone4
        drawKillZoneLine()

// ======================================================
// ASIA SESSION (18:00 → 00:00)
// ======================================================

asiaSession = not na(time(timeframe.period, "1800-0000", timezoneInput))

var float asiaHigh = na
var float asiaLow = na
var int asiaStartBar = na

var box asiaBox = na

newSession = asiaSession and not asiaSession[1]

// ======================================================
// START ASIA SESSION
// ======================================================

if showAsiaSession and newSession

    asiaHigh := high
    asiaLow := low
    asiaStartBar := bar_index

    asiaBox := box.new(
         left=bar_index,
         top=high,
         right=bar_index,
         bottom=low,
         bgcolor=asiaBoxColor,
         border_color=asiaBorderColor
     )

// ======================================================
// UPDATE ASIA SESSION
// ======================================================

if showAsiaSession and asiaSession

    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)

// ======================================================
// ASIA SESSION PIPS
// ======================================================

sessionEnded = not asiaSession and asiaSession[1]

if showAsiaSession and showAsiaPips and sessionEnded

    pipValue = syminfo.mintick * 10
    asiaPips = (asiaHigh - asiaLow) / pipValue

    midBar = math.floor((asiaStartBar + bar_index) / 2)

    label.new(
         x=midBar,
         y=asiaLow,
         text=str.tostring(math.round(asiaPips)) + " Pips",
         style=label.style_label_up,
         size=size.small,
         color=color.black,
         textcolor=asiaTextColor
     )

// ======================================================
// 00:00 OPEN HORIZONTAL LINE → 16:30
// ======================================================

var line midnightLine = na
var float midnightOpen = na
var int midnightStartBar = na

isMidnight = h == 0 and m == 0

if showMidnightLine

    // CAPTURE MIDNIGHT OPEN
    if isMidnight

        midnightOpen := open
        midnightStartBar := bar_index

        midnightLine := line.new(
             x1=midnightStartBar,
             y1=midnightOpen,
             x2=midnightStartBar,
             y2=midnightOpen,
             color=midnightLineColor,
             width=midnightLineWidth,
             style=line.style_solid
         )

    // EXTEND UNTIL 16:30
    if not na(midnightLine)

        currentMinutes = h * 60 + m
        endMinutes = 16 * 60 + 30

        if currentMinutes <= endMinutes

            line.set_x2(midnightLine, bar_index)
            line.set_y2(midnightLine, midnightOpen)
````
