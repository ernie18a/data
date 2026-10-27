# VXX True Session Expansion Card

- url: https://www.tradingview.com/script/bwoeOpPi-VXX-True-Session-Expansion-Card/
- type: indicator
- pine_id: PUB;402450f2df6b48ff982e840756eddf2b
- version: 3.0

## Description

# VXX True Session Expansion Card

## Overview

The VXX True Session Expansion Card is a volatility analysis tool designed for futures traders who want to understand how much of the market's expected daily movement has already been consumed throughout the trading session.

Unlike traditional volatility indicators that only display expected range, this indicator compares projected volatility against actual session expansion and helps traders determine whether the market still has room to move or is becoming stretched.

The indicator was developed specifically for session-based trading of futures markets such as MNQ, NQ, MES, ES, MGC, and similar instruments.

---

## Core Concept

The indicator treats volatility as a daily "budget."

First, an estimated daily range is calculated using the VXX volatility index:

VXX ÷ 16 = Expected Daily Volatility %

The expected percentage move is then applied to the Globex session opening price (6:00 PM Eastern Time):

Globex Open × Volatility % = Projected Daily Range

This projected range represents the market's estimated daily volatility budget.

The indicator then measures how much of that budget has been consumed as the trading day progresses.

---

## Session-Based Expansion Analysis

The indicator divides the futures trading day into three primary sessions:

• Asia Session (6:00 PM ET – 2:00 AM ET)

• London Session (3:00 AM ET – 8:00 AM ET)

• New York Session (8:00 AM ET – 5:00 PM ET)

Instead of measuring overlapping session ranges, the indicator focuses on non-overlapping expansion.

### Asia Range

Asia establishes the initial trading range.

Asia Range = Asia High − Asia Low

### London Expansion

London only counts new movement outside of the established Asia range.

Examples:

• New highs above Asia High

• New lows below Asia Low

Any movement occurring inside the Asia range is ignored.

### New York Expansion

New York only counts new movement outside of the combined Asia and London range.

This approach prevents double-counting volatility and provides a more accurate measure of true market expansion.

---

## Volatility Budget Tracking

The indicator calculates:

• Projected Daily Range

• Actual Expanded Range

• Remaining Range Available

This allows traders to determine whether the market has:

• Significant room left to expand

• Consumed most of its expected daily volatility

• Exceeded projected volatility

---

## Volatility Status System

To simplify interpretation, the indicator automatically classifies market conditions into four categories.

### 🟦 Plenty Left

Less than 50% of projected volatility has been consumed.

Interpretation:

The market still has substantial room for expansion.

### 🟩 Healthy

50%–80% of projected volatility has been consumed.

Interpretation:

Normal market conditions.

### 🟨 Caution

80%–100% of projected volatility has been consumed.

Interpretation:

The market is becoming extended and traders should be more selective when pursuing continuation trades.

### 🟥 Stretch

More than 100% of projected volatility has been consumed.

Interpretation:

The market has exceeded projected volatility expectations and may be more vulnerable to consolidation, profit-taking, failed breakouts, or reversals.

---

## News Day Volatility Adjustment

Major economic events can cause actual volatility to significantly exceed standard projections.

The indicator includes a Volatile Day Multiplier that allows traders to adjust expected range calculations.

Suggested values:

• 1.00x = Normal Trading Day

• 1.25x = Moderately Volatile Day

• 1.50x = High Volatility Day

• 1.75x–2.00x = Extreme Volatility Events

Examples include:

• CPI

• FOMC

• Non-Farm Payrolls (NFP)

• Major Central Bank Announcements

• Unexpected Geopolitical Events

---

## Compact Dashboard Mode

The indicator includes a Compact Mode designed for traders who prefer a simplified view.

Users can selectively display:

• News Day Reminder

• Globex Open

• Adjusted Full Range

• True Percent Used

• Volatility Status

Additional fields can be enabled or disabled individually to create a personalized dashboard.

---

## Intended Use

