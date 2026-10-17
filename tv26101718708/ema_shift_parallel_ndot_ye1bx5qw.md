# EMA SHIFT & PARALLEL [n_dot]

- url: https://www.tradingview.com/script/ye1BX5Qw-EMA-SHIFT-PARALLEL-n-dot/
- type: strategy
- pine_id: PUB;e979742deaeb496cb1bac5fa2c3c6444
- version: 1.0

## Description

[symbol="BINANCE:ETHUSDT.P"]BINANCE:ETHUSDT.P[/symbol]

This strategy was developed for CRYPTO FUTURES, (the settings for ETHUSDT.P) . I aimed for the strategy to function in a live environment, so I focused on making its operation realistic:

[list]
[*]When determining the position, only 80% (adjustable) of the available cash is invested to reduce the risk of position liquidation.
[*]I account for a 0.05% commission, typical on the futures market, for each entry and exit.
[/list]

[b]Concept:[/b]

I modified a simple, well-known method: the crossover of two exponential moving averages (FAST, SLOW) generates the entry and exit signals.

[quote]I enhanced the base idea as follows:

[list]
[*]For the fast EMA, I incorporated a multiplier (offset) to filter out market noise and focus only on strong signals.
[*]I use different EMAs for long and short entry points; both have their own FAST and SLOW EMAs and their own offset. For longs, the FAST EMA is adjusted downward (<1), while for shorts, it is adjusted upward (>1). Consequently, the signal is generated when the modified FAST EMA crosses the SLOW EMA.
[/list][/quote]

[b]Risk Management:[/b]
The position includes the following components:
[list]
[*]Separate stop-losses for long and short positions.
[*]Separate trailers for long and short positions.
[*]The strategy operates so that the entry point is determined by the EMA crossover, while the exit is governed only by the Stop Loss or Trailer. Optionally, it can be set to close the position at the EMA recrossing ("Close at Signal").
[/list]

Trailer Operation:
[list]
[*]An entry percentage and offset are defined. The trailer activates when the price surpasses the entry price, calculated automatically by the system.
[*]The trailer closes the position when the price drops by the offset percentage from the highest reached price.
[/list]

[i]Example for trailer:
[list]
[*]Purchase Price = 100
[*]Trailer Enter = 5% → Activation Price = 105 (triggers trailer if market price crosses it).
[*]Trailer Offset = 2%
[*]
[*]If the price rises to 110, the exit price becomes 107.8.
[*]If the price goes to 120, the exit price becomes 117.6.
[*]If the price falls below 117.6, the trailer closes the position.
[/list][/i]

[b]Settings:[/b]

[list]
[*]Source: Determines the market price reference.
[*]End Close: Closes positions at the end of the simulation to avoid "shadow positions" and provide an objective result.
[*]Lot proportional to free cash (%): Only a portion of free cash is invested to meet margin requirements.
[*]Plot Short, Plot Long: Simplifies displayed information by toggling indicator lines on/off.
[*]Long Position (toggleable):
[*]EMA Fast ws: Window size for FAST EMA.
[*]EMA Slow ws: Window size for SLOW EMA.
[*]EMA Fast down shift: Adjustment factor for FAST EMA.
[*]Stop Loss long (%): Percent drop to close the position.
[*]Trailer enter (%): Percent above the purchase price to activate the trailer.
[*]Trailer offset (%): Percent drop to close the position.
[*]Short Position (toggleable):
[*]EMA Fast ws: Window size for FAST EMA.
[*]EMA Slow ws: Window size for SLOW EMA.
[*]EMA Fast up shift: Adjustment factor for FAST EMA.
[*]Stop Loss short (%): Percent rise to close the position.
[*]Trailer enter (%): Percent below the purchase price to activate the trailer.
[*]Trailer offset (%): Percent rise to close the position.
[/list]

[b]Operational Framework:[/b]

[list]
[*]If in a long position and a short EMA crossover occurs, the strategy closes the long and opens a short (flip).
[*]If in a short position and a long EMA crossover occurs, the strategy closes the short and opens a long (flip).
[/list]

[b]A position can close in three ways:[/b]
[list]
[*]Stop Loss
[*]Trailer
[*]Signal Recrossing
[/list]
If none are active, the position remains open until the end of the simulation.

