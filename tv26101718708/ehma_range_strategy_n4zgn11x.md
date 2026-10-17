# EHMA Range Strategy

- url: https://www.tradingview.com/script/N4zgN11X-EHMA-Range-Strategy/
- type: strategy
- pine_id: PUB;ee969e2caa5a4b3da7701f14324f3d3c
- version: 2.0

## Description

This script is a modified version of @borserman's script for the [url=https://www.tradingview.com/script/m6iWoRsW/]Exponential Hull Moving Average[/url]
All credit for the EHMA goes to him :)

In addition to the EHMA, this script works with a range around the EHMA (which can be modified), in an attempt to be robust against fake signals. Many times a bar will close below a moving average, only to reverse again the next bar, which eats away at your profits. Especially on shorter timeframes, but also on choppy longer timeframes this can make a strategy unattractive to use.

With the range around the EHMA, the strategy only enters a long/exit-short position if a bar crosses above the upper range. Vice versa, it only enters a short/exit-long position if a bar crosses below the lower range. This avoids positions if bars behave choppy within the EHMA range & only enters a position if the market is confident in it's direction. Having said that, fakeouts are still possible, but a lot less frequent. Having backtested this strategy vs the regular EHMA strategy (and having experimented with various settings), this version seems to be a lot more robust & profitable! 

[b]Disclaimer[/b]
Please remember that past performance may not be indicative of future results.
Due to various factors, including changing market conditions, the strategy may no longer perform as good as in historical backtesting.
This post and the script don’t provide any financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GoldenPathStrategies

//@version=5

// ════════════════════════════════════════════════════════════════════════════════
// EXPONENTIAL HULL MOVING AVERAGE RANGE
// ════════════════════════════════════════════════════════════════════════════════
//
// DESCRIPTION:
// Exponential Hull Moving Average (EHMA) Range strategy creates dynamic
// bands around the Borserman EHMA to generate entry and exit signals.
// The EHMA combines exponential acceleration with Hull MA principles for
// responsive yet smooth trend tracking.
//
// HOW IT WORKS:
// 1. Calculate the Borserman EMA (exponentially-weighted smoothing)
// 2. Compose the EHMA from double-smoothed and regular Borserman EMA
// 3. Create upper and lower bands using a percentage-based range width
// 4. Generate signals when price crosses band boundaries
//
// STRATEGY LOGIC:
// - Long Entry: Price crosses above upper band
// - Long Exit: Price crosses below lower band
// - Short Entry: Price crosses below lower band
// - Short Exit: Price crosses above upper band
// ════════════════════════════════════════════════════════════════════════════════

strategy(
     title="Exponential Hull Moving Average Range [GoldenPathStrategies]",
     shorttitle="EHMA Range",
     overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     commission_type=strategy.commission.percent,
     calc_on_every_tick=false)

// ════════════════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════════════════

// EHMA Parameters
i_period = input.int(180, "Length", group="EHMA Parameters", tooltip="Period for EHMA calculation. Higher = smoother but slower response")
i_range_width = input.float(0.02, "Range Width", step=0.01, group="EHMA Parameters", tooltip="Percentage-based band width around EHMA")

// Position Type
i_pos_type = input.string("Long", "Position Type", options=["Both", "Long", "Short"], group="Strategy Settings", tooltip="Select which position types to trade")

// Backtest Period
i_start = input.time(timestamp("2017-01-01 00:00"), "Backtest Start Date", tooltip="Strategy will only execute trades after this date")
i_end = input.time(timestamp("2029-01-01 00:00"), "Backtest End Date", tooltip="Strategy will stop executing trades after this date")

