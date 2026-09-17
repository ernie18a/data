<!-- tradingview-pine-id: PUB;8d9dcd3a2c9f4260ac26b0408351222f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Before The Big Move

Source: https://www.tradingview.com/script/CT0vM7gd-Liquidity-Sweep-Detector/

## Description

Liquidity Sweep Detector is a price-action based indicator designed to identify potential liquidity sweeps around recent highs and lows and highlight subsequent directional confirmation.

The indicator focuses on a simple market behavior: price may temporarily move beyond a recent high or low, take available liquidity, and then return inside the previous range. After detecting this event, the indicator monitors the following candles for confirmation of a potential directional move.

## How It Works

The indicator calculates recent highs and lows using a configurable lookback period.

A bullish liquidity sweep is identified when price moves below a recent low and then closes back above that level.

A bearish liquidity sweep is identified when price moves above a recent high and then closes back below that level.

After a sweep occurs, the indicator monitors a configurable number of candles for directional confirmation. A bullish confirmation requires price to move above the previous candle's high, while a bearish confirmation requires price to move below the previous candle's low.

## Main Features

• Recent liquidity high and low levels
• Bullish liquidity sweep detection
• Bearish liquidity sweep detection
• Sweep zones for visual reference
• Directional confirmation signals
• Configurable confirmation window
• Optional candle-body confirmation
• BUY and SELL markers
• Alert conditions for sweep and confirmation events
• Adjustable visual settings

## Settings

Liquidity Lookback controls how many previous candles are used to identify recent highs and lows.

Confirmation Window controls how many candles the indicator monitors after a liquidity sweep.

Minimum Sweep Wick controls the minimum relative wick size required for a sweep to qualify.

Strong Candle Body can be enabled to require stronger directional candle confirmation.

Visual settings allow users to display or hide liquidity levels, sweep labels, sweep zones, and confirmation markers.

## How to Use

The indicator is intended to help traders study price behavior around recent liquidity levels.

A typical bullish sequence is:

Recent Low → Liquidity Sweep → Reclaim → Bullish Confirmation

A typical bearish sequence is:

Recent High → Liquidity Sweep → Rejection → Bearish Confirmation

Users can combine these observations with their own market analysis, timeframe context, and risk-management approach.

## Limitations

Liquidity sweeps can occur without producing a sustained directional move. A confirmed signal does not guarantee a particular market outcome.

The indicator is based on historical price data and should be treated as an analytical tool rather than a prediction system. Market conditions can change rapidly, and users should independently evaluate each setup.

This script does not guarantee profits, accuracy, or future performance.

## Originality

The indicator combines recent liquidity-level detection, sweep recognition, configurable confirmation logic, and visual sweep zones into a focused price-action tool. Its purpose is to provide a clear framework for observing liquidity events and subsequent price behavior without relying on excessive chart elements.

This publication is intended for educational and analytical purposes and is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep Before The Big Move", overlay=true, max_lines_count=200, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupLiquidity = "Liquidity Settings"
lookback       = input.int(20, "Liquidity Lookback", minval=5, maxval=100, group=groupLiquidity)
sweepWick      = input.float(0.15, "Minimum Sweep Wick %", minval=0.0, step=0.05, group=groupLiquidity)
showLevels     = input.bool(true, "Show Liquidity Levels", group=groupLiquidity)
extendBars     = input.int(15, "Level Extension", minval=1, maxval=100, group=groupLiquidity)

groupConfirm   = "Move Confirmation"
confirmBars    = input.int(3, "Confirmation Window", minval=1, maxval=10, group=groupConfirm)
useBodyConfirm = input.bool(true, "Require Strong Candle Body", group=groupConfirm)
bodyStrength   = input.float(0.55, "Body Strength", minval=0.1, maxval=1.0, step=0.05, group=groupConfirm)

