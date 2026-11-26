# Prop Bruh - Clock | Candle | Countdown | ATR

- url: https://www.tradingview.com/script/II66dn8M-Prop-Bruh-Clock-Candle-Countdown-ATR/
- type: indicator
- pine_id: PUB;f75af29292f44ae9ba034695e2122913
- version: 1.0

## Description

Prop Bruh - Clock | Candle | Countdown | ATR

A compact all-in-one trading panel built for futures day traders who need critical information at a glance without cluttering the chart. Four essential tools stacked into a single, clean overlay.

What it does...
This panel combines a live New York clock, a bar close countdown, a current timeframe ATR, and a fixed 15-minute ATR into one customizable widget. Designed for traders who work across session boundaries (NY, London, Globex) and need to track volatility regimes in real time.

Features...
-Live NY Clock: 12-hour format with AM/PM, updates every second

-Bar Close Countdown: Shows minutes and seconds until the current bar closes, with a traffic light warning cascade (gray → yellow under 20s → red under 10s → flashing white under 1s) so you never miss a close

-Dual ATR Display: Current timeframe ATR on the left, fixed 15-minute ATR on the right, giving you both immediate volatility and broader regime context

-Session-Aware Volatility Coloring: The ATR row background shifts through four tiers (slate gray, soft blue, green, bright green) based on the 15m ATR value, with separate thresholds for NY, London, and Globex sessions

-Spike Marker: A 🔥 symbol appears in front of the current TF ATR value when it spikes above its own recent average by a customizable multiplier (default 1.25x), alerting you to volatility bursts as they happen

-Fully Customizable: Pick from five spike marker symbols (🔥 ⚡ ⭐ 🚨 💥), adjust panel size (Small, Medium, Large), position the widget in any of nine screen locations, and customize every color

How to use it...
Place the panel wherever works best on your chart. Glance at the countdown as bars approach close. Watch the ATR row background to understand the current volatility regime relative to the active session. Pay attention when the spike marker appears, it means the current timeframe just produced a meaningful volatility burst relative to its recent norm.

The design philosophy is disciplined, the panel stays grayscale during quiet conditions and only lights up when information demands attention. Your eye learns to filter it out until something actually matters.

Best for...
- Futures day traders (MES, ES, NQ, MNQ, GC, etc.)
-Anyone trading session-based strategies where volatility context matters
-Traders who want countdown awareness without giant timers eating chart real estate

Default session thresholds (15m ATR)...
-NY Session: Red below 35, Green above 55
-London Session: Red below 28, Green above 45
-Globex Session: Red below 22, Green above 35

All thresholds are fully adjustable to match your instrument and style.

Built for discipline. Built for speed. Built for the Prop Bruh framework.

## Source Code

