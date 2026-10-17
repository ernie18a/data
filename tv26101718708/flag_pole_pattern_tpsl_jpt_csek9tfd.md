# Flag & Pole Pattern Tp-sl [JPT]

- url: https://www.tradingview.com/script/Csek9Tfd-Flag-Pole-Pattern-Tp-sl-JPT/
- type: indicator
- pine_id: PUB;e93481172acb45c0bf70f50f6da6b737
- version: 1.0

## Description

[b]🔷 OVERVIEW[/b]

The Flag & Pole Pattern TP-SL [JPT] indicator detects bullish and bearish flag patterns using price action, ATR-based pole detection, and confirmed swing pivots. It identifies potential breakout opportunities and displays BUY/SELL signals directly on the chart.

[b]🔷 HOW IT WORKS[/b]

• Pole Detection: Identifies a strong upward or downward price movement using ATR.
• Flag Formation: Detects flag structures using confirmed pivot highs and lows.
• Trendlines: Draws projected resistance and support boundaries around the flag.
• Breakout Confirmation: Generates a BUY signal when a candle closes above bullish flag resistance, or a SELL signal when a candle closes below bearish flag support.
• Take-Profit & Stop-Loss: Displays a blue target zone and a red stop-loss zone based on the entry price and flag boundary.
• Risk-Reward Ratio: Calculates the take-profit level using a configurable risk-reward ratio, set to 1.3:1 by default.

🔷 [b]HOW TO USE[/b]

1. Add the indicator to your TradingView chart.
2. Adjust the pole lookback, ATR multiplier, pivot length, and maximum flag length to suit your trading timeframe.
3. Wait for a valid flag structure and a confirmed breakout signal.
4. For a BUY setup, consider entry after the candle closes above resistance. For a SELL setup, consider entry after the candle closes below support.
5. Review the displayed entry, stop-loss, and target levels before taking a trade.
6.Configure TradingView alerts to receive notifications when flag patterns or breakout signals are detected.

[b]🔷 IMPORTANT NOTE[/b]

This Signals may be delayed because pivots require confirmation, and false breakouts can occur. The displayed risk-reward ratio is a calculation, not a prediction of the outcome. Always use proper risk management and validate the indicator through backtesting before trading with real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Flag & Pole Pattern Tp-sl [JPT]", shorttitle="F & P JPT", overlay=true, max_lines_count=100, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupPole = "Pole Detection"
poleLookback = input.int(20, "Pole Lookback", minval=5, maxval=100, group=groupPole)
poleATRMult = input.float(3.0, "Minimum Pole Size (ATR)", minval=1.0, step=0.5, group=groupPole)
atrLength = input.int(14, "ATR Length", minval=1, group=groupPole)

groupFlag = "Flag Detection"
pivotLen = input.int(6, "Pivot Length", minval=2, maxval=20, group=groupFlag)
touchTolerance = input.float(0.30, "Touch Tolerance (%)", minval=0.05, maxval=2.0, step=0.05, group=groupFlag)
maxFlagBars = input.int(40, "Maximum Flag Length (Bars)", minval=10, maxval=150, group=groupFlag)
minSlopePercent = input.float(0.02, "Minimum Trendline Slope (%)", minval=0.0, step=0.01, group=groupFlag)

