# Native Timeframe Moving Average

- url: https://www.tradingview.com/script/53IxoUrw-Native-Timeframe-Moving-Average/
- type: indicator
- pine_id: PUB;37d7828529414749a414c2ab4edd1f80
- version: 1.0

## Description

📈 Native Timeframe Moving Average

Overview

Native Timeframe Moving Average allows you to plot a moving average that is always calculated from its own selected timeframe, regardless of the chart timeframe you're viewing.

Instead of recalculating the MA using the current chart bars, this indicator performs the entire moving-average calculation inside the selected source timeframe before mapping the result back onto your chart. This ensures the moving average always remains true to its native timeframe.

For example, selecting a 200 SMA on the Daily timeframe will always display the genuine 200-day SMA whether you're viewing a 15-minute, 1-hour, 4-hour, Daily, Weekly, or any other timeframe.

✨ Features

✔ Native timeframe moving averages

✔ SMA, EMA, WMA, RMA & VWMA

✔ Any TradingView timeframe

✔ Developing and Confirmed calculation modes

✔ Connected and Native display modes

✔ Standard MA Offset

✔ Uses TradingView Style settings for colour and line width

✔ No repainting or future leakage

✔ Lightweight and fast

⚙️ Value Modes
📡 Developing (Default)

Includes the active source-timeframe candle in the calculation.

This behaves like traders generally expect when viewing a higher-timeframe moving average on a lower-timeframe chart, allowing the MA to update as the source candle develops.

Perfect for discretionary chart analysis.

🔒 Confirmed

Uses only completed source-timeframe candles.

The plotted value remains unchanged until the next source-timeframe candle closes.

Ideal for:

• Strategies

• Alerts

• Stable signal generation

• Any workflow requiring confirmed higher-timeframe values

📉 Line Modes

🔗 Connected (Default)

Connects each source-timeframe moving-average value using straight lines.

This provides a cleaner, smoother appearance that most traders prefer when analysing trends across multiple timeframes.

Note: The connecting segments are visual interpolation between confirmed source-timeframe values. They improve readability but should not be interpreted as the exact value that existed on every individual chart bar.

🪜 Native

Displays the actual sampled moving-average value available on every chart bar.

When the selected timeframe is higher than the chart timeframe, the line naturally appears as a staircase because the source-timeframe value only updates when that timeframe produces a new value.

This mode is recommended whenever the output is being used for:

• Strategy logic

• Alerts

• Numerical comparisons

• Other indicators

💡 Typical Uses

• Overlay a Daily 200 SMA while trading the 15-minute chart

• View Weekly trend direction without changing chart timeframe

• Display Monthly moving averages on swing-trading charts

• Compare multiple native timeframe moving averages by adding multiple indicator instances

• Keep important higher-timeframe trend references visible while executing on lower timeframes

🎯 Why use this instead of a standard Moving Average?

A standard Moving Average is always calculated from the timeframe of the chart you're viewing.

This indicator keeps the calculation anchored to the timeframe you choose.

That means a 200 Daily SMA always remains a 200 Daily SMA, regardless of whether you're looking at a 5-minute chart or a Weekly chart. It never silently becomes a 200-bar moving average of the current chart timeframe.

🚀 Final Notes

This indicator was designed to provide a clean, reliable and flexible way to work with native timeframe moving averages across any chart.

Whether you're monitoring long-term trend structure while trading intraday or building multi-timeframe confluence into your analysis, Native Timeframe Moving Average keeps your moving averages true to their original timeframe while giving you the flexibility to choose between the smooth appearance of Connected mode and the mathematically exact representation of Native mode.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TomKirk

//@version=6
indicator(
     "Native Timeframe Moving Average",
     shorttitle = "Native TF MA",
     overlay = true)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------

string GROUP_MA   = "Moving Average"
string GROUP_CALC = "Calculation"

