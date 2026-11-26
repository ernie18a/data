# Negative Volume Index Oscillator [ZOM]

- url: https://www.tradingview.com/script/6xHI4Y1z-Negative-Volume-Index-Oscillator-ZOM/
- type: indicator
- pine_id: PUB;4f91bf0fc85e4395a2fbbffba8890bef
- version: 1.0

## Description

[b]Negative Volume Index Oscillator [ZOM] (NVI Oscillator)[/b] is a momentum-based indicator designed to highlight underlying market activity by focusing on periods of declining volume. Built around the classic [b]Negative Volume Index[/b] [b](NVI)[/b], this tool transforms the raw data into a normalized oscillator, making it easier to interpret shifts in trend, momentum, and potential reversals.

The oscillator measures the deviation of smoothed [b]NVI[/b] from its long-term average, presenting this relationship as a percentage-based value centered around a zero line. This allows traders to quickly identify whether price action is supported by quieter, more “[i]informed[/i]” market participation, which is often associated with institutional positioning.

A configurable signal line is included to help identify momentum shifts through crossovers and crossunders. These interactions can be used to spot early trend changes or confirm continuation depending on market context.

To provide additional structure, the indicator includes optional volatility bands derived from standard deviation. These bands help identify statistically stretched conditions where price may be overextended, increasing the likelihood of mean reversion or consolidation.

The script also features built-in divergence detection, comparing oscillator movement to price action. Bullish and bearish divergences are automatically identified, offering early warning signals of potential reversals when momentum and price begin to disagree.

[b]Key features include:[/b]
- Oscillator derived from smoothed Negative Volume Index
- Signal line with multiple moving average options
- Volatility bands for identifying extreme conditions
- Histogram visualization for momentum strength
- Automatic bullish and bearish divergence detection
- Crossover and crossunder markers for signal clarity
- Fully customizable smoothing, lengths, and visual settings

This indicator is designed to complement price action analysis by providing a deeper view into momentum behavior during low-volume conditions, helping traders identify potential turning points and confirm trend strength.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Negative Volume Index Oscillator [ZOM]", "NVI Oscillator", timeframe = "", timeframe_gaps = true)

string GROUP_MAIN = "Main Settings"
string GROUP_BANDS = "Volatility Bands"
string GROUP_DIV  = "Divergences"
string GROUP_VIS  = "Visuals"

int   lenInput      = input.int(255, "NVI Average Length", 1, group = GROUP_MAIN, tooltip = "Length for the baseline EMA used to center the oscillator.")
int   smoothInput   = input.int(10, "NVI Smoothing", 1, group = GROUP_MAIN, tooltip = "Smooths the raw NVI to reduce noise. Higher values lead to a smoother indicator.")
string maTypeInput  = input.string("EMA", "Signal MA Type", options = ["EMA", "SMA", "RMA", "WMA"], group = GROUP_MAIN)
int   signalLen     = input.int(15, "Signal Length", 1, group = GROUP_MAIN, tooltip = "Length of the signal line. Increased for less noise.")

bool  showBands     = input.bool(true, "Show Volatility Bands", group = GROUP_BANDS)
float multInput     = input.float(2.0, "Band Multiplier", 0.1, group = GROUP_BANDS)
int   bandLen       = input.int(50, "Band Period", 1, group = GROUP_BANDS)

bool  showDiv       = input.bool(true, "Show Divergences", group = GROUP_DIV)
int   divLookback   = input.int(5, "Div Lookback Right", 1, group = GROUP_DIV)
int   divRange      = input.int(60, "Div Lookback Left", 10, group = GROUP_DIV)