groupDisplay = "Display Settings"
showPole = input.bool(true, "Show Pole Labels", group=groupDisplay)
showTrendlines = input.bool(true, "Show Flag Trendlines", group=groupDisplay)
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupDisplay)
showBreakoutLabels = input.bool(true, "Show Breakout Labels", group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — ATR & PIVOT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(atrLength)

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

// Store the last three confirmed pivot highs.
var float high1 = na
var float high2 = na
var float high3 = na

var int highBar1 = na
var int highBar2 = na
var int highBar3 = na

if not na(pivotHigh)
    high1 := high2
    high2 := high3
    high3 := pivotHigh

    highBar1 := highBar2
    highBar2 := highBar3
    highBar3 := bar_index - pivotLen

// Store the last three confirmed pivot lows.
var float low1 = na
var float low2 = na
var float low3 = na

var int lowBar1 = na
var int lowBar2 = na
var int lowBar3 = na

if not na(pivotLow)
    low1 := low2
    low2 := low3
    low3 := pivotLow

    lowBar1 := lowBar2
    lowBar2 := lowBar3
    lowBar3 := bar_index - pivotLen

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — POLE DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Compare price with the price at the beginning of the lookback period.
poleStart = close[poleLookback]
poleMove = not na(poleStart) ? close - poleStart : 0.0

bullPole = not na(poleStart) and poleMove >= atrValue * poleATRMult
bearPole = not na(poleStart) and poleMove <= -atrValue * poleATRMult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — THREE-TOUCH FLAG STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Three descending pivot highs and three descending pivot lows.
descendingHighs = not na(high1) and not na(high2) and not na(high3) and high1 > high2 and high2 > high3
descendingLows = not na(low1) and not na(low2) and not na(low3) and low1 > low2 and low2 > low3

// Three ascending pivot highs and three ascending pivot lows.
ascendingHighs = not na(high1) and not na(high2) and not na(high3) and high1 < high2 and high2 < high3
ascendingLows = not na(low1) and not na(low2) and not na(low3) and low1 < low2 and low2 < low3

// Ensure each boundary has a valid, non-flat slope.
highSlopeDown = not na(highBar1) and not na(highBar3) and highBar3 > highBar1 and high1 > high3
lowSlopeDown = not na(lowBar1) and not na(lowBar3) and lowBar3 > lowBar1 and low1 > low3

highSlopeUp = not na(highBar1) and not na(highBar3) and highBar3 > highBar1 and high1 < high3
lowSlopeUp = not na(lowBar1) and not na(lowBar3) and lowBar3 > lowBar1 and low1 < low3

// Confirm that the latest pivot boundaries are reasonably close together.
bullFlagSlope = highSlopeDown and lowSlopeDown
bearFlagSlope = highSlopeUp and lowSlopeUp

bullSlopePercent = bullFlagSlope ? math.abs((high3 - high2) / high2) * 100 : 0.0
bearSlopePercent = bearFlagSlope ? math.abs((high3 - high2) / high2) * 100 : 0.0

bullStructure = descendingHighs and descendingLows and bullFlagSlope and bullSlopePercent >= minSlopePercent
bearStructure = ascendingHighs and ascendingLows and bearFlagSlope and bearSlopePercent >= minSlopePercent

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — FLAG STATE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool bullishFlagActive = false
var bool bearishFlagActive = false

var int bullishFlagStart = na
var int bearishFlagStart = na

var line bullResistance = na
var line bullSupport = na
var line bearResistance = na
var line bearSupport = na

// Start a bullish flag after an upward pole and confirmed flag structure.
newBullFlag = barstate.isconfirmed and bullPole and bullStructure and not bullishFlagActive

// Start a bearish flag after a downward pole and confirmed flag structure.
newBearFlag = barstate.isconfirmed and bearPole and bearStructure and not bearishFlagActive

if newBullFlag
    bullishFlagActive := true
    bearishFlagActive := false
    bullishFlagStart := bar_index

    if not na(bullResistance)
        line.delete(bullResistance)
    if not na(bullSupport)
        line.delete(bullSupport)

    bullResistance := line.new(highBar1, high1, highBar3, high3, xloc=xloc.bar_index, extend=extend.right, color=color.lime, width=2, style=line.style_dashed)
    bullSupport := line.new(lowBar1, low1, lowBar3, low3, xloc=xloc.bar_index, extend=extend.right, color=color.aqua, width=2, style=line.style_dashed)

    if showPole
        label.new(bar_index, low, "Bullish Flag", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if newBearFlag
    bearishFlagActive := true
    bullishFlagActive := false
    bearishFlagStart := bar_index

    if not na(bearResistance)
        line.delete(bearResistance)
    if not na(bearSupport)
        line.delete(bearSupport)

    bearResistance := line.new(highBar1, high1, highBar3, high3, xloc=xloc.bar_index, extend=extend.right, color=color.orange, width=2, style=line.style_dashed)
    bearSupport := line.new(lowBar1, low1, lowBar3, low3, xloc=xloc.bar_index, extend=extend.right, color=color.red, width=2, style=line.style_dashed)

    if showPole
        label.new(bar_index, high, "Bearish Flag", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — TRENDLINE PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullResistancePrice = not na(highBar1) and not na(highBar3) and highBar3 != highBar1 ? high1 + (high3 - high1) / (highBar3 - highBar1) * (bar_index - highBar1) : na

bullSupportPrice = not na(lowBar1) and not na(lowBar3) and lowBar3 != lowBar1 ? low1 + (low3 - low1) / (lowBar3 - lowBar1) * (bar_index - lowBar1) : na

bearResistancePrice = not na(highBar1) and not na(highBar3) and highBar3 != highBar1 ? high1 + (high3 - high1) / (highBar3 - highBar1) * (bar_index - highBar1) : na

bearSupportPrice = not na(lowBar1) and not na(lowBar3) and lowBar3 != lowBar1 ? low1 + (low3 - low1) / (lowBar3 - lowBar1) * (bar_index - lowBar1) : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — BREAKOUT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullFlagExpired = bullishFlagActive and not na(bullishFlagStart) and bar_index - bullishFlagStart > maxFlagBars
bearFlagExpired = bearishFlagActive and not na(bearishFlagStart) and bar_index - bearishFlagStart > maxFlagBars

if bullFlagExpired
    bullishFlagActive := false
    if not na(bullResistance)
        line.set_extend(bullResistance, extend.none)
    if not na(bullSupport)
        line.set_extend(bullSupport, extend.none)

if bearFlagExpired
    bearishFlagActive := false
    if not na(bearResistance)
        line.set_extend(bearResistance, extend.none)
    if not na(bearSupport)
        line.set_extend(bearSupport, extend.none)

// Signals require a confirmed candle close beyond the relevant boundary.
buySignal = barstate.isconfirmed and bullishFlagActive and not bullFlagExpired and not na(bullResistancePrice) and close > bullResistancePrice and close[1] <= bullResistancePrice[1]

sellSignal = barstate.isconfirmed and bearishFlagActive and not bearFlagExpired and not na(bearSupportPrice) and close < bearSupportPrice and close[1] >= bearSupportPrice[1]

// Invalidate the pattern after a breakout.
if buySignal
    bullishFlagActive := false
    if not na(bullResistance)
        line.set_extend(bullResistance, extend.none)
    if not na(bullSupport)
        line.set_extend(bullSupport, extend.none)

if sellSignal
    bearishFlagActive := false
    if not na(bearResistance)
        line.set_extend(bearResistance, extend.none)
    if not na(bearSupport)
        line.set_extend(bearSupport, extend.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — CHART SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(showSignals and buySignal, title="Bullish Flag Breakout", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY", textcolor=color.white)

plotshape(showSignals and sellSignal, title="Bearish Flag Breakout", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", textcolor=color.white)

if showBreakoutLabels and buySignal
    label.new(bar_index, low, "FLAG BREAKOUT\nBUY", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if showBreakoutLabels and sellSignal
    label.new(bar_index, high, "FLAG BREAKDOWN\nSELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 1 — ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(buySignal, title="Bullish Flag Breakout [JPT]", message="Bullish Flag Breakout confirmed on {{ticker}} at {{close}}")

alertcondition(sellSignal, title="Bearish Flag Breakdown [JPT]", message="Bearish Flag Breakdown confirmed on {{ticker}} at {{close}}")

alertcondition(newBullFlag, title="Bullish Flag Detected [JPT]", message="Potential Bullish Flag detected on {{ticker}}")

alertcondition(newBearFlag, title="Bearish Flag Detected [JPT]", message="Potential Bearish Flag detected on {{ticker}}")
````
