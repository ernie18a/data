<!-- tradingview-pine-id: PUB;2ddbefdde6914060823e91971b24f2b0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Z-Score Bars

Source: https://www.tradingview.com/script/m0bcriQb-Volume-Z-Score-Bars/

## Description

🍀Overview

[*]Volume Z-Score Bars is a volume-analysis indicator that compares the current volume with its recent average and standard deviation. It calculates a volume Z-score to identify unusually high, normal, or below-normal volume conditions.
[*]The indicator displays volume as color-coded columns in a separate pane and can optionally apply the same volume-intensity coloring to the price-chart candles. Bullish candles use green, while bearish candles use red.

🍀Features

[*]Calculates the volume Z-score using the selected lookback period.
[*]Classifies volume into four categories: extra high, high, normal, and below normal.
[*]Uses adjustable opacity levels to visually represent volume intensity.
[*]Optionally colors price candles according to both candle direction and relative volume strength.
[*]Optionally displays the moving average of volume.
[*]Displays the current Volume Z-Score in the TradingView status line.
[*]Includes separate alert conditions for extra-high and high relative volume.
[*]The indicator requires valid volume statistics and returns no Z-score until sufficient data is available and the volume standard deviation is greater than zero.

🍀Inputs

[*]Lookback Length: Number of bars used to calculate the average volume and volume standard deviation. Default: 20.
[*]Show Volume Average: Displays or hides the moving average of volume in the indicator pane.
[*]Paint Price Bars: Colors price-chart candles using the same direction and opacity logic as the volume bars.
[*]Paint Volume Bars: Applies the relative-volume coloring and opacity to the volume columns.
[*]Extra High Volume: Z-score threshold for the extra-high-volume category. Default: 3.0.
[*]High Volume: Z-score threshold for the high-volume category. Default: 2.0.
[*]Normal Volume: Z-score threshold for the normal-volume category. Default: 1.0.
[*]Extra High Opacity: Opacity applied when the volume Z-score is above the extra-high threshold. Default: 100%.
[*]High Opacity: Opacity applied when the volume Z-score is above the high threshold. Default: 80%.
[*]Normal Opacity: Opacity applied when the volume Z-score is above the normal threshold. Default: 50%.
[*]Below Normal Opacity: Opacity applied when the volume Z-score is at or below the normal threshold. Default: 10%.

🍀Usage

[*]A volume Z-score measures how far the current volume is from its recent average in standard-deviation units.
[*]Readings above 3.0 indicate extra-high relative volume by default. Readings above 2.0 and up to 3.0 indicate high relative volume, while readings above 1.0 and up to 2.0 are classified as normal volume. Readings at or below 1.0 receive the below-normal opacity setting.
[*]Green bars represent candles where the close is greater than or equal to the open. Red bars represent candles where the close is below the open.
[*]Use high-volume readings to help identify increased market participation, potential breakout activity, or significant price movement. Use the indicator together with trend, price structure, support and resistance, and other market-context tools rather than treating volume intensity as a standalone trading signal.
[*]The Extra High Relative Volume alert triggers when the Volume Z-Score is above the Extra High Volume threshold. The High Relative Volume alert triggers when the Z-score is above the High Volume threshold but does not exceed the Extra High Volume threshold.

🍀Acknowledgement

[*]This indicator is built based on [Ghost Candles](https://www.tradingview.com/script/zs9fzekg-Ghost-Candles-BruzX/) by [BruzX](https://www.tradingview.com/u/BruzX/)

🍀Disclaimer

[*]This indicator is provided for informational and educational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument.
[*]Relative volume and Z-score readings do not predict future price direction or guarantee trading results. Alerts and visual signals should be interpreted in context and combined with independent analysis and appropriate risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title = "Volume Z-Score Bars",
     shorttitle = "Vol z-score",
     overlay = false,
     format = format.volume)

// ---------------------- INPUT GROUPS ----------------------
const string GROUP_SETTINGS = "Volume Settings"
const string GROUP_THRESHOLDS = "Z-Score Thresholds"
const string GROUP_OPACITY = "Volume Bar Opacity"

// ---------------------- CONSTANTS ----------------------
const color BULLISH_COLOR = #26a69a
const color BEARISH_COLOR = #ef5350
const color AVERAGE_COLOR = #2962ff

// ---------------------- INPUTS ----------------------
lookback_length = input.int(
     defval = 20,
     title = "Lookback length",
     minval = 5,
     group = GROUP_SETTINGS,
     tooltip = "Bars used to calculate the average volume and volume standard deviation.")