color bullColor     = input.color(#2196f3, "Bullish Color", group = GROUP_VIS, inline = "Colors")
color bearColor     = input.color(#787b86, "Bearish Color", group = GROUP_VIS, inline = "Colors")

ma(src, len, type) =>
    switch type
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "RMA" => ta.rma(src, len)
        "WMA" => ta.wma(src, len)
        => src

float rawNvi = ta.nvi * 1000.0

float smoothedNvi = ta.ema(rawNvi, smoothInput)

float baseline = ta.ema(smoothedNvi, lenInput)
float nviOsc = baseline != 0 ? (smoothedNvi - baseline) / baseline * 100 : 0

float signal = ma(nviOsc, signalLen, maTypeInput)

float stdDev = ta.stdev(nviOsc, bandLen)
float upperBand = multInput * stdDev
float lowerBand = -multInput * stdDev

float hist = nviOsc - signal

float top = ta.pivothigh(nviOsc, divLookback, divLookback)
float bot = ta.pivotlow(nviOsc, divLookback, divLookback)

float botVal   = ta.valuewhen(not na(bot), bot, 0)
float lowPrice = ta.valuewhen(not na(bot), low[divLookback], 0)
float prevBot  = ta.valuewhen(not na(bot), bot, 1)
float prevLow  = ta.valuewhen(not na(bot), low[divLookback], 1)
float lowRange = ta.lowest(nviOsc, divRange)

float topVal    = ta.valuewhen(not na(top), top, 0)
float highPrice = ta.valuewhen(not na(top), high[divLookback], 0)
float prevTop   = ta.valuewhen(not na(top), top, 1)
float prevHigh  = ta.valuewhen(not na(top), high[divLookback], 1)
float highRange = ta.highest(nviOsc, divRange)

bool isBullDiv = showDiv and not na(bot) and botVal > prevBot and lowPrice < prevLow and lowRange == botVal
bool isBearDiv = showDiv and not na(top) and topVal < prevTop and highPrice > prevHigh and highRange == topVal

hline(0, "Zero Line", color.new(chart.fg_color, 80), hline.style_dotted)
p_upper = plot(showBands ? upperBand : na, "Upper Band", color.new(chart.fg_color, 70), style = plot.style_linebr)
p_lower = plot(showBands ? lowerBand : na, "Lower Band", color.new(chart.fg_color, 70), style = plot.style_linebr)

color oscColor = nviOsc > 0 ? bullColor : bearColor
p_osc = plot(nviOsc, "NVI Oscillator", oscColor, 2)
plot(signal, "Signal Line", #ff9800, 1, plot.style_line)

fill(p_osc, plot(0), nviOsc, 0, color.new(oscColor, 50), color.new(oscColor, 100), "Oscillator Fill")

plot(hist, "Histogram", color.new(oscColor, 60), 2, plot.style_columns)

plotshape(ta.crossover(nviOsc, signal), "Crossover", shape.triangleup, location.bottom, bullColor, size = size.tiny)
plotshape(ta.crossunder(nviOsc, signal), "Crossunder", shape.triangledown, location.top, bearColor, size = size.tiny)

plotshape(isBullDiv ? nviOsc[divLookback] : na, "Bullish Div", shape.labelup, location.absolute, bullColor, offset = -divLookback, text = "BULL", textcolor = chart.fg_color, size = size.small)
plotshape(isBearDiv ? nviOsc[divLookback] : na, "Bearish Div", shape.labeldown, location.absolute, bearColor, offset = -divLookback, text = "BEAR", textcolor = chart.fg_color, size = size.small)

if ta.cum(nz(volume)) == 0.0 and barstate.islastconfirmedhistory
    runtime.error("No volume is provided by the data vendor.")

alertcondition(ta.crossover(nviOsc, signal), "NVI Cross Over Signal", "NVI Oscillator crossed above signal line")
alertcondition(ta.crossunder(nviOsc, signal), "NVI Cross Under Signal", "NVI Oscillator crossed below signal line")
alertcondition(isBullDiv, "Bullish Divergence", "NVI Bullish Divergence detected")
alertcondition(isBearDiv, "Bearish Divergence", "NVI Bearish Divergence detected")
````