[b]Observations:[/b]

[list]
[*]Shifts significantly deviating from 1 increase overfitting risk. Recommended ranges: 0.96–0.99 (long) and 1.01–1.05 (short).
[*]The strategy's advantage lies in risk management, crucial in leveraged futures markets. It operates with relatively low DrawDown.
[/list]

[b]Recommendations:[/b]

[list]
[*]Bullish Market: Higher entry threshold (e.g., 6%) and larger offset (e.g., 3%).
[*]Volatile/Sideways Market: Tighter parameters (e.g., 3%, 1%).
[*]The method is stable, and minor parameter adjustments do not significantly impact results, helping assess overfitting: if small changes lead to drastic differences, the strategy is over-optimized.
[*]EMA Settings: Adjust FAST and SLOW EMAs based on the asset's volatility and cyclicality.
[*]On the crypto market, especially in the Futures market, short time periods (1–15 minutes) often show significant noise, making patterns/repetitions hard to identify. I recommend setting the interval to at least 1 hour.
[/list]

I hope this contributes to your success!

## Source Code

````pine
// author n_dot

import TradingView/ta/7
//@version=6
strategy(shorttitle = 'EMA S&P', title = 'EMA SHIFT & PARALLEL [n_dot]', default_qty_type = strategy.percent_of_equity, initial_capital = 100000, default_qty_value = 70, pyramiding = 0, currency = 'USD', commission_type = strategy.commission.percent, commission_value = 0.05, precision = 16, calc_on_every_tick = true, calc_on_order_fills = false, risk_free_rate = 2, process_orders_on_close = true, overlay = true)

src = input.source(close, 'Source:', inline = 'els')
var bool end_close = input.bool(false, title = 'End Close:', inline = 'els')
var float lot_percent = input.int(80, minval = 1, maxval = 100, step = 1, title = 'Lot proportional to free cash(%):')
var bool is_plot_short = input.bool(true, title = 'Plot short       ',  inline = 'plt')
var bool is_plot_long = input.bool(true, title = 'Plot long ', inline = 'plt')

var bool is_long = input.bool(true, title = 'Long:', group = 'EMA LONG Settings', inline = 'els')
var int ema_fast_long = input.int(20, title = 'EMA FAST ws:', group = 'EMA LONG Settings', inline = 'els')
var int ema_slow_long = input.int(420, title = 'EMA SLOW ws:', group = 'EMA LONG Settings', inline = 'els')
var float ema_down_shift = input.float(0.98, title = 'EMA FAST down shift:', minval = 0.50, maxval = 2.0, step = 0.1, group = 'EMA LONG Settings')
var bool is_stop_loss_long = input.bool(true, title = '', group = 'EMA LONG Settings', inline = 'sll')
var float stop_loss_percent_long = input.float(2.0, minval = 1.0, maxval = 99.0, step = 0.1, title = 'Stop Loss long(%):', group = 'EMA LONG Settings', inline = 'sll')

var bool is_trailer_long = input.bool(true, title = 'Trailer', group = 'EMA LONG Settings', inline = 'trll')
var float trailer_long_enter_percent = input.float(6.0, minval = 1.0, maxval = 1000.0, step = 0.1, title = 'Enter(%):', group = 'EMA LONG Settings', inline = 'trll')
var float trailer_long_offset = input.float(3.0, minval = 1.0, maxval = 100.0, step = 0.1, title = 'Offset(%):', group = 'EMA LONG Settings', inline = 'trll')
var bool is_long_signal_close = input.bool(true, title = 'Close at signal', group = 'EMA LONG Settings')

var bool is_short = input.bool(true, title = 'Short:', group = 'EMA SHORT Settings', inline = 'ess')
var int ema_fast_short = input.int(30, title = 'EMA FAST ws:', group = 'EMA SHORT Settings', inline = 'ess')
var int ema_slow_short = input.int(500, title = 'EMA SLOW ws:', group = 'EMA SHORT Settings', inline = 'ess')
var float ema_up_shift = input.float(1.02, title = 'EMA FAST up shift:', minval = 0.50, maxval = 2.0, step = 0.1, group = 'EMA SHORT Settings')
var bool is_stop_loss_short = input.bool(true, title = '', group = 'EMA SHORT Settings', inline = 'slss')
var float stop_loss_percent_short = input.float(2.0, minval = 1.0, maxval = 99.0, step = 0.1, title = 'Stop Loss short(%):', group = 'EMA SHORT Settings', inline = 'slss')

