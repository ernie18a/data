# Scaled Moving Average

- url: https://www.tradingview.com/script/nGvIUWOa-Scaled-Moving-Average/
- type: indicator
- pine_id: PUB;625e2cc49b9c44238493d44903f33c50
- version: 1.0

## Description

Draws a moving average (SMA / EMA / etc.) whose values are multiplied by a factor of your choice. 

Designed to enable you set alerts for when price comes within a certain distance of a moving average but doesn't quite hit it (e.g. draw an EMA multiplied by 1.01 so you can set alerts for when price comes within 1% of the EMA)

It arguably features an improvement over the built-in tradingview SMA/EMAs: When the MA is a higher timeframe than the chart and "Wait for timeframe closes" is disabled, this indicator remains a smooth line diagonally connecting MA points, while the built-in indicators turn into steplines.

There are two differences between VWMA and rolling VWAP:
[list=1]
[*]e.g. a 100-day VWMA won't show anything for the first 99 days, but rolling VWAP will.
[*]if you select e.g. a 2-day VWMA, it is calculated based on only the highs, lows, closes, and volumes of two daily candlesticks, but VWAP is calculated with millisecond-level precision no matter how high of a timeframe you select.
[/list]

## Source Code

````pine
//@version=6
indicator(title="Scaled Moving Average", shorttitle="Scaled MA", overlay=true)

import PineCoders/ConditionalAverages/2 as pc

// Inputs
maType = input.string("SMA", "",
     options = ["SMA", "EMA", "HMA", "WMA", "VWMA", "RMA (SMMA)", "Rolling VWAP"], inline="ma")
len    = input.int(200, "Length", minval = 1, inline="ma")
src    = input.source(close, "", inline="ma")
scale  = input.float(0.5, "Scale (e.g. 2 for 2x)", step = 0.01)
tf     = input.timeframe("", "Timeframe", group="Calculation")  
waitTfClose = input.bool(true, "Wait for timeframe closes", group="Calculation")
offset = input.int(title="Offset", defval=0, display = display.none, group="Calculation")

// @function            Calculates a high-resolution rolling VWAP, e.g. if a 2-day VWAP is selected, it will calculate n = 2 * (milliseconds in a day), and plot an n-millisecond VWAP
// @returns             (int) the volume-weighted sum of `src` values divided by the volume sum.
//rollingVWAP() =>
    // Stop the indicator and raise an error if no volume data is available by the last bar.
    //if ta.cum(nz(volume)) == 0 and barstate.islast
    //    runtime.error("No volume is provided by the data vendor.")
    //int timeInMs = timeframe.in_seconds(tf) * 1000 * len
    //float sumSrcVol    = pc.totalForTimeWhen(src * volume, timeInMs, true, 0)
    //float sumVol       = pc.totalForTimeWhen(volume, timeInMs, true, 0) //args from TV's rolling vwap: (volume, timeInMs, minBarsInput)
    //float result = sumSrcVol / sumVol

// Selected moving average
maValue = switch maType
    "SMA"        => ta.sma(src, len)
    "EMA"        => ta.ema(src, len)
    "HMA"        => ta.hma(src, len)
    "WMA"        => ta.wma(src, len)
    "VWMA"       => ta.vwma(src, len)
    "RMA (SMMA)" => ta.rma(src, len)
    //"Rolling VWAP" => rollingVWAP() // old rudimentary VWAP code: math.sum(src * volume, len) / math.sum(volume, len)
    => na // => ta.sma(src, len)

float plotValue = na

if maType == "Rolling VWAP"   
    // Stop the indicator and raise an error if no volume data is available by the last bar.
    if ta.cum(nz(volume)) == 0 and barstate.islast
        runtime.error("No volume is provided by the data vendor.")
    int timeInMs = timeframe.in_seconds(tf) * 1000 * len
    float sumSrcVol    = pc.totalForTimeWhen(src * volume, timeInMs, true, 0)
    float sumVol       = pc.totalForTimeWhen(volume, timeInMs, true, 0) //args from TV's rolling vwap: (volume, timeInMs, minBarsInput)
    plotValue := sumSrcVol / sumVol
    //plotValue := rollingVWAP()
else
    // Request the HTF MA without shifting it
    htfMa = request.security(
        syminfo.tickerid,
        tf,
        maValue,
        lookahead = barmerge.lookahead_on)

    // Identify the final chart bar of each higher-timeframe bar

    // Close time of the HTF candle containing the current chart bar
    htfCloseTime = request.security(syminfo.tickerid, tf, time_close,
        lookahead = barmerge.lookahead_on)

    // True only on the final LTF candle of the HTF candle
    isHtfCloseBar = time_close == htfCloseTime

    // When enabled, show a value only on completed HTF closes
    // Checked: only confirmed HTF closes.
    // Unchecked: developing HTF value repaints on every realtime LTF candle;
    // historical values remain only at HTF closes.
    plotValue := waitTfClose ?
         (isHtfCloseBar and barstate.isconfirmed ? htfMa : na) :
         (isHtfCloseBar or barstate.isrealtime ? htfMa : na)


// Apply scale
out = plotValue * scale

// Plot
plot(out, "Scaled MA", color = color.black, linewidth = 1, offset = offset, style = plot.style_line) // line, stepline, etc.
````
