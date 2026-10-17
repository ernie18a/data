# EMA Momentum & Cross Engine

- url: https://www.tradingview.com/script/IQPJOQQT-EMA-Momentum-Cross-Engine/
- type: indicator
- pine_id: PUB;61d075a27f294654805d49014234cd1d
- version: 1.0

## Description

Indicator Summary: EMA Momentum & Cross Engine 
This indicator is an advanced, fully customizable trend and momentum tool built around the 20 and 50 Exponential Moving Averages (EMAs). Instead of solely relying on traditional, lagging crossover signals, it proactively identifies high-probability reversals by mathematically measuring the tension between the moving averages.

Core Features:
 
Early Reversal Detection (DIV Signals): It measures the distance between the 20 and 50 EMA. When this distance becomes severely overextended (exhaustion) and suddenly snaps back with high velocity, it fires early "BUY DIV" or "SELL DIV" signals before a crossover ever happens.

Standard Crossovers: Plots standard trend-following buy and sell signals when the EMAs actually cross.

Smart Filtering Engine: Includes a built-in cooldown timer and max-signal limiters. This prevents rapid-fire false signals during choppy, sideways markets and keeps the chart perfectly clean.

Deep Customization: Every visual element is customizable. You can change the text, colors, label sizes, and even the precise mathematical distance the labels sit away from the candle wicks. It also features floating, dynamic labels at the end of the EMA lines so you never lose track of them.

Why ATR-Normalized Divergence is Better Than Slope
When trying to catch early trend changes or pullbacks, measuring the Average True Range (ATR) normalized spread between the EMAs is vastly superior to just measuring the slope of the lines. Here is why:

1. It Eliminates the "Visual Illusion"
The slope (angle) of a moving average on your screen is an illusion. If you zoom out or stretch the y-axis of your chart, a "flat" slope suddenly looks incredibly steep. Measuring the ATR spread relies on hard, objective math—not how your monitor happens to be scaled at that exact second.

2. It Automatically Adapts to Market Volatility
A 10-point distance between the 20 and 50 EMA means something completely different depending on the market environment.

If market volatility is dead, a 10-point gap is a massive, overextended move.

If the market is wildly volatile (like during a major news event), a 10-point gap is just normal background noise.
By dividing the EMA distance by the ATR, the indicator standardizes the measurement. A value of 1.0 means the EMAs are stretched exactly 1x the normal volatility of the current market, ensuring your signals are accurate regardless of whether the market is slow or fast.

3. It Measures the "Rubber Band" Tension
Slope only tells you the direction the market is heading. ATR Divergence tells you the tension. Markets act like rubber bands—they can only stretch so far from their mean (the 50 EMA) before they snap back. By tracking the exact moment that ATR-normalized rubber band is stretched to its limit and begins to shrink (the velocity delta), you get a high-probability entry for a mean-reversion trade or a deep pullback.

## Source Code

````pine
//@version=6
indicator("EMA Momentum & Cross Engine", overlay=true)

// =========================================================================
// INPUTS
// =========================================================================
emaFastLen      = input.int(20, title="Fast EMA Length", group="Moving Averages")
emaSlowLen      = input.int(50, title="Slow EMA Length", group="Moving Averages")

// --- NEW: Line Labels Settings ---
fastEmaText     = input.string("EMA 20", title="Fast EMA Line Label", group="Moving Averages")
slowEmaText     = input.string("EMA 50", title="Slow EMA Line Label", group="Moving Averages")
showLineLabels  = input.bool(true, title="Show Labels at End of Lines", group="Moving Averages")
lineLabelOffset = input.int(2, title="Line Label Offset (Bars)", minval=0, tooltip="How far to the right the label sits", group="Moving Averages")
lineLabelSizeIn = input.string("Normal", title="Line Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Moving Averages")

atrLen          = input.int(14, title="ATR Length", group="Divergence Settings")
exhaustionLimit = input.float(1.0, title="Exhaustion Spread (ATR Multiplier)", step=0.1, group="Divergence Settings")
deltaThreshold  = input.float(0.1, title="Velocity Delta Threshold", step=0.05, group="Divergence Settings")

maxStandard     = input.int(5, title="Max Visible Standard Crosses", group="Limits & Cooldowns")
maxDiv          = input.int(3, title="Max Visible Div Signals", group="Limits & Cooldowns")
cooldownBars    = input.int(5, title="Div Signal Cooldown (Bars)", group="Limits & Cooldowns")

buyDivText        = input.string("BUY DIV", title="Buy Div Text", group="Labels & Visuals")
buyDivBgColor     = input.color(color.green, title="Buy Div Background Color", group="Labels & Visuals")
buyDivTxtColor    = input.color(color.white, title="Buy Div Text Color", group="Labels & Visuals")

sellDivText       = input.string("SELL DIV", title="Sell Div Text", group="Labels & Visuals")
sellDivBgColor    = input.color(color.red, title="Sell Div Background Color", group="Labels & Visuals")
sellDivTxtColor   = input.color(color.white, title="Sell Div Text Color", group="Labels & Visuals")

bullCrossText     = input.string("BUY", title="Standard Bull Cross Text", group="Labels & Visuals")
bullCrossBgColor  = input.color(color.new(color.gray, 20), title="Standard Buy Background Color", group="Labels & Visuals")
bullCrossTxtColor = input.color(color.white, title="Standard Buy Text Color", group="Labels & Visuals")