var bool is_trailer_short = input.bool(true, title = 'Trailer', group = 'EMA SHORT Settings', inline = 'trls')
var float trailer_short_enter_percent = input.float(3.0, minval = 1.0, maxval = 1000.0, step = 0.1, title = 'Enter(%):', group = 'EMA SHORT Settings', inline = 'trls')
var float trailer_short_offset = input.float(1.0, minval = 1.0, maxval = 100.0, step = 0.1, title = 'Offset(%):', group = 'EMA SHORT Settings', inline = 'trls')
var bool is_short_signal_close = input.bool(true, title = 'Close at signal', group = 'EMA SHORT Settings')

var comission_percen = 0.05 // 0.05%

// EMA
round_down(number, decimals) =>
    factor = math.pow(10, decimals)
    math.floor(number * factor) / factor

rsrc = round_down(src, 8)

pine_ema(src, length) =>
    alpha = math.round(2 / (length + 1), 8)
    sum = 0.0
    if na(sum[1])
        sum := math.round(src, 8)
        sum
    else
        sum := math.round(alpha * src + (1 - alpha) * nz(sum[1]), 8)
        sum
    sum

ema_fast_long_data = pine_ema(rsrc, ema_fast_long)
ema_slow_long_data = pine_ema(rsrc, ema_slow_long)
ema_fast_long_down_shift_data = math.round(ema_fast_long_data * ema_down_shift, 8)

long_display = display.all
if is_plot_long
    long_display := display.all
    long_display
else
    long_display := display.none
    long_display

