# Session Liquidity Levels - Pad

- url: https://www.tradingview.com/script/ZpimzHBS-Session-Liquidity-Levels-Pad/
- type: indicator
- pine_id: PUB;ad7657bb2edc4e859e8864227039a0ed
- version: 1.0

## Description

Session Liquidity Levels automatically identifies and displays the high and low of the Asian, London, and New York trading sessions.

The indicator plots six reference levels:

• Asia High
• Asia Low
• London High
• London Low
• New York High
• New York Low

Default session times are based on the America/New_York timezone:

• Asian session: 8:00 PM to 12:00 AM
• London session: 2:00 AM to 5:00 AM
• New York session: 9:30 AM to 4:00 PM

Using the America/New_York timezone allows the indicator to adjust automatically for U.S. daylight-saving time. Session times can also be modified in the indicator settings.

The high and low are calculated from each completed session and remain plotted as horizontal reference levels. These areas may help traders identify locations where liquidity, stop orders, reactions, breakouts, or price acceptance may occur.

The indicator was designed primarily for intraday analysis of index futures such as ES and NQ, but it can also be applied to other instruments when the selected session definitions are relevant.

Available settings include:

• Individual colors for all six levels
• Custom session times
• Line width adjustment
• Session visibility controls
• Optional level labels

Important limitations:

This indicator only identifies the high and low of completed sessions. It does not detect liquidity sweeps, rejection candles, market structure shifts, order blocks, or trade entries. It also does not generate alerts or buy and sell signals.

Session definitions can vary among traders, brokers, and markets. Users should adjust the session times when necessary and confirm that the settings are appropriate for the instrument being analyzed.

This tool is provided exclusively for educational, informational, and analytical purposes. It does not constitute financial advice or a recommendation to buy or sell any financial instrument.

## Source Code

````pine
//@version=6
indicator("Session Liquidity Levels - Pad", overlay=true)

// ============================================================================
// SETTINGS
// ============================================================================

// ----- General
groupGeneral = "General Settings"

lineWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = groupGeneral)

showLabels = input.bool(
     true,
     "Show Labels",
     group = groupGeneral)


// ----- Sessions
groupSessions = "Session Times - New York Time"

asiaSession = input.session(
     "1900-0000",
     "Asia Session",
     group = groupSessions)

londonSession = input.session(
     "0200-0500",
     "London Session",
     group = groupSessions)

nySession = input.session(
     "0930-1600",
     "New York Session",
     group = groupSessions)


// ----- Visibility
groupVisibility = "Show / Hide Sessions"

showAsia = input.bool(
     true,
     "Show Asia Levels",
     group = groupVisibility)

showLondon = input.bool(
     true,
     "Show London Levels",
     group = groupVisibility)

showNY = input.bool(
     true,
     "Show New York Levels",
     group = groupVisibility)


// ----- Colors
groupColors = "Line Colors"

asiaHighColor = input.color(
     color.new(color.aqua, 0),
     "Asia High",
     group = groupColors)

asiaLowColor = input.color(
     color.new(color.aqua, 0),
     "Asia Low",
     group = groupColors)

londonHighColor = input.color(
     color.new(color.orange, 0),
     "London High",
     group = groupColors)

londonLowColor = input.color(
     color.new(color.orange, 0),
     "London Low",
     group = groupColors)

nyHighColor = input.color(
     color.new(color.fuchsia, 0),
     "NY High",
     group = groupColors)

nyLowColor = input.color(
     color.new(color.fuchsia, 0),
     "NY Low",
     group = groupColors)


// ============================================================================
// TIMEZONE
// ============================================================================

string tz = "America/New_York"


// ============================================================================
// SESSION DETECTION
// ============================================================================

inAsia = not na(time(timeframe.period, asiaSession, tz))
inLondon = not na(time(timeframe.period, londonSession, tz))
inNY = not na(time(timeframe.period, nySession, tz))


// ============================================================================
// ASIA
// ============================================================================

var float asiaCurrentHigh = na
var float asiaCurrentLow = na

var float lastAsiaHigh = na
var float lastAsiaLow = na

asiaStart = inAsia and not inAsia[1]
asiaEnd = not inAsia and inAsia[1]

if asiaStart
    asiaCurrentHigh := high
    asiaCurrentLow := low

if inAsia
    asiaCurrentHigh := math.max(nz(asiaCurrentHigh, high), high)
    asiaCurrentLow := math.min(nz(asiaCurrentLow, low), low)

