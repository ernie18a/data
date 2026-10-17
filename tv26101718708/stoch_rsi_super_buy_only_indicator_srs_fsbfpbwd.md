# Stoch RSI Super BUY only indicator (SRS)

- url: https://www.tradingview.com/script/FsBfpbWD/
- type: indicator
- pine_id: PUB;6c0a8b9970bf425893b21fa0cce016ea
- version: 1.0

## Description

Overview
The Stoch RSI Super Strategy (SRS) Combined is a comprehensive, multi-layered momentum and trend-following indicator. It is designed to identify high-probability exhaustion zones, track price divergence, and validate potential entries using price action breakouts and dynamic Moving Average (MA) trend filtering.

Instead of generating basic crossover signals, this indicator operates on a "state-tracking" logic system. It requires a specific sequence of momentum shifts before generating an actionable breakout line and subsequent buy signal, reducing false entries in choppy markets.

How It Works (Under the Hood)
The script is built on three primary components:

Smoothed Stochastic RSI (%K): The script calculates a standard RSI, applies a Stochastic oscillator to that RSI, and then smooths it to create the %K line.

State-Tracking Logic: The indicator looks for a specific sequence of events:

Phase 1 (Overbought Setup): The %K must cross above the 80 level while the RSI is concurrently at or above 70. This plots a small Green Circle, indicating the market has reached extreme momentum.

Phase 2 (Oversold Trigger): After Phase 1 is validated, the indicator waits for the %K line to cross below the 20 level. When this happens, a Red Circle is plotted, and the corresponding price candle is colored black.

Price Action Breakout & Trend Filter: Once the black candle is established, a horizontal breakout line is drawn at its High. For a long signal to trigger, the closing price must break above this horizontal line AND close above the 21-period Simple Moving Average (SMA).

Divergence Detection: The script records the low price and %K value at each "Red Circle" event. If a new setup forms with a lower price but a higher %K value, the script flags a Bullish Divergence ("D" label).

Core Features

Dynamic MA 21: Plotted directly on the main chart, this Moving Average changes color (Green/Red) based on whether the current close is above or below it, providing an immediate visual cue for the baseline trend.

Smart Breakout Line: A dynamic horizontal line that tracks the high of the setup candle. It colors red while waiting for a breakout and locks to green once the price successfully closes above it.

Exit Logic: Once a trade is active, the script tracks the %K line. An exit signal (Red Downward Triangle) is generated when %K pushes back above 70 and subsequently crosses under it, signaling fading bullish momentum.

Built-in Alerts: Fully configured alertconditions for when the breakout line is generated and when a validated buy signal occurs.

How to Use This Indicator

Monitoring: Watch for the sequence to unfold in the sub-pane. A Green Circle followed by a Red Circle means the setup is actively being monitored.

Entry Validation: Do not enter blindly on the Red Circle. Wait for the price to close above the dynamic horizontal line and the 21 SMA. If the Buy label includes a "D", it indicates the setup is backed by hidden bullish divergence, adding confluence.

Trade Management: Use the dynamic 21 SMA as a potential trailing dynamic support, or utilize the built-in exit triangle as a signal to scale out or close the position.

Disclaimer: This script is for educational and analytical purposes only. It is highly recommended to use this indicator in conjunction with broader market structure analysis, support/resistance levels, and strict risk management. Past performance is not indicative of future results.

## Source Code

````pine
//Copyright © [2026] [Dr.Sayedr83]. This script may not be copied, reproduced, or distributed without explicit permission.
//@version=6
indicator("Stoch RSI Super BUY only indicator (SRS)", shorttitle="SRS", overlay=false, max_labels_count=500)

// --- Inputs ---
smoothK = input.int(14, "K", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)
src = input(close, title="Source")
maLength = input.int(21, title="MA Length")
ma21 = ta.sma(src, maLength)

// --- Plotting MA 21 on Main Chart ---
// Dynamic color: Green if close > MA, Red if close <= MA
maColor = close > ma21 ? color.green : color.red
plot(ma21, title="MA 21", color=maColor, linewidth=2, force_overlay=true)

// --- Calculations (Sub-pane) ---
rsiVal = ta.rsi(src, lengthRSI)
k = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, lengthStoch), smoothK)

