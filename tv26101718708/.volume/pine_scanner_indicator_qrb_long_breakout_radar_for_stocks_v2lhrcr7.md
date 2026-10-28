# Pine Scanner Indicator: QRB Long Breakout Radar (For STOCKS) 

- url: https://www.tradingview.com/script/v2lhRcr7-Pine-Scanner-Indicator-QRB-Long-Breakout-Radar-For-STOCKS/
- type: indicator
- pine_id: PUB;28b95f16f58e4efb9af469573dd7198e
- version: 1.0

## Description

[b]THIS IS NOT A TRADING INDICATOR[/b]

This script is a market discovery and scanning tool built specifically for TradingView’s Pine Screener. It is not designed to generate buy or sell signals directly on a trading chart.

[b]New to QRB?[/b]

If you are not familiar with QRB or want to understand the idea behind this scanner, read the full QRB article here:
[url=https://www.tradingview.com/chart/AAPL/ixmdpu1o-ORB-for-Swing-Traders-The-Quarterly-Range-Breakout-QRB-Method/]https://www.tradingview.com/chart/AAPL/ixmdpu1o-ORB-for-Swing-Traders-The-Quarterly-Range-Breakout-QRB-Method/[/url]

[b]Pine Scanner Indicator: QRB Long Breakout Radar[/b]

The QRB Long Breakout Radar is a discovery tool designed specifically for TradingView’s Pine Screener.

It is built around the [b]Quarterly Range Breakout (QRB)[/b] framework, which applies the same basic market principle behind an Opening Range Breakout to a much larger timeframe.

Instead of using the first minutes of a trading session to define a range, QRB uses the [b]previous completed calendar quarter.[/b]

The previous quarter creates three important reference levels:
[list]
[*] QRB High — previous quarter high
[*] QRB Low — previous quarter low
[*] QRB Midline — midpoint between the previous quarter high and low
[/list]
During the new quarter, price is evaluated relative to those fixed levels.

The purpose of this scanner is simple:

[i]Find stocks that are progressing toward, breaking, retesting, or expanding beyond the previous quarter’s high.[/i]

This version is designed for[b] long-side QRB opportunities only.[/b]

[b]What This Indicator Is[/b]

This indicator is a[b] market scanning and discovery tool.[/b]

Instead of manually opening hundreds or thousands of charts looking for stocks approaching a quarterly breakout, the scanner measures where each stock currently sits inside its previous-quarter range.

It can identify several stages of a developing QRB setup:

[b]QRB Building[/b]

Price is in the upper portion of the previous-quarter range and moving toward the QRB High.

[b]QRB Pre-Breakout Ready[/b]

Price has entered the final portion of the range immediately below the QRB High and has not already confirmed a breakout during the current quarter.

[b]QRB Fresh Breakout[/b]

Price has made its first confirmed move above the previous-quarter High during the current quarter.

[b]QRB Retest[/b]

A previous QRB breakout has occurred and price is returning toward the old QRB High while remaining above the breakout area.

[b]QRB Expansion[/b]

Price has already broken above the QRB High and is continuing through the expansion phase.

The scanner also keeps track of whether a breakout has already occurred during the current quarter so that an old breakout that later falls back into the range is not incorrectly presented as a new pre-breakout opportunity.

[b]What This Indicator Is NOT[/b]

The QRB Long Breakout Radar is not a trading strategy.

[i]It does not tell you:[/i]
[list]
[*] when to buy
[*] where to place a stop loss
[*] how large your position should be
[*] whether a breakout will succeed
[*] whether a stock is fundamentally strong
[*] whether an individual setup has favorable risk/reward
[/list]
It is also not intended to replace chart analysis.

The scanner answers one question:
[i]“Where is price located relative to the previous quarter, and what stage of the QRB process is it currently in?”
[/i]
Once a stock appears in the scanner, the actual chart should still be reviewed for market structure, price action, support/resistance, momentum, available room to move, risk, and any other confirmation a trader normally uses.
Think of the Radar as a way to find the charts worth looking at, rather than a system that automatically decides which stocks should be traded.


[b]How QRB Position Works[/b]

The scanner converts the previous-quarter range into a simple percentage scale.
 
[list]
[*]0% = QRB Low
[*]50% = QRB Midline
[*]100% = QRB High
[/list]

For example, if the previous quarter had:
[list]
[*]Low = $100
[*]High = $140
[/list]

The QRB range is $40.
If price is currently $132, the stock is approximately:
[b]80% through the previous-quarter range.[/b]
That makes it a possible QRB Building candidate.
This allows stocks with very different prices and volatility to be compared using the same framework.


[b]Main Scanner Columns[/b]

[b]QRB High[/b]

The High of the previous completed calendar quarter.

[b]QRB Midline[/b]

The midpoint of the previous quarter's range.

[b]QRB Low[/b]

The Low of the previous completed calendar quarter.

[b]QRB Position %[/b]

Shows where current price sits relative to the previous-quarter range.

[b]Distance to High %[/b]

Measures the remaining distance between current price and the QRB High relative to the size of the quarterly range.

[b]Days Into Quarter[/b]

Shows how many trading days have elapsed during the current calendar quarter.
This can also be useful for studying when QRB opportunities tend to develop.

[b]QRB Status[/b]

Identifies the current QRB state.

Approach Direction
[list]
[*]1 = Rising
[*]0 = Flat
[*]-1 = Falling
[/list]
This helps distinguish a stock moving toward the QRB High from one that simply happens to be located near it while moving lower.

[b]Breakout Seen[/b]

[list]
[*] 0 = No breakout above QRB High has occurred this quarter
[*] 1 = A breakout has already occurred
[/list]
This prevents previously triggered QRB setups from being mistaken for fresh opportunities.


[b]QRB Status Codes[/b]
The scanner uses the following status values:
[list]
[*] -1 — Not Eligible
[*] 0 — Below Midline
[*] 1 — Early Watch
[*] 2 — QRB Building
[*] 3 — QRB Pre-Breakout Ready
[*] 4 — QRB Fresh Breakout
[*] 5 — QRB Retest
[*] 6 — QRB Expansion
[*] 7 — QRB Returned Inside
[*] 8 — Ready Zone but Falling/Flat
[/list]

For most long-side QRB scanning, the primary statuses are 2 through 6.

[b]Recommended Pine Screener Setup[/b]
Use the indicator inside [b]TradingView's Pine Screener[/b].


Recommended timeframe:
[b]1D[/b]
You can scan an index such as the:
[list]
[*]S&P 500
[*]Russell 2000
[*]other supported universes
[*]or your own watchlist
[/list]
The following saved scans create a simple QRB workflow.


[b]1. QRB Building — Long[/b]
Set:
[b]QRB Status = 2[/b]
and
[b]Approach Direction = 1[/b]
This finds stocks approximately [b]70%–90% through the previous-quarter range[/b] that are currently moving toward the QRB High.
Use this as an [b]early watchlist.[/b]
These stocks are not yet at the breakout level, but the setup is beginning to develop.


[b]2. QRB Pre-Breakout Ready[/b]

Set:
[b]QRB Status = 3[/b]
and:
[b]Distance to High % = 0 to 10[/b]
These stocks are in the final portion of the previous-quarter range directly beneath the QRB High.
They are rising toward the level and have not already confirmed a breakout during the current quarter.
For this scan, I recommend sorting:
[b]Distance to High % — smallest to largest[/b]
This places the stocks closest to the QRB High at the top of the list.


[b]3. QRB Fresh Breakout[/b]

Set:
[b]QRB Status = 4[/b]
This identifies stocks making their first QRB breakout of the current quarter.
Because this is based on the daily timeframe, traders should still determine whether they require the daily candle to close before considering the breakout confirmed.


[b]4. QRB Retest — Long[/b]
Set:

[b]QRB Status = 5[/b]
This finds stocks that have already broken above the QRB High and have returned toward the breakout area.
The idea is to locate potential breakout-and-retest continuation structures.
A scanner result does not automatically mean the retest is valid. Review the chart to determine whether price is actually accepting the QRB High as support.


[b]5. QRB Expansion[/b]
Set:

[b]QRB Status = 6[/b]
These stocks have already broken above the previous-quarter High and are trading in the expansion phase.
This scan can be useful for monitoring:
[list]
[*]continuing trends
[*]existing positions
[*]strong QRB breakouts
[*]potential continuation opportunities
[/list]


[b]The QRB Workflow[/b]

The long-side QRB process can be viewed as a progression:
[b]Building → Pre-Breakout Ready → Fresh Breakout → Retest → Expansion[/b]
Not every stock will move through every stage cleanly.
Some breakouts fail.
Some stocks return inside the range.
Some never reach the QRB High at all.
That is why the scanner is designed to identify location and market state, rather than automatically generate trades.


[b]A Note About Scanner Results[/b]

Sometimes a QRB scan may return only a handful of stocks.
Sometimes it may return none.
That is not necessarily a problem.
A scanner should not manufacture opportunities simply because a trader wants something to trade.

If there are no stocks currently meeting the criteria, the scanner is simply saying:
[i]The market is not presenting that particular QRB condition right now.[/i]

Waiting is also part of the process.


[b]Suggested Workflow[/b]

[b]My preferred way to use the Radar is:[/b]

[b]1. Scan the market[/b]

Find QRB candidates.

[b]2. Open the actual chart[/b]

Confirm that the structure makes sense visually.

[b]3. Evaluate the approach[/b]

Is price moving cleanly toward the QRB High, or is it simply falling into the level?

[b]4. Check the surrounding structure[/b]

Look for nearby resistance, support, failed breakouts, gaps, earnings-related moves, or anything else that could materially affect the setup.

[b]5. Make the trade decision from the chart[/b]

The scanner finds the opportunity.
The chart determines whether there is actually a trade.


[b]Final Thought[/b]
QRB is built around a very simple idea:
The previous quarter establishes the battlefield. The current quarter shows how price responds to it.

The QRB Long Breakout Radar was created to make that process easier to scan across a large number of markets without manually searching chart by chart.
Keep it simple.
Use the scanner to find location.
Use the chart to read structure.
And wait for the clean setups.

## Source Code

````pine
//@version=6
indicator("Pine Scanner Indicator: QRB Long Breakout Radar", overlay=false)

//==============================================================================
// PINE SCANNER INDICATOR: QRB LONG BREAKOUT RADAR
// FINAL STOCK v1
//
// PURPOSE:
// Screening/discovery only. Designed for TradingView Pine Screener,
// not for trade execution.
//
// CORE IDEA:
// Scan for LONG Quarterly Range Breakout (QRB) opportunities using the previous
// COMPLETED calendar quarter as a fixed reference range.
//
// STATUS MAP:
// -1 = Not Eligible
//  0 = Below Midline
//  1 = Early Watch
//  2 = QRB Building
//  3 = QRB Pre-Breakout Ready
//  4 = QRB Fresh Breakout
//  5 = QRB Retest
//  6 = QRB Expansion
//  7 = QRB Returned Inside
//  8 = Ready Zone but Falling / Flat
//==============================================================================

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupQRB = "QRB Settings"

readyZonePct = input.float(
     10.0,
     "Ready Zone (% of QRB Range)",
     minval=1.0,
     maxval=30.0,
     step=0.5,
     group=groupQRB)

retestZonePct = input.float(
     5.0,
     "Retest Zone (+/- % of QRB Range)",
     minval=0.5,
     maxval=20.0,
     step=0.5,
     group=groupQRB)

retestLookback = input.int(
     15,
     "Retest Lookback (Trading Days)",
     minval=1,
     maxval=60,
     group=groupQRB)

approachLookback = input.int(
     5,
     "Approach Direction Lookback (Trading Days)",
     minval=1,
     maxval=30,
     group=groupQRB)

groupQuality = "Current Eligibility Filter"

minPrice = input.float(
     10.0,
     "Minimum Price",
     minval=0.0,
     step=1.0,
     group=groupQuality)

minAvgVolume = input.int(
     500000,
     "Minimum Average Daily Volume",
     minval=0,
     step=50000,
     group=groupQuality)

volumeLength = input.int(
     20,
     "Average Volume Length",
     minval=1,
     maxval=100,
     group=groupQuality)

//------------------------------------------------------------------------------
// Previous completed calendar-quarter levels
//------------------------------------------------------------------------------
f_previousQuarter() =>
    bool newQuarterMonth = month == 1 or month == 4 or month == 7 or month == 10

    float priorThreeMonthHigh = ta.highest(high[1], 3)
    float priorThreeMonthLow  = ta.lowest(low[1], 3)

    float previousQuarterHigh =
         ta.valuewhen(newQuarterMonth, priorThreeMonthHigh, 0)

    float previousQuarterLow =
         ta.valuewhen(newQuarterMonth, priorThreeMonthLow, 0)

    [previousQuarterHigh, previousQuarterLow]

[qrbHigh, qrbLow] = request.security(
     syminfo.tickerid,
     "1M",
     f_previousQuarter(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

//------------------------------------------------------------------------------
// Core QRB math
//------------------------------------------------------------------------------
validRange =
     not na(qrbHigh) and
     not na(qrbLow) and
     qrbHigh > qrbLow

qrbRange =
     validRange ? qrbHigh - qrbLow : na

qrbMidline =
     validRange ? (qrbHigh + qrbLow) / 2.0 : na

qrbPositionPct =
     validRange
     ? ((close - qrbLow) / qrbRange) * 100.0
     : na

distanceToHighPct =
     validRange
     ? ((qrbHigh - close) / qrbRange) * 100.0
     : na

readyStartPct =
     100.0 - readyZonePct

//------------------------------------------------------------------------------
// Current eligibility gate
//
// This determines whether a stock is eligible TODAY.
// It does NOT control breakout history.
//------------------------------------------------------------------------------
avgDailyVolume =
     ta.sma(volume, volumeLength)

eligible =
     validRange and
     close >= minPrice and
     avgDailyVolume >= minAvgVolume

//------------------------------------------------------------------------------
// Calendar-quarter tracking
//------------------------------------------------------------------------------
newCalendarQuarter =
     month != month[1] and
     (month == 1 or month == 4 or month == 7 or month == 10)

// First daily bar of the quarter = Day 1.
daysIntoQuarterRaw =
     ta.barssince(newCalendarQuarter)

daysIntoQuarter =
     not na(daysIntoQuarterRaw)
     ? daysIntoQuarterRaw + 1
     : na

//------------------------------------------------------------------------------
// Breakout history — independent of eligibility
//------------------------------------------------------------------------------
var bool breakoutSeenThisQuarter = false
var int firstBreakoutBarIndex = na

if newCalendarQuarter
    breakoutSeenThisQuarter := false
    firstBreakoutBarIndex := na

seenBeforeToday =
     breakoutSeenThisQuarter

rawFirstBreakout =
     validRange and
     not seenBeforeToday and
     close > qrbHigh

if rawFirstBreakout
    breakoutSeenThisQuarter := true
    firstBreakoutBarIndex := bar_index

barsSinceFirstBreakout =
     not na(firstBreakoutBarIndex)
     ? bar_index - firstBreakoutBarIndex
     : na

freshBreakout =
     eligible and
     rawFirstBreakout

//------------------------------------------------------------------------------
// Approach Direction
//
// +1 = Rising
//  0 = Flat
// -1 = Falling
//------------------------------------------------------------------------------
priceChange =
     close - close[approachLookback]

float approachDirection = na

if eligible and not na(priceChange)
    if priceChange > 0
        approachDirection := 1.0
    else if priceChange < 0
        approachDirection := -1.0
    else
        approachDirection := 0.0

approachRising =
     approachDirection == 1.0

//------------------------------------------------------------------------------
// Midline Cross
//------------------------------------------------------------------------------
midlineCross =
     eligible and
     ta.crossover(close, qrbMidline)

//------------------------------------------------------------------------------
// QRB Retest
//------------------------------------------------------------------------------
retestTolerance =
     validRange
     ? qrbRange * (retestZonePct / 100.0)
     : na

touchedRetestZone =
     eligible and
     breakoutSeenThisQuarter and
     low <= qrbHigh + retestTolerance and
     high >= qrbHigh - retestTolerance

qrbRetest =
     eligible and
     breakoutSeenThisQuarter and
     not rawFirstBreakout and
     not na(barsSinceFirstBreakout) and
     barsSinceFirstBreakout >= 1 and
     barsSinceFirstBreakout <= retestLookback and
     touchedRetestZone and
     close >= qrbHigh

//------------------------------------------------------------------------------
// Returned Inside
//------------------------------------------------------------------------------
returnedInside =
     eligible and
     breakoutSeenThisQuarter and
     not rawFirstBreakout and
     not qrbRetest and
     close <= qrbHigh

//------------------------------------------------------------------------------
// Expansion
//------------------------------------------------------------------------------
qrbExpansion =
     eligible and
     breakoutSeenThisQuarter and
     close > qrbHigh and
     not rawFirstBreakout and
     not qrbRetest

//------------------------------------------------------------------------------
// QRB Pre-Breakout Ready
//------------------------------------------------------------------------------
preBreakoutReady =
     eligible and
     not breakoutSeenThisQuarter and
     qrbPositionPct >= readyStartPct and
     qrbPositionPct <= 100.0 and
     approachRising

//------------------------------------------------------------------------------
// Status Code
//------------------------------------------------------------------------------
float statusCode = -1.0

if eligible
    if freshBreakout
        statusCode := 4.0

    else if qrbRetest
        statusCode := 5.0

    else if qrbExpansion
        statusCode := 6.0

    else if returnedInside
        statusCode := 7.0

    else if preBreakoutReady
        statusCode := 3.0

    else if (
         not breakoutSeenThisQuarter and
         qrbPositionPct >= readyStartPct and
         qrbPositionPct <= 100.0
    )
        statusCode := 8.0

    else if qrbPositionPct >= 70.0
        statusCode := 2.0

    else if qrbPositionPct >= 50.0
        statusCode := 1.0

    else
        statusCode := 0.0

//------------------------------------------------------------------------------
// Pine Screener columns
// First 10 plots are the primary screener columns.
//------------------------------------------------------------------------------
plot(close, "Price")
plot(qrbHigh, "QRB High")
plot(qrbMidline, "QRB Midline")
plot(qrbLow, "QRB Low")
plot(qrbPositionPct, "QRB Position %")
plot(distanceToHighPct, "Distance to High %")
plot(daysIntoQuarter, "Days Into Quarter")
plot(statusCode, "QRB Status")
plot(approachDirection, "Approach Direction")
plot(breakoutSeenThisQuarter ? 1.0 : 0.0, "Breakout Seen")

//------------------------------------------------------------------------------
// Pine Screener / alert conditions
//------------------------------------------------------------------------------
alertcondition(
     freshBreakout,
     "QRB Fresh Breakout",
     "QRB Fresh Breakout on {{ticker}}")

alertcondition(
     qrbRetest,
     "QRB Retest",
     "QRB Retest on {{ticker}}")

alertcondition(
     preBreakoutReady,
     "QRB Pre-Breakout Ready",
     "QRB Pre-Breakout Ready on {{ticker}}")

alertcondition(
     returnedInside,
     "QRB Returned Inside",
     "QRB Returned Inside on {{ticker}}")

alertcondition(
     midlineCross,
     "QRB Midline Cross",
     "QRB Midline Cross on {{ticker}}")
````