if asiaEnd
    lastAsiaHigh := asiaCurrentHigh
    lastAsiaLow := asiaCurrentLow


// ============================================================================
// LONDON
// ============================================================================

var float londonCurrentHigh = na
var float londonCurrentLow = na

var float lastLondonHigh = na
var float lastLondonLow = na

londonStart = inLondon and not inLondon[1]
londonEnd = not inLondon and inLondon[1]

if londonStart
    londonCurrentHigh := high
    londonCurrentLow := low

if inLondon
    londonCurrentHigh := math.max(nz(londonCurrentHigh, high), high)
    londonCurrentLow := math.min(nz(londonCurrentLow, low), low)

if londonEnd
    lastLondonHigh := londonCurrentHigh
    lastLondonLow := londonCurrentLow


// ============================================================================
// NEW YORK
// ============================================================================

var float nyCurrentHigh = na
var float nyCurrentLow = na

var float lastNYHigh = na
var float lastNYLow = na

nyStart = inNY and not inNY[1]
nyEnd = not inNY and inNY[1]

if nyStart
    nyCurrentHigh := high
    nyCurrentLow := low

if inNY
    nyCurrentHigh := math.max(nz(nyCurrentHigh, high), high)
    nyCurrentLow := math.min(nz(nyCurrentLow, low), low)

if nyEnd
    lastNYHigh := nyCurrentHigh
    lastNYLow := nyCurrentLow


// ============================================================================
// PLOTS
// ============================================================================

plot(
     showAsia ? lastAsiaHigh : na,
     title = "Asia High",
     color = asiaHighColor,
     linewidth = lineWidth,
     style = plot.style_stepline)

plot(
     showAsia ? lastAsiaLow : na,
     title = "Asia Low",
     color = asiaLowColor,
     linewidth = lineWidth,
     style = plot.style_stepline)

plot(
     showLondon ? lastLondonHigh : na,
     title = "London High",
     color = londonHighColor,
     linewidth = lineWidth,
     style = plot.style_stepline)

plot(
     showLondon ? lastLondonLow : na,
     title = "London Low",
     color = londonLowColor,
     linewidth = lineWidth,
     style = plot.style_stepline)

plot(
     showNY ? lastNYHigh : na,
     title = "NY High",
     color = nyHighColor,
     linewidth = lineWidth,
     style = plot.style_stepline)

plot(
     showNY ? lastNYLow : na,
     title = "NY Low",
     color = nyLowColor,
     linewidth = lineWidth,
     style = plot.style_stepline)


// ============================================================================
// LABELS
// ============================================================================

var label asiaHighLabel = na
var label asiaLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na
var label nyHighLabel = na
var label nyLowLabel = na

if barstate.islast

    label.delete(asiaHighLabel)
    label.delete(asiaLowLabel)
    label.delete(londonHighLabel)
    label.delete(londonLowLabel)
    label.delete(nyHighLabel)
    label.delete(nyLowLabel)

    if showLabels and showAsia and not na(lastAsiaHigh)
        asiaHighLabel := label.new(
             bar_index,
             lastAsiaHigh,
             "ASIA H",
             style = label.style_label_left,
             color = asiaHighColor,
             textcolor = color.white)

    if showLabels and showAsia and not na(lastAsiaLow)
        asiaLowLabel := label.new(
             bar_index,
             lastAsiaLow,
             "ASIA L",
             style = label.style_label_left,
             color = asiaLowColor,
             textcolor = color.white)

    if showLabels and showLondon and not na(lastLondonHigh)
        londonHighLabel := label.new(
             bar_index,
             lastLondonHigh,
             "LONDON H",
             style = label.style_label_left,
             color = londonHighColor,
             textcolor = color.white)

    if showLabels and showLondon and not na(lastLondonLow)
        londonLowLabel := label.new(
             bar_index,
             lastLondonLow,
             "LONDON L",
             style = label.style_label_left,
             color = londonLowColor,
             textcolor = color.white)

    if showLabels and showNY and not na(lastNYHigh)
        nyHighLabel := label.new(
             bar_index,
             lastNYHigh,
             "NY H",
             style = label.style_label_left,
             color = nyHighColor,
             textcolor = color.white)

    if showLabels and showNY and not na(lastNYLow)
        nyLowLabel := label.new(
             bar_index,
             lastNYLow,
             "NY L",
             style = label.style_label_left,
             color = nyLowColor,
             textcolor = color.white)
````
