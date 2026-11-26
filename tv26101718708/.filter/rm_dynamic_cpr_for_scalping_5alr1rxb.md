# RM Dynamic CPR for Scalping

- url: https://www.tradingview.com/script/5alR1RxB-RM-Dynamic-CPR-for-Scalping/
- type: indicator
- pine_id: PUB;56017c1a47e3487d81bd45ad48a617ab
- version: 2.0

## Description

[b]RM Dynamic CPR for Scalping[/b]

Overview

RM Dynamic CPR for Scalping is a dynamic Central Pivot Range (CPR) indicator designed for intraday traders and scalpers. Unlike traditional daily CPR indicators, this script calculates CPR levels using the previous candle of a user-selected higher timeframe (default: 25 minutes), making it highly adaptive to changing market conditions.

The indicator automatically plots CPR levels along with multiple support and resistance zones, helping traders identify potential breakout, breakdown, reversal, and target areas throughout the trading session.

[b]Features[/b]

Dynamic CPR Calculation

* Calculates CPR using the previous higher timeframe candle.
* User-selectable CPR timeframe (default: 25 minutes).
* Automatically updates CPR levels when a new timeframe period begins.

CPR Components

* **TC (Top Central)**
* **BC (Bottom Central)**
* **Pivot Point**

Support & Resistance Levels

* R1 / S1
* R2 / S2
* Optional R3 / S3

Visual Enhancements

* CPR zone highlighted using a shaded area between TC and BC.
* Optional line extension for better chart visibility.
* Clean and lightweight design suitable for scalping and intraday trading.

How to Use

Bullish Setup

* Price sustains above the CPR zone.
* CPR acts as support.
* Breakout above R1 may indicate bullish continuation.
* R2 and R3 can be used as potential targets.

Bearish Setup

* Price sustains below the CPR zone.
* CPR acts as resistance.
* Breakdown below S1 may indicate bearish continuation.
* S2 and S3 can be used as potential downside targets.

Range-Bound Markets

* CPR can act as a mean-reversion zone.
* Traders may look for reversals near support and resistance levels.

Best Use Cases

* Index Scalping
* Intraday Trading
* Futures Trading
* Options Trading
* Breakout and Breakdown Strategies
* CPR-Based Confluence Trading

Customization

Users can:

* Change the CPR timeframe.
* Enable or disable CPR levels.
* Show or hide Pivot, R1/S1, R2/S2, and R3/S3 levels.
* Extend plotted levels across the chart.

Disclaimer

This indicator is intended for educational and informational purposes only. It does not provide financial advice. Always use proper risk management and combine CPR levels with price action, volume analysis, and market structure before making trading decisions.

## Source Code

````pine
//@version=6
indicator("RM Dynamic CPR for Scalping", overlay=true, max_lines_count=500, max_labels_count=500)

// ======================================================
// SETTINGS
// ======================================================
tfInput     = input.timeframe("25", "CPR Timeframe")
showCPR     = input.bool(true,  "Show CPR")
showPivot   = input.bool(true,  "Show Pivot")
showR1S1    = input.bool(true,  "Show R1/S1")
showR2S2    = input.bool(true,  "Show R2/S2")
showR3S3    = input.bool(true, "Show R3/S3")


// ======================================================
// GET PREVIOUS 25-MIN CANDLE DATA
// ======================================================
prevHigh  = request.security(syminfo.tickerid, tfInput, high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, tfInput, low[1],   lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, tfInput, close[1], lookahead=barmerge.lookahead_on)

// ======================================================
// DETECT CPR PERIOD CHANGE
// ======================================================
isNewCPRPeriod = ta.change(request.security(syminfo.tickerid, tfInput, time, lookahead=barmerge.lookahead_on)) != 0

var int  cprStartBar       = 0
var int  prevCPRStartBar   = 0
var int  cprPeriodLength   = 25
var bool isFirstCPRPeriod  = true

if isNewCPRPeriod
    cprStartBar := bar_index

barsInPeriod = bar_index - cprStartBar

if isNewCPRPeriod
    if not isFirstCPRPeriod
        if prevCPRStartBar != 0
            cprPeriodLength := bar_index - prevCPRStartBar
    isFirstCPRPeriod := false
    prevCPRStartBar  := bar_index

isLastCPRBar = (barsInPeriod == cprPeriodLength - 1)

// ======================================================
// CPR CALCULATION
// ======================================================
pivot = (prevHigh + prevLow + prevClose) / 3
bc    = (prevHigh + prevLow) / 2
tc    = (pivot - bc) + pivot

topCentral    = math.max(tc, bc)
bottomCentral = math.min(tc, bc)

// ======================================================
// PIVOT LEVELS
// ======================================================
r1 = (2 * pivot) - prevLow
s1 = (2 * pivot) - prevHigh
r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)
r3 = prevHigh + 2 * (pivot - prevLow)
s3 = prevLow  - 2 * (prevHigh - pivot)


// ======================================================
// LINE STYLE
// ======================================================
lineStyle =plot.style_circles

// ======================================================
// PLOTS — CPR & PIVOT LEVELS
// ======================================================
plot(showCPR   ? topCentral    : na, title="TC",    color=color.orange, linewidth=2, style=lineStyle)
plot(showCPR   ? bottomCentral : na, title="BC",    color=color.orange, linewidth=2, style=lineStyle)
plot(showPivot ? pivot         : na, title="Pivot", color=color.yellow, linewidth=2, style=lineStyle)
plot(showR1S1  ? r1            : na, title="R1",    color=color.green,  linewidth=1, style=lineStyle)
plot(showR1S1  ? s1            : na, title="S1",    color=color.red,    linewidth=1, style=lineStyle)
plot(showR2S2  ? r2            : na, title="R2",    color=color.green,  linewidth=1, style=lineStyle)
plot(showR2S2  ? s2            : na, title="S2",    color=color.red,    linewidth=1, style=lineStyle)
plot(showR3S3  ? r3            : na, title="R3",    color=color.green,  linewidth=1, style=lineStyle)
plot(showR3S3  ? s3            : na, title="S3",    color=color.red,    linewidth=1, style=lineStyle)

// Fill between TC & BC
tcPlot = plot(showCPR ? topCentral    : na, display=display.none)
bcPlot = plot(showCPR ? bottomCentral : na, display=display.none)
fill(tcPlot, bcPlot, color=color.new(color.orange, 85))
````
