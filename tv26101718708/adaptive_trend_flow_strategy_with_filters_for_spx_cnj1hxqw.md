# Adaptive Trend Flow Strategy with Filters for SPX

- url: https://www.tradingview.com/script/CNJ1hXQw-Adaptive-Trend-Flow-Strategy-with-Filters-for-SPX/
- type: strategy
- pine_id: PUB;77839ca577044cf398b8af0ff29e9ab9
- version: 1.0

## Description

The Adaptive Trend Flow Strategy with Filters for SPX is a complete trading algorithm designed to identify traits and offer actionable alerts for the SPX index. This Pine Script approach leverages superior technical signs and user-described parameters to evolve to marketplace conditions and optimize performance.

[b]Key Features and Functionality[/b]

Dynamic Trend Detection: Utilizes a dual EMA-based totally adaptive method for fashion calculation.
The script smooths volatility the usage of an EMA filter and adjusts sensitivity through the sensitivity enter. This allows for real-time adaptability to market fluctuations.
Trend Filters for Precision:

SMA Filter: A Simple Moving Average (SMA) guarantees that trades are achieved best while the rate aligns with the shifting average trend, minimizing false indicators.
MACD Filter: The Moving Average Convergence Divergence (MACD) adds some other layer of confirmation with the aid of requiring alignment among the MACD line and its sign line.
Signal Generation:

Long Signals: Triggered when the fashion transitions from bearish to bullish, with all filters confirming the pass.
Short Signals: Triggered while the trend shifts from bullish to bearish, imparting opportunities for final positions.
User Customization:

Adjustable parameters for EMAs, smoothing duration, and sensitivity make certain the strategy can adapt to numerous buying and selling patterns.
Enable or disable filters (SMA or MACD) based totally on particular market conditions or consumer possibilities.

Leverage and Position Sizing: Incorporates a leverage aspect for dynamic position sizing.
Automatically calculates the exchange length based on account fairness and the leverage element, making sure hazard control is in area.

Visual Enhancements: Plots adaptive fashion ranges (foundation, top, decrease) for actual-time insights into marketplace conditions.
Color-coded bars and heritage to visually represent bullish or bearish developments.
Custom labels indicating crossover and crossunder occasions for clean sign visualization.

Alerts and Automation: Configurable alerts for each lengthy and quick indicators, well matched with automated buying and selling structures like plugpine.Com.
JSON-based alert messages consist of account credentials, motion type, and calculated position length for seamless integration.

Backtesting and Realistic Assumptions: Includes practical slippage, commissions, and preliminary capital settings for backtesting accuracy.
Leverages excessive-frequency trade sampling to make certain strong strategy assessment.

[b]How It Works[/b]

Trend Calculation: The method derives a principal trend basis with the aid of combining fast and gradual EMAs. It then uses marketplace volatility to calculate adaptive upper and decrease obstacles, creating a dynamic channel.

Filter Integration: SMA and MACD filters work in tandem with the fashion calculation to ensure that handiest excessive-probability signals are accomplished.

Signal Execution: Signals are generated whilst the charge breaches those dynamic tiers and aligns with the fashion and filters, ensuring sturdy change access situations.

[b]How to Use[/b]

Setup: Apply the approach to SPX or other well suited indices.
Adjust person inputs, together with ATR length, EMA smoothing, and sensitivity, to align together with your buying and selling possibilities.
Enable or disable the SMA and MACD filters to test unique setups.

Alerts: Configure signals for computerized notifications or direct buying and selling execution through third-celebration systems.
Use the supplied JSON payload to integrate with broking APIs or automation tools.
Optimization:

Experiment with leverage, filter out settings, and sensitivity to find most effective configurations to your hazard tolerance and marketplace situations.

[b]Considerations and Best Practices[/b]

Risk Management: Always backtest the method with realistic parameters, together with conservative leverage and commissions.

Market Suitability: While designed for SPX, this method can adapt to other gadgets by means of adjusting key parameters.

Limitations: The method is trend-following and can underperform in enormously risky or ranging markets. Regularly evaluate and modify parameters primarily based on recent market conduct.

If you have any questions please let me know - I'm here to help!

## Source Code

