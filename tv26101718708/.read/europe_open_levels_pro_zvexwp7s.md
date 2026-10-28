# Europe Open Levels PRO

- url: https://www.tradingview.com/script/ZVEXWp7s-Europe-Open-Levels-PRO/
- type: indicator
- pine_id: PUB;4088754d872c4a0e96e7c7b8051fab0f
- version: 1.0

## Description

Europe Open Levels PRO is a clean and lightweight intraday trading tool designed specifically for European market open traders.

This indicator automatically plots the most important institutional intraday reference levels for the European session:

* Overnight High (ONH)
* Overnight Low (ONL)
* Previous Day High (PDH)
* Previous Day Low (PDL)
* Opening Range High (ORH)
* Opening Range Low (ORL)

The script is optimized for traders focusing on:

* DAX (DE40)
* UK100 (FTSE)
* European index CFDs
* Opening range breakouts
* Liquidity sweeps
* Scalping and short-term intraday trading

---

## Features

### Overnight High / Low (ONH / ONL)

Tracks the overnight session liquidity range before the European cash open.

Useful for:

* liquidity grabs
* stop hunts
* reversal setups
* breakout continuation

---

### Previous Day High / Low (PDH / PDL)

Uses the European cash session only (09:00–17:30 CET) instead of full 24h CFD data.

This provides cleaner and more relevant institutional reference levels for intraday trading.

---

### Opening Range (OR)

Automatically calculates the Opening Range High and Low after the European market open.

The Opening Range duration is fully customizable.

Ideal for:

* OR breakouts
* momentum confirmation
* trend continuation setups
* fakeout detection

---

## Designed For

This indicator is especially useful for traders who use:

* Price Action
* Smart Money Concepts (SMC)
* Market Structure
* Liquidity concepts
* CHoCH / BOS
* Opening Range trading

---

## Clean Visual Design

* Lightweight and non-cluttered
* Thin institutional-style level plotting
* Dynamic labels
* Session-aware calculations
* Optimized for intraday charts

---

## Recommended Timeframes

Best used on:

* 1 Minute
* 3 Minute
* 5 Minute
* 15 Minute

---

## Notes

* Timezone: Europe/Berlin
* Designed for European market sessions
* Best suited for active intraday traders and scalpers

If you find this indicator useful, feel free to like and share it with the TradingView community.

## Source Code

````pine
//@version=6
indicator("Europe Open Levels PRO", overlay=true)

//==================================================
// SETTINGS
//==================================================

// Overnight Session
overnightSession = input.session("0000-0859", "Overnight Session")

// Cash Session for Previous Day High / Low
cashSession = input.session("0900-1730", "Cash Session for PDH/PDL")

// Opening Range Minutes
orMinutes = input.int(5, "Opening Range Minutes", minval=1, maxval=60)

// Colors
onColor  = color.orange
pdColor  = color.blue
orhColor = color.green
orlColor = color.red

//==================================================
// DAY LOGIC
//==================================================

newDay = ta.change(dayofmonth) != 0

//==================================================
// OVERNIGHT HIGH / LOW
//==================================================

inOvernight = not na(time(timeframe.period, overnightSession, "Europe/Berlin"))

var float onHigh = na
var float onLow  = na

if newDay
    onHigh := na
    onLow  := na

if inOvernight
    onHigh := na(onHigh) ? high : math.max(onHigh, high)
    onLow  := na(onLow)  ? low  : math.min(onLow, low)

//==================================================
// CASH SESSION PREVIOUS DAY HIGH / LOW
//==================================================

inCashSession = not na(time(timeframe.period, cashSession, "Europe/Berlin"))
cashSessionStart = inCashSession and not inCashSession[1]

var float cashHighToday = na
var float cashLowToday  = na
var float pdHigh        = na
var float pdLow         = na

if cashSessionStart
    pdHigh := cashHighToday
    pdLow  := cashLowToday

    cashHighToday := high
    cashLowToday  := low

else if inCashSession
    cashHighToday := na(cashHighToday) ? high : math.max(cashHighToday, high)
    cashLowToday  := na(cashLowToday)  ? low  : math.min(cashLowToday, low)

//==================================================
// OPENING RANGE
//==================================================

marketOpen = timestamp("Europe/Berlin", year, month, dayofmonth, 9, 0)

inOR = time >= marketOpen and time < marketOpen + (orMinutes * 60 * 1000)

var float orHigh = na
var float orLow  = na

if newDay
    orHigh := na
    orLow  := na

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

//==================================================
// PLOTS
//==================================================

plot(onHigh, "ONH", color=onColor, linewidth=1, style=plot.style_linebr)
plot(onLow,  "ONL", color=onColor, linewidth=1, style=plot.style_linebr)

plot(pdHigh, "PDH Cash Session", color=pdColor, linewidth=1, style=plot.style_linebr)
plot(pdLow,  "PDL Cash Session", color=pdColor, linewidth=1, style=plot.style_linebr)

plot(orHigh, "ORH", color=orhColor, linewidth=1, style=plot.style_linebr)
plot(orLow,  "ORL", color=orlColor, linewidth=1, style=plot.style_linebr)

//==================================================
// LABELS
//==================================================

var label lblONH = na
var label lblONL = na
var label lblPDH = na
var label lblPDL = na
var label lblORH = na
var label lblORL = na

if barstate.islast
    label.delete(lblONH)
    label.delete(lblONL)
    label.delete(lblPDH)
    label.delete(lblPDL)
    label.delete(lblORH)
    label.delete(lblORL)

    if not na(onHigh)
        lblONH := label.new(bar_index, onHigh, "ONH", style=label.style_label_right, color=onColor, textcolor=color.white, size=size.small)

    if not na(onLow)
        lblONL := label.new(bar_index, onLow, "ONL", style=label.style_label_right, color=onColor, textcolor=color.white, size=size.small)

    if not na(pdHigh)
        lblPDH := label.new(bar_index, pdHigh, "PDH Cash", style=label.style_label_right, color=pdColor, textcolor=color.white, size=size.small)

    if not na(pdLow)
        lblPDL := label.new(bar_index, pdLow, "PDL Cash", style=label.style_label_right, color=pdColor, textcolor=color.white, size=size.small)

    if not na(orHigh)
        lblORH := label.new(bar_index, orHigh, "ORH", style=label.style_label_right, color=orhColor, textcolor=color.white, size=size.small)

    if not na(orLow)
        lblORL := label.new(bar_index, orLow, "ORL", style=label.style_label_right, color=orlColor, textcolor=color.white, size=size.small)
````