groupVisual    = "Visual Settings"
showSweep      = input.bool(true, "Show Sweep Labels", group=groupVisual)
showBigMove    = input.bool(true, "Show Big Move Signals", group=groupVisual)
showZones      = input.bool(true, "Show Sweep Zone", group=groupVisual)
bullColor      = input.color(color.rgb(0, 200, 140), "Bullish Color", group=groupVisual)
bearColor      = input.color(color.rgb(245, 75, 90), "Bearish Color", group=groupVisual)
liqColor       = input.color(color.rgb(150, 150, 160), "Liquidity Color", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

prevHigh = ta.highest(high[1], lookback)
prevLow  = ta.lowest(low[1], lookback)

plot(showLevels ? prevHigh : na, "Buy-Side Liquidity", color=color.new(liqColor, 45), linewidth=1, style=plot.style_stepline)
plot(showLevels ? prevLow : na, "Sell-Side Liquidity", color=color.new(liqColor, 45), linewidth=1, style=plot.style_stepline)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleRange = math.max(high - low, syminfo.mintick)
body        = math.abs(close - open)
bodyRatio   = body / candleRange

bullCandle = close > open
bearCandle = close < open

strongBull = bullCandle and bodyRatio >= bodyStrength
strongBear = bearCandle and bodyRatio >= bodyStrength

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY SWEEPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bearish sweep:
// Price takes previous high but closes back below it.
bearSweep = high > prevHigh and close < prevHigh

// Bullish sweep:
// Price takes previous low but closes back above it.
bullSweep = low < prevLow and close > prevLow

// Wick strength
bearWick = high - math.max(open, close)
bullWick = math.min(open, close) - low

bearWickPct = bearWick / candleRange
bullWickPct = bullWick / candleRange

validBearSweep = bearSweep and bearWickPct >= sweepWick
validBullSweep = bullSweep and bullWickPct >= sweepWick

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int bullSweepBar = na
var int bearSweepBar = na

var float bullSweepPrice = na
var float bearSweepPrice = na

if validBullSweep
    bullSweepBar := bar_index
    bullSweepPrice := low

if validBearSweep
    bearSweepBar := bar_index
    bearSweepPrice := high

bullWindow = not na(bullSweepBar) and bar_index - bullSweepBar <= confirmBars
bearWindow = not na(bearSweepBar) and bar_index - bearSweepBar <= confirmBars

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BIG MOVE CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullConfirm = bullWindow and close > high[1] and (not useBodyConfirm or strongBull)
bearConfirm = bearWindow and close < low[1] and (not useBodyConfirm or strongBear)

// Prevent repeated signals
var int lastBullSignal = na
var int lastBearSignal = na

newBullSignal = bullConfirm and (na(lastBullSignal) or bar_index > lastBullSignal)
newBearSignal = bearConfirm and (na(lastBearSignal) or bar_index > lastBearSignal)

if newBullSignal
    lastBullSignal := bar_index
    bullSweepBar := na

if newBearSignal
    lastBearSignal := bar_index
    bearSweepBar := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showZones and validBullSweep
    box.new(
         left=bar_index,
         top=prevLow,
         right=bar_index + extendBars,
         bottom=low,
         bgcolor=color.new(bullColor, 90),
         border_color=color.new(bullColor, 65))

if showZones and validBearSweep
    box.new(
         left=bar_index,
         top=high,
         right=bar_index + extendBars,
         bottom=prevHigh,
         bgcolor=color.new(bearColor, 90),
         border_color=color.new(bearColor, 65))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSweep and validBullSweep
    label.new(
         bar_index,
         low,
         "LIQUIDITY\nSWEEP",
         style=label.style_label_up,
         color=color.new(bullColor, 5),
         textcolor=color.white,
         size=size.small)

if showSweep and validBearSweep
    label.new(
         bar_index,
         high,
         "LIQUIDITY\nSWEEP",
         style=label.style_label_down,
         color=color.new(bearColor, 5),
         textcolor=color.white,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BIG MOVE SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showBigMove and newBullSignal,
     title="Bullish Big Move",
     style=shape.labelup,
     location=location.belowbar,
     color=bullColor,
     text="BUY",
     textcolor=color.white,
     size=size.small)

plotshape(
     showBigMove and newBearSignal,
     title="Bearish Big Move",
     style=shape.labeldown,
     location=location.abovebar,
     color=bearColor,
     text="SELL",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     validBullSweep,
     title="Bullish Liquidity Sweep",
     message="Bullish liquidity sweep detected on {{ticker}} {{interval}}")

alertcondition(
     validBearSweep,
     title="Bearish Liquidity Sweep",
     message="Bearish liquidity sweep detected on {{ticker}} {{interval}}")

alertcondition(
     newBullSignal,
     title="Bullish Big Move",
     message="Bullish Big Move confirmed after liquidity sweep on {{ticker}} {{interval}}")

alertcondition(
     newBearSignal,
     title="Bearish Big Move",
     message="Bearish Big Move confirmed after liquidity sweep on {{ticker}} {{interval}}")
````
