# EMA 200 Deviation Channels [Statistical Zones] by Zephyros

- url: https://www.tradingview.com/script/Ze74oGQi-ema-200-deviation-channels-statistical-zones-by-zephyros/
- type: indicator
- pine_id: PUB;c44944b5345141fe92e9083282545b1d
- version: 1.0

## Description

EMA 200 Deviation Channels [Statistical Zones] is an adaptive overlay indicator that measures the percentage distance between price and the 200-period Exponential Moving Average and converts the recent distribution of those deviations into dynamic statistical zones.

## Purpose

The indicator is designed to show how unusually far the current price has moved away from EMA 200 relative to its own recent behavior.

Instead of placing channels at fixed percentage distances from the moving average, the script calculates the boundaries separately for the selected symbol, timeframe, and historical lookback. This allows the zones to adapt to instruments with different volatility characteristics.

The zones are not buy or sell signals. They identify statistically stretched price locations where a trader may evaluate the possibility of a reversal, consolidation, or return toward the moving average using their own analysis.

## Calculation Method

The indicator performs the following calculations:

1. Calculates EMA 200 using closing prices.

2. Measures the percentage deviation of each closing price from EMA 200:

   `Deviation = (Close - EMA 200) / EMA 200 × 100`

3. Creates a rolling sample of deviations using the selected History Length.

4. Calculates the 95th percentile and the 5th percentile of that sample.

5. Converts those percentile values back into price levels around the current EMA 200.

6. Calculates additional outer boundaries from the average extension of observations beyond the 95th and 5th percentile levels.

The main statistical boundaries are:

* Upper Level - the price corresponding to the 95th percentile of historical deviations.
* Lower Level - the price corresponding to the 5th percentile of historical deviations.
* Extreme Upper Level - the 95th-percentile deviation plus the average additional extension above that percentile.
* Extreme Lower Level - the 5th-percentile deviation minus the average additional extension below that percentile.

All boundaries are recalculated continuously using the latest rolling sample.

## Visual Interpretation

* Blue line - EMA 200.
* Light red zone - the area between EMA 200 and the Upper Level.
* Light green zone - the area between the Lower Level and EMA 200.
* Darker red zone - the area between the Upper Level and the Extreme Upper Level.
* Darker green zone - the area between the Extreme Lower Level and the Lower Level.

The colors indicate the direction of the deviation from EMA 200. They do not represent automatic long or short recommendations.

The optional `Extreme Upper` and `Extreme Lower` background highlights mark bars whose closing price is above the Upper Level or below the Lower Level. These background highlights are disabled by default and can be enabled manually in the indicator's Style settings.

## History Length

`History Length for Percentiles` determines how many recent deviation observations are used for the statistical calculations.

The default value is 1000 bars.

* A shorter lookback adapts more quickly to recent market behavior but may produce less stable boundaries.
* A longer lookback changes more slowly and represents a broader historical sample.

The appropriate setting depends on the selected market, timeframe, and analytical objective. Changing the symbol, timeframe, or History Length recalculates the entire statistical distribution.

The indicator requires enough historical data to initialize both EMA 200 and the selected percentile lookback. Until sufficient data is available, some zones and statistical values may remain unavailable.

## Statistics Table

The statistics table is disabled by default. It can be enabled through:

`Settings → Inputs → Show Statistics Table`

The table displays:

* Maximum upward deviation in the current sample.
* Maximum downward deviation in the current sample.
* 95th percentile deviation.
* 5th percentile deviation.
* Average extension above the 95th percentile.
* Average extension below the 5th percentile.
* Current price.
* Current EMA 200 value.
* Current percentage deviation.
* Upper and Lower Levels.
* Extreme Upper and Extreme Lower Levels.
* Current numerical zone classification.

## Zone Classification Output

The script includes a hidden numerical output named `ZEP_EMA_DEV_SIGNAL`.

Despite its technical name, this output is not a trading signal. It is only a numerical classification of the current closing price relative to the calculated zones:

* `3` - below the Extreme Lower Level.
* `2` - between the Extreme Lower Level and the Lower Level.
* `1` - between the Lower Level and EMA 200.
* `-1` - between EMA 200 and the Upper Level.
* `-2` - between the Upper Level and the Extreme Upper Level.
* `-3` - above the Extreme Upper Level.
* `0` - insufficient data, undefined levels, or price exactly at EMA 200.

