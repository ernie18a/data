<!-- tradingview-pine-id: PUB;68af300545594ba58a3e412948635fd6 -->
<!-- tradingviewscripts-format: 1 -->
# QD Session Boxes

Source: https://www.tradingview.com/script/vFUs1OPR-QD-Session-Range-Boxes/

## Description

This indicator draws boxes around the price range of the Asia, London, and New York sessions, automatically calculated with no manual setup required.

How to use it The boxes let you visually track each session's movement and trend at a glance. Instead of manually marking session highs and lows, you get an instant, clear picture of where price moved during each session — useful for spotting range expansion, session momentum, and how one session's range relates to the next.

Session times (NY time):
* Asia: 20:00 – 00:00
* London: 02:00 – 07:00
* New York: 09:30 – 12:00

Features
* Toggle each session (Asia, London, NY) on/off independently
* Toggle historical boxes on/off, or limit how many days back are shown
* Adjustable label offset lets you position session names exactly where you want above the boxes
* Style controls let you individually show/hide boxes and labels, and choose whether inputs (like Days to Show and Label Offset) appear on the status line, for a cleaner chart

Notes Colors are fixed (purple, blue, green) for a clean, consistent chart display.

---

## Source Code

````pine
//@version=6
indicator("QD Session Boxes", overlay=true)

// --- INPUTS ---
showHistory  = input.bool(false, "Show Historical Boxes")
lookback     = input.int(2, "Days to Show", minval=1, maxval=30)
labelOffset  = input.float(5.0, "Label Offset %", minval=0.0, maxval=100.0, step=0.5, tooltip="Adjusts how high labels sit above boxes")

// --- SESSION TOGGLES ---
showAsia   = input.bool(true,  "Show Asia Session",     group="Sessions")
showLondon = input.bool(true,  "Show London Session",   group="Sessions")
showNY     = input.bool(true,  "Show New York Session", group="Sessions")

// --- COLORS ---
babyPurple = color.rgb(191, 148, 228)
babyBlue   = color.rgb(137, 207, 240)
babyGreen  = color.rgb(152, 214, 170)

// --- HELPER ---
inAsiaSession = not na(time(timeframe.period, "2000-0000:1234567", "America/New_York"))
var int lastAsiaSessionStart = na

if inAsiaSession and not inAsiaSession[1]
    lastAsiaSessionStart := time

asiaSessionCount = 0
if not na(lastAsiaSessionStart)
    asiaSessionCount := math.floor((timenow - lastAsiaSessionStart) / 86400000)

withinLookback = asiaSessionCount < lookback or (na(lastAsiaSessionStart) and (timenow - time) / 86400000 <= lookback)

get_y_pos(high_val, low_val) =>
    boxHeight = high_val - low_val
    high_val + (boxHeight * (labelOffset / 100))

// --- ASIA (20:00 - 00:00) ---
inAsia = not na(time(timeframe.period, "2000-0000:1234567", "America/New_York"))
var float asiaHigh  = na
var float asiaLow   = na
var box   asiaBox   = na
var label asiaLabel = na
var int   asiaStart = na

if inAsia
    if not inAsia[1]
        asiaHigh  := high
        asiaLow   := low
        asiaStart := bar_index
        if showAsia and (showHistory or withinLookback)
            asiaBox   := box.new(bar_index, asiaHigh, bar_index, asiaLow, border_color=na, bgcolor=color.new(babyPurple, 80))
            asiaLabel := label.new(bar_index, asiaHigh, "ASIA", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal, textalign=text.align_center)
    else
        asiaHigh := math.max(asiaHigh, high)
        asiaLow  := math.min(asiaLow, low)
        if not na(asiaBox)
            box.set_top(asiaBox, asiaHigh)
            box.set_bottom(asiaBox, asiaLow)
            box.set_right(asiaBox, bar_index)
        if not na(asiaLabel)
            label.set_x(asiaLabel, math.round((asiaStart + bar_index) / 2))
            label.set_y(asiaLabel, get_y_pos(asiaHigh, asiaLow))

// --- LONDON (02:00 - 07:00) ---
inLondon = not na(time(timeframe.period, "0200-0700:1234567", "America/New_York"))
var float lonHigh  = na
var float lonLow   = na
var box   lonBox   = na
var label lonLabel = na
var int   lonStart = na

if inLondon
    if not inLondon[1]
        lonHigh  := high
        lonLow   := low
        lonStart := bar_index
        if showLondon and (showHistory or withinLookback)
            lonBox   := box.new(bar_index, lonHigh, bar_index, lonLow, border_color=na, bgcolor=color.new(babyBlue, 80))
            lonLabel := label.new(bar_index, lonHigh, "LONDON", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal, textalign=text.align_center)
    else
        lonHigh := math.max(lonHigh, high)
        lonLow  := math.min(lonLow, low)
        if not na(lonBox)
            box.set_top(lonBox, lonHigh)
            box.set_bottom(lonBox, lonLow)
            box.set_right(lonBox, bar_index)
        if not na(lonLabel)
            label.set_x(lonLabel, math.round((lonStart + bar_index) / 2))
            label.set_y(lonLabel, get_y_pos(lonHigh, lonLow))

// --- NEW YORK (09:30 - 12:00) ---
inNY = not na(time(timeframe.period, "0930-1200:1234567", "America/New_York"))
var float nyHigh  = na
var float nyLow   = na
var box   nyBox   = na
var label nyLabel = na
var int   nyStart = na

if inNY
    if not inNY[1]
        nyHigh  := high
        nyLow   := low
        nyStart := bar_index
        if showNY and (showHistory or withinLookback)
            nyBox   := box.new(bar_index, nyHigh, bar_index, nyLow, border_color=na, bgcolor=color.new(babyGreen, 80))
            nyLabel := label.new(bar_index, nyHigh, "NEW YORK", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal, textalign=text.align_center)
    else
        nyHigh := math.max(nyHigh, high)
        nyLow  := math.min(nyLow, low)
        if not na(nyBox)
            box.set_top(nyBox, nyHigh)
            box.set_bottom(nyBox, nyLow)
            box.set_right(nyBox, bar_index)
        if not na(nyLabel)
            label.set_x(nyLabel, math.round((nyStart + bar_index) / 2))
            label.set_y(nyLabel, get_y_pos(nyHigh, nyLow))

// Updated name + Asia session day boundary
````
