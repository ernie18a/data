# Amol Kadam

- url: https://www.tradingview.com/script/0GLNUqXO-Amol-Kadam/
- type: indicator
- pine_id: PUB;37a5b7445da643b985bb9d2e001ad3a1
- version: 1.0

## Description

Camarilla R3/S3 Rejection Trading Setup

Overview

This intraday trading strategy is based on Camarilla Pivot Levels, specifically H3 (R3) and L3 (S3), combined with the market structure formed during the first part of the trading session.

The setup aims to identify high-probability reversal trades after the initial market range is established, using Camarilla levels as key support and resistance zones.

⸻

Market Preparation

Step 1: Define the Morning Range

Mark the High and Low formed between:

09:15 AM – 11:30 AM (IST)

This range represents the market’s initial balance area and is used as a filter for valid Camarilla levels.

Step 2: Calculate Camarilla Levels

Using the previous trading day’s:

* High
* Low
* Close

Calculate:

* H3 (R3) – Potential resistance zone
* L3 (S3) – Potential support zone

⸻

Trade Qualification

A trade is considered valid only when:

* H3 (R3) lies within the 09:15–11:30 range, or
* L3 (S3) lies within the 09:15–11:30 range.

If the Camarilla level is outside the morning range, no trade is taken.

⸻

Long Trade Setup

Conditions

1. Time is after 11:30 AM.
2. L3 (S3) is within the morning range.
3. Price touches or trades below S3.
4. The candle closes back above S3, indicating rejection of support.

Entry

Enter a Buy trade at the close of the rejection candle.

Stop Loss

0.5% below the entry price.

Target

0.5% above the entry price.

⸻

Short Trade Setup

Conditions

1. Time is after 11:30 AM.
2. H3 (R3) is within the morning range.
3. Price touches or trades above R3.
4. The candle closes back below R3, indicating rejection of resistance.

Entry

Enter a Sell trade at the close of the rejection candle.

Stop Loss

0.5% above the entry price.

Target

0.5% below the entry price.

⸻

Trade Management Rules

* Only one trade can remain active at a time.
* No new signals are generated while a trade is active.
* A new trade is allowed only after the previous trade reaches either:
    * Target, or
    * Stop Loss.
* Entry, Stop Loss, and Target levels are displayed on the chart for active trades.

⸻

Key Advantages

* Uses objective Camarilla support and resistance levels.
* Avoids trading during the market’s opening volatility.
* Filters trades using the morning range.
* Provides predefined risk and reward.
* Eliminates overlapping positions through single-trade management.

⸻

Suitable Instruments

This setup is best suited for:

* NIFTY 50
* BANKNIFTY
* Highly liquid index derivatives
* Liquid large-cap stocks

Recommended chart timeframes:

* 3 Minute
* 5 Minute
* 15 Minute

⸻

Strategy Objective

The goal of the setup is to capture intraday reversals from important Camarilla levels after the market establishes direction and liquidity during the first half of the trading session.

## Source Code

````pine
//@version=5
indicator("AK Associates", overlay=true)

// ======================================================
// INPUTS
// ======================================================
rangeSession = input.session("0900-1130", "Range Session")
entrySession = input.session("1300-2359", "Trade After")

// ======================================================
// SESSION CONDITIONS
// ======================================================
inRange  = not na(time(timeframe.period, rangeSession, "Asia/Kolkata"))
afterOne = not na(time(timeframe.period, entrySession, "Asia/Kolkata"))

// ======================================================
// VARIABLES
// ======================================================
var float rangeHigh = na
var float rangeLow  = na
var bool tradeTaken = false

// Session tracking
var int startBar = na
var int endBar   = na

// Box
var box sessionBox = na

// Lines
var line highLine  = na
var line lowLine   = na
var line entryLine = na
var line slLine    = na
var line tpLine    = na

// Labels
var label entryLbl = na
var label slLbl    = na
var label tpLbl    = na

// ======================================================
// RESET DAILY
// ======================================================
newDay = ta.change(dayofmonth)

if newDay

    rangeHigh := na
    rangeLow  := na
    tradeTaken := false

    startBar := na
    endBar := na

    box.delete(sessionBox)

    line.delete(highLine)
    line.delete(lowLine)
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)

    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tpLbl)

