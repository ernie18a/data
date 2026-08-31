<!-- tradingview-pine-id: PUB;1398b68df71842d9b5f53b3ef7e0b824 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Pro - RVOL States + MA

Source: https://www.tradingview.com/script/bEP7on0P-Volume-Pro-RVOL-States-MA/

## Description

Volume Pro is an enhanced volume indicator designed to provide greater visual control and make abnormal trading activity easier to identify than with the standard TradingView Volume indicator.

The indicator displays trading volume for each chart bar while comparing current volume against a configurable historical average. Volume bars are automatically classified into different relative-volume states, allowing unusually high participation to stand out immediately.

Key Features:

Displays volume synchronized with each price candle.
Adjustable volume-bar width for improved spacing and chart readability.
Configurable colors for normal up-volume and normal down-volume bars.
Identifies High Relative Volume when volume exceeds a configurable multiple of average volume, such as 2×.
Identifies Extreme Relative Volume when volume exceeds a higher configurable threshold, such as 3× or 5×.
Relative Volume (RVOL) is calculated by dividing the current bar's volume by the average volume over the selected lookback period.
Configurable RVOL lookback period, with 20 bars as the default.
Configurable High and Extreme RVOL thresholds.
Displays a configurable moving-average line across volume bars to provide a visual baseline for current versus typical volume.
Supports SMA, EMA, WMA, and RMA volume moving averages.
Adjustable moving-average length, color, and line width.
Adjustable volume-bar colors and transparency.

Default Volume Classification:

Normal Up Volume: Volume below 2× average with positive price direction.
Normal Down Volume: Volume below 2× average with negative price direction.
High Relative Volume: Volume at or above 2× average but below 3× average.
Extreme Relative Volume: Volume at or above 3× average.

For example, if average volume is 500,000 shares, a 1,250,000-share bar represents 2.5× relative volume and is classified as High Relative Volume. A 2,000,000-share bar represents 4× relative volume and is classified as Extreme Relative Volume.

The indicator is intended to make changes in market participation easier to recognize visually, including volume expansion associated with momentum, breakouts, reversals, increased selling pressure, and other significant price movements.

All major settings are configurable so the indicator can be adapted to different securities, chart timeframes, trading styles, and market conditions.

Note: Relative-volume measurements in this indicator compare each bar's volume with a moving average of recent chart-bar volume. This is different from time-of-day normalized RVOL, which compares a bar with corresponding time periods from previous trading sessions. Volume and RVOL should be evaluated together with price action and other market information rather than used as standalone buy or sell signals.

---

## Source Code

````pine
//@version=6
indicator("Volume Pro - RVOL States + MA", shorttitle="Volume Pro", overlay=false, format=format.volume)

//====================================================
// VOLUME BAR SETTINGS
//====================================================

groupVolume = "Volume Bars"

barWidth = input.int(
     2,
     title="Volume Bar Width",
     minval=1,
     maxval=50,
     step=1,
     group=groupVolume,
     tooltip="Controls histogram bar width. Lower values create more visual space between bars."
)

barTransparency = input.int(
     0,
     title="Bar Transparency",
     minval=0,
     maxval=100,
     group=groupVolume
)


//====================================================
// VOLUME STATE COLORS
//====================================================

groupColors = "Volume State Colors"

normalUpColor = input.color(
     color.rgb(38, 166, 154),
     title="Normal Up Volume",
     group=groupColors
)

normalDownColor = input.color(
     color.rgb(239, 83, 80),
     title="Normal Down Volume",
     group=groupColors
)

highVolumeColor = input.color(
     color.orange,
     title="High Relative Volume",
     group=groupColors
)

extremeVolumeColor = input.color(
     color.fuchsia,
     title="Extreme Relative Volume",
     group=groupColors
)


//====================================================
// RELATIVE VOLUME SETTINGS
//====================================================

groupRVOL = "Relative Volume"

rvolLength = input.int(
     20,
     title="RVOL Average Length",
     minval=1,
     group=groupRVOL,
     tooltip="Number of bars used to calculate average volume."
)

highThreshold = input.float(
     2.0,
     title="High Volume Threshold",
     minval=1.0,
     step=0.1,
     group=groupRVOL,
     tooltip="Example: 2.0 means current volume is at least 2x average volume."
)

extremeThreshold = input.float(
     3.0,
     title="Extreme Volume Threshold",
     minval=1.0,
     step=0.1,
     group=groupRVOL,
     tooltip="Example: 3.0 means current volume is at least 3x average volume."
)


//====================================================
// MOVING AVERAGE SETTINGS
//====================================================

groupMA = "Volume Moving Average"

showMA = input.bool(
     true,
     title="Show Volume Moving Average",
     group=groupMA
)

maType = input.string(
     "SMA",
     title="MA Type",
     options=["SMA", "EMA", "WMA", "RMA"],
     group=groupMA
)

maLength = input.int(
     20,
     title="MA Length",
     minval=1,
     group=groupMA
)

maColor = input.color(
     color.yellow,
     title="MA Color",
     group=groupMA
)

maWidth = input.int(
     2,
     title="MA Line Width",
     minval=1,
     maxval=5,
     group=groupMA
)


//====================================================
// VOLUME AVERAGE / RVOL
//====================================================

rvolAverage = ta.sma(volume, rvolLength)

rvol = rvolAverage > 0
     ? volume / rvolAverage
     : na


//====================================================
// PRICE DIRECTION
//====================================================

// Similar visual behavior to TradingView's volume bars.
// Current bar closes higher/equal to prior close = Up.
isUp = close >= close[1]


//====================================================
// VOLUME STATE CLASSIFICATION
//====================================================

isExtremeVolume = rvol >= extremeThreshold

isHighVolume =
     rvol >= highThreshold and
     rvol < extremeThreshold

isNormalVolume =
     rvol < highThreshold


//====================================================
// BAR COLOR LOGIC
//====================================================

// Priority:
// 1. Extreme Volume
// 2. High Volume
// 3. Normal Up
// 4. Normal Down

volumeColor =
     isExtremeVolume
     ? extremeVolumeColor
     : isHighVolume
     ? highVolumeColor
     : isUp
     ? normalUpColor
     : normalDownColor

volumeColorFinal =
     color.new(volumeColor, barTransparency)


//====================================================
// VOLUME MOVING AVERAGE
//====================================================

volumeMA = switch maType
    "SMA" => ta.sma(volume, maLength)
    "EMA" => ta.ema(volume, maLength)
    "WMA" => ta.wma(volume, maLength)
    "RMA" => ta.rma(volume, maLength)
    => ta.sma(volume, maLength)


//====================================================
// PLOT VOLUME
//====================================================

plot(
     volume,
     title="Volume",
     style=plot.style_histogram,
     linewidth=barWidth,
     color=volumeColorFinal,
     histbase=0
)


//====================================================
// PLOT MOVING AVERAGE
//====================================================

plot(
     showMA ? volumeMA : na,
     title="Volume MA",
     color=maColor,
     linewidth=maWidth
)
````
