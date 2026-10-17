# Black Diamond - Session Highs and Lows with Alerts

- url: https://www.tradingview.com/script/kPvhiAKF-Black-Diamond-Session-Highs-and-Lows-with-Alerts/
- type: indicator
- pine_id: PUB;db23136cad82470baf6766b894cbd448
- version: 1.0

## Description

# Black Diamond – Session Highs and Lows with Alerts

## Overview

Black Diamond – Session Highs and Lows with Alerts is a professional session analysis tool designed to automatically identify and display the High and Low of the three major trading sessions:

• Asia Session
• London Session
• New York Session

The indicator continuously tracks each session's highest and lowest price and plots them directly on the chart using colour-coded levels. Once a session closes, the High and Low levels can be extended into the following session, allowing traders to monitor key liquidity levels, potential support and resistance zones, breakout areas and market reactions.

Session Highs and Lows are some of the most respected price levels used by professional traders, institutions and smart money participants. These levels frequently act as liquidity targets, reversal zones, breakout triggers and areas where market participants make important decisions.

This indicator provides a clean visual representation of these levels without cluttering the chart, making it suitable for scalpers, day traders, swing traders and smart money traders alike.

---

## Features

✔ Automatic Asia Session High and Low

✔ Automatic London Session High and Low

✔ Automatic New York Session High and Low

✔ Individual session colour settings

✔ Session High and Low labels

✔ Adjustable line thickness

✔ Extend session levels into the following session

✔ Customisable session times

✔ Customisable timezone support

✔ Session completion alerts

✔ Session High touch alerts

✔ Session Low touch alerts

✔ Clean and lightweight design

✔ Works on all markets and timeframes

---

## How To Use

### 1. Session Liquidity Trading

Many traders watch previous session highs and lows as liquidity targets.

Examples:

• London often targets Asia High or Asia Low

• New York often targets London High or London Low

• Markets frequently sweep these levels before reversing

A break above a session high can indicate bullish strength.

A break below a session low can indicate bearish strength.

---

### 2. Smart Money Concepts

Session highs and lows are often used as:

• Liquidity pools

• Stop-loss clusters

• Institutional entry zones

• Market manipulation zones

Many traders combine these levels with:

• Liquidity Sweeps

• Order Blocks

• Fair Value Gaps

• Break of Structure (BOS)

• Change of Character (CHOCH)

---

### 3. Support and Resistance

Session highs and lows frequently act as natural support and resistance zones.

Watch for:

• Rejections

• Breakouts

• Retests

• Continuation moves

These levels become even stronger when they align with:

• Daily Highs/Lows

• Weekly Highs/Lows

• Round Numbers

• Supply and Demand Zones

---

### 4. Breakout Trading

When price breaks and closes above a session high:

• Potential bullish continuation

• Possible breakout entry

When price breaks and closes below a session low:

• Potential bearish continuation

• Possible breakout entry

Always wait for confirmation before entering trades.

---

### 5. Alert System

The indicator includes alerts for:

• Asia High Touch

• Asia Low Touch

• London High Touch

• London Low Touch

• New York High Touch

• New York Low Touch

• Session Completion Alerts

To create an alert:

1. Add the indicator to your chart.
2. Click Create Alert.
3. Select this indicator.
4. Choose the desired alert condition.
5. Configure notifications as required.

---

## Recommended Usage

Best suited for:

• Forex Trading

• Gold (XAUUSD)

• Silver (XAGUSD)

• Indices

• Cryptocurrency

• Futures

Popular timeframes:

• 1 Minute

• 3 Minute

• 5 Minute

• 15 Minute

• 1 Hour

• 4 Hour

---

## Settings Guide

### Show Asia Session

Displays the Asia Session High and Low.

### Show London Session

Displays the London Session High and Low.

### Show New York Session

Displays the New York Session High and Low.

### Session Timezone

Choose the timezone used for session calculations.

### Extend Hours Into Following Session

Controls how long completed session levels remain visible after the session ends.

### Show Labels

Displays session labels beside each level.

### Line Width

Adjusts the thickness of the session levels.

### Session Colours

Allows individual colours to be assigned to:

• Asia Session

• London Session

• New York Session

---

## Trading Ideas

Many traders use the following approach:

1. Mark Asia High and Low.
2. Wait for London Open.
3. Look for liquidity sweeps of Asia levels.
4. Wait for confirmation.
5. Trade back into the range or trade the breakout.

Similarly:

1. Mark London High and Low.
2. Watch New York Open.
3. Look for liquidity grabs.
4. Trade confirmed reactions.