// ======================================================
// CAPTURE SESSION RANGE
// ======================================================
if inRange

    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow, low)

    startBar := na(startBar) ? bar_index : startBar
    endBar := bar_index

// ======================================================
// DRAW FIXED SESSION BOX
// ======================================================
if not na(startBar) and not na(endBar)

    box.delete(sessionBox)

    sessionBox := box.new(
         left=startBar,
         top=rangeHigh,
         right=endBar,
         bottom=rangeLow,
         xloc=xloc.bar_index,
         bgcolor=color.new(color.yellow, 85),
         border_color=color.yellow,
         border_width=2)

// ======================================================
// DRAW FIXED HIGH & LOW LINES
// ======================================================
if not na(rangeHigh)

    line.delete(highLine)

    highLine := line.new(
         x1=endBar,
         y1=rangeHigh,
         x2=bar_index + 50,
         y2=rangeHigh,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.green,
         width=2)

if not na(rangeLow)

    line.delete(lowLine)

    lowLine := line.new(
         x1=endBar,
         y1=rangeLow,
         x2=bar_index + 50,
         y2=rangeLow,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.red,
         width=2)

// ======================================================
// BREAKOUT CONDITIONS
// ======================================================
buyBreak  = afterOne and ta.crossover(close, rangeHigh)
sellBreak = afterOne and ta.crossunder(close, rangeLow)

// ======================================================
// BUY TRADE
// ======================================================
if buyBreak and not tradeTaken

    entryPrice  = close
    slPrice     = rangeLow
    risk        = entryPrice - slPrice
    targetPrice = entryPrice + risk

    // ENTRY
    entryLine := line.new(
         x1=bar_index,
         y1=entryPrice,
         x2=bar_index + 50,
         y2=entryPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.blue,
         width=2)

    // SL
    slLine := line.new(
         x1=bar_index,
         y1=slPrice,
         x2=bar_index + 50,
         y2=slPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.red,
         width=2)

    // TARGET
    tpLine := line.new(
         x1=bar_index,
         y1=targetPrice,
         x2=bar_index + 50,
         y2=targetPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.green,
         width=2)

    // LABELS
    entryLbl := label.new(
         x=bar_index + 1,
         y=entryPrice,
         text="ENTRY : " + str.tostring(entryPrice),
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    slLbl := label.new(
         x=bar_index + 1,
         y=slPrice,
         text="SL : " + str.tostring(slPrice),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    tpLbl := label.new(
         x=bar_index + 1,
         y=targetPrice,
         text="TARGET : " + str.tostring(targetPrice),
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)

    tradeTaken := true

// ======================================================
// SELL TRADE
// ======================================================
if sellBreak and not tradeTaken

    entryPrice  = close
    slPrice     = rangeHigh
    risk        = slPrice - entryPrice
    targetPrice = entryPrice - risk

    // ENTRY
    entryLine := line.new(
         x1=bar_index,
         y1=entryPrice,
         x2=bar_index + 50,
         y2=entryPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.orange,
         width=2)

    // SL
    slLine := line.new(
         x1=bar_index,
         y1=slPrice,
         x2=bar_index + 50,
         y2=slPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.red,
         width=2)

    // TARGET
    tpLine := line.new(
         x1=bar_index,
         y1=targetPrice,
         x2=bar_index + 50,
         y2=targetPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.green,
         width=2)

    // LABELS
    entryLbl := label.new(
         x=bar_index + 1,
         y=entryPrice,
         text="ENTRY : " + str.tostring(entryPrice),
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.white)

    slLbl := label.new(
         x=bar_index + 1,
         y=slPrice,
         text="SL : " + str.tostring(slPrice),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    tpLbl := label.new(
         x=bar_index + 1,
         y=targetPrice,
         text="TARGET : " + str.tostring(targetPrice),
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)

    tradeTaken := true

// ======================================================
// ALERTS
// ======================================================
alertcondition(buyBreak, title="BUY SIGNAL", message="BUY breakout above session high")
alertcondition(sellBreak, title="SELL SIGNAL", message="SELL breakdown below session low")
````
