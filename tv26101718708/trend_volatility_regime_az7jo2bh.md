# Trend Volatility Regime

- url: https://www.tradingview.com/script/az7JO2Bh-Trend-Volatility-Regime/
- type: indicator
- pine_id: PUB;52dff073898c47b7b2c3945313bd7ea9
- version: 3.0

## Description

The Trend Volatility Regime is an all-in-one trend-following model that identifies changes in the market regime by combining moving-average crossover signals with volatility-adaptive trailing stops. It features an integrated backtesting engine that provides institutional-grade insights into historical strategy performance, along with a built-in alert system that notifies investors in real time when regime changes occur. The model integrates seamlessly into the price chart and presents backtest results in a clear, color-coded table benchmarked against buy-and-hold.

At its core, the model combines two complementary trend detection components to determine the prevailing market regime. The first component identifies the underlying structural trend using a volatility-adjusted moving-average crossover based on the spread between fast and slow moving averages. The second component identifies trend reversals using an adaptive trailing stop based on changes in price and volatility. Bullish and bearish regimes occur when both crossover and volatility signals are directionally aligned, while conflicting signals result in neutral regimes.

[list]
[*]Bullish Crossover Signal = (Fast MA – Slow MA) > (ATR × Trend Margin)
[*]Bearish Crossover Signal = (Fast MA – Slow MA) < –(ATR × Trend Margin)
[*]Bullish Volatility Signal = Price > (Highest Price – (Volatility × Stop Factor))
[*]Bearish Volatility Signal = Price < (Lowest Price + (Volatility × Stop Factor))
[/list]
By default, the model applies an asymmetric regime design in which conflicting signals default to a bullish regime unless half-equity positions are enabled in the menu. This asymmetric design reflects the tendency of risk assets to deteriorate gradually while recovering more abruptly. The moving-average component captures the slower deterioration typically observed during market tops, while the trailing stop component responds more dynamically to faster reversals typically observed at market bottoms. This helps reduce overreaction to corrections during uptrends while still allowing for faster re-entry following sharp recoveries. To evaluate the performance of different parameter configurations, the model includes a built-in table with the following metrics:

[list]
[*]CAGR = Compounded Annual Growth Rate.
[*]Excess = CAGR in excess of buy-and-hold.
[*]Sharpe = CAGR per unit of standard deviation.
[*]Sortino = CAGR per unit of downside deviation.
[*]Calmar = CAGR relative to maximum drawdown.
[*]Max DD = Largest peak-to-trough decline in value.
[*]Alpha (α) = Excess annualized risk-adjusted returns.
[*]Win Rate = Ratio of profitable trades to total trades.
[*]Profit Factor = Total gross profit per unit of losses.
[*]Expectancy = Average expected return per trade.
[*]Turnover = Average annualized change in exposure.
[/list]
This indicator is designed with flexibility in mind, enabling users to specify the start date of the backtesting period, the preferred trend type, volatility type, and regime visualization. Supported regime visualizations include line, candle, and shaded background. Supported moving-average types include the Exponential Moving Average (EMA), Simple Moving Average (SMA), Wilder’s Moving Average (RMA), and Weighted Moving Average (WMA). Supported volatility types include the Average True Range (ATR), Standard Deviation (SD), and Mean Absolute Deviation (MAD). Supported price sources include Close, HL2, HLC3, and OHLC4. The table follows an intuitive color-coded logic that allows for quick performance comparison against buy-and-hold (B&H):

[list]
[*]CAGR = Green indicates above 0%, while red indicates below 0%.
[*]Excess = Green indicates above 0%, while red indicates below 0%.
[*]Sharpe = Green indicates better than B&H, while red indicates worse.
[*]Sortino = Green indicates better than B&H, while red indicates worse.
[*]Calmar = Green indicates better than B&H, while red indicates worse.
[*]Max DD = Green indicates better than B&H, while red indicates worse.
[*]Alpha (α) = Green indicates above 0%, while red indicates below 0%.
[*]Win Rate = Green indicates above 50%, while red indicates below 50%.
[*]Profit Factor = Green indicates above 2, while red indicates below 1.
[*]Expectancy = Green indicates above 0%, while red indicates below 0%.
[/list]
In summary, the Trend Volatility Regime is a comprehensive trend-following tool designed to help investors stay on the right side of the market by identifying key changes in the market regime. By combining volatility-adjusted moving-average crossover signals with adaptive volatility-based trailing stops, the model seeks to maximise participation during uptrends while reducing exposure during sustained downtrends. While the model provides valuable historical insights, users should remain mindful that past results may not necessarily persist under future market conditions.