This indicator is designed to assist traders with:

• Session-based trading

• ICT / Smart Money Concepts

• Liquidity sweeps

• Session range expansion studies

• Market structure analysis

• Intraday volatility assessment

• Trade management

• Risk management

The indicator is not intended to generate buy or sell signals.

Instead, it provides contextual information about volatility consumption and remaining expansion potential throughout the trading day.

---

## Disclaimer

This indicator provides volatility estimates and market context only. Projected ranges are not guarantees of future market movement. Traders should combine this tool with their existing analysis, risk management, and trading methodology.

## Source Code

````pine
//@version=6
indicator("VXX True Session Expansion Card", overlay=true)

// =====================
// INPUTS
// =====================
vxxSymbol = input.symbol("VXX2026", "VXX / Volatility Symbol")
divider   = input.float(16.0, "VXX Divider")
tz        = input.string("America/New_York", "Timezone")

tableMode = input.string("Full", "Table Mode", options=["Full", "Compact"])

showCompactOpen      = input.bool(true, "Compact: Globex Open")
showCompactFullRange = input.bool(true, "Compact: Adjusted Full Range")
showCompactTruePct   = input.bool(true, "Compact: True % Used")
showCompactStatus    = input.bool(true, "Compact: Volatility Status")
showCompactRemaining = input.bool(true, "Compact: Remaining Range")
showCompactAsia      = input.bool(true, "Compact: Asia Range")
showCompactLondon    = input.bool(true, "Compact: London Expansion")
showCompactNY        = input.bool(false, "Compact: NY Expansion")
showCompactNewsNote  = input.bool(true, "Compact: News Day Note")

volatileMultiplier = input.float(1.0, "Volatile Day Multiplier - Use 1.25 to 1.50 on CPI/FOMC/NFP", minval=1.0, step=0.25)

asiaSession   = input.session("1800-0200", "Asia Session")
londonSession = input.session("0300-0800", "London Session")
nySession     = input.session("0800-1700", "New York Session")

