# Market Structure

- url: https://www.tradingview.com/script/QoJJgLDU-Market-Structure/
- type: indicator
- pine_id: PUB;df8925e01752420a8c606d82edb084bb
- version: 2.0

## Description

This indicator identifies market structure shifts by tracking confirmed swing highs and swing lows using pivot-based price action. A BUY signal is generated when price closes above the most recent confirmed swing high, while a SELL signal is generated when price closes below the most recent confirmed swing low. The script also maintains directional bias, highlights bullish or bearish conditions with optional background coloring, and plots the active swing reference levels directly on the chart.

“Bars Left” controls how many candles are used to validate a swing high or swing low, while “Bars Right” determines how many candles must confirm the pivot before it becomes valid. Higher values create stronger but slower structure levels, while lower values react faster but may produce more noise. “Show BUY / SELL Labels” enables or hides signal labels on the chart. “Show Background Bias” colors the chart background based on the current bullish or bearish structure bias. “Show Swing Reference Levels” displays the active prior swing high and swing low levels used for structure break confirmation. “Non-Repaint Mode” waits for candle confirmation before signals are allowed, helping reduce repaint behavior during live market conditions.

This tool is designed for structure-based trend confirmation and breakout continuation analysis. Conservative traders typically use higher pivot settings to focus on major market structure, while aggressive traders may reduce pivot settings for faster directional shifts and earlier entries.

## Source Code

````pine
//@version=5
indicator("Market Structure", overlay=true, max_labels_count=200)

// Inputs
leftBars = input.int(20, "Bars Left", minval=5, maxval = 200, step = 1)
rightBars = input.int(5, "Bars Right", minval=1, maxval = 100, step = 1)

showBuySellLabels = input.bool(false, "Show BUY / SELL Labels")
showBackground = input.bool(true, "Show Background Bias")
showReferenceLevels = input.bool(true, "Show Swing Reference Levels")
nonRepaint = input.bool(true, "Non-Repaint Mode")

// Swing pivots
swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow = ta.pivotlow(low, leftBars, rightBars)

// Stored structure levels
var float lastHigh = na
var float lastLow = na
var int structure = 0

// Update confirmed swings
if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

// Confirmation logic
confirmedBar = nonRepaint ? barstate.isconfirmed : true

// Break logic
bullishBreak = confirmedBar and not na(lastHigh) and ta.crossover(close, lastHigh)
bearishBreak = confirmedBar and not na(lastLow) and ta.crossunder(close, lastLow)

// Signals only fire on bias change
buySignal = bullishBreak and structure != 1
sellSignal = bearishBreak and structure != -1

// Bullish update
if buySignal
    structure := 1
    if showBuySellLabels
        label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green, textcolor=color.white)

// Bearish update
if sellSignal
    structure := -1
    if showBuySellLabels
        label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white)

// Background bias
bgColor = showBackground ? structure == 1 ? color.new(color.green, 85) : structure == -1 ? color.new(color.red, 85) : na : na
bgcolor(bgColor)

// Reference levels
plot(showReferenceLevels ? lastHigh : na, title="Prior Swing High", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(showReferenceLevels ? lastLow : na, title="Prior Swing Low", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)

// Alerts
alertcondition(buySignal, title="BUY Signal", message="Market Structure BUY signal")
alertcondition(sellSignal, title="SELL Signal", message="Market Structure SELL signal")
````
