<!-- tradingview-pine-id: PUB;3ed6f7ef63284612a6077c79bca747bd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Asia + London + NY Open + Market Structure

Source: https://www.tradingview.com/script/hW1ygB6X-NINETHOUSBITCH/

## Description

# Asia • London • NY 15M • Market Structure

A clean, session-based trading indicator designed to help traders identify key **liquidity levels, opening ranges, and market structure** without cluttering the chart.

### 🔴 Asia High & Low

Tracks the **5:00 PM – 12:00 AM Pacific** Asia session and automatically identifies the session high and low.

Only the **most recent Asia High and Low** are displayed, keeping the chart clean and focused on the levels that matter for the current trading day.

### 🟠 London High & Low

Tracks the **8:00 AM – 11:00 AM London time** session and marks its high and low.

The indicator automatically resets with each new London session so historical levels don't build up across the chart.

### 🔵 NY 15-Minute Opening Range

Highlights the **6:30 – 6:45 AM Pacific** New York opening window.

The indicator calculates the **highest high and lowest low of the candles inside this 15-minute window** and extends those levels forward as key intraday reference points.

The candles inside the opening range can also be visually highlighted.

### 📈 Market Structure

Automatically identifies swing-based:

* **HH — Higher High**
* **HL — Higher Low**
* **LH — Lower High**
* **LL — Lower Low**

Swing sensitivity is fully adjustable, allowing you to control how significant a move must be before it is classified as market structure.

### 🎨 Fully Customizable

Customize the appearance of the indicator with adjustable:

* Session level colors
* NY opening range colors
* Market structure colors
* Line styles
* Line widths
* Structure label size
* NY opening-range highlighting
* Individual visibility controls

### ⚡ Built for a Clean Chart

The goal is simple: provide the most important session levels and market-structure information while keeping the chart **clean, readable, and focused on current price action**.

Use the Asia and London levels to identify potential liquidity areas, the NY 15-minute range as an opening reference, and HH/HL/LH/LL to help read the broader price structure.

---

## Source Code

````pine
//@version=6
indicator("Asia + London + NY Open + Market Structure", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupSessions = "Session Settings"

// Asia
asiaSession = input.session("1700-0000", "Asia Session", group=groupSessions)
asiaTZ = input.string("America/Los_Angeles", "Asia Time Zone", group=groupSessions)

// London
londonSession = input.session("0800-1100", "London Session", group=groupSessions)
londonTZ = input.string("Europe/London", "London Time Zone", group=groupSessions)

// New York first 15 minutes
nyOpenSession = input.session("0830-0845", "NY 15 Minute Open", group=groupSessions)
nyTZ = input.string("America/New_York", "NY Time Zone", group=groupSessions)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupAsia = "Asia High / Low"

showAsia = input.bool(true, "Show Asia High / Low", group=groupAsia)

asiaHighColor = input.color(color.red, "Asia High Color", group=groupAsia)
asiaLowColor = input.color(color.green, "Asia Low Color", group=groupAsia)

asiaLineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupAsia)

asiaLineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupAsia)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupLondon = "London High / Low"

showLondon = input.bool(true, "Show London High / Low", group=groupLondon)

londonHighColor = input.color(color.orange, "London High Color", group=groupLondon)
londonLowColor = input.color(color.aqua, "London Low Color", group=groupLondon)

londonLineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupLondon)

londonLineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupLondon)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NY OPEN SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupNY = "New York 15 Minute Open"

showNY = input.bool(true, "Show NY 15 Minute Open", group=groupNY)

nyOpenColor = input.color(color.blue, "NY Open Color", group=groupNY)

nyLineWidth = input.int(3, "NY Open Line Width", minval=1, maxval=5, group=groupNY)

nyLineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupNY)

showNYLabel = input.bool(true, "Show NY Open Label", group=groupNY)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET STRUCTURE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStructure = "Market Structure"

showStructure = input.bool(true, "Show HH / HL / LH / LL", group=groupStructure)

swingLength = input.int(
     3,
     "Swing Length",
     minval=1,
     maxval=20,
     group=groupStructure)

hhColor = input.color(color.lime, "HH Color", group=groupStructure)
hlColor = input.color(color.green, "HL Color", group=groupStructure)
lhColor = input.color(color.orange, "LH Color", group=groupStructure)
llColor = input.color(color.red, "LL Color", group=groupStructure)