string TOOLTIP_TIMEFRAME =
     "The moving average is always calculated from this timeframe, regardless " +
     "of the chart timeframe. When the chart timeframe is higher than the " +
     "selected timeframe, the lower-timeframe MA is sampled onto the chart’s " +
     "larger bars, so not every intrabar movement can be displayed."

string TOOLTIP_VALUE_MODE =
     "Developing includes the active source-timeframe candle, so the current " +
     "MA value may change until that source-timeframe candle closes. Confirmed " +
     "uses only completed source-timeframe candles and remains stable until " +
     "the next source-timeframe close."

string TOOLTIP_LINE_MODE =
     "Connected joins source-timeframe MA points with straight lines and is " +
     "the preferred setting for visual chart analysis. Values between those " +
     "points are visual interpolation and are not the literal MA value that " +
     "existed on every chart bar. Select Native when using the output for " +
     "strategy logic, alerts, numerical comparisons, or mathematically " +
     "accurate bar-by-bar values."

string TOOLTIP_OFFSET =
     "Shifts the plotted line left or right by a number of chart bars, like " +
     "the Offset setting in TradingView’s standard moving averages. It changes " +
     "only the visual position of the plot and does not alter the calculation."

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

string maType = input.string(
     "SMA",
     "Type",
     options = ["SMA", "EMA", "WMA", "RMA", "VWMA"],
     group = GROUP_MA)

string maTimeframe = input.timeframe(
     "1D",
     "Timeframe",
     tooltip = TOOLTIP_TIMEFRAME,
     group = GROUP_MA)

int maLength = input.int(
     200,
     "Length",
     minval = 1,
     group = GROUP_MA)

series float maSource = input.source(
     close,
     "Source",
     group = GROUP_CALC)

string valueMode = input.string(
     "Developing",
     "Value Mode",
     options = ["Developing", "Confirmed"],
     tooltip = TOOLTIP_VALUE_MODE,
     group = GROUP_CALC)

string lineMode = input.string(
     "Connected",
     "Line Mode",
     options = ["Connected", "Native"],
     tooltip = TOOLTIP_LINE_MODE,
     group = GROUP_CALC)

int plotOffset = input.int(
     0,
     "Offset",
     minval = -500,
     maxval = 500,
     tooltip = TOOLTIP_OFFSET,
     group = GROUP_CALC)

//------------------------------------------------------------------------------
// Moving-average helper
//------------------------------------------------------------------------------

ma(series float source, simple int length, simple string averageType) =>
    switch averageType
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "RMA"  => ta.rma(source, length)
        "VWMA" => ta.vwma(source, length)
        => ta.sma(source, length)

//------------------------------------------------------------------------------
// Native-timeframe calculation
//------------------------------------------------------------------------------

bool sourceIsHigher =
     timeframe.in_seconds(maTimeframe) > timeframe.in_seconds()

// Developing values include the active source-timeframe candle.
// The complete MA calculation executes inside the requested context.
float developingMa = request.security(
     syminfo.tickerid,
     maTimeframe,
     ma(maSource, maLength, maType),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

// Confirmed mode offsets the completed MA inside the requested context.
// Higher-timeframe requests use the standard offset + lookahead_on pattern.
// Equal/lower-timeframe requests use lookahead_off for consistent sampling.
float confirmedMa = request.security(
     syminfo.tickerid,
     maTimeframe,
     ma(maSource, maLength, maType)[1],
     gaps = barmerge.gaps_on,
     lookahead = sourceIsHigher
          ? barmerge.lookahead_on
          : barmerge.lookahead_off)

float sparseMa = valueMode == "Confirmed"
     ? confirmedMa
     : developingMa

// Connected leaves gaps between source-timeframe points. The standard line
// plot bridges those gaps diagonally.
//
// Native fills each gap with the last known value, accurately showing the
// value available on each chart bar.
float plottedMa = lineMode == "Connected"
     ? sparseMa
     : fixnan(sparseMa)

//------------------------------------------------------------------------------
plot(
     plottedMa,
     title = "Native Timeframe MA",
     offset = plotOffset)
````