---

## Disclaimer

This indicator is provided for educational and informational purposes only.

Nothing contained within this indicator constitutes financial advice, investment advice or a recommendation to buy or sell any financial instrument.

Trading financial markets involves substantial risk and may not be suitable for all investors. Past performance does not guarantee future results.

Users should conduct their own analysis, risk management and due diligence before placing any trades.

The creator of this indicator accepts no responsibility for any trading losses, financial losses or damages arising from the use of this script.

Use at your own risk.

## Source Code

````pine
//@version=6
indicator("Black Diamond - Session Highs and Lows with Alerts", overlay=true, max_lines_count=300, max_labels_count=300)

// Inputs
showAsia    = input.bool(true, "Show Asia Session")
showLondon  = input.bool(true, "Show London Session")
showNewYork = input.bool(true, "Show New York Session")

sessionTimezone = input.string("Europe/London", "Session Timezone")

asiaSession   = input.session("0000-0800", "Asia Session")
londonSession = input.session("0800-1600", "London Session")
nySession     = input.session("1330-2100", "New York Session")

extendHours = input.int(4, "Extend Hours Into Following Session", minval=1, maxval=12)

showLabels = input.bool(true, "Show Labels")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=5)

// Session Colours
asiaColour   = input.color(color.new(color.green, 0), "Asia Session Colour")
londonColour = input.color(color.new(color.blue, 0), "London Session Colour")
nyColour     = input.color(color.new(color.purple, 0), "New York Session Colour")

// Extension in milliseconds
extendMs = extendHours * 60 * 60 * 1000

// Session checks
inAsia   = not na(time(timeframe.period, asiaSession, sessionTimezone))
inLondon = not na(time(timeframe.period, londonSession, sessionTimezone))
inNY     = not na(time(timeframe.period, nySession, sessionTimezone))

asiaStart   = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart     = inNY and not inNY[1]

asiaEnd   = not inAsia and inAsia[1]
londonEnd = not inLondon and inLondon[1]
nyEnd     = not inNY and inNY[1]

// Variables
var float asiaHigh = na
var float asiaLow = na
var line asiaHighLine = na
var line asiaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na

var float londonHigh = na
var float londonLow = na
var line londonHighLine = na
var line londonLowLine = na
var label londonHighLabel = na
var label londonLowLabel = na

var float nyHigh = na
var float nyLow = na
var line nyHighLine = na
var line nyLowLine = na
var label nyHighLabel = na
var label nyLowLabel = na

// ==========================
// ASIA SESSION
// ==========================
if showAsia and asiaStart
    asiaHigh := high
    asiaLow := low

    asiaHighLine := line.new(time, asiaHigh, time, asiaHigh, xloc=xloc.bar_time, color=asiaColour, width=lineWidth)
    asiaLowLine := line.new(time, asiaLow, time, asiaLow, xloc=xloc.bar_time, color=asiaColour, width=lineWidth)

    if showLabels
        asiaHighLabel := label.new(time, asiaHigh, "Asia High", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=asiaColour, size=size.small)
        asiaLowLabel := label.new(time, asiaLow, "Asia Low", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=asiaColour, size=size.small)

if showAsia and inAsia and not na(asiaHighLine) and not na(asiaLowLine)
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    line.set_xy1(asiaHighLine, line.get_x1(asiaHighLine), asiaHigh)
    line.set_xy2(asiaHighLine, time, asiaHigh)

    line.set_xy1(asiaLowLine, line.get_x1(asiaLowLine), asiaLow)
    line.set_xy2(asiaLowLine, time, asiaLow)

    if showLabels and not na(asiaHighLabel) and not na(asiaLowLabel)
        label.set_xy(asiaHighLabel, time, asiaHigh)
        label.set_xy(asiaLowLabel, time, asiaLow)

if showAsia and asiaEnd and not na(asiaHighLine) and not na(asiaLowLine)
    finalTime = time + extendMs

    line.set_x2(asiaHighLine, finalTime)
    line.set_x2(asiaLowLine, finalTime)

    if showLabels and not na(asiaHighLabel) and not na(asiaLowLabel)
        label.set_x(asiaHighLabel, finalTime)
        label.set_x(asiaLowLabel, finalTime)