// --- Plotting Indicator ---
plot(rsiVal, title="RSI", color=color.blue, linewidth=2, force_overlay=false)
plot(k, title="%K", color=color.red, force_overlay=false)
plot(80, "Upper Band 80", color=color.green, style=plot.style_linebr, force_overlay=false)
plot(70, "RSI 70 Level", color=color.green, style=plot.style_linebr, force_overlay=false) 
plot(50, "Midline 50", color=color.orange, style=plot.style_linebr, force_overlay=false)   
plot(20, "Lower Band", color=color.red, style=plot.style_linebr, force_overlay=false)

// --- State Tracking Logic ---
var bool waitingForRsi65 = false
if k > 80
    waitingForRsi65 := true
triggerGreenTriangle = waitingForRsi65 and (rsiVal >= 70)
if triggerGreenTriangle or k <= 80
    waitingForRsi65 := false

triggerRedShadow = ta.crossover(k, 80)
var bool allowRedCircles = false
if triggerGreenTriangle
    allowRedCircles := true
else if triggerRedShadow
    allowRedCircles := false

triggerRedCircle = allowRedCircles and ta.crossover(k, 20)

// --- Plotting Shapes ---
plotshape(triggerGreenTriangle ? k + 5 : na, title="Green Down Triangle", style=shape.circle, location=location.absolute, color=color.green, size=size.tiny, force_overlay=false)
bgcolor(triggerRedShadow ? color.new(color.red, 85) : na, title="Red Shadow Cross 80 Up")
plotshape(triggerRedCircle ? k : na, title="Red Circle", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny, force_overlay=false)
barcolor(triggerRedCircle ? color.black : na, title="Black Price Candle")

// --- Line Drawing Logic (Main Chart) ---
var line breakoutLine = na
var float blackCandleHigh = na 
var bool isWaitingForBuy = false

if triggerRedCircle
    blackCandleHigh := high
    line.delete(breakoutLine) 
    breakoutLine := line.new(bar_index, high, bar_index + 1, high, color=color.red, width=2, extend=extend.right, force_overlay=true)
    isWaitingForBuy := true

// Dynamic Color Logic: While waiting for buy, update line color based on price
if isWaitingForBuy and not na(breakoutLine)
    line.set_color(breakoutLine, close > blackCandleHigh ? color.green : color.red)

// --- Buy Signal & Divergence Logic ---
var float prevCirclePriceLow = na
var float prevCircleStochVal = na
var float currentCirclePriceLow = na
var float currentCircleStochVal = na
var bool isBullishDiv = false
var bool hasTriggeredBuy = false 

if triggerRedCircle
    prevCirclePriceLow := currentCirclePriceLow
    prevCircleStochVal := currentCircleStochVal
    currentCirclePriceLow := low
    currentCircleStochVal := k
    if not na(prevCirclePriceLow)
        isBullishDiv := (currentCirclePriceLow < prevCirclePriceLow) and (currentCircleStochVal > prevCircleStochVal)
    else
        isBullishDiv := false
    hasTriggeredBuy := false

bool buySignal = false
if not na(blackCandleHigh)
    if close > blackCandleHigh and close > ma21 and not hasTriggeredBuy
        buySignal := true
        hasTriggeredBuy := true
        isWaitingForBuy := false // Stop dynamic color updates
        line.set_color(breakoutLine, color.green) // Lock to green

// --- Plot Buy Signals (Sub-pane) ---
plotshape(buySignal and isBullishDiv ? 20 : na, title="Buy Signal (Div)", 
     style=shape.labelup, location=location.absolute, color=color.green, 
     text="D", textcolor=color.white, size=size.small, force_overlay=false)

plotshape(buySignal and not isBullishDiv ? 20 : na, title="Buy Signal (Standard)", 
     style=shape.labelup, location=location.absolute, color=color.green, 
     size=size.small, force_overlay=false)

// --- Exit Signal ---
var bool inActiveTrade = false
var bool kReached70 = false
if buySignal
    inActiveTrade := true
    kReached70 := false
if inActiveTrade and k > 70
    kReached70 := true
bool exitSignal = false
if inActiveTrade and kReached70 and ta.crossunder(k, 70)
    exitSignal := true
    inActiveTrade := false 
    kReached70 := false

plotshape(exitSignal ? k + 5 : na, title="Exit Triangle Down", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny, force_overlay=false)

// --- Alerts ---
alertcondition(triggerRedCircle, title="Breakout Line Generated Alert", message="A new black candle and horizontal breakout line have been generated.")
alertcondition(buySignal, title="Buy Signal Alert", message="Buy signal triggered! Price closed above the line and the MA21.")
````