show_volume_average = input.bool(
     defval = true,
     title = "Show volume average",
     group = GROUP_SETTINGS,
     tooltip = "Displays the moving average of volume in the indicator pane.")

paint_price_bars = input.bool(
     defval = true,
     title = "Paint price bars",
     group = GROUP_SETTINGS,
     tooltip = "Colors price-chart candles using the same color and opacity as their volume bars.")

paint_volume_bars = input.bool(
     defval = true,
     title = "Paint volume bars",
     group = GROUP_SETTINGS,
     tooltip = "Applies color and opacity to volume bars based on volume intensity.")

extra_high_threshold = input.float(
     defval = 3.0,
     title = "Extra high volume",
     step = 0.05,
     group = GROUP_THRESHOLDS,
     tooltip = "Volume Z-score required for the extra-high-volume category. This should be greater than the high threshold.")

high_threshold = input.float(
     defval = 2.0,
     title = "High volume",
     step = 0.05,
     group = GROUP_THRESHOLDS,
     tooltip = "Volume Z-score required for the high-volume category. This should be greater than the normal threshold.")

normal_threshold = input.float(
     defval = 1.0,
     title = "Normal volume",
     step = 0.05,
     group = GROUP_THRESHOLDS,
     tooltip = "Volume Z-score required for the normal-volume category.")

extra_high_opacity = input.int(
     defval = 100,
     title = "Extra high opacity %",
     minval = 0,
     maxval = 100,
     group = GROUP_OPACITY,
     tooltip = "Opacity for volume Z-scores above the extra-high threshold.")

high_opacity = input.int(
     defval = 80,
     title = "High opacity %",
     minval = 0,
     maxval = 100,
     group = GROUP_OPACITY,
     tooltip = "Opacity for volume Z-scores above the high threshold.")

normal_opacity = input.int(
     defval = 50,
     title = "Normal opacity %",
     minval = 0,
     maxval = 100,
     group = GROUP_OPACITY,
     tooltip = "Opacity for volume Z-scores above the normal threshold.")

below_normal_opacity = input.int(
     defval = 10,
     title = "Below normal opacity %",
     minval = 0,
     maxval = 100,
     group = GROUP_OPACITY,
     tooltip = "Opacity for volume Z-scores at or below the normal threshold.")

// ---------------------- HELPER FUNCTIONS ----------------------
safe_div(numerator, denominator, fallback) =>
    denominator == 0 or na(denominator) ? fallback : numerator / denominator

// ---------------------- VOLUME Z-SCORE ----------------------
average_volume = ta.sma(volume, lookback_length)
volume_std_dev = ta.stdev(volume, lookback_length)

has_volume_statistics = not na(average_volume) and not na(volume_std_dev) and volume_std_dev > 0

volume_z_score = has_volume_statistics
     ? safe_div(volume - average_volume, volume_std_dev, 0)
     : na

// ---------------------- VOLUME OPACITY CLASSES ----------------------
volume_opacity = na(volume_z_score) ? below_normal_opacity : volume_z_score > extra_high_threshold
     ? extra_high_opacity : volume_z_score > high_threshold
     ? high_opacity : volume_z_score > normal_threshold
     ? normal_opacity : below_normal_opacity

volume_transparency = 100 - volume_opacity

direction_color = close >= open ? BULLISH_COLOR : BEARISH_COLOR
volume_bar_color = paint_volume_bars ? color.new(direction_color, volume_transparency) : direction_color
price_bar_color = paint_price_bars ? color.new(direction_color, volume_transparency) : direction_color

// ---------------------- DISPLAY ----------------------
volume_plot = plot(
     volume,
     title = "Relative Volume",
     color = volume_bar_color,
     style = plot.style_columns)

average_volume_plot = plot(
     show_volume_average ? average_volume : na,
     title = "Volume Average",
     color = AVERAGE_COLOR,
     linewidth = 1)

// ---------------------- PRICE BAR PAINTING ----------------------
barcolor(
     paint_price_bars ? price_bar_color : na,
     title = "Relative Volume Price Bar Color")

// ---------------------- STATUS LINE (Z-SCORE) ----------------------
plot(
     volume_z_score,
     title = "Volume Z-Score",
     display = display.status_line)

// ---------------------- ALERTS ----------------------
alertcondition(
     volume_z_score > extra_high_threshold,
     title = "Extra High Relative Volume",
     message = "Extra-high relative volume on {{ticker}}.")

alertcondition(
     volume_z_score > high_threshold and volume_z_score <= extra_high_threshold,
     title = "High Relative Volume",
     message = "High relative volume on {{ticker}}.")
````
