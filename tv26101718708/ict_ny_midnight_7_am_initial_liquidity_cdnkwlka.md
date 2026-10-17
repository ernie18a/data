# ICT NY Midnight - 7 AM Initial Liquidity

- url: https://www.tradingview.com/script/cdnKWLka-ICT-NY-Midnight-7-AM-Initial-Liquidity/
- type: indicator
- pine_id: PUB;054d223797a84a0ab4d162e2f3439cad
- version: 7.0

## Description

This simple indicator identifies and plots with a horizontal ray, the highest high (Initial Buyside Liquidity) and lowest low (Initial Sellside Liquidity) between New York midnight and 7:00 AM.

It also plots the NY midnight open and extends this across the entire session, all previous levels are automatically deleted at 00:00 to start a fresh session and keep your charts nice and clean.

## Source Code

````pine
//@version=6
indicator("ICT NY Midnight - 7 AM Dynamic Liquidity", overlay=true)

// Inputs
var string G_TIME    = "Time & Session Settings"
sessionTimeZone      = input.string("America/New_York", "Time Zone", group=G_TIME)
sessionInterval      = input.string("0000-0700:23456", "Session Time", group=G_TIME)
midnightInterval     = input.string("0000-0005:23456", "Midnight True Open Check", group=G_TIME)

var string G_STYLE   = "Style Settings"
bslColor             = input.color(color.blue, "Buyside Liquidity (BSL)", group=G_STYLE)
sslColor             = input.color(color.maroon, "Sellside Liquidity (SSL)", group=G_STYLE)
midnightColor        = input.color(color.gray, "Midnight Open", group=G_STYLE)
lineWidth            = input.int(2, "Line Width", minval=1, group=G_STYLE)
lineStyleStr         = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_STYLE)
labelTextColor       = input.color(color.white, "Label Text Color", group=G_STYLE)

var string G_LABELS  = "Label Text & Padding Settings"
bslTextCustom        = input.string("BSL", "Buyside Label Text", group=G_LABELS)
sslTextCustom        = input.string("SSL", "Sellside Label Text", group=G_LABELS)
midnightTextCustom   = input.string("Midnight Open", "Midnight Label Text", group=G_LABELS)
labelPadding         = input.int(3, "Label Right Padding (Bars)", minval=0, group=G_LABELS)

// Map line style string to Pine Script line styles
getLineStyle(styleStr) =>
    switch styleStr
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Check session states
inSession     = not na(time(timeframe.period, sessionInterval, sessionTimeZone))
isMidnightBar = not na(time(timeframe.period, midnightInterval, sessionTimeZone))

var bool sessionActivePrev = false

// Tracking variables
var float highestHigh       = na
var float lowestLow         = na
var int bslStartBar         = na
var int sslStartBar         = na
var float midnightOpenPrice = na
var int midnightStartBar    = na

// Drawing references
var line bslRay      = na
var line sslRay      = na
var line midnightRay = na

var label bslLabel      = na
var label sslLabel      = na
var label midnightLabel = na

// Detect session transitions
sessionJustStarted = inSession and not sessionActivePrev
sessionActivePrev := inSession

// Detect exact Midnight Open across timeframes
var bool midnightFound = false

if sessionJustStarted
    midnightFound := false

if isMidnightBar and not midnightFound
    midnightOpenPrice := open
    midnightStartBar  := bar_index
    midnightFound     := true

// Process session logic and dynamic tracking (Only updates peaks while session is live)
if sessionJustStarted
    highestHigh := high
    lowestLow   := low
    bslStartBar := bar_index
    sslStartBar := bar_index
else if inSession
    if (na(highestHigh) or high > highestHigh)
        highestHigh := high
        bslStartBar := bar_index
    if (na(lowestLow) or low < lowestLow)
        lowestLow   := low
        sslStartBar := bar_index

// Calculate the structural anchor position for the right side
targetX2 = bar_index + labelPadding

// Manage real-time visual rays and labels
if sessionJustStarted
    // Delete older drawings when a new session cycle triggers
    line.delete(bslRay)
    line.delete(sslRay)
    line.delete(midnightRay)
    label.delete(bslLabel)
    label.delete(sslLabel)
    label.delete(midnightLabel)
    
    // Initialize new lines extended directly to the label anchor space
    bslRay      := line.new(x1=bslStartBar, y1=highestHigh, x2=targetX2, y2=highestHigh, color=bslColor, width=lineWidth, style=getLineStyle(lineStyleStr))
    sslRay      := line.new(x1=sslStartBar, y1=lowestLow, x2=targetX2, y2=lowestLow, color=sslColor, width=lineWidth, style=getLineStyle(lineStyleStr))
    midnightRay := line.new(x1=midnightStartBar, y1=midnightOpenPrice, x2=targetX2, y2=midnightOpenPrice, color=midnightColor, width=lineWidth, style=line.style_dashed)

    // Initialize new labels
    bslLabel      := label.new(x=targetX2, y=highestHigh, text=bslTextCustom + ": " + str.tostring(highestHigh, "#.#####"), color=bslColor, textcolor=labelTextColor, style=label.style_label_left, size=size.small)
    sslLabel      := label.new(x=targetX2, y=lowestLow, text=sslTextCustom + ": " + str.tostring(lowestLow, "#.#####"), color=sslColor, textcolor=labelTextColor, style=label.style_label_left, size=size.small)
    midnightLabel := label.new(x=targetX2, y=midnightOpenPrice, text=midnightTextCustom + ": " + str.tostring(midnightOpenPrice, "#.#####"), color=midnightColor, textcolor=labelTextColor, style=label.style_label_left, size=size.small)

// Continuously extend drawings forward as new bars print
if inSession or not na(highestHigh)
    // Update Lines (Price origins 'xy1' remain frozen if the session is over)
    if not na(bslRay)
        if inSession
            line.set_xy1(bslRay, bslStartBar, highestHigh)
        line.set_xy2(bslRay, targetX2, highestHigh)
        
    if not na(sslRay)
        if inSession
            line.set_xy1(sslRay, sslStartBar, lowestLow)
        line.set_xy2(sslRay, targetX2, lowestLow)
        
    if not na(midnightRay) and not na(midnightOpenPrice)
        if inSession
            line.set_xy1(midnightRay, midnightStartBar, midnightOpenPrice)
        line.set_xy2(midnightRay, targetX2, midnightOpenPrice)

    // Update Label Positions and Content dynamically
    if not na(bslLabel)
        label.set_xy(bslLabel, targetX2, highestHigh)
        label.set_text(bslLabel, bslTextCustom + ": " + str.tostring(highestHigh, "#.#####"))
    if not na(sslLabel)
        label.set_xy(sslLabel, targetX2, lowestLow)
        label.set_text(sslLabel, sslTextCustom + ": " + str.tostring(lowestLow, "#.#####"))
    if not na(midnightLabel) and not na(midnightOpenPrice)
        label.set_xy(midnightLabel, targetX2, midnightOpenPrice)
        label.set_text(midnightLabel, midnightTextCustom + ": " + str.tostring(midnightOpenPrice, "#.#####"))
````
