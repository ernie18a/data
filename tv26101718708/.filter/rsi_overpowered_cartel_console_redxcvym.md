# RSI Overpowered [Cartel Console]

- url: https://www.tradingview.com/script/REDxCVym-RSI-Overpowered-Cartel-Console/
- type: indicator
- pine_id: PUB;470b4e064f60456b91219c24bf760c62
- version: 1.0

## Description

# RSI Overpowered [Cartel Console]

RSI Overpowered [Cartel Console] is a momentum and volume-pressure analysis tool designed to provide a broader view of market strength by combining multiple volume-based market internals into a single composite oscillator framework.

Instead of relying solely on traditional price-based RSI calculations, this indicator incorporates Relative Strength Index calculations derived from Positive Volume Index (PVI), Negative Volume Index (NVI), and On-Balance Volume (OBV). These components are blended into a Composite RSI that aims to highlight shifts in participation, accumulation, distribution, and momentum conditions.

The indicator includes multiple layers of analysis:

• Composite RSI built from PVI, NVI, and OBV RSI values
• Smoothed signal line for trend and momentum comparison
• Secondary RSI oscillator derived from the composite calculation
• Configurable overbought and oversold zones
• Trend filtering using Supertrend methodology
• Bullish and bearish momentum signals with trend confirmation
• Divergence detection between price and the Composite RSI
• Dynamic area fills and visual momentum shading
• Built-in alert conditions for key events

### How It Works

The script first calculates three independent volume-based indexes:

• Positive Volume Index (PVI)
• Negative Volume Index (NVI)
• On-Balance Volume (OBV)

An RSI is then calculated for each component. The average of these values forms the Composite RSI, which is subsequently smoothed to reduce noise and improve readability.

A secondary RSI oscillator is generated from the Composite RSI itself, creating an additional layer of momentum analysis that can help identify shifts in directional strength.

### Trend Confirmation

To reduce counter-trend signals, the indicator incorporates a Supertrend-based trend filter.

Bullish momentum signals are generated only when the trend filter indicates a bullish environment.

Bearish momentum signals are generated only when the trend filter indicates a bearish environment.

This approach helps align momentum events with broader directional market conditions.

### Divergence Detection

The indicator automatically searches for potential divergences between price action and the Composite RSI.

Bullish divergence may occur when price forms a lower low while the Composite RSI forms a higher low.

Bearish divergence may occur when price forms a higher high while the Composite RSI forms a lower high.

Divergence signals are visualized directly on the oscillator using pivot-based detection logic.

### Visualization Features

• Composite RSI line
• Smoothed signal line
• Dynamic momentum fills
• Overbought and oversold markers
• Trend-filtered signal circles
• Divergence labels and connecting lines
• Momentum gradient visualization

### Alerts Included

• Bullish Momentum Signal
• Bearish Momentum Signal
• Overbought Event
• Oversold Event

### Notes

This indicator is intended for market analysis and educational purposes only. Signals, divergences, trend filters, and oscillator conditions should be used alongside a complete trading plan and appropriate risk management techniques.

No indicator can guarantee future market outcomes, and all market decisions remain the responsibility of the user.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CartelConsole