````pine
//@version=6
indicator("Prop Bruh - Clock | Candle | Countdown | ATR", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
boxPosition = input.string("top_center", "Box Position", options=[
    "top_left", "top_center", "top_right",
    "middle_left", "middle_center", "middle_right",
    "bottom_left", "bottom_center", "bottom_right"
])

horizontalOffset = input.int(0, "Horizontal Offset", minval=0, maxval=20)
verticalOffset   = input.int(0, "Vertical Offset", minval=0, maxval=20)

panelSize = input.string("Large", "Overall Size", options=["Small", "Medium", "Large"])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOM COLORS — "Traffic Light" palette
// Neutral charcoal defaults, color only appears when info demands attention
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
clockBg      = input.color(color.rgb(26, 26, 26),    "Clock Background")
timerBg      = input.color(color.rgb(26, 26, 26),    "Timer Background")

clockColor   = input.color(color.rgb(229, 229, 229), "Clock Text Color")
timerColor   = input.color(color.rgb(229, 229, 229), "Timer Text Color")
atrTextColor = input.color(color.rgb(229, 229, 229), "ATR Text Color")

borderColor  = input.color(color.rgb(60, 60, 60),    "Border Color")

// Countdown warning cascade (classic traffic light: yellow → orange → red)
warnColor    = input.color(color.rgb(255, 200, 0),   "Warning Color (<20s, yellow)")
dangerColor  = input.color(color.rgb(220, 50, 50),   "Danger Color (<10s, red)")
flashBg      = input.color(color.white,              "Flash Background (<1s)")
flashText    = input.color(color.black,              "Flash Text (<1s)")

// ATR row palette — grayscale default, color only appears for meaningful regimes
atrRed       = input.color(color.rgb(90, 90, 95),    "ATR Low (slate gray)")
atrYellow    = input.color(color.rgb(100, 150, 200), "ATR Mid (soft blue)")
atrGreenLow  = input.color(color.rgb(60, 180, 100),  "ATR High (green)")
atrGreenHigh = input.color(color.rgb(0, 230, 118),   "ATR Max (bright green)")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showAtrBadge   = input.bool(true, "Show ATR Row")
atr1Len        = input.int(14, "ATR Current TF Length", minval=1, maxval=200)
atr15Len       = input.int(14, "ATR 15m Length", minval=1, maxval=200)
atrDecimals    = input.int(1, "ATR Decimals", minval=0, maxval=6)

showAtr1Spike  = input.bool(true, "Show Current TF ATR Spike Marker (🔥)")
atr1SpikeMaLen = input.int(10, "Spike MA Length", minval=1, maxval=100)
atr1SpikeMult  = input.float(1.25, "Spike Multiplier", minval=1.0, step=0.05, tooltip="Fires when current ATR > average × this value.\n1.25 = fires on genuine bursts (recommended).\n1.50 = only on major volatility explosions.\n1.10 = noisier, fires more often.")

spikeMarker    = input.string("🔥", "Spike Marker Symbol", options=["🔥", "⚡", "⭐", "🚨", "💥"], tooltip="Pick the symbol that catches your eye best.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION THRESHOLDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nyRedTh       = input.float(35.0, "NY Red Threshold (ATR 15)", minval=0)
nyGreenTh     = input.float(55.0, "NY Green Threshold (ATR 15)", minval=0)

londonRedTh   = input.float(28.0, "London Red Threshold (ATR 15)", minval=0)
londonGreenTh = input.float(45.0, "London Green Threshold (ATR 15)", minval=0)

globexRedTh   = input.float(22.0, "Globex Red Threshold (ATR 15)", minval=0)
globexGreenTh = input.float(35.0, "Globex Green Threshold (ATR 15)", minval=0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIZE MAP
// v1.4 rebalance: clock smaller, ATR bigger, all three match
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
clockSize = panelSize == "Small" ? size.tiny   : panelSize == "Medium" ? size.normal : size.large
timerSize = panelSize == "Small" ? size.small  : panelSize == "Medium" ? size.normal : size.large
atrSize   = panelSize == "Small" ? size.small  : panelSize == "Medium" ? size.normal : size.large

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos = boxPosition == "top_left" ? position.top_left :
      boxPosition == "top_center" ? position.top_center :
      boxPosition == "top_right" ? position.top_right :
      boxPosition == "middle_left" ? position.middle_left :
      boxPosition == "middle_center" ? position.middle_center :
      boxPosition == "middle_right" ? position.middle_right :
      boxPosition == "bottom_left" ? position.bottom_left :
      boxPosition == "bottom_center" ? position.bottom_center :
      position.bottom_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRETTY TIMEFRAME LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_prettyTf(_tf) =>
    switch _tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "360" => "6H"
        "480" => "8H"
        "720" => "12H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => _tf

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK TIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nyHour   = hour(timenow, "America/New_York")
nyMinute = minute(timenow, "America/New_York")
nySecond = second(timenow, "America/New_York")

ampm = nyHour >= 12 ? " PM" : " AM"

hour12 = nyHour % 12
hour12 := hour12 == 0 ? 12 : hour12

hourStr   = str.tostring(hour12)
minuteStr = str.tostring(nyMinute, "00")
secondStr = str.tostring(nySecond, "00")

clockText = "[" + hourStr + ":" + minuteStr + ":" + secondStr + ampm + "]"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nyTotalMinutes = nyHour * 60 + nyMinute

isNySession     = nyTotalMinutes >= 570 and nyTotalMinutes < 960
isLondonSession = nyTotalMinutes >= 180 and nyTotalMinutes < 570
isGlobexSession = not isNySession and not isLondonSession

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COUNTDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barCloseTime = time_close
msLeft       = math.max(barCloseTime - timenow, 0)

totalSeconds = int(math.floor(msLeft / 1000))
mins         = int(math.floor(totalSeconds / 60))
secs         = totalSeconds % 60

minsStr = str.tostring(mins)
secsStr = str.tostring(secs, "00")

countdownText = minsStr + ":" + secsStr

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMER COLORS
// Traffic light cascade: charcoal → yellow → red → flashing
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
timerBgFinal   = timerBg
timerTextFinal = timerColor

if totalSeconds < 20
    timerBgFinal := warnColor
    timerTextFinal := color.black

if totalSeconds < 10
    timerBgFinal := dangerColor
    timerTextFinal := color.white

flashOn = nySecond % 2 == 0
if totalSeconds <= 1
    timerBgFinal   := flashOn ? flashBg : dangerColor
    timerTextFinal := flashOn ? flashText : color.white

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR CALC
// Current TF ATR on left with spike marker (🔥) in front when firing
// Fixed 15m ATR on right (regime color only, no marker)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrCurrent      = ta.atr(atr1Len)
atrCurrentAvg   = ta.sma(atrCurrent, atr1SpikeMaLen)
atrCurrentSpike = showAtr1Spike and not na(atrCurrentAvg) and atrCurrent > atrCurrentAvg * atr1SpikeMult

atr15 = request.security(syminfo.tickerid, "15", ta.atr(atr15Len))

atrFmt = "#"
if atrDecimals > 0
    atrFmt := atrFmt + "." + str.repeat("0", atrDecimals)

atrCurrentStr = str.tostring(atrCurrent, atrFmt)
atr15Str      = str.tostring(atr15, atrFmt)

// Prepend the spike marker to the value so it reads first
if atrCurrentSpike
    atrCurrentStr := spikeMarker + " " + atrCurrentStr

tfPretty = f_prettyTf(timeframe.period)

atrRowText = tfPretty + ": " + atrCurrentStr + " | 15m: " + atr15Str

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR COLOR LOGIC
// Row color based on ATR 15 (regime indicator)
// Slate gray → soft blue → green → bright green
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
redTh   = isNySession ? nyRedTh : isLondonSession ? londonRedTh : globexRedTh
greenTh = isNySession ? nyGreenTh : isLondonSession ? londonGreenTh : globexGreenTh
highTh  = greenTh * 1.4

atrBgFinal = atrGreenHigh
if atr15 < redTh
    atrBgFinal := atrRed
else if atr15 < greenTh
    atrBgFinal := atrYellow
else if atr15 < highTh
    atrBgFinal := atrGreenLow
else
    atrBgFinal := atrGreenHigh

atrBgCell = color.new(atrBgFinal, 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE GEOMETRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
totalColumns = horizontalOffset + 1
totalRows    = verticalOffset + (showAtrBadge ? 3 : 2)

panelColumn = horizontalOffset
clockRow    = verticalOffset
timerRow    = verticalOffset + 1
atrRow      = verticalOffset + 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE SETUP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table  panel            = na
var string lastBoxPosition  = ""
var int    lastHOffset      = -1
var int    lastVOffset      = -1
var string lastPanelSize    = ""
var bool   lastShowAtrBadge = false

needsRebuild =
     barstate.isfirst or
     na(panel) or
     boxPosition      != lastBoxPosition or
     horizontalOffset != lastHOffset or
     verticalOffset   != lastVOffset or
     panelSize        != lastPanelSize or
     showAtrBadge     != lastShowAtrBadge

if needsRebuild
    if not na(panel)
        table.delete(panel)

    panel := table.new(
         pos,
         totalColumns,
         totalRows,
         frame_color  = borderColor,
         border_color = borderColor,
         border_width = 1
     )

    lastBoxPosition  := boxPosition
    lastHOffset      := horizontalOffset
    lastVOffset      := verticalOffset
    lastPanelSize    := panelSize
    lastShowAtrBadge := showAtrBadge

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    table.clear(panel, 0, 0, totalColumns - 1, totalRows - 1)

    table.cell(
         panel,
         panelColumn,
         clockRow,
         clockText,
         text_color = clockColor,
         text_size  = clockSize,
         bgcolor    = clockBg
     )

    table.cell(
         panel,
         panelColumn,
         timerRow,
         countdownText,
         text_color = timerTextFinal,
         text_size  = timerSize,
         bgcolor    = timerBgFinal
     )

    if showAtrBadge
        table.cell(
             panel,
             panelColumn,
             atrRow,
             atrRowText,
             text_color = atrTextColor,
             text_size  = atrSize,
             bgcolor    = atrBgCell
         )
````