The hidden output can be used for visual inspection, data export, or integration with other Pine Script tools. It does not create orders, alerts, entries, exits, stop-loss levels, or profit targets.

## Suggested Use

1. Select the market and timeframe you want to analyze.
2. Choose a History Length appropriate for the amount of market history you want the indicator to evaluate.
3. Use EMA 200 as the central reference point.
4. Observe whether price is inside the regular deviation area, inside an outer statistical zone, or beyond the outer boundary.
5. Treat the zones as market context rather than standalone entry instructions.
6. Use independent confirmation such as market structure, price reaction, volume, momentum, or another method appropriate to your trading process.

The indicator can be applied to any market and timeframe with sufficient historical bars. All calculations are performed independently for the current chart symbol and timeframe.

## Originality

The original element of this indicator is its two-stage adaptive channel construction.

The first stage uses rolling 5th and 95th percentiles of percentage deviation from EMA 200. The second stage measures the average continuation beyond those percentile boundaries and uses it to create additional outer zones.

As a result, the channel distances are derived from the observed deviation distribution of the current market and timeframe rather than from a fixed percentage or manually selected distance.

This script is an original implementation by Zephyros and is published with open source code so that all calculations can be inspected.

## Limitations

* The indicator does not calculate or guarantee the probability of a reversal.
* Statistically unusual deviation does not mean that price must immediately return to EMA 200.
* Strong directional markets can remain inside or beyond an extreme zone for an extended period.
* All deviation calculations and zone classifications use closing prices, not candle highs or lows.
* Values on the currently open bar can change as its closing price changes.
* The calculated zones depend entirely on the selected symbol, timeframe, available history, and History Length.
* Very large History Length values can increase calculation time.
* The indicator is not a strategy and does not provide backtest results.
* It should not be used as the sole basis for a trading decision.

## Source Code

````pine
//@version=6
indicator(
     title = "EMA 200 Deviation Channels [Statistical Zones] V.2.0 - by Zephyros",
     overlay = true,
     max_bars_back = 5000
)

// Inputs
history_length = input.int(
     1000,
     title = "History Length for Percentiles",
     minval = 1
)

show_statistics_table = input.bool(
     false,
     title = "Show Statistics Table"
)

// EMA 200 calculation
ema200 = ta.ema(close, 200)
price_now = close

// Percentage deviation from EMA 200
deviation = (close - ema200) / ema200 * 100

// Array containing the rolling deviation sample
var float[] dev_array = array.new_float(0)

if not na(deviation)
    array.push(dev_array, deviation)

    if array.size(dev_array) > history_length
        array.shift(dev_array)

// Rolling percentiles
p95 = ta.percentile_nearest_rank(deviation, history_length, 95)
p5 = ta.percentile_nearest_rank(deviation, history_length, 5)

// Rolling statistics
var float max_up = na
var float max_down = na
var float avg_above_p95 = 0.0
var float avg_below_p5 = 0.0

if array.size(dev_array) >= history_length
    max_up := array.max(dev_array)
    max_down := array.min(dev_array)

    // Values above the 95th percentile
    float[] above = array.new_float(0)

    for val in dev_array
        if val > p95
            array.push(above, val)

    if array.size(above) > 0
        float[] diffs_above = array.new_float(0)

        for val in above
            array.push(diffs_above, val - p95)

        avg_above_p95 := array.avg(diffs_above)

    // Values below the 5th percentile
    float[] below = array.new_float(0)

    for val in dev_array
        if val < p5
            array.push(below, val)

    if array.size(below) > 0
        float[] diffs_below = array.new_float(0)

        for val in below
            array.push(diffs_below, p5 - val)

        avg_below_p5 := array.avg(diffs_below)

// Outer statistical boundaries
extreme_upper = ema200 * (1 + (p95 + avg_above_p95) / 100)
extreme_lower = ema200 * (1 + (p5 - avg_below_p5) / 100)

// Main percentile boundaries
upper_level = ema200 * (1 + p95 / 100)
lower_level = ema200 * (1 + p5 / 100)

// Numerical zone classification
int zep_ema_dev_signal = 0

values_ready =
     not na(price_now) and
     not na(ema200) and
     not na(upper_level) and
     not na(lower_level) and
     not na(extreme_upper) and
     not na(extreme_lower)