plot(ema_fast_long_down_shift_data, color = #84d286, style = plot.style_line, linewidth = 1, title = 'EMA long fast down shift', display = long_display)
plot(ema_fast_long_data, color = color.green, style = plot.style_line, linewidth = 1, title = 'EMA long fast', display = long_display)
plot(ema_slow_long_data, color = color.rgb(10, 57, 13), style = plot.style_line, linewidth = 2, title = 'EMA long slow', display = long_display)

ema_fast_short_data = pine_ema(rsrc, ema_fast_short)
ema_slow_short_data = pine_ema(rsrc, ema_slow_short)
ema_fast_short_up_shift_data = math.round(ema_fast_short_data * ema_up_shift, 8)

short_display = display.all
if is_plot_short
    short_display := display.all
    short_display
else
    short_display := display.none
    short_display

plot(ema_slow_short_data, color = #440e0e, style = plot.style_line, linewidth = 2, title = 'EMA short slow', display = short_display)
plot(ema_fast_short_data, color = color.red, style = plot.style_line, linewidth = 1, title = 'EMA short fast', display = short_display)
plot(ema_fast_short_up_shift_data, color = #e5acac, style = plot.style_line, linewidth = 1, title = 'EMA short fast down shift', display = short_display)

long_signal = math.round(ema_fast_long_down_shift_data[0], 2) > math.round(ema_slow_long_data[0], 2) and math.round(ema_fast_long_down_shift_data[1], 2) <= math.round(ema_slow_long_data[1], 2)
long_close = math.round(ema_fast_long_down_shift_data[0], 2) < math.round(ema_slow_long_data[0], 2) and math.round(ema_fast_long_down_shift_data[1], 2) >= math.round(ema_slow_long_data[1], 2)

short_signal = math.round(ema_fast_short_up_shift_data[0], 2) < math.round(ema_slow_short_data[0], 2) and math.round(ema_fast_short_up_shift_data[1], 2) >= math.round(ema_slow_short_data[1], 2)
short_close = math.round(ema_fast_short_up_shift_data[0], 2) > math.round(ema_slow_short_data[0], 2) and math.round(ema_fast_short_up_shift_data[1], 2) <= math.round(ema_slow_short_data[1], 2)

id = 'id_' + str.tostring(bar_index)
var float long_stop_price = 0.0
var float short_stop_price = 1000000000000.0

var float trailer_long_activation_price = 0.0
var float trailer_short_activation_price = 0.0
var bool trailer_long_active = false
var bool trailer_short_active = false
var float trailer_short_lowest_price = 1000000000000.0
var float trailer_long_highest_price = 0.0
var float trailer_long_stop_price = 0.0 // / 1000 !!!  30.0= 3.0%
var float trailer_short_stop_price = 0.0 // / 1000 !!!  30.0= 3.0%

var float free_cash = 100000.0
var float last_long_qty = 0.0
var float last_long_price = 0.0
var float last_short_qty = 0.0
var float last_short_price = 0.0
var float sum_profit = 0.0

// alertcondition(is_stop_loss_long and rsrc < long_stop_price and strategy.position_size > 0.0 and is_long, title = 'EMA S&P Alert', message = 'LONG STOP LOSS')
// alertcondition(long_close and strategy.position_size > 0.0 and is_long, title = 'EMA S&P Alert', message = 'LONG CLOSE')

if is_long
    if long_signal and strategy.position_size <= 0.0
        if strategy.position_size < 0.0
            // CLOSE  PROTOCOL ---------------------------------------------------------------
            profit = 0.0
            if strategy.position_size < 0.0
                comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
                comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
                profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
                profit
            else if strategy.position_size > 0.0
                comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
                comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
                profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
                profit
            sum_profit := sum_profit + profit
            free_cash := free_cash + profit
            trailer_long_active := false
            trailer_short_active := false
            long_stop_price := 0.0
            short_stop_price := 1000000000000.0
            trailer_long_highest_price := 0.0
            trailer_short_lowest_price := 1000000000000.0
            trailer_short_stop_price := 0.0
            trailer_long_stop_price := 0.0
            // -------------------------------------------------------------------------------
            strategy.close_all(comment = 'Short->Long')

        last_long_qty := math.round(free_cash * (lot_percent / 100) / rsrc, 2)
        last_long_price := rsrc

        // Stop loss price set
        long_stop_price := rsrc * (1 - stop_loss_percent_long / 100)

        // Trailer sets
        trailer_long_activation_price := rsrc * (1 + trailer_long_enter_percent / 100)
        trailer_long_active := false
        trailer_long_highest_price := 0.0

        // comm = "Long" + str.tostring(bar_index) + " " + str.tostring(close)
        comm = 'Long'
        strategy.entry(id, strategy.long, qty = last_long_qty, comment = comm)

    else if is_stop_loss_long and rsrc < long_stop_price and strategy.position_size > 0.0
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
            comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
            profit
        else if strategy.position_size > 0.0
            comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
            comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
            profit
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        strategy.close_all(comment = 'Long_SLoss')

    else if is_trailer_long and trailer_long_active and rsrc < trailer_long_stop_price and strategy.position_size > 0.0
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
            comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
            profit
        else if strategy.position_size > 0.0
            comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
            comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
            profit
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        strategy.close_all(comment = 'LONG_TRLStop')

    else if long_close and strategy.position_size > 0.0 and is_long_signal_close
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round((last_short_qty * last_short_price) * (comission_percen / 100), 4) 
            comission_short_stop = math.round((last_short_qty * rsrc) * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
        else if strategy.position_size > 0.0
            comission_long = math.round((last_long_qty * last_long_price) * (comission_percen / 100), 4) 
            comission_long_stop = math.round((last_long_qty * rsrc) * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        // comm = "Long_Close" + str.tostring(bar_index) + " " + str.tostring(close)
        comm = "Long_Close"
        strategy.close_all(comment = comm)

    if is_trailer_long and strategy.position_size > 0.0 and rsrc > trailer_long_activation_price and not trailer_long_active
        trailer_long_active := true
        trailer_long_active

    if is_trailer_long and trailer_long_active
        trailer_long_highest_price := math.max(trailer_long_highest_price, rsrc)
        trailer_long_stop_price := trailer_long_highest_price * (1 - trailer_long_offset / 100)
        trailer_long_stop_price

// alertcondition(short_signal and short_position_id == "" and is_short , title="EMA S&P Alert", message="SHORT")
// alertcondition(is_stop_loss_short and rsrc > short_stop_price and strategy.position_size < 0.0 and is_short, title = 'EMA S&P Alert', message = 'SHORT STOP LOSS')
// alertcondition(short_close and strategy.position_size < 0.0 and is_short, title = 'EMA S&P Alert', message = 'SHORT CLOSE')

if is_short
    if short_signal and strategy.position_size >= 0.0
        if strategy.position_size > 0.0
            // CLOSE  PROTOCOL ---------------------------------------------------------------
            profit = 0.0
            if strategy.position_size < 0.0
                comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
                comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
                profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
                profit
            else if strategy.position_size > 0.0
                comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
                comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
                profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
                profit
            sum_profit := sum_profit + profit
            free_cash := free_cash + profit
            trailer_long_active := false
            trailer_short_active := false
            long_stop_price := 0.0
            short_stop_price := 1000000000000.0
            trailer_long_highest_price := 0.0
            trailer_short_lowest_price := 1000000000000.0
            trailer_long_stop_price := 0.0
            trailer_short_stop_price := 0.0
            // -------------------------------------------------------------------------------
            strategy.close_all(comment = 'Long->Short')

        last_short_qty := math.round(free_cash * (lot_percent / 100) / rsrc, 2)
        last_short_price := rsrc

        // Stop loss price set
        short_stop_price := rsrc * (1 + stop_loss_percent_short / 100)

        // Trailer sets
        trailer_short_activation_price := rsrc * (1 - trailer_short_enter_percent / 100)
        trailer_short_active := false
        trailer_short_lowest_price := 1000000000000.0

        comm = 'Short'
        strategy.entry(id, strategy.short, qty = last_short_qty, comment = comm)

    else if is_stop_loss_short and rsrc > short_stop_price and strategy.position_size < 0.0
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
            comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
            profit
        else if strategy.position_size > 0.0
            comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
            comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
            profit
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        strategy.close_all(comment = 'Short_SLoss')

    else if is_trailer_short and trailer_short_active and rsrc > trailer_short_stop_price and strategy.position_size < 0.0
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round(last_short_qty * last_short_price * (comission_percen / 100), 4)
            comission_short_stop = math.round(last_short_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
            profit
        else if strategy.position_size > 0.0
            comission_long = math.round(last_long_qty * last_long_price * (comission_percen / 100), 4)
            comission_long_stop = math.round(last_long_qty * rsrc * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
            profit
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        strategy.close_all(comment = 'Short_TRLStop')

    else if short_close and strategy.position_size < 0.0 and is_short_signal_close
        // CLOSE  PROTOCOL ---------------------------------------------------------------
        profit = 0.0
        if strategy.position_size < 0.0
            comission_short = math.round((last_short_qty * last_short_price) * (comission_percen / 100), 4) 
            comission_short_stop = math.round((last_short_qty * rsrc) * (comission_percen / 100), 4)
            profit := math.round(last_short_qty * (last_short_price - rsrc), 2) - comission_short - comission_short_stop
        else if strategy.position_size > 0.0
            comission_long = math.round((last_long_qty * last_long_price) * (comission_percen / 100), 4) 
            comission_long_stop = math.round((last_long_qty * rsrc) * (comission_percen / 100), 4)
            profit := math.round(last_long_qty * (rsrc - last_long_price), 2) - comission_long - comission_long_stop
        sum_profit := sum_profit + profit
        free_cash := free_cash + profit
        trailer_long_active := false
        trailer_short_active := false
        long_stop_price := 0.0
        short_stop_price := 1000000000000.0
        trailer_long_highest_price := 0.0
        trailer_short_lowest_price := 1000000000000.0
        trailer_long_stop_price := 0.0
        trailer_short_stop_price := 0.0
        // -------------------------------------------------------------------------------
        strategy.close_all(comment = "Short_Close")

    if is_trailer_short and strategy.position_size < 0.0 and rsrc < trailer_short_activation_price and not trailer_short_active
        trailer_short_active := true
        trailer_short_active

    if is_trailer_short and trailer_short_active
        trailer_short_lowest_price := math.min(trailer_short_lowest_price, rsrc)
        trailer_short_stop_price := trailer_short_lowest_price * (1 + trailer_short_offset / 100)
        trailer_short_stop_price

if barstate.islast and end_close
    strategy.close_all(comment = 'STOP CLOSE')
````