//@version=6
indicator("RSI Overpowered [Cartel Console]", overlay = false, max_lines_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiLen      = input.int(10, "RSI Length", minval = 1, tooltip = "Length for RSI calculations.")
smoothLen   = input.int(5, "RSI Smoothing", minval = 1, tooltip = "EMA smoothing length for the composite RSI.")
oscSmooth   = input.int(3, "Oscillator Smooth", minval = 1, tooltip = "EMA smoothing length for the composite RSI oscillator.")

obLevel     = input.float(70.0, "Overbought", tooltip = "Overbought level for RSI and signals.")
osLevel     = input.float(30.0, "Oversold", tooltip = "Oversold level for RSI and signals.")

stFactor    = input.float(3.0, "Trend Factor", group = "Trend Filter", tooltip = "ATR multiplier for the Supertrend trend filter.")
stAtrLen    = input.int(10, "Trend ATR Length", group = "Trend Filter", tooltip = "ATR length for the Supertrend trend filter.")

pivotRight  = input.int(5, "Pivot Right", group = "Divergence", tooltip = "Right bars for divergence pivots.")
pivotLeft   = input.int(5, "Pivot Left", group = "Divergence", tooltip = "Left bars for divergence pivots.")
maxBars     = input.int(60, "Max Lookback", group = "Divergence", tooltip = "Maximum bars between pivots for divergence.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Pressure Components (PVI, NVI, OBV)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float pvi = 1000.0
pvi := volume > volume[1] ? nz(pvi[1], 1000.0) * (1 + (close - close[1]) / close[1]) : nz(pvi[1], 1000.0)

var float nvi = 1000.0
nvi := volume < volume[1] ? nz(nvi[1], 1000.0) * (1 + (close - close[1]) / close[1]) : nz(nvi[1], 1000.0)

var float obv = 0.0
obv += close > close[1] ? volume : close < close[1] ? -volume : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Component RSIs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pviRSI = ta.rsi(pvi, rsiLen)
nviRSI = ta.rsi(nvi, rsiLen)
obvRSI = ta.rsi(obv, rsiLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Composite RSI Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
composite = (pviRSI + nviRSI + obvRSI) / 3.0

smooth = ta.ema(composite, smoothLen)
signal = ta.ema(smooth, smoothLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Composite RSI Oscillator
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
compositeRSI = ta.rsi(composite, rsiLen)
compositeRSI := ta.ema(compositeRSI, oscSmooth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Supertrend Filter
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[st, stDir] = ta.supertrend(stFactor, stAtrLen)

isBullishTrend = stDir < 0
isBearishTrend = stDir > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullSignal = ta.crossover(compositeRSI, osLevel) and isBullishTrend
bearSignal = ta.crossunder(compositeRSI, obLevel) and isBearishTrend

rsiOB = smooth >= obLevel and smooth[1] < obLevel
rsiOS = smooth <= osLevel and smooth[1] > osLevel

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Divergence on Composite RSI (smooth)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Look for pivots in the Composite RSI
plFound = ta.pivothigh(smooth, pivotLeft, pivotRight)
phFound = ta.pivotlow(smooth, pivotLeft, pivotRight)

// To check if the pivots are in the OB/OS zones, we must reference the smooth value at the pivot point
pivotIndex = pivotRight

// High Pivot (Bearish Divergence)
smoothPh = ta.pivothigh(smooth, pivotLeft, pivotRight)
pricePh = ta.pivothigh(high, pivotLeft, pivotRight)

var float lastSmoothPh = na
var float lastPricePh = na
var int lastPhBar = na

if not na(smoothPh) and smooth[pivotIndex] >= obLevel
    if not na(lastSmoothPh) and (bar_index - pivotIndex - lastPhBar) <= maxBars
        // Bearish divergence: Price makes higher high, oscillator makes lower high
        if high[pivotIndex] > lastPricePh and smooth[pivotIndex] < lastSmoothPh
            line.new(lastPhBar, lastSmoothPh, bar_index - pivotIndex, smooth[pivotIndex], color = color.new(#f23645, 0), width = 2)
            label.new(bar_index - pivotIndex, smooth[pivotIndex], "Bear Div", color = color.new(#00000000, 100), style = label.style_label_down, textcolor = color.new(#f23645, 0), size = size.tiny)
            
    lastSmoothPh := smooth[pivotIndex]
    lastPricePh := high[pivotIndex]
    lastPhBar := bar_index - pivotIndex

// Low Pivot (Bullish Divergence)
smoothPl = ta.pivotlow(smooth, pivotLeft, pivotRight)
pricePl = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSmoothPl = na
var float lastPricePl = na
var int lastPlBar = na

if not na(smoothPl) and smooth[pivotIndex] <= osLevel
    if not na(lastSmoothPl) and (bar_index - pivotIndex - lastPlBar) <= maxBars
        // Bullish divergence: Price makes lower low, oscillator makes higher low
        if low[pivotIndex] < lastPricePl and smooth[pivotIndex] > lastSmoothPl
            line.new(lastPlBar, lastSmoothPl, bar_index - pivotIndex, smooth[pivotIndex], color = color.new(#089981, 0), width = 2)
            label.new(bar_index - pivotIndex, smooth[pivotIndex], "Bull Div", color = color.new(#00000000, 100), style = label.style_label_up, textcolor = color.new(#089981, 0), size = size.tiny)
            
    lastSmoothPl := smooth[pivotIndex]
    lastPricePl := low[pivotIndex]
    lastPlBar := bar_index - pivotIndex

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Levels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hline(obLevel, "Overbought", color = color.new(#f23645, 50), linestyle = hline.style_dashed)
hline(50, "Midline", color = color.new(#787b86, 50), linestyle = hline.style_dotted)
hline(osLevel, "Oversold", color = color.new(#089981, 50), linestyle = hline.style_dashed)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals: Composite RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
p1 = plot(smooth, title = "Composite RSI", color = color.new(#089981, 0), linewidth = 2)
p2 = plot(signal, title = "Signal", color = color.rgb(242, 54, 70, 96), linewidth = 1)
fill(p1, p2, color = smooth >= signal ? color.new(#089981, 70) : color.new(#f23645, 70))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals: Composite RSI Oscillator
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiColor = compositeRSI > compositeRSI[1] ? color.rgb(0, 187, 212, 73) : color.rgb(255, 82, 82, 78)
oscPlot = plot(compositeRSI, title = "Composite RSI Oscillator", color = rsiColor, linewidth = 2)
midPlot = plot(50, display = display.none)

fill(oscPlot, midPlot, color = compositeRSI > 50 ? 
  color.from_gradient(compositeRSI, 50, 100, color.new(#089981, 100), color.new(#089981, 20)) : 
  color.from_gradient(compositeRSI, 0, 50, color.new(#f23645, 20), color.new(#f23645, 100)))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals: Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(bullSignal ? compositeRSI : na, title = "Bull RSI Signal", style = shape.circle, location = location.absolute, size = size.tiny, color = #00bcd4)
plotshape(bearSignal ? compositeRSI : na, title = "Bear RSI Signal", style = shape.circle, location = location.absolute, size = size.tiny, color = #ff5252)

plotshape(rsiOB ? obLevel : na, title = "RSI Overbought", style = shape.triangledown, location = location.absolute, color = #f23645, size = size.tiny)
plotshape(rsiOS ? osLevel : na, title = "RSI Oversold", style = shape.triangleup, location = location.absolute, color = #089981, size = size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullSignal, title = "Bullish RSI Signal", message = "Composite RSI crossed above Oversold with bullish Supertrend")
alertcondition(bearSignal, title = "Bearish RSI Signal", message = "Composite RSI crossed below Overbought with bearish Supertrend")
alertcondition(rsiOB, title = "RSI Overbought", message = "Composite RSI entered Overbought zone")
alertcondition(rsiOS, title = "RSI Oversold", message = "Composite RSI entered Oversold zone")
````
