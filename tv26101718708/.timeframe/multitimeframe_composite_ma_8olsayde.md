# Multi-Timeframe Composite MA

- url: https://www.tradingview.com/script/8OlSAyde-Multi-Timeframe-Composite-MA/
- type: indicator
- pine_id: PUB;3d01ec1b3360415a99b446843a6b42ac
- version: 1.0

## Description

[b]Multi-Timeframe Composite MA[/b]

The Multi-Timeframe Composite MA is a trend and confluence tool that combines moving-average values from five fixed timeframes into one composite line.

It calculates the selected moving-average type on:

[list]
[*]4H
[*]1H
[*]30M
[*]15M
[*]5M
[/list]

Each timeframe contributes equally to the composite, with a 20% weight. The five values are averaged into a single line that provides a compact view of multi-timeframe trend direction.

[b]How It Works[/b]

The indicator calculates either an SMA or EMA using the selected Moving Average Length. The default length is 7.

The composite value is calculated as:

(4H MA + 1H MA + 30M MA + 15M MA + 5M MA) / 5

The composite line changes color according to its current direction:

[list]
[*]Green = composite is rising
[*]Red = composite is falling
[*]Gray = composite is flat
[/list]

The individual timeframe moving averages are also included as optional plots and are hidden by default to keep the chart clean.

[b]How to Use[/b]

This indicator is designed primarily as a trend and confluence reference rather than a standalone buy or sell signal.

It is particularly useful on lower timeframes when you want to keep higher-timeframe context visible through a single composite line.

For example, on a lower-timeframe chart, the composite can provide a broader trend reference while price action is analyzed on the current chart timeframe.

Users can select either SMA or EMA and adjust the Moving Average Length according to their analysis.

[b]Lower-Timeframe Use[/b]

This indicator is intended to be especially useful on lower chart timeframes, where the fixed 4H, 1H, 30M, 15M, and 5M components can provide multi-timeframe context without requiring several visible moving-average lines.

The indicator is designed to handle different chart timeframes, including situations where one or more of the fixed component timeframes are lower than the current chart timeframe.

[b]Originality and Purpose[/b]

The purpose of this script is to provide a single composite reference from five specific market timeframes rather than displaying five separate moving averages as independent signals.

The equal-weighted structure gives each timeframe the same contribution to the composite value. The result is intended to simplify multi-timeframe trend observation and reduce visual clutter.

[b]Important Limitations[/b]

This indicator does not generate buy or sell signals and should not be interpreted as a standalone trading system.

The 4H, 1H, 30M, and 15M components can use developing higher-timeframe values while those candles are still forming. Consequently, the composite value and its direction can change before a higher-timeframe candle closes.

The 5M component is included as a fixed part of the composite and is not intended to represent a signal by itself.

As with any moving-average-based tool, the indicator is derived from price data and may react later to sudden market changes.

Use the composite together with your own price-action, market-structure, risk-management, and other analysis rather than treating it as a prediction of future price movement.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Composite MA", shorttitle="MTF Composite MA", overlay=true, dynamic_requests=true)

// ==============================================================================
// 1. INPUTS
// ==============================================================================

maLength = input.int(7, title="Moving Average Length", minval=1)
maType   = input.string("SMA", title="MA Type", options=["SMA", "EMA"])

// ==============================================================================
// 2. MA CALCULATION FUNCTION
// ==============================================================================

// Calculates either an SMA or EMA in the requested timeframe context.
f_ma(src, len, type) =>
    type == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

// ==============================================================================
// 3. MULTI-TIMEFRAME DATA
// ==============================================================================

// Fixed timeframes used by the composite:
// 4H + 1H + 30M + 15M + 5M

// Returns the requested MA correctly whether the requested timeframe is
// higher than, equal to, or lower than the chart timeframe.
f_mtf_ma(tf) =>
    float result = na
    int chartSeconds = timeframe.in_seconds(timeframe.period)
    int requestedSeconds = timeframe.in_seconds(tf)

    if requestedSeconds >= chartSeconds
        // Same or higher timeframe.
        result := request.security(
             syminfo.tickerid,
             tf,
             f_ma(close, maLength, maType)
         )
    else
        // Lower timeframe.
        // Retrieve all available intrabars and use the latest one.
        array<float> ltfValues = request.security_lower_tf(
             syminfo.tickerid,
             tf,
             f_ma(close, maLength, maType)
         )

        if array.size(ltfValues) > 0
            result := array.last(ltfValues)

    result

// ==============================================================================
// 4. FETCH THE FIVE FIXED TIMEFRAMES
// ==============================================================================

ma_4H  = f_mtf_ma("240")
ma_1H  = f_mtf_ma("60")
ma_30m = f_mtf_ma("30")
ma_15m = f_mtf_ma("15")
ma_5m  = f_mtf_ma("5")

// ==============================================================================
// 5. COMPOSITE CALCULATION
// ==============================================================================

// Equal weighting:
// 4H  = 20%
// 1H  = 20%
// 30M = 20%
// 15M = 20%
// 5M  = 20%

bool allValuesAvailable =
     not na(ma_4H) and
     not na(ma_1H) and
     not na(ma_30m) and
     not na(ma_15m) and
     not na(ma_5m)

float compositeMA = allValuesAvailable
     ? (ma_4H + ma_1H + ma_30m + ma_15m + ma_5m) / 5.0
     : na

// ==============================================================================
// 6. COMPOSITE DIRECTION
// ==============================================================================

// Rising   = Green
// Falling  = Red
// Flat     = Gray

lineColor =
     na(compositeMA) or na(compositeMA[1])
     ? color.gray
     : compositeMA > compositeMA[1]
     ? color.new(#26A69A, 0)
     : compositeMA < compositeMA[1]
     ? color.new(#EF5350, 0)
     : color.new(color.gray, 0)

// ==============================================================================
// 7. MAIN COMPOSITE MA
// ==============================================================================

plot(
     compositeMA,
     title="Composite MTF MA",
     color=lineColor,
     linewidth=3
)

// ==============================================================================
// 8. OPTIONAL INDIVIDUAL TIMEFRAME MAs
// ==============================================================================

// Hidden by default to keep the chart clean.
// Users can enable them from the Style settings.

plot(
     ma_4H,
     title="4H MA",
     color=color.new(color.purple, 70),
     display=display.none
)

plot(
     ma_1H,
     title="1H MA",
     color=color.new(color.blue, 70),
     display=display.none
)

plot(
     ma_30m,
     title="30M MA",
     color=color.new(color.teal, 70),
     display=display.none
)

plot(
     ma_15m,
     title="15M MA",
     color=color.new(color.orange, 70),
     display=display.none
)

plot(
     ma_5m,
     title="5M MA",
     color=color.new(color.yellow, 70),
     display=display.none
)
````