// =====================
// DASHBOARD TEXT COLOR INPUTS
// =====================
headerTextBaseColor = input.color(color.white, "Header Text Color", group="Dashboard Text Colors")
headerTextOpacity   = input.int(0, "Header Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

labelTextBaseColor = input.color(color.white, "Label Cell Text Color", group="Dashboard Text Colors")
labelTextOpacity   = input.int(0, "Label Cell Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

valueTextBaseColor = input.color(color.yellow, "Value Cell Text Color", group="Dashboard Text Colors")
valueTextOpacity   = input.int(0, "Value Cell Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

keyTextBaseColor = input.color(color.yellow, "Key Metric Text Color", group="Dashboard Text Colors")
keyTextOpacity   = input.int(0, "Key Metric Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

newsTextBaseColor = input.color(color.black, "News Note Text Color", group="Dashboard Text Colors")
newsTextOpacity   = input.int(0, "News Note Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

useDynamicStatusColor = input.bool(true, "Use Dynamic Volatility Status Color", group="Dashboard Text Colors")

statusTextBaseColor = input.color(color.white, "Manual Status Text Color", group="Dashboard Text Colors")
statusTextOpacity   = input.int(0, "Manual Status Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

dynamicStatusOpacity = input.int(0, "Dynamic Status Text Opacity", minval=0, maxval=100, group="Dashboard Text Colors")

// =====================
// DASHBOARD BACKGROUND COLOR INPUTS
// =====================
headerBgBaseColor = input.color(color.black, "Header Background Color", group="Dashboard Background Colors")
headerBgOpacity   = input.int(0, "Header Background Opacity", minval=0, maxval=100, group="Dashboard Background Colors")

newsBgBaseColor = input.color(color.yellow, "News Note Background Color", group="Dashboard Background Colors")
newsBgOpacity   = input.int(50, "News Note Background Opacity", minval=0, maxval=100, group="Dashboard Background Colors")

// =====================
// FINAL DASHBOARD COLORS
// =====================
headerTextColor = color.new(headerTextBaseColor, headerTextOpacity)
labelTextColor  = color.new(labelTextBaseColor, labelTextOpacity)
valueTextColor  = color.new(valueTextBaseColor, valueTextOpacity)
keyTextColor    = color.new(keyTextBaseColor, keyTextOpacity)
newsTextColor   = color.new(newsTextBaseColor, newsTextOpacity)

manualStatusTextColor = color.new(statusTextBaseColor, statusTextOpacity)

headerBgColor = color.new(headerBgBaseColor, headerBgOpacity)
newsBgColor   = color.new(newsBgBaseColor, newsBgOpacity)

// =====================
// DATA
// =====================
vxx = request.security(vxxSymbol, timeframe.period, close)

// =====================
// GLOBEX OPEN / DAILY RESET
// =====================
isGlobexOpen = hour(time, tz) == 18 and minute(time, tz) == 0

var float globexOpen = na

var float asiaHigh = na
var float asiaLow  = na
var float londonHigh = na
var float londonLow  = na
var float nyHigh = na
var float nyLow  = na

if isGlobexOpen
    globexOpen := open

    asiaHigh := na
    asiaLow  := na

    londonHigh := na
    londonLow  := na

    nyHigh := na
    nyLow  := na

// =====================
// SESSION DETECTION
// =====================
inAsia   = not na(time(timeframe.period, asiaSession, tz))
inLondon = not na(time(timeframe.period, londonSession, tz))
inNY     = not na(time(timeframe.period, nySession, tz))

asiaStart   = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart     = inNY and not inNY[1]

// =====================
// ASIA HIGH / LOW
// =====================
if asiaStart
    asiaHigh := high
    asiaLow  := low

if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow, low)

// =====================
// LONDON HIGH / LOW
// =====================
if londonStart
    londonHigh := high
    londonLow  := low

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow)  ? low  : math.min(londonLow, low)

// =====================
// NY HIGH / LOW
// =====================
if nyStart
    nyHigh := high
    nyLow  := low

if inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)

// =====================
// PROJECTED RANGE
// =====================
volPercent = vxx / divider
volDecimal = volPercent / 100

baseFullRange = globexOpen * volDecimal
fullRange = baseFullRange * volatileMultiplier

// =====================
// TRUE NON-OVERLAPPING EXPANSION
// =====================
asiaRange = not na(asiaHigh) and not na(asiaLow) ? asiaHigh - asiaLow : na

londonUpExpansion   = not na(londonHigh) and not na(asiaHigh) and londonHigh > asiaHigh ? londonHigh - asiaHigh : 0
londonDownExpansion = not na(londonLow) and not na(asiaLow) and londonLow < asiaLow ? asiaLow - londonLow : 0
londonExpansion     = londonUpExpansion + londonDownExpansion

rangeHighAfterLondon = math.max(nz(asiaHigh), nz(londonHigh))
rangeLowAfterLondon  = math.min(nz(asiaLow), nz(londonLow))

nyUpExpansion   = not na(nyHigh) and nyHigh > rangeHighAfterLondon ? nyHigh - rangeHighAfterLondon : 0
nyDownExpansion = not na(nyLow) and nyLow < rangeLowAfterLondon ? rangeLowAfterLondon - nyLow : 0
nyExpansion     = nyUpExpansion + nyDownExpansion

trueExpandedRange = nz(asiaRange) + londonExpansion + nyExpansion

// =====================
// PERCENT USED
// =====================
asiaPct   = fullRange > 0 ? (nz(asiaRange) / fullRange) * 100 : na
londonPct = fullRange > 0 ? (londonExpansion / fullRange) * 100 : na
nyPct     = fullRange > 0 ? (nyExpansion / fullRange) * 100 : na
truePct   = fullRange > 0 ? (trueExpandedRange / fullRange) * 100 : na

remainingRange = fullRange - trueExpandedRange
remainingRange := remainingRange < 0 ? 0 : remainingRange

// =====================
// VOLATILITY STATUS
// =====================
string volStatus =
     truePct < 50  ? "🟦 Plenty Left" :
     truePct < 80  ? "🟩 Healthy" :
     truePct < 100 ? "🟨 Caution" :
                     "🟥 Stretch"

color volColorBase =
     truePct < 50  ? color.aqua :
     truePct < 80  ? color.lime :
     truePct < 100 ? color.orange :
                     color.red

dynamicStatusTextColor = color.new(volColorBase, dynamicStatusOpacity)
statusFinalTextColor   = useDynamicStatusColor ? dynamicStatusTextColor : manualStatusTextColor

// =====================
// DISPLAY TEXT
// =====================
asiaHLText = not na(asiaHigh) and not na(asiaLow) ? str.tostring(asiaHigh, "#.##") + " / " + str.tostring(asiaLow, "#.##") : "Pending"

londonHLText = not na(londonHigh) and not na(londonLow) ? str.tostring(londonHigh, "#.##") + " / " + str.tostring(londonLow, "#.##") : "Pending"

nyHLText = not na(nyHigh) and not na(nyLow) ? str.tostring(nyHigh, "#.##") + " / " + str.tostring(nyLow, "#.##") : "Pending"

// =====================
// TABLE
// =====================
var table t = table.new(position.top_right, 2, 22, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 1, 21)

    int r = 0

    table.cell(t, 0, r, tableMode == "Compact" ? "Compact Card" : "True Expansion Card", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(t, 1, r, "Value", text_color=headerTextColor, bgcolor=headerBgColor)
    r += 1

    if tableMode == "Compact"
        if showCompactNewsNote
            table.cell(t, 0, r, "News Day Note", bgcolor=newsBgColor, text_color=newsTextColor)
            table.cell(t, 1, r, "1.25x-1.50x CPI/FOMC/NFP", bgcolor=newsBgColor, text_color=newsTextColor)
            r += 1

        if showCompactOpen
            table.cell(t, 0, r, "Globex Open", text_color=labelTextColor)
            table.cell(t, 1, r, str.tostring(globexOpen, "#.##"), text_color=valueTextColor)
            r += 1

        if showCompactFullRange
            table.cell(t, 0, r, "Adjusted Full Range", text_color=keyTextColor)
            table.cell(t, 1, r, str.tostring(fullRange, "#.##") + " pts", text_color=keyTextColor)
            r += 1

        if showCompactTruePct
            table.cell(t, 0, r, "True % Used", text_color=keyTextColor)
            table.cell(t, 1, r, str.tostring(truePct, "#.##") + "%", text_color=keyTextColor)
            r += 1

        if showCompactStatus
            table.cell(t, 0, r, "Volatility Status", text_color=labelTextColor)
            table.cell(t, 1, r, volStatus, text_color=statusFinalTextColor)
            r += 1

        if showCompactRemaining
            table.cell(t, 0, r, "Remaining Range", text_color=labelTextColor)
            table.cell(t, 1, r, str.tostring(remainingRange, "#.##") + " pts", text_color=valueTextColor)
            r += 1

        if showCompactAsia
            table.cell(t, 0, r, "Asia Range", text_color=labelTextColor)
            table.cell(t, 1, r, str.tostring(asiaRange, "#.##") + " pts / " + str.tostring(asiaPct, "#.##") + "%", text_color=valueTextColor)
            r += 1

        if showCompactLondon
            table.cell(t, 0, r, "London Expansion", text_color=labelTextColor)
            table.cell(t, 1, r, str.tostring(londonExpansion, "#.##") + " pts / " + str.tostring(londonPct, "#.##") + "%", text_color=valueTextColor)
            r += 1

        if showCompactNY
            table.cell(t, 0, r, "NY Expansion", text_color=labelTextColor)
            table.cell(t, 1, r, str.tostring(nyExpansion, "#.##") + " pts / " + str.tostring(nyPct, "#.##") + "%", text_color=valueTextColor)
            r += 1

    else
        table.cell(t, 0, 1, "Globex Open", text_color=labelTextColor)
        table.cell(t, 1, 1, str.tostring(globexOpen, "#.##"), text_color=valueTextColor)

        table.cell(t, 0, 2, "VXX", text_color=keyTextColor)
        table.cell(t, 1, 2, str.tostring(vxx, "#.##"), text_color=keyTextColor)

        table.cell(t, 0, 3, "VXX ÷ 16", text_color=labelTextColor)
        table.cell(t, 1, 3, str.tostring(volPercent, "#.##") + "%", text_color=valueTextColor)

        table.cell(t, 0, 4, "Base Projected Range", text_color=labelTextColor)
        table.cell(t, 1, 4, str.tostring(baseFullRange, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 5, "Volatile Multiplier", text_color=keyTextColor)
        table.cell(t, 1, 5, str.tostring(volatileMultiplier, "#.##") + "x", text_color=keyTextColor)

        table.cell(t, 0, 6, "Adjusted Full Range", text_color=labelTextColor)
        table.cell(t, 1, 6, str.tostring(fullRange, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 7, "Asia Range", text_color=labelTextColor)
        table.cell(t, 1, 7, str.tostring(asiaRange, "#.##") + " pts / " + str.tostring(asiaPct, "#.##") + "%", text_color=valueTextColor)

        table.cell(t, 0, 8, "London Up Expansion", text_color=labelTextColor)
        table.cell(t, 1, 8, str.tostring(londonUpExpansion, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 9, "London Down Expansion", text_color=labelTextColor)
        table.cell(t, 1, 9, str.tostring(londonDownExpansion, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 10, "London Expansion", text_color=labelTextColor)
        table.cell(t, 1, 10, str.tostring(londonExpansion, "#.##") + " pts / " + str.tostring(londonPct, "#.##") + "%", text_color=valueTextColor)

        table.cell(t, 0, 11, "NY Up Expansion", text_color=labelTextColor)
        table.cell(t, 1, 11, str.tostring(nyUpExpansion, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 12, "NY Down Expansion", text_color=labelTextColor)
        table.cell(t, 1, 12, str.tostring(nyDownExpansion, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 13, "NY Expansion", text_color=labelTextColor)
        table.cell(t, 1, 13, str.tostring(nyExpansion, "#.##") + " pts / " + str.tostring(nyPct, "#.##") + "%", text_color=valueTextColor)

        table.cell(t, 0, 14, "True Expanded Range", text_color=labelTextColor)
        table.cell(t, 1, 14, str.tostring(trueExpandedRange, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 15, "True % Used", text_color=keyTextColor)
        table.cell(t, 1, 15, str.tostring(truePct, "#.##") + "%", text_color=keyTextColor)

        table.cell(t, 0, 16, "Remaining Range", text_color=labelTextColor)
        table.cell(t, 1, 16, str.tostring(remainingRange, "#.##") + " pts", text_color=valueTextColor)

        table.cell(t, 0, 17, "Asia High / Low", text_color=labelTextColor)
        table.cell(t, 1, 17, asiaHLText, text_color=valueTextColor)

        table.cell(t, 0, 18, "London High / Low", text_color=labelTextColor)
        table.cell(t, 1, 18, londonHLText, text_color=valueTextColor)

        table.cell(t, 0, 19, "NY High / Low", text_color=labelTextColor)
        table.cell(t, 1, 19, nyHLText, text_color=valueTextColor)

        table.cell(t, 0, 20, "Volatility Status", text_color=keyTextColor)
        table.cell(t, 1, 20, volStatus, text_color=statusFinalTextColor)

        table.cell(t, 0, 21, "News Day Note", bgcolor=newsBgColor, text_color=newsTextColor)
        table.cell(t, 1, 21, "1.25x-1.50x CPI/FOMC/NFP", bgcolor=newsBgColor, text_color=newsTextColor)
````