if values_ready
    if price_now < extreme_lower
        zep_ema_dev_signal := 3
    else if price_now < lower_level and price_now >= extreme_lower
        zep_ema_dev_signal := 2
    else if price_now < ema200 and price_now >= lower_level
        zep_ema_dev_signal := 1
    else if price_now > extreme_upper
        zep_ema_dev_signal := -3
    else if price_now > upper_level and price_now <= extreme_upper
        zep_ema_dev_signal := -2
    else if price_now > ema200 and price_now <= upper_level
        zep_ema_dev_signal := -1

// EMA plot
plot_ema = plot(
     ema200,
     color = color.blue,
     title = "EMA 200"
)

// Invisible boundary plots used to create fills
plot_upper = plot(
     upper_level,
     color = na,
     title = "Upper Level"
)

plot_lower = plot(
     lower_level,
     color = na,
     title = "Lower Level"
)

plot_extreme_upper = plot(
     extreme_upper,
     color = na,
     title = "Extreme Upper Level"
)

plot_extreme_lower = plot(
     extreme_lower,
     color = na,
     title = "Extreme Lower Level"
)

// Hidden numerical state output
plot(
     zep_ema_dev_signal,
     title = "ZEP_EMA_DEV_SIGNAL",
     display = display.none
)

// Main deviation zones
fill(
     plot_ema,
     plot_upper,
     color = color.new(color.red, 70),
     title = "Upper Zone"
)

fill(
     plot_lower,
     plot_ema,
     color = color.new(color.green, 70),
     title = "Lower Zone"
)

// Outer statistical zones
fill(
     plot_upper,
     plot_extreme_upper,
     color = color.new(color.red, 50),
     title = "Extreme Upper Zone"
)

fill(
     plot_extreme_lower,
     plot_lower,
     color = color.new(color.green, 50),
     title = "Extreme Lower Zone"
)

// Optional background highlights.
// display.none makes both items disabled by default in the Style settings.
bgcolor(
     price_now > upper_level ? color.new(color.maroon, 50) : na,
     title = "Extreme Upper",
     display = display.none
)

bgcolor(
     price_now < lower_level ? color.new(color.lime, 50) : na,
     title = "Extreme Lower",
     display = display.none
)

// Statistics table
var table tbl = table.new(
     position.top_right,
     columns = 2,
     rows = 14,
     bgcolor = color.gray,
     border_width = 1
)

if barstate.islast and show_statistics_table
    table.cell(
         tbl,
         0,
         0,
         "Maximum Upward Deviation (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         0,
         str.tostring(max_up, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         1,
         "Maximum Downward Deviation (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         1,
         str.tostring(max_down, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         2,
         "95th Percentile (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         2,
         str.tostring(p95, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         3,
         "5th Percentile (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         3,
         str.tostring(p5, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         4,
         "Average Extension Above P95 (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         4,
         str.tostring(avg_above_p95, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         5,
         "Average Extension Below P5 (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         5,
         str.tostring(avg_below_p5, "#.##"),
         text_color = color.white
    )

    signal_bg =
         zep_ema_dev_signal > 0
         ? color.new(color.lime, 70)
         : zep_ema_dev_signal < 0
         ? color.new(color.red, 70)
         : color.new(color.gray, 70)

    table.cell(
         tbl,
         0,
         6,
         "Current Price",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         6,
         str.tostring(price_now, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         7,
         "EMA 200",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         7,
         str.tostring(ema200, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         8,
         "Current Deviation (%)",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         8,
         str.tostring(deviation, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         9,
         "Upper Level",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         9,
         str.tostring(upper_level, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         10,
         "Lower Level",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         10,
         str.tostring(lower_level, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         11,
         "Extreme Upper Level",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         11,
         str.tostring(extreme_upper, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         12,
         "Extreme Lower Level",
         text_color = color.white
    )

    table.cell(
         tbl,
         1,
         12,
         str.tostring(extreme_lower, "#.##"),
         text_color = color.white
    )

    table.cell(
         tbl,
         0,
         13,
         "ZEP_EMA_DEV_SIGNAL",
         text_color = color.white,
         bgcolor = signal_bg
    )

    table.cell(
         tbl,
         1,
         13,
         str.tostring(zep_ema_dev_signal),
         text_color = color.white,
         bgcolor = signal_bg
    )
````
