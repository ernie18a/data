# Saty ATR Levels (with SPX levels overlay)

- url: https://www.tradingview.com/script/9q5NiTQc-Saty-ATR-Levels-with-SPX-levels-overlay/
- type: indicator
- pine_id: PUB;93f94b152c2f4b19b97d1b10d3468da4
- version: 1.0

## Description

Credit: Saty Mahajan  https://www.satyland.com/ - derivative of his indicator.

The goal behind this modification is to be able to see futures candlesticks and use a cash index's (SPX) ATR levels adjusted by the cost-basis difference in the futures contract. This addition has a toggle to select which cash index as well as how the basis is calculated - I recommend using the RTH open basis which aligns the session window and adjusts using the 9:30 candle close basis so price is properly relative to the SPX ATR levels.

## Source Code

````pine
// Saty ATR Levels
// Copyright (C) 2022 Saty Mahajan
// Author is not responsible for your trading using this script.
// Data provided in this script is not financial advice.
//
// Modified: added optional SPX data source so levels can be derived
// from SPX while charting MES/ES/SPY/etc.
//
// Features:
// - Day, Multiday, Swing, Position, Long-term, Keltner trading modes
// - Range against ATR for each period
// - Put and call trigger idea levels
// - Intermediate levels
// - Full-range levels
// - Extension levels
// - Trend label based on the 8-21-34 Pivot Ribbon
// - Optional SPX ATR data source (useful for futures traders)
//
// Special thanks to Gabriel Viana.
// Based on my own ideas and ideas from Ripster, drippy2hard,
// Adam Sliver, and others.

//@version=5
indicator('Saty ATR Levels', shorttitle='Saty ATR Levels', overlay=true)

// Options
day_trading = 'Day'
multiday_trading = 'Multiday'
swing_trading = 'Swing'
position_trading = 'Position'
longterm_trading = 'Long-term'
trading_type = input.string(day_trading, 'Trading Type', options=[day_trading, multiday_trading, swing_trading, position_trading, longterm_trading])
use_options_labels = input(true, 'Use Options Labels')
use_spx_data = input(false, 'Use SPX for ATR Levels')
spx_symbol = input.symbol('SPX', 'SPX Symbol (when enabled)')
basis_mode = input.string('Locked at RTH open', 'Basis Mode (SPX mode)', options=['Static (yesterday close)', 'Live (real-time)', 'Locked at RTH open'])
atr_length = input(14, 'ATR Length')
trigger_percentage = input(0.236, 'Trigger Percentage')
previous_close_level_color = input(color.white, 'Previous Close Level Color')
lower_trigger_level_color = input(color.yellow, 'Lower Trigger Level Color')
upper_trigger_level_color = input(color.aqua, 'Upper Trigger Level Color')
key_target_level_color = input(color.silver, 'Key Target Level Color')
atr_target_level_color = input(color.white, 'ATR Target Level Color')
intermediate_target_level_color = input(color.gray, 'Intermediate Target Level Color')
show_all_fibonacci_levels = input(true, 'Show All Fibonacci Levels')
show_extensions = input(false, 'Show Extensions')
level_size = input(2, 'Level Size')
show_info = input(true, 'Show Info Label')
use_current_close = input(false, 'Use Current Close')
fast_ema = input(8, 'Fast EMA')
pivot_ema = input(21, 'Pivot EMA')
slow_ema = input(34, 'Slow EMA')

// Set the appropriate timeframe based on trading mode
timeframe_func() =>
    timeframe = 'D'
    if trading_type == day_trading
        timeframe := 'D'
    else if trading_type == multiday_trading
        timeframe := 'W'
    else if trading_type == swing_trading
        timeframe := 'M'
    else if trading_type == position_trading
        timeframe := '3M'
    else if trading_type == longterm_trading
        timeframe := '12M'
    else
        timeframe := 'D'

// Trend
price = close
fast_ema_value = ta.ema(price, fast_ema)
pivot_ema_value = ta.ema(price, pivot_ema)
slow_ema_value = ta.ema(price, slow_ema)
bullish = price >= fast_ema_value and fast_ema_value >= pivot_ema_value and pivot_ema_value >= slow_ema_value
bearish = price <= fast_ema_value and fast_ema_value <= pivot_ema_value and pivot_ema_value <= slow_ema_value

// Data
period_index = use_current_close ? 0 : 1

// When SPX mode is on, aggregate the chart symbol's daily candles using the
// US RTH session so the daily close lines up with SPX's 4pm cash close
// (technically 4:15pm for ES/MES due to the closing auction) and the daily
// candle resets at 9:30am — matching SPX's session boundary.
//
// IMPORTANT: For CME equity index futures, session.regular and session.extended
// are aliases that BOTH resolve to the full Globex (ETH) session. The actual
// RTH session is exposed under the named-session string "us_regular", which
// must be passed as a literal string to ticker.new().
chart_session = use_spx_data ? "us_regular" : session.extended
chart_ticker = ticker.new(syminfo.prefix, syminfo.ticker, session=chart_session)