## Source Code

````pine
// © QuantitativeAlpha
//@version=6
indicator(title = 'Trend Volatility Regime', shorttitle = 'TVR', overlay = true)
src_type = input.string('Close', 'Price Source', options = ['Close', 'HL2', 'HLC3', 'OHLC4'])
strategy_type = input.string('Combined', title = 'Strategy Type', options = ['Trend', 'Volatility', 'Combined'])
cross_type = input.string('EMA', title = 'Trend Type', options = ['EMA', 'SMA', 'RMA', 'WMA'])
fast_len = input.int(30, title = 'Fast Length', minval = 1)
slow_len = input.int(60, title = 'Slow Length', minval = 1)
cross_margin = input.float(0.3, title = 'Trend Margin', minval = 0.0)
vol_type = input.string('ATR', title = 'Volatility Type', options = ['ATR', 'SD', 'MAD'])
vol_length = input.int(10, title = 'Stop Length', minval = 1)
vol_factor = input.float(3.0, title = 'Stop Factor', minval = 0.1)
allow_half_positions = input.bool(false, title = 'Enable Half Equity Positions')
display_mode = input.string('Line', 'Display Mode', options = ['Line', 'Candle', 'Shade'])
show_dd_label = input.bool(false, title = 'Show Max Drawdown Label')
display_table = input.bool(true, title = 'Show Backtesting Statistics')
start_month_name = input.string('Jan', title = 'Start Month', options = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
start_year = input.int(2017, title = 'Start Year')
fee_input = input.float(0.1, title = 'Fees (%)', minval = 0.0)
price_type = input.string('Open', title = 'Entry/Exit', options = ['Open', 'Close'])
width_input = input.int(10, title = 'Table Width', minval = 1)
table_input = input.string('Low', title = 'Table Position', options = ['High', 'Middle', 'Low'])
table_position = table_input == 'High' ? position.top_right : table_input == 'Middle' ? position.middle_right : position.bottom_right
src = src_type == 'HL2' ? hl2 : src_type == 'HLC3' ? hlc3 : src_type == 'OHLC4' ? ohlc4 : close
raw_type = price_type == 'Open' ? open : close
transaction_cost = fee_input / 100.0
fast_ma = cross_type == 'SMA' ? ta.sma(src, fast_len) : cross_type == 'WMA' ? ta.wma(src, fast_len) : cross_type == 'RMA' ? ta.rma(src, fast_len) : ta.ema(src, fast_len)
slow_ma = cross_type == 'SMA' ? ta.sma(src, slow_len) : cross_type == 'WMA' ? ta.wma(src, slow_len) : cross_type == 'RMA' ? ta.rma(src, slow_len) : ta.ema(src, slow_len)
diff = fast_ma - slow_ma
bull_cross = diff > cross_margin * ta.atr(slow_len)
bear_cross = diff < -cross_margin * ta.atr(slow_len)
cross_score = bull_cross ? 1 : bear_cross ? -1 : 0
volatility = vol_type == 'SD' ? ta.stdev(src, vol_length) : vol_type == 'MAD' ? ta.sma(math.abs(src - ta.sma(src, vol_length)), vol_length) : ta.atr(vol_length)
vol_stop(src, volatility, vol_factor) =>
    var float max_val = na
    var float min_val = na
    var bool up_trend = true
    var float stop = na
    if not na(src) and not na(volatility)
        vol_m = vol_factor * volatility
        max_val := na(max_val) ? src : math.max(max_val, src)
        min_val := na(min_val) ? src : math.min(min_val, src)
        stop := na(stop) ? src : up_trend ? math.max(stop, max_val - vol_m) : math.min(stop, min_val + vol_m)
        prev_up_trend = up_trend
        up_trend := src >= stop
        if up_trend != prev_up_trend
            max_val := src
            min_val := src
            stop := up_trend ? max_val - vol_m : min_val + vol_m
    [stop, up_trend]
[v_stop, up_trend] = vol_stop(src, volatility, vol_factor)
vol_score = up_trend ? 1 : -1
ready_cross = not na(fast_ma) and not na(slow_ma)
ready_vol = not na(volatility) and not na(v_stop)
ready = strategy_type == 'Trend' ? ready_cross : strategy_type == 'Volatility' ? ready_vol : ready_cross and ready_vol
total_score = strategy_type == 'Trend' ? cross_score : strategy_type == 'Volatility' ? vol_score : ready ? cross_score + vol_score : na
regime_bull = ready and total_score > 0
regime_bear = ready and total_score < 0
regime_neutral = ready and total_score == 0
bull = ready and (allow_half_positions ? total_score > 0 : total_score >= 0)
bear = ready and total_score < 0
neutral = ready and allow_half_positions and total_score == 0
clr_bull = color.new(#00FF00, 0)
clr_bear = color.new(#FF0000, 0)
clr_neutral = color.new(#FFFFFF, 0)
fill_bull = color.new(#00FF00, 85)
fill_bear = color.new(#FF0000, 85)
fill_neutral = color.new(#FFFFFF, 85)
regime_color = not ready ? na : bull ? clr_bull : bear ? clr_bear : clr_neutral
shade_color = not ready ? na : bull ? fill_bull : bear ? fill_bear : fill_neutral
plot(display_mode == 'Line' ? close : na, color = regime_color, linewidth = 2, title = 'Line')
plotcandle(display_mode == 'Candle' ? open : na, display_mode == 'Candle' ? high : na, display_mode == 'Candle' ? low : na, display_mode == 'Candle' ? close : na, color = regime_color, wickcolor = regime_color, bordercolor = regime_color, title = 'Candle')
bgcolor(display_mode == 'Shade' ? shade_color : na, title = 'Shade')
start_month = start_month_name == 'Jan' ? 1 : start_month_name == 'Feb' ? 2 : start_month_name == 'Mar' ? 3 : start_month_name == 'Apr' ? 4 : start_month_name == 'May' ? 5 : start_month_name == 'Jun' ? 6 : start_month_name == 'Jul' ? 7 : start_month_name == 'Aug' ? 8 : start_month_name == 'Sep' ? 9 : start_month_name == 'Oct' ? 10 : start_month_name == 'Nov' ? 11 : 12
is_crypto = syminfo.type == 'crypto'
trading_days_per_year = is_crypto ? 365.0 : 252.0
user_start_ts = timestamp(start_year, start_month, 1)
var int ipo_ts = na
if na(ipo_ts)
    ipo_ts := time
start_ts = math.max(user_start_ts, ipo_ts)
raw_start_bar = time >= start_ts
in_sample_bar = raw_start_bar and ready
in_sample_ret = in_sample_bar and in_sample_bar[1]
var int period_start_ts = na
if na(period_start_ts) and in_sample_bar
    period_start_ts := time
ms_per_year = 365.0 * 24.0 * 60.0 * 60.0 * 1000.0
elapsed_years = not na(period_start_ts) ? (time - period_start_ts) / ms_per_year : na
safe_years = not na(elapsed_years) ? math.max(elapsed_years, 1.0 / trading_days_per_year) : na
bh_strat_ret = math.log(raw_type / raw_type[1])
var float bh_equity = na
var float bh_equity_start = na
var float bh_peak = na
var float bh_max_dd = na
var int bh_count = 0
var float bh_mean = 0.0
var float bh_sumsq = 0.0
var int bh_neg_count = 0
var float bh_down_sumsq = 0.0
if in_sample_bar
    bh_equity := nz(bh_equity[1], 1) * math.exp(in_sample_ret ? nz(bh_strat_ret, 0) : 0)
if na(bh_equity_start) and in_sample_bar
    bh_equity_start := bh_equity
bh_cagr = not na(bh_equity_start) and bh_equity_start > 0 and not na(safe_years) ? math.pow(bh_equity / bh_equity_start, 1 / safe_years) - 1 : na
if in_sample_ret and not na(bh_strat_ret)
    bh_prev_mean = bh_mean
    bh_count += 1
    bh_dx = bh_strat_ret - bh_prev_mean
    bh_mean += bh_dx / bh_count
    bh_sumsq += bh_dx * (bh_strat_ret - bh_mean)
    bh_down = math.min(bh_strat_ret, 0.0)
    if bh_down < 0
        bh_neg_count += 1
        bh_down_sumsq += bh_down * bh_down
bars_per_year = not na(elapsed_years) and elapsed_years > 0 and bh_count > 0 ? bh_count / elapsed_years : na
bh_vol = bh_count > 1 ? math.sqrt(bh_sumsq / (bh_count - 1)) : na
bh_hvol = not na(bh_vol) and not na(bars_per_year) ? bh_vol * math.sqrt(bars_per_year) : na
bh_sharpe = not na(bh_cagr) and not na(bh_hvol) and bh_hvol != 0 ? bh_cagr / bh_hvol : na
bh_semi = bh_neg_count > 0 ? math.sqrt(bh_down_sumsq / bh_neg_count) : na
bh_ddev = not na(bh_semi) and not na(bars_per_year) ? bh_semi * math.sqrt(bars_per_year) : na
bh_sortino = not na(bh_cagr) and not na(bh_ddev) and bh_ddev != 0 ? bh_cagr / bh_ddev : na
if in_sample_bar and not na(bh_equity)
    bh_peak := na(bh_peak) ? bh_equity : math.max(bh_peak, bh_equity)
bh_dd = not na(bh_peak) and bh_peak > 0 ? (bh_equity / bh_peak - 1.0) : na
if in_sample_bar and not na(bh_dd)
    bh_max_dd := na(bh_max_dd) ? bh_dd : math.min(bh_max_dd, bh_dd)
bh_mdd = not na(bh_max_dd) and bh_max_dd < 0 ? bh_max_dd : na
bh_calmar = not na(bh_cagr) and not na(bh_mdd) and bh_mdd != 0 ? bh_cagr / math.abs(bh_mdd) : na
var bool in_trade = false
var float entry_eq = na
var int trade_count = 0
var int wins = 0
var int losses = 0
var float tot_win = 0.0
var float tot_loss = 0.0
var int count = 0
var float mean = 0.0
var float squared = 0.0
var int neg_count = 0
var float down_sumsq = 0.0
var float equity_start = na
var float equity = na
var float peak = na
var float max_dd = na
var float bench_mean = 0.0
var float bench_sumsq = 0.0
var float cov_sumsq = 0.0
var int period_start_bar = na
if na(period_start_bar) and in_sample_bar
    period_start_bar := bar_index
exposure = not na(total_score[1]) ? (bull[1] ? 1.0 : bear[1] ? 0.0 : allow_half_positions and neutral[1] ? 0.5 : 0.0) : 0.0
is_long_now = exposure > 0.0
was_long = exposure[1] > 0.0
long_signal = is_long_now and not was_long
short_signal = not is_long_now and was_long
raw_ret = exposure[1] * math.log(raw_type / raw_type[1])
turnover = not na(exposure) and not na(exposure[1]) ? math.abs(exposure - exposure[1]) : 0.0
cost = turnover * transaction_cost
strat_ret = raw_ret - cost
var float cum_turnover = 0.0
if in_sample_ret and not na(turnover)
    cum_turnover += turnover
turnover_annualized = not na(safe_years) and safe_years > 0 ? cum_turnover / safe_years : na
if in_sample_bar
    base = na(equity[1]) ? 1.0 : equity[1]
    equity := base * math.exp(in_sample_ret ? nz(strat_ret, 0.0) : 0.0)
if in_sample_bar and not in_trade and bar_index == period_start_bar and is_long_now
    entry_eq := equity
    in_trade := true
if in_sample_ret and not in_trade and long_signal
    entry_eq := equity[1]
    in_trade := true
if in_sample_ret and in_trade and short_signal and not na(entry_eq) and not na(equity)
    r = equity / entry_eq - 1.0
    trade_count += 1
    if r > 0
        wins += 1
        tot_win += r
    else
        losses += 1
        tot_loss += r
    entry_eq := na
    in_trade := false
if barstate.islastconfirmedhistory and in_trade and not na(entry_eq) and not na(equity)
    r = equity / entry_eq - 1.0
    trade_count += 1
    if r > 0
        wins += 1
        tot_win += r
    else
        losses += 1
        tot_loss += r
    entry_eq := na
    in_trade := false
if in_sample_ret and not na(strat_ret) and not na(bh_strat_ret)
    prev_mean = mean
    prev_bench_mean = bench_mean
    count += 1
    dx = strat_ret - prev_mean
    mean += dx / count
    squared += dx * (strat_ret - mean)
    dy = bh_strat_ret - prev_bench_mean
    bench_mean += dy / count
    bench_sumsq += dy * (bh_strat_ret - bench_mean)
    cov_sumsq += dx * (bh_strat_ret - bench_mean)
    down = math.min(strat_ret, 0.0)
    if down < 0
        neg_count += 1
        down_sumsq += down * down
if na(equity_start) and in_sample_bar
    equity_start := equity
if in_sample_bar and not na(equity)
    peak := na(peak) ? equity : math.max(peak, equity)
dd = peak > 0 ? (equity / peak - 1.0) : na
if in_sample_bar and not na(dd)
    max_dd := na(max_dd) ? dd : math.min(max_dd, dd)
cagr = not na(equity_start) and equity_start > 0 and not na(safe_years) ? math.pow(equity / equity_start, 1 / safe_years) - 1 : na
vol = count > 1 ? math.sqrt(squared / (count - 1)) : na
hvol = not na(vol) and not na(bars_per_year) ? vol * math.sqrt(bars_per_year) : na
sharpe = not na(cagr) and not na(hvol) and hvol != 0 ? cagr / hvol : na
semi = neg_count > 0 ? math.sqrt(down_sumsq / neg_count) : na
ddev = not na(semi) and not na(bars_per_year) ? semi * math.sqrt(bars_per_year) : na
sortino = not na(cagr) and not na(ddev) and ddev != 0 ? cagr / ddev : na
mdd = not na(max_dd) and max_dd < 0 ? max_dd : na
calmar = not na(cagr) and not na(mdd) and mdd != 0 ? cagr / math.abs(mdd) : na
var_bh = count > 1 ? bench_sumsq / (count - 1) : na
cov_xy = count > 1 ? cov_sumsq / (count - 1) : na
beta = not na(cov_xy) and not na(var_bh) and var_bh != 0 ? cov_xy / var_bh : na
excess = not na(cagr) and not na(bh_cagr) ? cagr - bh_cagr : na
alpha_bar_log = not na(beta) and not na(mean) and not na(bench_mean) ? (mean - beta * bench_mean) : na
alpha_ann_log = not na(alpha_bar_log) and not na(bars_per_year) ? alpha_bar_log * bars_per_year : na
alpha = not na(alpha_ann_log) ? math.exp(alpha_ann_log) - 1 : na
profit_factor = trade_count == 0 ? na : (losses == 0 and wins > 0 ? 99 : (tot_loss != 0 ? (tot_win / math.abs(tot_loss)) : 0.0))
win_rate = trade_count > 0 ? wins / trade_count : na
loss_rate = trade_count > 0 ? losses / trade_count : na
avg_win = wins > 0 ? tot_win / wins : na
avg_loss = losses > 0 ? tot_loss / losses : na
expectancy = not na(win_rate) and not na(avg_win) and losses == 0 ? win_rate * avg_win : not na(loss_rate) and not na(avg_loss) and wins == 0 ? -loss_rate * math.abs(avg_loss) : not na(win_rate) and not na(loss_rate) and not na(avg_win) and not na(avg_loss) ? (win_rate * avg_win - loss_rate * math.abs(avg_loss)) : na
excess_final = na(excess) ? '-' : str.tostring(excess, '#%')
cagr_final = na(cagr) ? '-' : str.tostring(cagr, '#%')
sharpe_final = na(sharpe) ? '-' : str.tostring(sharpe, '#.#')
sortino_final = na(sortino) ? '-' : str.tostring(sortino, '#.#')
calmar_final = na(calmar) ? '-' : str.tostring(calmar, '#.#')
mdd_final = na(mdd) ? '-' : str.tostring(mdd, '#%')
alpha_final = na(alpha) ? '-' : str.tostring(alpha, '#%')
win_final = na(win_rate) ? '-' : str.tostring(win_rate, '#%')
profit_factor_final = na(profit_factor) ? '-' : str.tostring(profit_factor, '#.#') + 'x'
expectancy_final = na(expectancy) ? '-' : str.tostring(expectancy, '#%')
turnover_final = na(turnover_annualized) ? '-' : str.tostring(turnover_annualized, '#.#')
vol_final = not ready_vol ? '-' : up_trend ? 'BULL' : 'BEAR'
trend_final = not ready_cross ? '-' : diff > 0 ? 'BULL' : 'BEAR'
position_y = close - ta.atr(slow_len)
var label strategy_dd_label = na
if show_dd_label and in_sample_bar and not na(dd)
    if na(max_dd[1]) or dd < max_dd[1]
        label.delete(strategy_dd_label)
        strategy_dd_label := label.new(x = bar_index, y = position_y, text = str.tostring(dd, '#%'), style = label.style_label_up, color = color.blue, textcolor = color.white)
if display_table
    var table t = table.new(table_position, 2, 11, frame_color = color.white, frame_width = 1, border_color = color.white, border_width = 1)
    table.cell(t, 0, 0, text = 'CAGR', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 1, text = 'Excess', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 2, text = 'Sharpe', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 3, text = 'Sortino', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 4, text = 'Calmar', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 5, text = 'Max DD', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 6, text = 'Alpha (α)', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 7, text = 'Win Rate', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 8, text = 'Profit Factor', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 9, text = 'Expectancy', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 0, 10, text = 'Turnover', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(t, 1, 0, text = cagr_final, width = width_input, text_color = color.white, bgcolor = cagr > 0 ? color.green : cagr < 0 ? color.red : color.gray)
    table.cell(t, 1, 1, text = excess_final, width = width_input, text_color = color.white, bgcolor = excess > 0 ? color.green : excess < 0 ? color.red : color.gray)
    table.cell(t, 1, 2, text = sharpe_final, width = width_input, text_color = color.white, bgcolor = sharpe > bh_sharpe ? color.green : sharpe < bh_sharpe ? color.red : color.gray)
    table.cell(t, 1, 3, text = sortino_final, width = width_input, text_color = color.white, bgcolor = sortino > bh_sortino ? color.green : sortino < bh_sortino ? color.red : color.gray)
    table.cell(t, 1, 4, text = calmar_final, width = width_input, text_color = color.white, bgcolor = calmar > bh_calmar ? color.green : calmar < bh_calmar ? color.red : color.gray)
    table.cell(t, 1, 5, text = mdd_final, width = width_input, text_color = color.white, bgcolor = mdd > bh_mdd ? color.green : mdd < bh_mdd ? color.red : color.gray)
    table.cell(t, 1, 6, text = alpha_final, width = width_input, text_color = color.white, bgcolor = alpha > 0 ? color.green : alpha < 0 ? color.red : color.gray)
    table.cell(t, 1, 7, text = win_final, width = width_input, text_color = color.white, bgcolor = win_rate > 0.5 ? color.green : win_rate < 0.5 ? color.red : color.gray)
    table.cell(t, 1, 8, text = profit_factor_final, width = width_input, text_color = color.white, bgcolor = profit_factor > 2 ? color.green : profit_factor < 1 ? color.red : color.gray)
    table.cell(t, 1, 9, text = expectancy_final, width = width_input, text_color = color.white, bgcolor = expectancy > 0 ? color.green : expectancy < 0 ? color.red : color.gray)
    table.cell(t, 1, 10, text = turnover_final, width = width_input, text_color = color.white, bgcolor = color.gray)
if not display_table
    var table signal_t = table.new(table_position, 1, 3, border_width = 2)
    table.cell(signal_t, 0, 0, text = vol_final, width = 14, text_color = color.white, bgcolor = not ready_vol ? color.gray : up_trend ? color.green : color.red)
    table.cell(signal_t, 0, 1, text = trend_final, width = 14, text_color = color.white, bgcolor = bull_cross ? color.green : bear_cross ? color.red : color.gray)
    table.cell(signal_t, 0, 2, text = '', width = 14, text_color = color.new(color.white, 100), bgcolor = color.new(color.white, 100))
bull_condition = regime_bull and not regime_bull[1]
bear_condition = regime_bear and not regime_bear[1]
neutral_condition = regime_neutral and not regime_neutral[1]
trend_neutral = ready_cross and not bull_cross and not bear_cross
trend_bull_condition = ready_cross and bull_cross and not bull_cross[1]
trend_bear_condition = ready_cross and bear_cross and not bear_cross[1]
trend_neutral_condition = trend_neutral and not trend_neutral[1]
vol_bull_condition = ready_vol and up_trend and not up_trend[1]
vol_bear_condition = ready_vol and not up_trend and up_trend[1]
alertcondition(bull_condition, title = 'Bullish', message = '{{ticker}} Trend Volatility Bullish!')
alertcondition(bear_condition, title = 'Bearish', message = '{{ticker}} Trend Volatility Bearish!')
alertcondition(neutral_condition, title = 'Neutral', message = '{{ticker}} Trend Volatility Neutral!')
if trend_bull_condition
    alert(syminfo.ticker + ' Trend Bullish!', alert.freq_once_per_bar_close)
if trend_bear_condition
    alert(syminfo.ticker + ' Trend Bearish!', alert.freq_once_per_bar_close)
if trend_neutral_condition
    alert(syminfo.ticker + ' Trend Neutral!', alert.freq_once_per_bar_close)
if vol_bull_condition
    alert(syminfo.ticker + ' Volatility Bullish!', alert.freq_once_per_bar_close)
if vol_bear_condition
    alert(syminfo.ticker + ' Volatility Bearish!', alert.freq_once_per_bar_close)
````