// ==========================
// LONDON SESSION
// ==========================
if showLondon and londonStart
    londonHigh := high
    londonLow := low

    londonHighLine := line.new(time, londonHigh, time, londonHigh, xloc=xloc.bar_time, color=londonColour, width=lineWidth)
    londonLowLine := line.new(time, londonLow, time, londonLow, xloc=xloc.bar_time, color=londonColour, width=lineWidth)

    if showLabels
        londonHighLabel := label.new(time, londonHigh, "London High", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=londonColour, size=size.small)
        londonLowLabel := label.new(time, londonLow, "London Low", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=londonColour, size=size.small)

if showLondon and inLondon and not na(londonHighLine) and not na(londonLowLine)
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    line.set_xy1(londonHighLine, line.get_x1(londonHighLine), londonHigh)
    line.set_xy2(londonHighLine, time, londonHigh)

    line.set_xy1(londonLowLine, line.get_x1(londonLowLine), londonLow)
    line.set_xy2(londonLowLine, time, londonLow)

    if showLabels and not na(londonHighLabel) and not na(londonLowLabel)
        label.set_xy(londonHighLabel, time, londonHigh)
        label.set_xy(londonLowLabel, time, londonLow)

if showLondon and londonEnd and not na(londonHighLine) and not na(londonLowLine)
    finalTime = time + extendMs

    line.set_x2(londonHighLine, finalTime)
    line.set_x2(londonLowLine, finalTime)

    if showLabels and not na(londonHighLabel) and not na(londonLowLabel)
        label.set_x(londonHighLabel, finalTime)
        label.set_x(londonLowLabel, finalTime)

// ==========================
// NEW YORK SESSION
// ==========================
if showNewYork and nyStart
    nyHigh := high
    nyLow := low

    nyHighLine := line.new(time, nyHigh, time, nyHigh, xloc=xloc.bar_time, color=nyColour, width=lineWidth)
    nyLowLine := line.new(time, nyLow, time, nyLow, xloc=xloc.bar_time, color=nyColour, width=lineWidth)

    if showLabels
        nyHighLabel := label.new(time, nyHigh, "New York High", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=nyColour, size=size.small)
        nyLowLabel := label.new(time, nyLow, "New York Low", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=nyColour, size=size.small)

if showNewYork and inNY and not na(nyHighLine) and not na(nyLowLine)
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    line.set_xy1(nyHighLine, line.get_x1(nyHighLine), nyHigh)
    line.set_xy2(nyHighLine, time, nyHigh)

    line.set_xy1(nyLowLine, line.get_x1(nyLowLine), nyLow)
    line.set_xy2(nyLowLine, time, nyLow)

    if showLabels and not na(nyHighLabel) and not na(nyLowLabel)
        label.set_xy(nyHighLabel, time, nyHigh)
        label.set_xy(nyLowLabel, time, nyLow)

if showNewYork and nyEnd and not na(nyHighLine) and not na(nyLowLine)
    finalTime = time + extendMs

    line.set_x2(nyHighLine, finalTime)
    line.set_x2(nyLowLine, finalTime)

    if showLabels and not na(nyHighLabel) and not na(nyLowLabel)
        label.set_x(nyHighLabel, finalTime)
        label.set_x(nyLowLabel, finalTime)

// Alerts
alertcondition(asiaEnd, "Asia Session Complete", "Asia session high and low complete")
alertcondition(londonEnd, "London Session Complete", "London session high and low complete")
alertcondition(nyEnd, "New York Session Complete", "New York session high and low complete")
// Price touching session high / low alerts
asiaHighTouch   = showAsia and not na(asiaHigh) and high >= asiaHigh and low <= asiaHigh
asiaLowTouch    = showAsia and not na(asiaLow) and high >= asiaLow and low <= asiaLow

londonHighTouch = showLondon and not na(londonHigh) and high >= londonHigh and low <= londonHigh
londonLowTouch  = showLondon and not na(londonLow) and high >= londonLow and low <= londonLow

nyHighTouch     = showNewYork and not na(nyHigh) and high >= nyHigh and low <= nyHigh
nyLowTouch      = showNewYork and not na(nyLow) and high >= nyLow and low <= nyLow

alertcondition(asiaHighTouch, "Asia High Touch", "Price has touched the Asia session high")
alertcondition(asiaLowTouch, "Asia Low Touch", "Price has touched the Asia session low")

alertcondition(londonHighTouch, "London High Touch", "Price has touched the London session high")
alertcondition(londonLowTouch, "London Low Touch", "Price has touched the London session low")

alertcondition(nyHighTouch, "New York High Touch", "Price has touched the New York session high")
alertcondition(nyLowTouch, "New York Low Touch", "Price has touched the New York session low")
````