````pine
//@version=6
strategy("Adaptive Trend Flow Strategy with Filters for SPX", overlay=true, max_labels_count=500, 
     initial_capital=1000, commission_type=strategy.commission.cash_per_order, commission_value=0.01, slippage=2,
     margin_long=20, margin_short=20, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// User-defined inputs for trend logic
atr           = input.int(14, "Main Length", minval=2, group = "Find more strategies like this on pineindicators.com")
length        = input.int(2, "Main Length", minval=2)
smooth_len    = input.int(2, "Smoothing Length", minval=2)
sensitivity   = input.float(2.0, "Sensitivity", step=0.1)

// User-defined inputs for SMA filter
use_sma_filter = input.bool(true, "Enable SMA Filter?")
sma_length = input.int(4, "SMA Length", minval=1)

// User-defined inputs for MACD filter
use_macd_filter = input.bool(true, "Enable MACD Filter?")
macd_fast_length = input.int(2, "MACD Fast Length", minval=1)
macd_slow_length = input.int(7, "MACD Slow Length", minval=1)
macd_signal_length = input.int(2, "MACD Signal Length", minval=1)
// User-defined inputs for leverage
leverage_factor = input.float(4.5, "Leverage Factor", minval=1.0, step=0.1)
id           = input("besttrader123", title= "Your TradingView username", group = "Automate this strategy with plugpine.com")
key           = input("nc739ja84gf", title= "Unique identifier (UID)")
ticker        = input("SPX", title= "Ticker/symbol of your broker")
bullcolor     = #0097a7
bearcolor     = #ff195f
showbars      = input.bool(true, "Color Bars?")
showbg        = input.bool(true, "Background Color?")
showsignals   = input.bool(true, "Show Signals?")


// Trend calculation functions
calculate_trend_levels() =>
    typical = hlc3
    fast_ema = ta.ema(typical, length)
    slow_ema = ta.ema(typical, length * 2)
    basis = (fast_ema + slow_ema) / 2
    vol = ta.stdev(typical, length)
    smooth_vol = ta.ema(vol, smooth_len)
    upper = basis + (smooth_vol * sensitivity)
    lower = basis - (smooth_vol * sensitivity)
    [basis, upper, lower]

get_trend_state(upper, lower, basis) =>
    var float prev_level = na
    var int trend = 0
    if na(prev_level)
        trend := close > basis ? 1 : -1
        prev_level := trend == 1 ? lower : upper
    if trend == 1
        if close < lower
            trend := -1
            prev_level := upper
        else
            prev_level := lower
    else
        if close > upper
            trend := 1
            prev_level := lower
        else
            prev_level := upper
    [trend, prev_level]

[basis, upper, lower] = calculate_trend_levels()
[trend, level] = get_trend_state(upper, lower, basis)

// SMA filter
sma_value = ta.sma(close, sma_length)
sma_condition = use_sma_filter ? close > sma_value : true

// MACD filter
[macd_line, signal_line, _] = ta.macd(close, macd_fast_length, macd_slow_length, macd_signal_length)
macd_condition = use_macd_filter ? macd_line > signal_line : true

// Signal detection with filters
long_signal = trend == 1 and trend[1] == -1 and sma_condition and macd_condition
short_signal = trend == -1 and trend[1] == 1

// Plotting visuals
p2 = plot(basis, color=trend == 1 ? bullcolor : bearcolor, linewidth=2)
p1 = plot(level, color=close > level ? bullcolor : bearcolor, linewidth=2, style=plot.style_linebr)
if showsignals and ta.crossover(close, level)
    label.new(bar_index, level, "▲", color=bullcolor, textcolor=chart.bg_color, style=label.style_label_upper_right)
if showsignals and ta.crossunder(close, level)
    label.new(bar_index, level, "▼", color=bearcolor, textcolor=chart.fg_color, style=label.style_label_lower_right)

qty = strategy.equity / close * leverage_factor

// Automated alerts
if long_signal
    alert('{"AccountID": "' + id + '","Key": "' + key + '", "symbol": "' + ticker + '", "action": "long", "volume": ' + str.tostring(qty) + '}', alert.freq_once_per_bar)
if short_signal
    alert('{"AccountID": "' + id + '","Key": "' + key + '", "symbol": "' + ticker + '", "action": "closelong"}', alert.freq_once_per_bar)

// Strategy entries and exits
if long_signal
    strategy.entry("Long", strategy.long, qty=qty)
if short_signal
    strategy.close("Long")

// Optional SMA and MACD plot
plot(use_sma_filter ? sma_value : na, color=color.new(color.blue, 80), title="SMA")
plot(use_macd_filter ? macd_line : na, color=color.new(color.orange, 80), title="MACD Line")
plot(use_macd_filter ? signal_line : na, color=color.new(color.red, 80), title="Signal Line")
````
