# Momentum Volume Trend BB -Pro v6

- url: https://www.tradingview.com/script/VkEHaj6V/
- type: indicator
- pine_id: PUB;9b03e7e446ec4494be23c5984b388fbf
- version: 1.0

## Description

A. Buy Signal
When the "BUY" label appears on the screen, it means the following has occurred:

The price is above the 50 EMA (Uptrend).

The VWAP-RSI value has crossed above 50 (Beginning of positive momentum).

Additional Confirmation: If the candle color is bright lime, this indicates that the purchase is supported by volume, and the signal is more reliable.

B. Sell Signal
When the "SELL" label appears on the screen, it means the following has occurred:

The price is below the 50 EMA (Downtrend).

The VWAP-RSI value has crossed below 50 (Beginning of negative momentum).

Additional Confirmation: If the candle color is bright red, it indicates high selling pressure.

C. Using Bollinger Zones (Take Profit / Exit)
Upper Green Zone (2.0 - 3.0 Divergence): When the price enters this zone, the trend has strengthened considerably, but it is approaching the "overbought" zone. This can be considered a profit-taking point for long positions.

Lower Red Zone (2.0 - 3.0 Divergence): When the price hits here, "oversold" may have occurred. This is a warning to close short positions.

## Source Code

````pine
//@version=6
indicator("Momentum Volume Trend BB -Pro v6", overlay=true)

// ==========================================
// --- Inputs: Momentum & Trend ---
// ==========================================
int momLen      = input.int(14, "Momentum Period", minval=1, group="Momentum Settings")
int trendLen    = input.int(50, "Trend Filter Length", minval=1, group="Momentum Settings")
float volMult   = input.float(1.5, "Volume Threshold Multiplier", step=0.1, group="Momentum Settings")

// ==========================================
// --- Inputs: Bollinger Bands ---
// ==========================================
int bbLen       = input.int(20, "BB Period", minval=1, group="Bollinger Bands")
float bbSrc     = input.source(close, "BB Source", group="Bollinger Bands")
// Updated deviations to 2.0 and 3.0
float multInner = input.float(2.0, "Inner Band StdDev", step=0.1, group="Bollinger Bands")
float multOuter = input.float(3.0, "Outer Band StdDev", step=0.1, group="Bollinger Bands")

// ==========================================
// --- Calculations: Momentum & Volume ---
// ==========================================
float vwapVal    = ta.vwap(close)
float vRsi       = ta.rsi(vwapVal, momLen)
float emaTrend   = ta.ema(close, trendLen)
float volAvg     = ta.sma(volume, 20)
bool isHighVol   = volume > (volAvg * volMult)

bool isBullish   = vRsi > 50 and close > emaTrend
bool isBearish   = vRsi < 50 and close < emaTrend

// ==========================================
// --- Calculations: Bollinger Bands ---
// ==========================================
float bbBasis    = ta.sma(bbSrc, bbLen)
float bbStdDev   = ta.stdev(bbSrc, bbLen)

float upperInner = bbBasis + (multInner * bbStdDev)
float lowerInner = bbBasis - (multInner * bbStdDev)
float upperOuter = bbBasis + (multOuter * bbStdDev)
float lowerOuter = bbBasis - (multOuter * bbStdDev)

// ==========================================
// --- Visuals: Bar Coloring ---
// ==========================================
color barCol = color.gray 

if isBullish
    barCol := isHighVol ? color.lime : color.green
else if isBearish
    barCol := isHighVol ? color.red : color.orange

barcolor(barCol)

// ==========================================
// --- Visuals: Plots & Fills ---
// ==========================================
plot(emaTrend, "Dynamic Trend Line", color = isBullish ? color.teal : isBearish ? color.maroon : color.gray, linewidth=2)

plot(bbBasis, "BB Basis", color=color.gray, linewidth=1)
pUpperInner = plot(upperInner, "Upper Inner Band", color=color.new(color.blue, 50))
pLowerInner = plot(lowerInner, "Lower Inner Band", color=color.new(color.blue, 50))
pUpperOuter = plot(upperOuter, "Upper Outer Band", color=color.new(color.red, 50))
pLowerOuter = plot(lowerOuter, "Lower Outer Band", color=color.new(color.red, 50))

fill(pUpperInner, pUpperOuter, color=color.new(color.green, 90), title="Upper Bullish Zone")
fill(pLowerInner, pLowerOuter, color=color.new(color.red, 90), title="Lower Bearish Zone")

// ==========================================
// --- Signals: Labels ---
// ==========================================
bool longSignal  = ta.crossover(vRsi, 50) and close > emaTrend
bool shortSignal = ta.crossunder(vRsi, 50) and close < emaTrend

if longSignal
    label.new(bar_index, low, "BUY", color=color.lime, style=label.style_label_up, textcolor=color.black, size=size.small)

if shortSignal
    label.new(bar_index, high, "SELL", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.small)
````