// Pull chart-symbol data (always — used directly when SPX mode is off,
// and as the anchor / ratio basis when SPX mode is on)
chart_previous_close = request.security(chart_ticker, timeframe_func(), close[period_index], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
chart_atr = request.security(chart_ticker, timeframe_func(), ta.atr(atr_length)[period_index], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
chart_high = request.security(chart_ticker, timeframe_func(), high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
chart_low = request.security(chart_ticker, timeframe_func(), low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Pull SPX data (used when SPX mode is on)
spx_previous_close = request.security(spx_symbol, timeframe_func(), close[period_index], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
spx_atr = request.security(spx_symbol, timeframe_func(), ta.atr(atr_length)[period_index], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
spx_high = request.security(spx_symbol, timeframe_func(), high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
spx_low = request.security(spx_symbol, timeframe_func(), low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Translate SPX values into chart-symbol price space using basis (additive offset).
// Three modes:
//   - Static (yesterday close): yesterday's close-to-close difference. Lines stay
//                               flat but tracking degrades as basis drifts away
//                               from yesterday's close basis.
//   - Live (real-time): real-time difference (chart_now - spx_now). Lines drift
//                       through the session as basis evolves; SPX taps and chart
//                       taps coincide exactly at the plotted level.
//   - Locked at RTH open: basis snapshotted at 9:30am ET each day and held
//                         constant for the rest of the session. Lines stay flat
//                         through RTH; overnight repricing is captured but
//                         intraday basis drift is ignored. This is roughly what
//                         most futures desks use for SPX-vs-ES adjustments.

// Live SPX price at the current chart bar.
spx_current = request.security(spx_symbol, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Static basis (yesterday close-to-close), used as fallback and for static mode.
static_basis = chart_previous_close - spx_previous_close

// Detect the first chart bar of the cash RTH session (9:30am ET) using a
// time-based session string, so it works regardless of the chart's timezone.
rth_session_string = '0930-1600:23456'
in_rth = not na(time(timeframe.period, rth_session_string, 'America/New_York'))
new_rth_session = in_rth and not in_rth[1]

// Snapshot basis at RTH open and persist it across bars until the next RTH open.
var float opening_basis = na
if new_rth_session and not na(spx_current) and spx_current > 0
    opening_basis := close - spx_current

// Pick basis based on selected mode.
basis = static_basis
if basis_mode == 'Live (real-time)' and not na(spx_current) and spx_current > 0
    basis := close - spx_current
else if basis_mode == 'Locked at RTH open' and not na(opening_basis)
    basis := opening_basis

previous_close = use_spx_data ? spx_previous_close + basis : chart_previous_close
atr = use_spx_data ? spx_atr : chart_atr
period_high = use_spx_data ? spx_high + basis : chart_high
period_low = use_spx_data ? spx_low + basis : chart_low
range_1 = period_high - period_low
tr_percent_of_atr = range_1 / atr * 100
lower_trigger = previous_close - trigger_percentage * atr
upper_trigger = previous_close + trigger_percentage * atr
lower_0382 = previous_close - atr * 0.382
upper_0382 = previous_close + atr * 0.382
lower_0500 = previous_close - atr * 0.5
upper_0500 = previous_close + atr * 0.5
lower_0618 = previous_close - atr * 0.618
upper_0618 = previous_close + atr * 0.618
lower_0786 = previous_close - atr * 0.786
upper_0786 = previous_close + atr * 0.786
lower_1000 = previous_close - atr
upper_1000 = previous_close + atr
lower_1236 = lower_1000 - atr * 0.236
upper_1236 = upper_1000 + atr * 0.236
lower_1382 = lower_1000 - atr * 0.382
upper_1382 = upper_1000 + atr * 0.382
lower_1500 = lower_1000 - atr * 0.5
upper_1500 = upper_1000 + atr * 0.5
lower_1618 = lower_1000 - atr * 0.618
upper_1618 = upper_1000 + atr * 0.618
lower_1786 = lower_1000 - atr * 0.786
upper_1786 = upper_1000 + atr * 0.786
lower_2000 = lower_1000 - atr
upper_2000 = upper_1000 + atr
lower_2236 = lower_2000 - atr * 0.236
upper_2236 = upper_2000 + atr * 0.236
lower_2382 = lower_2000 - atr * 0.382
upper_2382 = upper_2000 + atr * 0.382
lower_2500 = lower_2000 - atr * 0.5
upper_2500 = upper_2000 + atr * 0.5
lower_2618 = lower_2000 - atr * 0.618
upper_2618 = upper_2000 + atr * 0.618
lower_2786 = lower_2000 - atr * 0.786
upper_2786 = upper_2000 + atr * 0.786
lower_3000 = lower_2000 - atr
upper_3000 = upper_2000 + atr

// Add Labels
tr_vs_atr_color = color.green
if tr_percent_of_atr <= 70
    tr_vs_atr_color := color.green
else if tr_percent_of_atr >= 90
    tr_vs_atr_color := color.red
else
    tr_vs_atr_color := color.orange

trading_mode = 'Day'
if trading_type == day_trading
    trading_mode := 'Day'
else if trading_type == multiday_trading
    trading_mode := 'Multiday'
else if trading_type == swing_trading
    trading_mode := 'Swing'
else if trading_type == position_trading
    trading_mode := 'Position'
else if trading_type == longterm_trading
    trading_mode := 'Long-term'
else
    trading_mode := ''

long_label = ''
short_label = ''
if use_options_labels
    long_label := 'Calls'
    short_label := 'Puts'
else
    long_label := 'Long'
    short_label := 'Short'

trend_color = color.orange
if bullish
    trend_color := color.green
else if bearish
    trend_color := color.red
else
    trend_color := color.orange

// Source label for the info table
source_label = use_spx_data ? ' (SPX)' : ''

var tbl = table.new(position.top_right, 1, 4)
if barstate.islast and show_info
    table.cell(tbl, 0, 0, 'Saty ATR Levels' + source_label, bgcolor=trend_color)
    table.cell(tbl, 0, 1, trading_mode + ' Range ($' + str.tostring(range_1, '#.##') + ') is ' + str.tostring(tr_percent_of_atr, '#.#') + '% of ATR ($' + str.tostring(atr, '#.##') + ')', bgcolor=tr_vs_atr_color)
    table.cell(tbl, 0, 2, long_label + ' > $' + str.tostring(upper_trigger, '#.##') + ' | +1 ATR $' + str.tostring(upper_1000, '#.##'), bgcolor=upper_trigger_level_color)
    table.cell(tbl, 0, 3, short_label + ' < $' + str.tostring(lower_trigger, '#.##') + ' | -1 ATR: $' + str.tostring(lower_1000, '#.##'), bgcolor=lower_trigger_level_color)

// Add levels
plot(show_extensions ? lower_3000 : na, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='-300.0%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? lower_2786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-278.6%', style=plot.style_stepline)
plot(show_extensions ? lower_2618 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='-261.8%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? lower_2500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-250.0%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? lower_2382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-238.2%', style=plot.style_stepline)
plot(show_extensions ? lower_2236 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='-223.6%', style=plot.style_stepline)
plot(show_extensions ? lower_2000 : na, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='-200.0%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? lower_1786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-178.6%', style=plot.style_stepline)
plot(show_extensions ? lower_1618 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='-161.8%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? lower_1500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-150.0%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? lower_1382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-138.2%', style=plot.style_stepline)
plot(show_extensions ? lower_1236 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='-123.6%', style=plot.style_stepline)
plot(lower_1000, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='-100%', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? lower_0786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-78.6%', style=plot.style_stepline)
plot(lower_0618, color=color.new(key_target_level_color, 40), linewidth=level_size, title='-61.8%', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? lower_0500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-50.0%', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? lower_0382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='-38.2%', style=plot.style_stepline)
plot(lower_trigger, color=color.new(lower_trigger_level_color, 40), linewidth=level_size, title='Lower Trigger', style=plot.style_stepline)
plot(previous_close, color=color.new(previous_close_level_color, 40), linewidth=level_size, title='Previous Close', style=plot.style_stepline)
plot(upper_trigger, color=color.new(upper_trigger_level_color, 40), linewidth=level_size, title='Upper Trigger', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? upper_0382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='38.2%', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? upper_0500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='50.0%', style=plot.style_stepline)
plot(upper_0618, color=color.new(key_target_level_color, 40), linewidth=level_size, title='61.8%', style=plot.style_stepline)
plot(show_all_fibonacci_levels ? upper_0786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='78.6%', style=plot.style_stepline)
plot(upper_1000, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='100%', style=plot.style_stepline)
plot(show_extensions ? upper_1236 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='123.6%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? upper_1382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='138.2%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? upper_1500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='150.0%', style=plot.style_stepline)
plot(show_extensions ? upper_1618 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='161.8%', style=plot.style_stepline)
plot(show_all_fibonacci_levels and show_extensions ? upper_1786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='178.6%', style=plot.style_stepline)
plot(show_extensions ? upper_2000 : na, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='200.0%', style=plot.style_stepline)
plot(show_extensions ? upper_2236 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='223.6%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? upper_2382 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='238.2%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? upper_2500 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='250.0%', style=plot.style_stepline)
plot(show_extensions ? upper_2618 : na, color=color.new(key_target_level_color, 40), linewidth=level_size, title='261.8%', style=plot.style_stepline)
//plot(show_all_fibonacci_levels and show_extensions ? upper_2786 : na, color=color.new(intermediate_target_level_color, 40), linewidth=level_size, title='278.6%', style=plot.style_stepline)
plot(show_extensions ? upper_3000 : na, color=color.new(atr_target_level_color, 40), linewidth=level_size, title='300%', style=plot.style_stepline)
````