bearCrossText     = input.string("SELL", title="Standard Bear Cross Text", group="Labels & Visuals")
bearCrossBgColor  = input.color(color.new(color.gray, 20), title="Standard Sell Background Color", group="Labels & Visuals")
bearCrossTxtColor = input.color(color.white, title="Standard Sell Text Color", group="Labels & Visuals")

labelOffset       = input.float(0.5, title="Signal Label Distance from Wick (ATR)", step=0.1, group="Labels & Visuals")

// =========================================================================
// CALCULATIONS
// =========================================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atr_val = ta.atr(atrLen)
safeAtr = atr_val == 0 ? 0.0001 : atr_val

spread = (emaFast - emaSlow) / safeAtr
deltaSpread = spread - spread[1]

// Convert string input to Pine Script size constant
getLabelSize(txt) =>
    txt == "Tiny" ? size.tiny : txt == "Small" ? size.small : txt == "Normal" ? size.normal : txt == "Large" ? size.large : size.huge

lblSize = getLabelSize(lineLabelSizeIn)

// Dynamic Label Y-Coordinates (Distance from wick)
yPosAbove = high + (safeAtr * labelOffset)
yPosBelow = low - (safeAtr * labelOffset)

// =========================================================================
// STATE TRACKING
// =========================================================================
var bool isBearExhausted = false
var bool isBullExhausted = false
var int lastDivBar = -9999

if spread <= -exhaustionLimit
    isBearExhausted := true
    isBullExhausted := false

if spread >= exhaustionLimit
    isBullExhausted := true
    isBearExhausted := false

if ta.crossover(spread, 0)
    isBearExhausted := false
if ta.crossunder(spread, 0)
    isBullExhausted := false

// =========================================================================
// SIGNAL LOGIC 
// =========================================================================
validBullCross = ta.crossover(emaFast, emaSlow)
validBearCross = ta.crossunder(emaFast, emaSlow)

buyDivSignalRaw = isBearExhausted and (deltaSpread > deltaThreshold) and (close > emaFast)
sellDivSignalRaw = isBullExhausted and (deltaSpread < -deltaThreshold) and (close < emaFast)

bool validBuyDiv = false
bool validSellDiv = false
bool cooldownPassed = (bar_index - lastDivBar) >= cooldownBars

if buyDivSignalRaw and cooldownPassed
    validBuyDiv := true
    lastDivBar := bar_index
    isBearExhausted := false 

if sellDivSignalRaw and cooldownPassed
    validSellDiv := true
    lastDivBar := bar_index
    isBullExhausted := false 

// =========================================================================
// PLOTTING & VISUALS
// =========================================================================
plot(emaFast, color=color.new(color.blue, 0), title="Fast EMA", linewidth=2)
plot(emaSlow, color=color.new(color.red, 0), title="Slow EMA", linewidth=2)

var label[] bullCrossLabels = array.new<label>()
var label[] bearCrossLabels = array.new<label>()
var label[] buyDivLabels = array.new<label>()
var label[] sellDivLabels = array.new<label>()

if validBullCross
    lbl = label.new(bar_index, yPosBelow, text=bullCrossText, style=label.style_label_up, color=bullCrossBgColor, textcolor=bullCrossTxtColor, size=size.small)
    array.push(bullCrossLabels, lbl)
    if array.size(bullCrossLabels) > maxStandard
        label.delete(array.shift(bullCrossLabels))

if validBearCross
    lbl = label.new(bar_index, yPosAbove, text=bearCrossText, style=label.style_label_down, color=bearCrossBgColor, textcolor=bearCrossTxtColor, size=size.small)
    array.push(bearCrossLabels, lbl)
    if array.size(bearCrossLabels) > maxStandard
        label.delete(array.shift(bearCrossLabels))

if validBuyDiv
    lbl = label.new(bar_index, yPosBelow, text=buyDivText, style=label.style_label_up, color=buyDivBgColor, textcolor=buyDivTxtColor, size=size.small)
    array.push(buyDivLabels, lbl)
    if array.size(buyDivLabels) > maxDiv
        label.delete(array.shift(buyDivLabels))

if validSellDiv
    lbl = label.new(bar_index, yPosAbove, text=sellDivText, style=label.style_label_down, color=sellDivBgColor, textcolor=sellDivTxtColor, size=size.small)
    array.push(sellDivLabels, lbl)
    if array.size(sellDivLabels) > maxDiv
        label.delete(array.shift(sellDivLabels))

// =========================================================================
// FLOATING EMA LINE LABELS
// =========================================================================
var label fastLineLbl = na
var label slowLineLbl = na

if showLineLabels and barstate.islast
    int targetBar = bar_index + lineLabelOffset

    if na(fastLineLbl)
        fastLineLbl := label.new(targetBar, emaFast, text=fastEmaText, style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.blue, size=lblSize)
    else
        label.set_xy(fastLineLbl, targetBar, emaFast)
        label.set_text(fastLineLbl, fastEmaText)
        label.set_size(fastLineLbl, lblSize)
        
    if na(slowLineLbl)
        slowLineLbl := label.new(targetBar, emaSlow, text=slowEmaText, style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.red, size=lblSize)
    else
        label.set_xy(slowLineLbl, targetBar, emaSlow)
        label.set_text(slowLineLbl, slowEmaText)
        label.set_size(slowLineLbl, lblSize)
````