structureTextSize = input.string(
     "Small",
     "Structure Text Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupStructure)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getLineStyle(style) =>
    style == "Dashed" ? line.style_dashed :
     style == "Dotted" ? line.style_dotted :
     line.style_solid

getTextSize(size) =>
    size == "Tiny" ? size.tiny :
     size == "Small" ? size.small :
     size == "Large" ? size.large :
     size.normal

asiaStyle = getLineStyle(asiaLineStyleInput)
londonStyle = getLineStyle(londonLineStyleInput)
nyStyle = getLineStyle(nyLineStyleInput)

structureSize = getTextSize(structureTextSize)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA HIGH / LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inAsia = not na(time(timeframe.period, asiaSession, asiaTZ))

newAsia = inAsia and not inAsia[1]

var float asiaHigh = na
var float asiaLow = na

var line asiaHighLine = na
var line asiaLowLine = na

if newAsia

    asiaHigh := high
    asiaLow := low

    if showAsia

        asiaHighLine := line.new(
             bar_index,
             asiaHigh,
             bar_index,
             asiaHigh,
             color=asiaHighColor,
             width=asiaLineWidth,
             style=asiaStyle)

        asiaLowLine := line.new(
             bar_index,
             asiaLow,
             bar_index,
             asiaLow,
             color=asiaLowColor,
             width=asiaLineWidth,
             style=asiaStyle)

if inAsia

    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    if showAsia

        line.set_y1(asiaHighLine, asiaHigh)
        line.set_y2(asiaHighLine, asiaHigh)

        line.set_y1(asiaLowLine, asiaLow)
        line.set_y2(asiaLowLine, asiaLow)

if showAsia and not na(asiaHighLine)

    line.set_x2(asiaHighLine, bar_index)
    line.set_x2(asiaLowLine, bar_index)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON HIGH / LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inLondon = not na(time(timeframe.period, londonSession, londonTZ))

newLondon = inLondon and not inLondon[1]

var float londonHigh = na
var float londonLow = na

var line londonHighLine = na
var line londonLowLine = na

if newLondon

    londonHigh := high
    londonLow := low

    if showLondon

        londonHighLine := line.new(
             bar_index,
             londonHigh,
             bar_index,
             londonHigh,
             color=londonHighColor,
             width=londonLineWidth,
             style=londonStyle)

        londonLowLine := line.new(
             bar_index,
             londonLow,
             bar_index,
             londonLow,
             color=londonLowColor,
             width=londonLineWidth,
             style=londonStyle)

if inLondon

    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    if showLondon

        line.set_y1(londonHighLine, londonHigh)
        line.set_y2(londonHighLine, londonHigh)

        line.set_y1(londonLowLine, londonLow)
        line.set_y2(londonLowLine, londonLow)

if showLondon and not na(londonHighLine)

    line.set_x2(londonHighLine, bar_index)
    line.set_x2(londonLowLine, bar_index)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK 15 MINUTE OPEN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inNYOpen = not na(time(timeframe.period, nyOpenSession, nyTZ))

newNYOpen = inNYOpen and not inNYOpen[1]

var float nyOpenPrice = na
var line nyOpenLine = na
var label nyOpenLabel = na

if newNYOpen

    nyOpenPrice := open

    if showNY

        nyOpenLine := line.new(
             bar_index,
             nyOpenPrice,
             bar_index,
             nyOpenPrice,
             color=nyOpenColor,
             width=nyLineWidth,
             style=nyStyle)

        if showNYLabel

            nyOpenLabel := label.new(
                 bar_index,
                 nyOpenPrice,
                 "NY 15M OPEN",
                 style=label.style_none,
                 textcolor=nyOpenColor,
                 size=size.small)

if showNY and not na(nyOpenLine)

    line.set_x2(nyOpenLine, bar_index)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float previousHigh = na
var float previousLow = na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showStructure and not na(pivotHigh)

    currentHigh = pivotHigh

    if not na(previousHigh)

        if currentHigh > previousHigh

            label.new(
                 bar_index - swingLength,
                 currentHigh,
                 "HH",
                 style=label.style_none,
                 textcolor=hhColor,
                 size=structureSize)

        else if currentHigh < previousHigh

            label.new(
                 bar_index - swingLength,
                 currentHigh,
                 "LH",
                 style=label.style_none,
                 textcolor=lhColor,
                 size=structureSize)

    previousHigh := currentHigh


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOW STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showStructure and not na(pivotLow)

    currentLow = pivotLow

    if not na(previousLow)

        if currentLow > previousLow

            label.new(
                 bar_index - swingLength,
                 currentLow,
                 "HL",
                 style=label.style_none,
                 textcolor=hlColor,
                 size=structureSize)

        else if currentLow < previousLow

            label.new(
                 bar_index - swingLength,
                 currentLow,
                 "LL",
                 style=label.style_none,
                 textcolor=llColor,
                 size=structureSize)

    previousLow := currentLow
````
