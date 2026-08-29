<!-- tradingview-pine-id: PUB;8992d4aad33d44d293fd6111268381c9 -->
<!-- tradingviewscripts-format: 1 -->
# NATR (Normalized ATR) Oscillator

Source: https://www.tradingview.com/script/358ZxT4e-NATR-Normalized-ATR-Oscillator/

## Description

🍀Overview

[*]NATR (Normalized ATR) Oscillator converts Normalized Average True Range into a rolling 0–100 oscillator, making it easier to evaluate current volatility relative to recent market conditions.
[*]NATR is calculated as ATR divided by the current closing price and expressed as a percentage. The indicator then compares that value with the highest and lowest NATR readings over the selected lookback period.

🍀Features

[*]Displays normalized volatility on a 0–100 scale.
[*]Highlights low- and high-volatility conditions with configurable threshold levels.
[*]Includes a 50 midline to identify neutral relative-volatility conditions.
[*]Uses gradient fills to visually emphasize elevated volatility above the midline and subdued volatility below it.
[*]Works across markets and price ranges because ATR is normalized by price.

🍀Inputs

[*]ATR Length — Number of bars used to calculate Average True Range. Default: 14.
[*]NATR Min-Max Lookback — Number of bars used to normalize NATR into the rolling 0–100 oscillator range. Default: 14.
[*]High Volatility Level — Upper threshold used to identify relatively high volatility. Default: 80.
[*]Low Volatility Level — Lower threshold used to identify relatively low volatility. Default: 20.

🍀Usage

[*]Readings above the High Volatility Level indicate that normalized volatility is near the upper end of its recent range. This may occur during breakouts, rapid price moves, or volatile market conditions.
[*]Readings below the Low Volatility Level indicate that normalized volatility is near the lower end of its recent range. This may occur during consolidation, compression, or quieter trading conditions.
[*]Readings near 50 suggest that volatility is relatively neutral compared with the selected lookback period.
[*]Use the oscillator to adapt trade selection, position sizing, stop placement, or strategy expectations to the current volatility regime.
[*]Combine it with trend, momentum, volume, and price-action tools for context. The oscillator measures volatility only; it does not determine market direction.

🍀Disclaimer

[*]This indicator is provided for informational and educational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any asset.
[*]The oscillator measures relative volatility within the selected rolling lookback window. A high or low reading reflects recent context and does not guarantee future price movement, trend direction, or trading performance. Always use independent analysis and appropriate risk management before making trading decisions.

---

## Source Code

````pine
//@version=6
indicator(
     title = "NATR (Normalized ATR) Oscillator",
     shorttitle = "NATR Oscillator",
     overlay = false)

// ---------------------- INPUT GROUPS ----------------------
const string GROUP_SETTINGS = "NATR Settings"

// ---------------------- CONSTANTS ----------------------
const float MID_LEVEL = 50.0

// ---------------------- INPUTS ----------------------
atr_len = input.int(
     defval = 14,
     title = "ATR length",
     minval = 1,
     group = GROUP_SETTINGS,
     tooltip = "Length used to calculate Average True Range.")

natr_lookback = input.int(
     defval = 14,
     title = "NATR min-max lookback",
     minval = 1,
     group = GROUP_SETTINGS,
     tooltip = "Bars used to normalize NATR to a 0-100 oscillator.")

high_volatility_level = input.float(
     defval = 80.0,
     title = "High Volatility Level",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     group = GROUP_SETTINGS,
     tooltip = "Upper threshold for high volatility.")

low_volatility_level = input.float(
     defval = 20.0,
     title = "Low Volatility Level",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     group = GROUP_SETTINGS,
     tooltip = "Lower threshold for low volatility.")

// ---------------------- HELPER FUNCTIONS ----------------------
safe_div(x, y, fallback) =>
    y == 0 or na(y) ? fallback : x / y

// ---------------------- NATR OSCILLATOR ----------------------
// Normalized ATR: ATR as a percentage of the current close.
atr_value = ta.atr(atr_len)
natr = safe_div(atr_value, close, 0.0) * 100.0

// Normalize NATR into a rolling 0-100 range.
highest_natr = ta.highest(natr, natr_lookback)
lowest_natr = ta.lowest(natr, natr_lookback)
natr_range = highest_natr - lowest_natr

natr_oscillator = safe_div(natr - lowest_natr, natr_range, 0.0) * 100.0

// ---------------------- DISPLAY ----------------------
natr_oscillator_plot = plot(
     natr_oscillator,
     title = "NATR Oscillator",
     color = color.blue,
     linewidth = 1)

natr_oscillator_upper_band = hline(
     high_volatility_level,
     "NATR Oscillator Upper Band",
     color = color.gray,
     linestyle = hline.style_dashed)

mid_line = hline(
     MID_LEVEL,
     "Mid Line",
     color = color.new(color.gray, 50),
     linestyle = hline.style_dashed)

natr_oscillator_lower_band = hline(
     low_volatility_level,
     "NATR Oscillator Lower Band",
     color = color.gray,
     linestyle = hline.style_dashed)

fill(natr_oscillator_upper_band, natr_oscillator_lower_band, color=color.rgb(126, 87, 194, 90), title="NATR Oscillator Background Fill")
mid_line_plot = plot(MID_LEVEL, color = na, editable = false, display = display.none)
fill(natr_oscillator_plot, mid_line_plot, 100, high_volatility_level, top_color = color.new(color.green, 80), bottom_color = color.new(color.green, 100),  title = "High Volatility Gradient Fill")
fill(natr_oscillator_plot, mid_line_plot, low_volatility_level,  0,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 80),      title = "Low Volatility Gradient Fill")
````