// Visual Settings
i_color_bullish = input.color(#e9c060, "Bullish Color", group="Colors", tooltip="Color for bullish trend, upper band, and bar coloring")
i_color_bearish = input.color(#3199ea, "Bearish Color", group="Colors", tooltip="Color for bearish trend, lower band, and bar coloring")
i_show_barcolor = input.bool(true, "Show Bar Colors", group="Colors", tooltip="Enable/disable bar coloring based on trend")

i_alert_buy = input.text_area("Buy alert!", "Buy Alert Message", group="Alert Messages", tooltip="Message sent when a Buy/Long entry is triggered.\nUse plain text for simple notifications, or paste a JSON payload for automated trading bots.\nAccess this message in your TradingView alert by placing {{strategy.order.alert_message}} in the alert's Message field.\n\nExample JSON for bots:\n{\"action\": \"market_order\", \"coin\": \"BTC/USDC\", \"is_buy\": true, \"size_pct\": 1, \"bot_id\": 123, \"api_key\": \"xyz\"}")
i_alert_sell = input.text_area("Sell alert!", "Sell Alert Message", group="Alert Messages", tooltip="Message sent when a Sell/Exit is triggered.\nUse plain text for simple notifications, or paste a JSON payload for automated trading bots.\nAccess this message in your TradingView alert by placing {{strategy.order.alert_message}} in the alert's Message field.\n\nExample JSON for bots:\n{\"action\": \"market_order\", \"coin\": \"BTC/USDC\", \"is_buy\": false, \"size_pct\": 1, \"bot_id\": 123, \"api_key\": \"xyz\"}")

// ════════════════════════════════════════════════════════════════════════════════
// CORE LOGIC
// ════════════════════════════════════════════════════════════════════════════════

f_borserman_ema(float x, float y) =>
    float alpha = 2.0 / (y + 1)
    var float bsum = 0.0
    bsum := alpha * x + (1 - alpha) * nz(bsum[1])
    bsum

sqrtPeriod = math.sqrt(i_period)

// Calculate the Exponential Hull Moving Average
ehma = f_borserman_ema(2 * f_borserman_ema(close, i_period / 2) - f_borserman_ema(close, i_period), sqrtPeriod)

// Create upper & lower bounds around the EHMA for broader entries & exits
upper_band = ehma + (ehma * i_range_width)
lower_band = ehma - (ehma * i_range_width)

// Trend state
var int trend = 0
if close > upper_band
    trend := 1
if close < lower_band
    trend := -1

trend_up = trend == 1 and trend[1] != 1
trend_down = trend == -1 and trend[1] != -1

// ════════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ════════════════════════════════════════════════════════════════════════════════

ehma_color = close > ehma ? i_color_bullish : i_color_bearish

p_upper = plot(upper_band, "Upper Band", i_color_bullish, 1)
p_lower = plot(lower_band, "Lower Band", i_color_bearish, 1)
plot(ehma, "EHMA", ehma_color, 2, plot.style_linebr)

// Band Fill
fill(p_upper, p_lower, color.new(i_color_bearish, 80), "Band Area")

// Bar Coloring
bar_color = close > upper_band ? i_color_bullish : close < lower_band ? i_color_bearish : close[1] > lower_band[1] ? i_color_bullish : close[1] < upper_band[1] ? i_color_bearish : color.gray
barcolor(i_show_barcolor ? bar_color : na, title="Trend Colors")

// ════════════════════════════════════════════════════════════════════════════════
// STRATEGY EXECUTION
// ════════════════════════════════════════════════════════════════════════════════

bool in_date_range = time >= i_start and time <= i_end
bool long_signal = trend_up
bool exit_long_signal = trend_down
bool short_signal = trend_down
bool exit_short_signal = trend_up

// Both
if i_pos_type == "Both"
    if in_date_range and long_signal and strategy.position_size == 0
        strategy.entry("Long", strategy.long, comment="Entry", alert_message=i_alert_buy)
    if in_date_range and exit_long_signal and strategy.position_size > 0
        strategy.close("Long", comment="Exit", alert_message=i_alert_sell)
    if in_date_range and short_signal and strategy.position_size == 0
        strategy.entry("Short", strategy.short, comment="Short", alert_message=i_alert_sell)
    if in_date_range and exit_short_signal and strategy.position_size < 0
        strategy.close("Short", comment="Exit Short", alert_message=i_alert_buy)

// Long only
if i_pos_type == "Long"
    if in_date_range and long_signal and strategy.position_size == 0
        strategy.entry("Long", strategy.long, comment="Entry", alert_message=i_alert_buy)
    if in_date_range and exit_long_signal and strategy.position_size > 0
        strategy.close("Long", comment="Exit", alert_message=i_alert_sell)

// Short only
if i_pos_type == "Short"
    if in_date_range and short_signal and strategy.position_size == 0
        strategy.entry("Short", strategy.short, comment="Short", alert_message=i_alert_sell)
    if in_date_range and exit_short_signal and strategy.position_size < 0
        strategy.close("Short", comment="Exit Short", alert_message=i_alert_buy)

// Force close at end of backtest period
if time > i_end and strategy.position_size != 0
    strategy.close_all(comment="Backtest End", alert_message=i_alert_sell)

// ════════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════════

alertcondition(long_signal, "EHMA Long Entry", "EHMA: Price Crossed Above Upper Band")
alertcondition(exit_long_signal, "EHMA Long Exit", "EHMA: Price Crossed Below Lower Band")
alertcondition(short_signal, "EHMA Short Entry", "EHMA: Price Crossed Below Lower Band")
alertcondition(exit_short_signal, "EHMA Short Exit", "EHMA: Price Crossed Above Upper Band")
````
