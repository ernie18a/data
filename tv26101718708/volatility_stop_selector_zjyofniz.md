# Volatility Stop Selector

- url: https://www.tradingview.com/script/ZJyofNiZ-Volatility-Stop-Selector/
- type: indicator
- pine_id: PUB;736bd47ea3224f0690fcf2a57a35d33a
- version: 3.0

## Description

The Volatility Stop Selector is a comprehensive trend-following tool designed to automatically identify the optimal volatility stop strategy. It features adjustable parameters and an integrated backtester that delivers institutional-grade insights into the recommended strategy. The model continuously adapts to new data in real time by evaluating multiple volatility length and factor combinations, determining the best-performing configuration, and presenting the backtest results in a clear, color-coded table that benchmarks performance against the buy-and-hold strategy.

At its core, the model systematically backtests a wide range of volatility stop combinations to identify the configuration that maximizes the selected optimization metric. Users can choose to optimize for absolute returns or risk-adjusted returns using metrics such as the Sharpe, Sortino, Martin, or Calmar ratios. The Martin ratio is particularly well suited for volatility-based risk management strategies, as it evaluates returns relative to the Ulcer Index, capturing both the depth and duration of drawdowns and therefore favoring smoother equity curves. Alternatively, users can enable manual optimization to test custom volatility length and factor settings and view the corresponding backtest results. The label displays the Compounded Annual Growth Rate (CAGR) of the strategy, with the buy-and-hold CAGR in parentheses for comparison. The table presents the backtest results based on the volatility length and factor displayed at the top:

[list]
[*]Sharpe = CAGR per unit of standard deviation.
[*]Sortino = CAGR per unit of downside deviation.
[*]Calmar = CAGR relative to maximum drawdown.
[*]Max DD = Largest peak-to-trough decline in value.
[*]Beta (β) = Return sensitivity relative to buy-and-hold.
[*]Alpha (α) = Excess annualized risk-adjusted returns.
[*]Win Rate = Ratio of profitable trades to total trades.
[*]Profit Factor = Total gross profit per unit of losses.
[*]Expectancy = Average expected return per trade.
[*]Trades/Year = Average number of trades per year.
[/list]
This indicator is designed with flexibility in mind, enabling users to specify the start date of the backtesting period, the preferred volatility type, and the price source. Supported volatility types include the Average True Range (ATR), Standard Deviation (SD), and Mean Absolute Deviation (MAD). Supported price sources include Close, Heikin Ashi, HL2, HLC3, and OHLC4. To minimize overfitting, users can define constraints such as a minimum and maximum number of trades per year, as well as an optional optimization margin that prioritizes more robust combinations by requiring more reactive combinations to exceed this threshold. The table follows an intuitive color-coded logic that enables quick performance comparison against buy-and-hold (B&H):

[list]
[*]Sharpe = Green indicates better than B&H, while red indicates worse.
[*]Sortino = Green indicates better than B&H, while red indicates worse.
[*]Calmar = Green indicates better than B&H, while red indicates worse.
[*]Max DD = Green indicates better than B&H, while red indicates worse.
[*]Beta (β) = Green indicates better than B&H, while red indicates worse.
[*]Alpha (α) = Green indicates above 0%, while red indicates below 0%.
[*]Win Rate = Green indicates above 50%, while red indicates below 50%.
[*]Profit Factor = Green indicates above 2, while red indicates below 1.
[*]Expectancy = Green indicates above 0%, while red indicates below 0%.
[/list]
In summary, the Volatility Stop Selector is a powerful tool designed to help investors make data-driven decisions when selecting volatility-based trend-following strategies. By optimizing for risk-adjusted returns, investors can identify the best configurations using institutional-grade metrics. While results are based on the selected historical period, users should be mindful of overfitting, as past results may not persist under future market conditions. Since the model continuously recalibrates to incorporate new data, the recommended length and factor may evolve over time.

## Source Code

````pine
// © QuantitativeAlpha
//@version=6
indicator(title = 'Volatility Stop Selector', shorttitle = 'VSS', overlay = true)
start_month_name = input.string('Jan', title = 'Start Month', options = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
start_year = input.int(2008, title = 'Start Year')
vol_type = input.string('ATR', 'Volatility Type', options = ['ATR', 'SD', 'MAD'])
src_type = input.string('Close', 'Price Source', options = ['Close', 'HA', 'HL2', 'HLC3', 'OHLC4'])
length_logic = input.string('Martin', title = 'Optimization', options = ['Return', 'Martin', 'Sharpe', 'Sortino', 'Calmar', 'Manual'])
margin = input.float(0.0, title = 'Margin (%)', minval = 0.0)
price_type = input.string('Open', title = 'Entry/Exit', options = ['Open', 'Close'])
max_trades = input.float(10.0, title = 'Max Trades', minval = 1.0)
min_trades = input.float(0.0, title = 'Min Trades', minval = 0.0)
manual_vol_length = input.int(10, title = 'Manual Length', minval = 1)
manual_vol_factor = input.float(3.0, title = 'Manual Factor', minval = 0.1)
width_input = input.int(10, title = 'Table Width', minval = 1)
table_input = input.string('Low', title = 'Table Position', options = ['High', 'Middle', 'Low'])
table_position = table_input == 'High' ? position.top_right : table_input == 'Middle' ? position.middle_right : position.bottom_right
start_month = start_month_name == 'Jan' ? 1 : start_month_name == 'Feb' ? 2 : start_month_name == 'Mar' ? 3 : start_month_name == 'Apr' ? 4 : start_month_name == 'May' ? 5 : start_month_name == 'Jun' ? 6 : start_month_name == 'Jul' ? 7 : start_month_name == 'Aug' ? 8 : start_month_name == 'Sep' ? 9 : start_month_name == 'Oct' ? 10 : start_month_name == 'Nov' ? 11 : 12
raw_type = price_type == 'Open' ? open : close
is_crypto = syminfo.type == 'crypto'
trading_days_per_year = is_crypto ? 365.0 : 252.0
user_start_ts = timestamp(start_year, start_month, 1)
var int ipo_ts = na
if na(ipo_ts)
    ipo_ts := time
start_ts = math.max(user_start_ts, ipo_ts)
in_sample_bar = time >= start_ts
in_sample_ret = time >= start_ts and time[1] >= start_ts
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
var int bh_ui_count = 0
var float bh_ui_sumsq = 0.0
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
if in_sample_bar and not na(bh_dd)
    bh_ui_count += 1
    bh_ui_sumsq += bh_dd * bh_dd
bh_mdd = not na(bh_max_dd) and bh_max_dd < 0 ? bh_max_dd : na
bh_calmar = not na(bh_cagr) and not na(bh_mdd) and bh_mdd != 0 ? bh_cagr / math.abs(bh_mdd) : na
bh_ulcer = bh_ui_count > 0 ? math.sqrt(bh_ui_sumsq / bh_ui_count) : na
bh_martin = not na(bh_cagr) and not na(bh_ulcer) and bh_ulcer != 0 ? bh_cagr / bh_ulcer : na
var int slots = 89
var bool[] in_trade_a = array.new_bool(slots, false)
var float[] entry_eq_a = array.new_float(slots, na)
var int[] trade_count_a = array.new_int(slots, 0)
var int[] wins_a = array.new_int(slots, 0)
var int[] losses_a = array.new_int(slots, 0)
var float[] total_profit_a = array.new_float(slots, 0.0)
var float[] total_loss_a = array.new_float(slots, 0.0)
var int[] count_arr = array.new_int(slots, 0)
var float[] mean_arr = array.new_float(slots, 0.0)
var float[] squared_arr = array.new_float(slots, 0.0)
var int[] neg_count_arr = array.new_int(slots, 0)
var float[] down_sumsq_arr = array.new_float(slots, 0)
var float[] equity_start_a = array.new_float(slots, na)
var float[] eq_a = array.new_float(slots, na)
var float[] peak_a = array.new_float(slots, na)
var float[] max_dd_a = array.new_float(slots, na)
var float[] bench_mean_arr = array.new_float(slots, 0.0)
var float[] bench_sumsq_arr = array.new_float(slots, 0.0)
var float[] cov_sumsq_arr = array.new_float(slots, 0.0)
var int[] ui_count_a = array.new_int(slots, 0)
var float[] ui_sumsq_a = array.new_float(slots, 0.0)
var float[] max_src_a = array.new_float(slots, na)
var float[] min_src_a = array.new_float(slots, na)
var bool[] uptrend_a = array.new_bool(slots, true)
var float[] trend_a = array.new_float(slots, na)
var int period_start_bar = na
ha_close = (open + high + low + close) / 4
var float ha_open = na
ha_open := na(ha_open[1]) ? (open + close) / 2 : (ha_open[1] + ha_close[1]) / 2
ha_high = math.max(high, math.max(ha_open, ha_close))
ha_low = math.min(low, math.min(ha_open, ha_close))
src = src_type == 'HA' ? ha_close : src_type == 'HL2' ? hl2 : src_type == 'HLC3' ? hlc3 : src_type == 'OHLC4' ? ohlc4 : close
if na(period_start_bar) and in_sample_bar
    period_start_bar := bar_index
score_combo(slot, vol_length, vol_factor) =>
    ha_tr = math.max(ha_high - ha_low, math.max(math.abs(ha_high - ha_close[1]), math.abs(ha_low - ha_close[1])))
    vol = vol_type == 'SD' ? ta.stdev(src, vol_length) : vol_type == 'MAD' ? ta.sma(math.abs(src - ta.sma(src, vol_length)), vol_length) : src_type == 'HA' ? ta.rma(ha_tr, vol_length) : ta.atr(vol_length)
    max_src = array.get(max_src_a, slot)
    min_src = array.get(min_src_a, slot)
    uptrend = array.get(uptrend_a, slot)
    trend = array.get(trend_a, slot)
    prev_trend = trend
    prev_uptrend = uptrend
    prev_vol_dir = prev_uptrend ? -1 : 1
    if not na(src) and not na(vol)
        max_src := na(max_src) ? src : math.max(max_src, src)
        min_src := na(min_src) ? src : math.min(min_src, src)
        long_stop = max_src - vol_factor * vol
        short_stop = min_src + vol_factor * vol
        trend := na(trend) ? src : uptrend ? math.max(trend, long_stop) : math.min(trend, short_stop)
        uptrend := src >= trend
        if uptrend != prev_uptrend
            max_src := src
            min_src := src
            trend := uptrend ? max_src - vol_factor * vol : min_src + vol_factor * vol
    vol_stop = trend
    vol_dir = uptrend ? -1 : 1
    exposure = not na(prev_trend) and prev_vol_dir < 0 ? 1.0 : 0.0
    is_long_now = exposure > 0.0
    was_long = exposure[1] > 0.0
    long_signal = is_long_now and not was_long
    short_signal = not is_long_now and was_long
    array.set(max_src_a, slot, max_src)
    array.set(min_src_a, slot, min_src)
    array.set(uptrend_a, slot, uptrend)
    array.set(trend_a, slot, trend)
    strat_ret = exposure[1] * math.log(raw_type / raw_type[1])
    in_trade = array.get(in_trade_a, slot)
    entry_eq = array.get(entry_eq_a, slot)
    trade_count = array.get(trade_count_a, slot)
    wins = array.get(wins_a, slot)
    losses = array.get(losses_a, slot)
    tot_win = array.get(total_profit_a, slot)
    tot_loss = array.get(total_loss_a, slot)
    count = array.get(count_arr, slot)
    mean = array.get(mean_arr, slot)
    squared = array.get(squared_arr, slot)
    neg_count = array.get(neg_count_arr, slot)
    down_sumsq = array.get(down_sumsq_arr, slot)
    equity_start = array.get(equity_start_a, slot)
    eq_prev = array.get(eq_a, slot)
    peak = array.get(peak_a, slot)
    max_dd_slot = array.get(max_dd_a, slot)
    bench_mean = array.get(bench_mean_arr, slot)
    bench_sumsq = array.get(bench_sumsq_arr, slot)
    cov_sumsq = array.get(cov_sumsq_arr, slot)
    ui_count = array.get(ui_count_a, slot)
    ui_sumsq = array.get(ui_sumsq_a, slot)
    bh_r = bh_strat_ret
    float equity = na
    if in_sample_bar
        base = na(eq_prev) ? 1.0 : eq_prev
        equity := base * math.exp(in_sample_ret ? nz(strat_ret, 0) : 0)
    if in_sample_bar and not in_trade and bar_index == period_start_bar and is_long_now
        entry_eq := equity
        in_trade := true
    if in_sample_ret and not in_trade and long_signal
        entry_eq := eq_prev
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
    if in_sample_ret and not na(strat_ret) and not na(bh_r)
        prev_mean = mean
        prev_bench_mean = bench_mean
        count += 1
        dx = strat_ret - prev_mean
        mean += dx / count
        squared += dx * (strat_ret - mean)
        dy = bh_r - prev_bench_mean
        bench_mean += dy / count
        bench_sumsq += dy * (bh_r - bench_mean)
        cov_sumsq += dx * (bh_r - bench_mean)
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
        max_dd_slot := na(max_dd_slot) ? dd : math.min(max_dd_slot, dd)
    if in_sample_bar and not na(dd)
        ui_count += 1
        ui_sumsq += dd * dd
    cagr = not na(equity_start) and equity_start > 0 and not na(safe_years) ? math.pow(equity / equity_start, 1 / safe_years) - 1 : na
    rvol = count > 1 ? math.sqrt(squared / (count - 1)) : na
    hvol = not na(rvol) and not na(bars_per_year) ? rvol * math.sqrt(bars_per_year) : na
    sharpe = not na(cagr) and not na(hvol) and hvol != 0 ? cagr / hvol : na
    semi = neg_count > 0 ? math.sqrt(down_sumsq / neg_count) : na
    ddev = not na(semi) and not na(bars_per_year) ? semi * math.sqrt(bars_per_year) : na
    sortino = not na(cagr) and not na(ddev) and ddev != 0 ? cagr / ddev : na
    mdd = not na(max_dd_slot) and max_dd_slot < 0 ? max_dd_slot : na
    calmar = not na(cagr) and not na(mdd) and mdd != 0 ? cagr / math.abs(mdd) : na
    ulcer = ui_count > 0 ? math.sqrt(ui_sumsq / ui_count) : na
    martin = not na(cagr) and not na(ulcer) and ulcer != 0 ? cagr / ulcer : na
    var_bh = count > 1 ? bench_sumsq / (count - 1) : na
    cov_xy = count > 1 ? cov_sumsq / (count - 1) : na
    beta = not na(cov_xy) and not na(var_bh) and var_bh != 0 ? cov_xy / var_bh : na
    alpha_bar_log = not na(beta) and not na(mean) and not na(bench_mean) ? (mean - beta * bench_mean) : na
    alpha_ann_log = not na(alpha_bar_log) and not na(bars_per_year) ? alpha_bar_log * bars_per_year : na
    alpha = not na(alpha_ann_log) ? math.exp(alpha_ann_log) - 1 : na
    factor = trade_count == 0 ? na : (losses == 0 and wins > 0 ? 99 : (tot_loss != 0 ? (tot_win / math.abs(tot_loss)) : 0.0))
    win_rate = trade_count > 0 ? wins / trade_count : na
    loss_rate = trade_count > 0 ? losses / trade_count : na
    avg_win = wins > 0 ? tot_win / wins : na
    avg_loss = losses > 0 ? tot_loss / losses : na
    expectancy = not na(win_rate) and not na(avg_win) and losses == 0 ? win_rate * avg_win : not na(loss_rate) and not na(avg_loss) and wins == 0 ? -loss_rate * math.abs(avg_loss) : not na(win_rate) and not na(loss_rate) and not na(avg_win) and not na(avg_loss) ? (win_rate * avg_win - loss_rate * math.abs(avg_loss)) : na
    trades = trade_count > 0 and not na(safe_years) and safe_years > 0 ? trade_count / safe_years : na
    array.set(in_trade_a, slot, in_trade)
    array.set(entry_eq_a, slot, entry_eq)
    array.set(trade_count_a, slot, trade_count)
    array.set(wins_a, slot, wins)
    array.set(losses_a, slot, losses)
    array.set(total_profit_a, slot, tot_win)
    array.set(total_loss_a, slot, tot_loss)
    array.set(count_arr, slot, count)
    array.set(mean_arr, slot, mean)
    array.set(squared_arr, slot, squared)
    array.set(neg_count_arr, slot, neg_count)
    array.set(down_sumsq_arr, slot, down_sumsq)
    array.set(equity_start_a, slot, equity_start)
    array.set(eq_a, slot, equity)
    array.set(peak_a, slot, peak)
    array.set(max_dd_a, slot, max_dd_slot)
    array.set(bench_mean_arr, slot, bench_mean)
    array.set(bench_sumsq_arr, slot, bench_sumsq)
    array.set(cov_sumsq_arr, slot, cov_sumsq)
    array.set(ui_count_a, slot, ui_count)
    array.set(ui_sumsq_a, slot, ui_sumsq)
    score_metric = length_logic == 'Martin' ? martin : length_logic == 'Calmar' ? calmar : length_logic == 'Sortino' ? sortino : length_logic == 'Return' ? cagr : sharpe
    score = not na(trades) and trades >= min_trades and trades <= max_trades and not na(score_metric) ? score_metric : na
    [score, cagr, sharpe, calmar, sortino, mdd, beta, alpha, win_rate, factor, expectancy, trades, vol_stop, vol_dir]
[score1, cagr1, sharpe1, calmar1, sortino1, mdd1, beta1, alpha1, win_rate1, pf1, expectancy1, trades1, stop1, dir1] = score_combo(0, 5, 2.0)
[score2, cagr2, sharpe2, calmar2, sortino2, mdd2, beta2, alpha2, win_rate2, pf2, expectancy2, trades2, stop2, dir2] = score_combo(1, 5, 2.5)
[score3, cagr3, sharpe3, calmar3, sortino3, mdd3, beta3, alpha3, win_rate3, pf3, expectancy3, trades3, stop3, dir3] = score_combo(2, 5, 3.0)
[score4, cagr4, sharpe4, calmar4, sortino4, mdd4, beta4, alpha4, win_rate4, pf4, expectancy4, trades4, stop4, dir4] = score_combo(3, 5, 3.5)
[score5, cagr5, sharpe5, calmar5, sortino5, mdd5, beta5, alpha5, win_rate5, pf5, expectancy5, trades5, stop5, dir5] = score_combo(4, 5, 4.0)
[score6, cagr6, sharpe6, calmar6, sortino6, mdd6, beta6, alpha6, win_rate6, pf6, expectancy6, trades6, stop6, dir6] = score_combo(5, 5, 4.5)
[score7, cagr7, sharpe7, calmar7, sortino7, mdd7, beta7, alpha7, win_rate7, pf7, expectancy7, trades7, stop7, dir7] = score_combo(6, 5, 5.0)
[score8, cagr8, sharpe8, calmar8, sortino8, mdd8, beta8, alpha8, win_rate8, pf8, expectancy8, trades8, stop8, dir8] = score_combo(7, 5, 6.0)
[score9, cagr9, sharpe9, calmar9, sortino9, mdd9, beta9, alpha9, win_rate9, pf9, expectancy9, trades9, stop9, dir9] = score_combo(8, 5, 7.0)
[score10, cagr10, sharpe10, calmar10, sortino10, mdd10, beta10, alpha10, win_rate10, pf10, expectancy10, trades10, stop10, dir10] = score_combo(9, 5, 8.0)
[score11, cagr11, sharpe11, calmar11, sortino11, mdd11, beta11, alpha11, win_rate11, pf11, expectancy11, trades11, stop11, dir11] = score_combo(10, 5, 10.0)
[score12, cagr12, sharpe12, calmar12, sortino12, mdd12, beta12, alpha12, win_rate12, pf12, expectancy12, trades12, stop12, dir12] = score_combo(11, 10, 2.0)
[score13, cagr13, sharpe13, calmar13, sortino13, mdd13, beta13, alpha13, win_rate13, pf13, expectancy13, trades13, stop13, dir13] = score_combo(12, 10, 2.5)
[score14, cagr14, sharpe14, calmar14, sortino14, mdd14, beta14, alpha14, win_rate14, pf14, expectancy14, trades14, stop14, dir14] = score_combo(13, 10, 3.0)
[score15, cagr15, sharpe15, calmar15, sortino15, mdd15, beta15, alpha15, win_rate15, pf15, expectancy15, trades15, stop15, dir15] = score_combo(14, 10, 3.5)
[score16, cagr16, sharpe16, calmar16, sortino16, mdd16, beta16, alpha16, win_rate16, pf16, expectancy16, trades16, stop16, dir16] = score_combo(15, 10, 4.0)
[score17, cagr17, sharpe17, calmar17, sortino17, mdd17, beta17, alpha17, win_rate17, pf17, expectancy17, trades17, stop17, dir17] = score_combo(16, 10, 4.5)
[score18, cagr18, sharpe18, calmar18, sortino18, mdd18, beta18, alpha18, win_rate18, pf18, expectancy18, trades18, stop18, dir18] = score_combo(17, 10, 5.0)
[score19, cagr19, sharpe19, calmar19, sortino19, mdd19, beta19, alpha19, win_rate19, pf19, expectancy19, trades19, stop19, dir19] = score_combo(18, 10, 6.0)
[score20, cagr20, sharpe20, calmar20, sortino20, mdd20, beta20, alpha20, win_rate20, pf20, expectancy20, trades20, stop20, dir20] = score_combo(19, 10, 7.0)
[score21, cagr21, sharpe21, calmar21, sortino21, mdd21, beta21, alpha21, win_rate21, pf21, expectancy21, trades21, stop21, dir21] = score_combo(20, 10, 8.0)
[score22, cagr22, sharpe22, calmar22, sortino22, mdd22, beta22, alpha22, win_rate22, pf22, expectancy22, trades22, stop22, dir22] = score_combo(21, 10, 10.0)
[score23, cagr23, sharpe23, calmar23, sortino23, mdd23, beta23, alpha23, win_rate23, pf23, expectancy23, trades23, stop23, dir23] = score_combo(22, 15, 2.0)
[score24, cagr24, sharpe24, calmar24, sortino24, mdd24, beta24, alpha24, win_rate24, pf24, expectancy24, trades24, stop24, dir24] = score_combo(23, 15, 2.5)
[score25, cagr25, sharpe25, calmar25, sortino25, mdd25, beta25, alpha25, win_rate25, pf25, expectancy25, trades25, stop25, dir25] = score_combo(24, 15, 3.0)
[score26, cagr26, sharpe26, calmar26, sortino26, mdd26, beta26, alpha26, win_rate26, pf26, expectancy26, trades26, stop26, dir26] = score_combo(25, 15, 3.5)
[score27, cagr27, sharpe27, calmar27, sortino27, mdd27, beta27, alpha27, win_rate27, pf27, expectancy27, trades27, stop27, dir27] = score_combo(26, 15, 4.0)
[score28, cagr28, sharpe28, calmar28, sortino28, mdd28, beta28, alpha28, win_rate28, pf28, expectancy28, trades28, stop28, dir28] = score_combo(27, 15, 4.5)
[score29, cagr29, sharpe29, calmar29, sortino29, mdd29, beta29, alpha29, win_rate29, pf29, expectancy29, trades29, stop29, dir29] = score_combo(28, 15, 5.0)
[score30, cagr30, sharpe30, calmar30, sortino30, mdd30, beta30, alpha30, win_rate30, pf30, expectancy30, trades30, stop30, dir30] = score_combo(29, 15, 6.0)
[score31, cagr31, sharpe31, calmar31, sortino31, mdd31, beta31, alpha31, win_rate31, pf31, expectancy31, trades31, stop31, dir31] = score_combo(30, 15, 7.0)
[score32, cagr32, sharpe32, calmar32, sortino32, mdd32, beta32, alpha32, win_rate32, pf32, expectancy32, trades32, stop32, dir32] = score_combo(31, 15, 8.0)
[score33, cagr33, sharpe33, calmar33, sortino33, mdd33, beta33, alpha33, win_rate33, pf33, expectancy33, trades33, stop33, dir33] = score_combo(32, 15, 10.0)
[score34, cagr34, sharpe34, calmar34, sortino34, mdd34, beta34, alpha34, win_rate34, pf34, expectancy34, trades34, stop34, dir34] = score_combo(33, 20, 2.0)
[score35, cagr35, sharpe35, calmar35, sortino35, mdd35, beta35, alpha35, win_rate35, pf35, expectancy35, trades35, stop35, dir35] = score_combo(34, 20, 2.5)
[score36, cagr36, sharpe36, calmar36, sortino36, mdd36, beta36, alpha36, win_rate36, pf36, expectancy36, trades36, stop36, dir36] = score_combo(35, 20, 3.0)
[score37, cagr37, sharpe37, calmar37, sortino37, mdd37, beta37, alpha37, win_rate37, pf37, expectancy37, trades37, stop37, dir37] = score_combo(36, 20, 3.5)
[score38, cagr38, sharpe38, calmar38, sortino38, mdd38, beta38, alpha38, win_rate38, pf38, expectancy38, trades38, stop38, dir38] = score_combo(37, 20, 4.0)
[score39, cagr39, sharpe39, calmar39, sortino39, mdd39, beta39, alpha39, win_rate39, pf39, expectancy39, trades39, stop39, dir39] = score_combo(38, 20, 4.5)
[score40, cagr40, sharpe40, calmar40, sortino40, mdd40, beta40, alpha40, win_rate40, pf40, expectancy40, trades40, stop40, dir40] = score_combo(39, 20, 5.0)
[score41, cagr41, sharpe41, calmar41, sortino41, mdd41, beta41, alpha41, win_rate41, pf41, expectancy41, trades41, stop41, dir41] = score_combo(40, 20, 6.0)
[score42, cagr42, sharpe42, calmar42, sortino42, mdd42, beta42, alpha42, win_rate42, pf42, expectancy42, trades42, stop42, dir42] = score_combo(41, 20, 7.0)
[score43, cagr43, sharpe43, calmar43, sortino43, mdd43, beta43, alpha43, win_rate43, pf43, expectancy43, trades43, stop43, dir43] = score_combo(42, 20, 8.0)
[score44, cagr44, sharpe44, calmar44, sortino44, mdd44, beta44, alpha44, win_rate44, pf44, expectancy44, trades44, stop44, dir44] = score_combo(43, 20, 10.0)
[score45, cagr45, sharpe45, calmar45, sortino45, mdd45, beta45, alpha45, win_rate45, pf45, expectancy45, trades45, stop45, dir45] = score_combo(44, 25, 2.0)
[score46, cagr46, sharpe46, calmar46, sortino46, mdd46, beta46, alpha46, win_rate46, pf46, expectancy46, trades46, stop46, dir46] = score_combo(45, 25, 2.5)
[score47, cagr47, sharpe47, calmar47, sortino47, mdd47, beta47, alpha47, win_rate47, pf47, expectancy47, trades47, stop47, dir47] = score_combo(46, 25, 3.0)
[score48, cagr48, sharpe48, calmar48, sortino48, mdd48, beta48, alpha48, win_rate48, pf48, expectancy48, trades48, stop48, dir48] = score_combo(47, 25, 3.5)
[score49, cagr49, sharpe49, calmar49, sortino49, mdd49, beta49, alpha49, win_rate49, pf49, expectancy49, trades49, stop49, dir49] = score_combo(48, 25, 4.0)
[score50, cagr50, sharpe50, calmar50, sortino50, mdd50, beta50, alpha50, win_rate50, pf50, expectancy50, trades50, stop50, dir50] = score_combo(49, 25, 4.5)
[score51, cagr51, sharpe51, calmar51, sortino51, mdd51, beta51, alpha51, win_rate51, pf51, expectancy51, trades51, stop51, dir51] = score_combo(50, 25, 5.0)
[score52, cagr52, sharpe52, calmar52, sortino52, mdd52, beta52, alpha52, win_rate52, pf52, expectancy52, trades52, stop52, dir52] = score_combo(51, 25, 6.0)
[score53, cagr53, sharpe53, calmar53, sortino53, mdd53, beta53, alpha53, win_rate53, pf53, expectancy53, trades53, stop53, dir53] = score_combo(52, 25, 7.0)
[score54, cagr54, sharpe54, calmar54, sortino54, mdd54, beta54, alpha54, win_rate54, pf54, expectancy54, trades54, stop54, dir54] = score_combo(53, 25, 8.0)
[score55, cagr55, sharpe55, calmar55, sortino55, mdd55, beta55, alpha55, win_rate55, pf55, expectancy55, trades55, stop55, dir55] = score_combo(54, 25, 10.0)
[score56, cagr56, sharpe56, calmar56, sortino56, mdd56, beta56, alpha56, win_rate56, pf56, expectancy56, trades56, stop56, dir56] = score_combo(55, 30, 2.0)
[score57, cagr57, sharpe57, calmar57, sortino57, mdd57, beta57, alpha57, win_rate57, pf57, expectancy57, trades57, stop57, dir57] = score_combo(56, 30, 2.5)
[score58, cagr58, sharpe58, calmar58, sortino58, mdd58, beta58, alpha58, win_rate58, pf58, expectancy58, trades58, stop58, dir58] = score_combo(57, 30, 3.0)
[score59, cagr59, sharpe59, calmar59, sortino59, mdd59, beta59, alpha59, win_rate59, pf59, expectancy59, trades59, stop59, dir59] = score_combo(58, 30, 3.5)
[score60, cagr60, sharpe60, calmar60, sortino60, mdd60, beta60, alpha60, win_rate60, pf60, expectancy60, trades60, stop60, dir60] = score_combo(59, 30, 4.0)
[score61, cagr61, sharpe61, calmar61, sortino61, mdd61, beta61, alpha61, win_rate61, pf61, expectancy61, trades61, stop61, dir61] = score_combo(60, 30, 4.5)
[score62, cagr62, sharpe62, calmar62, sortino62, mdd62, beta62, alpha62, win_rate62, pf62, expectancy62, trades62, stop62, dir62] = score_combo(61, 30, 5.0)
[score63, cagr63, sharpe63, calmar63, sortino63, mdd63, beta63, alpha63, win_rate63, pf63, expectancy63, trades63, stop63, dir63] = score_combo(62, 30, 6.0)
[score64, cagr64, sharpe64, calmar64, sortino64, mdd64, beta64, alpha64, win_rate64, pf64, expectancy64, trades64, stop64, dir64] = score_combo(63, 30, 7.0)
[score65, cagr65, sharpe65, calmar65, sortino65, mdd65, beta65, alpha65, win_rate65, pf65, expectancy65, trades65, stop65, dir65] = score_combo(64, 30, 8.0)
[score66, cagr66, sharpe66, calmar66, sortino66, mdd66, beta66, alpha66, win_rate66, pf66, expectancy66, trades66, stop66, dir66] = score_combo(65, 30, 10.0)
[score67, cagr67, sharpe67, calmar67, sortino67, mdd67, beta67, alpha67, win_rate67, pf67, expectancy67, trades67, stop67, dir67] = score_combo(66, 40, 2.0)
[score68, cagr68, sharpe68, calmar68, sortino68, mdd68, beta68, alpha68, win_rate68, pf68, expectancy68, trades68, stop68, dir68] = score_combo(67, 40, 2.5)
[score69, cagr69, sharpe69, calmar69, sortino69, mdd69, beta69, alpha69, win_rate69, pf69, expectancy69, trades69, stop69, dir69] = score_combo(68, 40, 3.0)
[score70, cagr70, sharpe70, calmar70, sortino70, mdd70, beta70, alpha70, win_rate70, pf70, expectancy70, trades70, stop70, dir70] = score_combo(69, 40, 3.5)
[score71, cagr71, sharpe71, calmar71, sortino71, mdd71, beta71, alpha71, win_rate71, pf71, expectancy71, trades71, stop71, dir71] = score_combo(70, 40, 4.0)
[score72, cagr72, sharpe72, calmar72, sortino72, mdd72, beta72, alpha72, win_rate72, pf72, expectancy72, trades72, stop72, dir72] = score_combo(71, 40, 4.5)
[score73, cagr73, sharpe73, calmar73, sortino73, mdd73, beta73, alpha73, win_rate73, pf73, expectancy73, trades73, stop73, dir73] = score_combo(72, 40, 5.0)
[score74, cagr74, sharpe74, calmar74, sortino74, mdd74, beta74, alpha74, win_rate74, pf74, expectancy74, trades74, stop74, dir74] = score_combo(73, 40, 6.0)
[score75, cagr75, sharpe75, calmar75, sortino75, mdd75, beta75, alpha75, win_rate75, pf75, expectancy75, trades75, stop75, dir75] = score_combo(74, 40, 7.0)
[score76, cagr76, sharpe76, calmar76, sortino76, mdd76, beta76, alpha76, win_rate76, pf76, expectancy76, trades76, stop76, dir76] = score_combo(75, 40, 8.0)
[score77, cagr77, sharpe77, calmar77, sortino77, mdd77, beta77, alpha77, win_rate77, pf77, expectancy77, trades77, stop77, dir77] = score_combo(76, 40, 10.0)
[score78, cagr78, sharpe78, calmar78, sortino78, mdd78, beta78, alpha78, win_rate78, pf78, expectancy78, trades78, stop78, dir78] = score_combo(77, 50, 2.0)
[score79, cagr79, sharpe79, calmar79, sortino79, mdd79, beta79, alpha79, win_rate79, pf79, expectancy79, trades79, stop79, dir79] = score_combo(78, 50, 2.5)
[score80, cagr80, sharpe80, calmar80, sortino80, mdd80, beta80, alpha80, win_rate80, pf80, expectancy80, trades80, stop80, dir80] = score_combo(79, 50, 3.0)
[score81, cagr81, sharpe81, calmar81, sortino81, mdd81, beta81, alpha81, win_rate81, pf81, expectancy81, trades81, stop81, dir81] = score_combo(80, 50, 3.5)
[score82, cagr82, sharpe82, calmar82, sortino82, mdd82, beta82, alpha82, win_rate82, pf82, expectancy82, trades82, stop82, dir82] = score_combo(81, 50, 4.0)
[score83, cagr83, sharpe83, calmar83, sortino83, mdd83, beta83, alpha83, win_rate83, pf83, expectancy83, trades83, stop83, dir83] = score_combo(82, 50, 4.5)
[score84, cagr84, sharpe84, calmar84, sortino84, mdd84, beta84, alpha84, win_rate84, pf84, expectancy84, trades84, stop84, dir84] = score_combo(83, 50, 5.0)
[score85, cagr85, sharpe85, calmar85, sortino85, mdd85, beta85, alpha85, win_rate85, pf85, expectancy85, trades85, stop85, dir85] = score_combo(84, 50, 6.0)
[score86, cagr86, sharpe86, calmar86, sortino86, mdd86, beta86, alpha86, win_rate86, pf86, expectancy86, trades86, stop86, dir86] = score_combo(85, 50, 7.0)
[score87, cagr87, sharpe87, calmar87, sortino87, mdd87, beta87, alpha87, win_rate87, pf87, expectancy87, trades87, stop87, dir87] = score_combo(86, 50, 8.0)
[score88, cagr88, sharpe88, calmar88, sortino88, mdd88, beta88, alpha88, win_rate88, pf88, expectancy88, trades88, stop88, dir88] = score_combo(87, 50, 10.0)
[mscore, mcagr, msharpe, mcalmar, msortino, mmdd, mbeta, malpha, mwin_rate, mpf, mexpectancy, mtrades, mstop, mdir] = score_combo(88, manual_vol_length, manual_vol_factor)
float best_score = na
float best_cagr = na
float best_sharpe = na
float best_calmar = na
float best_sortino = na
float best_mdd = na
float best_beta = na
float best_alpha = na
float best_win_rate = na
float best_factor = na
float best_expectancy = na
float best_trades = na
float best_stop = na
float best_dir = na
int best_vol_length = na
float best_vol_factor = na
int best_id = na
if length_logic == 'Manual'
    best_score := mscore
    best_cagr := mcagr
    best_sharpe := msharpe
    best_calmar := mcalmar
    best_sortino := msortino
    best_mdd := mmdd
    best_beta := mbeta
    best_alpha := malpha
    best_win_rate := mwin_rate
    best_factor := mpf
    best_expectancy := mexpectancy
    best_trades := mtrades
    best_stop := mstop
    best_dir := mdir
    best_vol_length := manual_vol_length
    best_vol_factor := manual_vol_factor
    best_id := 0
else
    if not na(score88) and (na(best_score) or score88 > best_score * (1 + margin / 100))
        best_score := score88
        best_cagr := cagr88
        best_sharpe := sharpe88
        best_calmar := calmar88
        best_sortino := sortino88
        best_mdd := mdd88
        best_beta := beta88
        best_alpha := alpha88
        best_win_rate := win_rate88
        best_factor := pf88
        best_expectancy := expectancy88
        best_trades := trades88
        best_stop := stop88
        best_dir := dir88
        best_vol_length := 50
        best_vol_factor := 10.0
        best_id := 88
    if not na(score87) and (na(best_score) or score87 > best_score * (1 + margin / 100))
        best_score := score87
        best_cagr := cagr87
        best_sharpe := sharpe87
        best_calmar := calmar87
        best_sortino := sortino87
        best_mdd := mdd87
        best_beta := beta87
        best_alpha := alpha87
        best_win_rate := win_rate87
        best_factor := pf87
        best_expectancy := expectancy87
        best_trades := trades87
        best_stop := stop87
        best_dir := dir87
        best_vol_length := 50
        best_vol_factor := 8.0
        best_id := 87
    if not na(score86) and (na(best_score) or score86 > best_score * (1 + margin / 100))
        best_score := score86
        best_cagr := cagr86
        best_sharpe := sharpe86
        best_calmar := calmar86
        best_sortino := sortino86
        best_mdd := mdd86
        best_beta := beta86
        best_alpha := alpha86
        best_win_rate := win_rate86
        best_factor := pf86
        best_expectancy := expectancy86
        best_trades := trades86
        best_stop := stop86
        best_dir := dir86
        best_vol_length := 50
        best_vol_factor := 7.0
        best_id := 86
    if not na(score85) and (na(best_score) or score85 > best_score * (1 + margin / 100))
        best_score := score85
        best_cagr := cagr85
        best_sharpe := sharpe85
        best_calmar := calmar85
        best_sortino := sortino85
        best_mdd := mdd85
        best_beta := beta85
        best_alpha := alpha85
        best_win_rate := win_rate85
        best_factor := pf85
        best_expectancy := expectancy85
        best_trades := trades85
        best_stop := stop85
        best_dir := dir85
        best_vol_length := 50
        best_vol_factor := 6.0
        best_id := 85
    if not na(score84) and (na(best_score) or score84 > best_score * (1 + margin / 100))
        best_score := score84
        best_cagr := cagr84
        best_sharpe := sharpe84
        best_calmar := calmar84
        best_sortino := sortino84
        best_mdd := mdd84
        best_beta := beta84
        best_alpha := alpha84
        best_win_rate := win_rate84
        best_factor := pf84
        best_expectancy := expectancy84
        best_trades := trades84
        best_stop := stop84
        best_dir := dir84
        best_vol_length := 50
        best_vol_factor := 5.0
        best_id := 84
    if not na(score83) and (na(best_score) or score83 > best_score * (1 + margin / 100))
        best_score := score83
        best_cagr := cagr83
        best_sharpe := sharpe83
        best_calmar := calmar83
        best_sortino := sortino83
        best_mdd := mdd83
        best_beta := beta83
        best_alpha := alpha83
        best_win_rate := win_rate83
        best_factor := pf83
        best_expectancy := expectancy83
        best_trades := trades83
        best_stop := stop83
        best_dir := dir83
        best_vol_length := 50
        best_vol_factor := 4.5
        best_id := 83
    if not na(score82) and (na(best_score) or score82 > best_score * (1 + margin / 100))
        best_score := score82
        best_cagr := cagr82
        best_sharpe := sharpe82
        best_calmar := calmar82
        best_sortino := sortino82
        best_mdd := mdd82
        best_beta := beta82
        best_alpha := alpha82
        best_win_rate := win_rate82
        best_factor := pf82
        best_expectancy := expectancy82
        best_trades := trades82
        best_stop := stop82
        best_dir := dir82
        best_vol_length := 50
        best_vol_factor := 4.0
        best_id := 82
    if not na(score81) and (na(best_score) or score81 > best_score * (1 + margin / 100))
        best_score := score81
        best_cagr := cagr81
        best_sharpe := sharpe81
        best_calmar := calmar81
        best_sortino := sortino81
        best_mdd := mdd81
        best_beta := beta81
        best_alpha := alpha81
        best_win_rate := win_rate81
        best_factor := pf81
        best_expectancy := expectancy81
        best_trades := trades81
        best_stop := stop81
        best_dir := dir81
        best_vol_length := 50
        best_vol_factor := 3.5
        best_id := 81
    if not na(score80) and (na(best_score) or score80 > best_score * (1 + margin / 100))
        best_score := score80
        best_cagr := cagr80
        best_sharpe := sharpe80
        best_calmar := calmar80
        best_sortino := sortino80
        best_mdd := mdd80
        best_beta := beta80
        best_alpha := alpha80
        best_win_rate := win_rate80
        best_factor := pf80
        best_expectancy := expectancy80
        best_trades := trades80
        best_stop := stop80
        best_dir := dir80
        best_vol_length := 50
        best_vol_factor := 3.0
        best_id := 80
    if not na(score79) and (na(best_score) or score79 > best_score * (1 + margin / 100))
        best_score := score79
        best_cagr := cagr79
        best_sharpe := sharpe79
        best_calmar := calmar79
        best_sortino := sortino79
        best_mdd := mdd79
        best_beta := beta79
        best_alpha := alpha79
        best_win_rate := win_rate79
        best_factor := pf79
        best_expectancy := expectancy79
        best_trades := trades79
        best_stop := stop79
        best_dir := dir79
        best_vol_length := 50
        best_vol_factor := 2.5
        best_id := 79
    if not na(score78) and (na(best_score) or score78 > best_score * (1 + margin / 100))
        best_score := score78
        best_cagr := cagr78
        best_sharpe := sharpe78
        best_calmar := calmar78
        best_sortino := sortino78
        best_mdd := mdd78
        best_beta := beta78
        best_alpha := alpha78
        best_win_rate := win_rate78
        best_factor := pf78
        best_expectancy := expectancy78
        best_trades := trades78
        best_stop := stop78
        best_dir := dir78
        best_vol_length := 50
        best_vol_factor := 2.0
        best_id := 78
    if not na(score77) and (na(best_score) or score77 > best_score * (1 + margin / 100))
        best_score := score77
        best_cagr := cagr77
        best_sharpe := sharpe77
        best_calmar := calmar77
        best_sortino := sortino77
        best_mdd := mdd77
        best_beta := beta77
        best_alpha := alpha77
        best_win_rate := win_rate77
        best_factor := pf77
        best_expectancy := expectancy77
        best_trades := trades77
        best_stop := stop77
        best_dir := dir77
        best_vol_length := 40
        best_vol_factor := 10.0
        best_id := 77
    if not na(score76) and (na(best_score) or score76 > best_score * (1 + margin / 100))
        best_score := score76
        best_cagr := cagr76
        best_sharpe := sharpe76
        best_calmar := calmar76
        best_sortino := sortino76
        best_mdd := mdd76
        best_beta := beta76
        best_alpha := alpha76
        best_win_rate := win_rate76
        best_factor := pf76
        best_expectancy := expectancy76
        best_trades := trades76
        best_stop := stop76
        best_dir := dir76
        best_vol_length := 40
        best_vol_factor := 8.0
        best_id := 76
    if not na(score75) and (na(best_score) or score75 > best_score * (1 + margin / 100))
        best_score := score75
        best_cagr := cagr75
        best_sharpe := sharpe75
        best_calmar := calmar75
        best_sortino := sortino75
        best_mdd := mdd75
        best_beta := beta75
        best_alpha := alpha75
        best_win_rate := win_rate75
        best_factor := pf75
        best_expectancy := expectancy75
        best_trades := trades75
        best_stop := stop75
        best_dir := dir75
        best_vol_length := 40
        best_vol_factor := 7.0
        best_id := 75
    if not na(score74) and (na(best_score) or score74 > best_score * (1 + margin / 100))
        best_score := score74
        best_cagr := cagr74
        best_sharpe := sharpe74
        best_calmar := calmar74
        best_sortino := sortino74
        best_mdd := mdd74
        best_beta := beta74
        best_alpha := alpha74
        best_win_rate := win_rate74
        best_factor := pf74
        best_expectancy := expectancy74
        best_trades := trades74
        best_stop := stop74
        best_dir := dir74
        best_vol_length := 40
        best_vol_factor := 6.0
        best_id := 74
    if not na(score73) and (na(best_score) or score73 > best_score * (1 + margin / 100))
        best_score := score73
        best_cagr := cagr73
        best_sharpe := sharpe73
        best_calmar := calmar73
        best_sortino := sortino73
        best_mdd := mdd73
        best_beta := beta73
        best_alpha := alpha73
        best_win_rate := win_rate73
        best_factor := pf73
        best_expectancy := expectancy73
        best_trades := trades73
        best_stop := stop73
        best_dir := dir73
        best_vol_length := 40
        best_vol_factor := 5.0
        best_id := 73
    if not na(score72) and (na(best_score) or score72 > best_score * (1 + margin / 100))
        best_score := score72
        best_cagr := cagr72
        best_sharpe := sharpe72
        best_calmar := calmar72
        best_sortino := sortino72
        best_mdd := mdd72
        best_beta := beta72
        best_alpha := alpha72
        best_win_rate := win_rate72
        best_factor := pf72
        best_expectancy := expectancy72
        best_trades := trades72
        best_stop := stop72
        best_dir := dir72
        best_vol_length := 40
        best_vol_factor := 4.5
        best_id := 72
    if not na(score71) and (na(best_score) or score71 > best_score * (1 + margin / 100))
        best_score := score71
        best_cagr := cagr71
        best_sharpe := sharpe71
        best_calmar := calmar71
        best_sortino := sortino71
        best_mdd := mdd71
        best_beta := beta71
        best_alpha := alpha71
        best_win_rate := win_rate71
        best_factor := pf71
        best_expectancy := expectancy71
        best_trades := trades71
        best_stop := stop71
        best_dir := dir71
        best_vol_length := 40
        best_vol_factor := 4.0
        best_id := 71
    if not na(score70) and (na(best_score) or score70 > best_score * (1 + margin / 100))
        best_score := score70
        best_cagr := cagr70
        best_sharpe := sharpe70
        best_calmar := calmar70
        best_sortino := sortino70
        best_mdd := mdd70
        best_beta := beta70
        best_alpha := alpha70
        best_win_rate := win_rate70
        best_factor := pf70
        best_expectancy := expectancy70
        best_trades := trades70
        best_stop := stop70
        best_dir := dir70
        best_vol_length := 40
        best_vol_factor := 3.5
        best_id := 70
    if not na(score69) and (na(best_score) or score69 > best_score * (1 + margin / 100))
        best_score := score69
        best_cagr := cagr69
        best_sharpe := sharpe69
        best_calmar := calmar69
        best_sortino := sortino69
        best_mdd := mdd69
        best_beta := beta69
        best_alpha := alpha69
        best_win_rate := win_rate69
        best_factor := pf69
        best_expectancy := expectancy69
        best_trades := trades69
        best_stop := stop69
        best_dir := dir69
        best_vol_length := 40
        best_vol_factor := 3.0
        best_id := 69
    if not na(score68) and (na(best_score) or score68 > best_score * (1 + margin / 100))
        best_score := score68
        best_cagr := cagr68
        best_sharpe := sharpe68
        best_calmar := calmar68
        best_sortino := sortino68
        best_mdd := mdd68
        best_beta := beta68
        best_alpha := alpha68
        best_win_rate := win_rate68
        best_factor := pf68
        best_expectancy := expectancy68
        best_trades := trades68
        best_stop := stop68
        best_dir := dir68
        best_vol_length := 40
        best_vol_factor := 2.5
        best_id := 68
    if not na(score67) and (na(best_score) or score67 > best_score * (1 + margin / 100))
        best_score := score67
        best_cagr := cagr67
        best_sharpe := sharpe67
        best_calmar := calmar67
        best_sortino := sortino67
        best_mdd := mdd67
        best_beta := beta67
        best_alpha := alpha67
        best_win_rate := win_rate67
        best_factor := pf67
        best_expectancy := expectancy67
        best_trades := trades67
        best_stop := stop67
        best_dir := dir67
        best_vol_length := 40
        best_vol_factor := 2.0
        best_id := 67
    if not na(score66) and (na(best_score) or score66 > best_score * (1 + margin / 100))
        best_score := score66
        best_cagr := cagr66
        best_sharpe := sharpe66
        best_calmar := calmar66
        best_sortino := sortino66
        best_mdd := mdd66
        best_beta := beta66
        best_alpha := alpha66
        best_win_rate := win_rate66
        best_factor := pf66
        best_expectancy := expectancy66
        best_trades := trades66
        best_stop := stop66
        best_dir := dir66
        best_vol_length := 30
        best_vol_factor := 10.0
        best_id := 66
    if not na(score65) and (na(best_score) or score65 > best_score * (1 + margin / 100))
        best_score := score65
        best_cagr := cagr65
        best_sharpe := sharpe65
        best_calmar := calmar65
        best_sortino := sortino65
        best_mdd := mdd65
        best_beta := beta65
        best_alpha := alpha65
        best_win_rate := win_rate65
        best_factor := pf65
        best_expectancy := expectancy65
        best_trades := trades65
        best_stop := stop65
        best_dir := dir65
        best_vol_length := 30
        best_vol_factor := 8.0
        best_id := 65
    if not na(score64) and (na(best_score) or score64 > best_score * (1 + margin / 100))
        best_score := score64
        best_cagr := cagr64
        best_sharpe := sharpe64
        best_calmar := calmar64
        best_sortino := sortino64
        best_mdd := mdd64
        best_beta := beta64
        best_alpha := alpha64
        best_win_rate := win_rate64
        best_factor := pf64
        best_expectancy := expectancy64
        best_trades := trades64
        best_stop := stop64
        best_dir := dir64
        best_vol_length := 30
        best_vol_factor := 7.0
        best_id := 64
    if not na(score63) and (na(best_score) or score63 > best_score * (1 + margin / 100))
        best_score := score63
        best_cagr := cagr63
        best_sharpe := sharpe63
        best_calmar := calmar63
        best_sortino := sortino63
        best_mdd := mdd63
        best_beta := beta63
        best_alpha := alpha63
        best_win_rate := win_rate63
        best_factor := pf63
        best_expectancy := expectancy63
        best_trades := trades63
        best_stop := stop63
        best_dir := dir63
        best_vol_length := 30
        best_vol_factor := 6.0
        best_id := 63
    if not na(score62) and (na(best_score) or score62 > best_score * (1 + margin / 100))
        best_score := score62
        best_cagr := cagr62
        best_sharpe := sharpe62
        best_calmar := calmar62
        best_sortino := sortino62
        best_mdd := mdd62
        best_beta := beta62
        best_alpha := alpha62
        best_win_rate := win_rate62
        best_factor := pf62
        best_expectancy := expectancy62
        best_trades := trades62
        best_stop := stop62
        best_dir := dir62
        best_vol_length := 30
        best_vol_factor := 5.0
        best_id := 62
    if not na(score61) and (na(best_score) or score61 > best_score * (1 + margin / 100))
        best_score := score61
        best_cagr := cagr61
        best_sharpe := sharpe61
        best_calmar := calmar61
        best_sortino := sortino61
        best_mdd := mdd61
        best_beta := beta61
        best_alpha := alpha61
        best_win_rate := win_rate61
        best_factor := pf61
        best_expectancy := expectancy61
        best_trades := trades61
        best_stop := stop61
        best_dir := dir61
        best_vol_length := 30
        best_vol_factor := 4.5
        best_id := 61
    if not na(score60) and (na(best_score) or score60 > best_score * (1 + margin / 100))
        best_score := score60
        best_cagr := cagr60
        best_sharpe := sharpe60
        best_calmar := calmar60
        best_sortino := sortino60
        best_mdd := mdd60
        best_beta := beta60
        best_alpha := alpha60
        best_win_rate := win_rate60
        best_factor := pf60
        best_expectancy := expectancy60
        best_trades := trades60
        best_stop := stop60
        best_dir := dir60
        best_vol_length := 30
        best_vol_factor := 4.0
        best_id := 60
    if not na(score59) and (na(best_score) or score59 > best_score * (1 + margin / 100))
        best_score := score59
        best_cagr := cagr59
        best_sharpe := sharpe59
        best_calmar := calmar59
        best_sortino := sortino59
        best_mdd := mdd59
        best_beta := beta59
        best_alpha := alpha59
        best_win_rate := win_rate59
        best_factor := pf59
        best_expectancy := expectancy59
        best_trades := trades59
        best_stop := stop59
        best_dir := dir59
        best_vol_length := 30
        best_vol_factor := 3.5
        best_id := 59
    if not na(score58) and (na(best_score) or score58 > best_score * (1 + margin / 100))
        best_score := score58
        best_cagr := cagr58
        best_sharpe := sharpe58
        best_calmar := calmar58
        best_sortino := sortino58
        best_mdd := mdd58
        best_beta := beta58
        best_alpha := alpha58
        best_win_rate := win_rate58
        best_factor := pf58
        best_expectancy := expectancy58
        best_trades := trades58
        best_stop := stop58
        best_dir := dir58
        best_vol_length := 30
        best_vol_factor := 3.0
        best_id := 58
    if not na(score57) and (na(best_score) or score57 > best_score * (1 + margin / 100))
        best_score := score57
        best_cagr := cagr57
        best_sharpe := sharpe57
        best_calmar := calmar57
        best_sortino := sortino57
        best_mdd := mdd57
        best_beta := beta57
        best_alpha := alpha57
        best_win_rate := win_rate57
        best_factor := pf57
        best_expectancy := expectancy57
        best_trades := trades57
        best_stop := stop57
        best_dir := dir57
        best_vol_length := 30
        best_vol_factor := 2.5
        best_id := 57
    if not na(score56) and (na(best_score) or score56 > best_score * (1 + margin / 100))
        best_score := score56
        best_cagr := cagr56
        best_sharpe := sharpe56
        best_calmar := calmar56
        best_sortino := sortino56
        best_mdd := mdd56
        best_beta := beta56
        best_alpha := alpha56
        best_win_rate := win_rate56
        best_factor := pf56
        best_expectancy := expectancy56
        best_trades := trades56
        best_stop := stop56
        best_dir := dir56
        best_vol_length := 30
        best_vol_factor := 2.0
        best_id := 56
    if not na(score55) and (na(best_score) or score55 > best_score * (1 + margin / 100))
        best_score := score55
        best_cagr := cagr55
        best_sharpe := sharpe55
        best_calmar := calmar55
        best_sortino := sortino55
        best_mdd := mdd55
        best_beta := beta55
        best_alpha := alpha55
        best_win_rate := win_rate55
        best_factor := pf55
        best_expectancy := expectancy55
        best_trades := trades55
        best_stop := stop55
        best_dir := dir55
        best_vol_length := 25
        best_vol_factor := 10.0
        best_id := 55
    if not na(score54) and (na(best_score) or score54 > best_score * (1 + margin / 100))
        best_score := score54
        best_cagr := cagr54
        best_sharpe := sharpe54
        best_calmar := calmar54
        best_sortino := sortino54
        best_mdd := mdd54
        best_beta := beta54
        best_alpha := alpha54
        best_win_rate := win_rate54
        best_factor := pf54
        best_expectancy := expectancy54
        best_trades := trades54
        best_stop := stop54
        best_dir := dir54
        best_vol_length := 25
        best_vol_factor := 8.0
        best_id := 54
    if not na(score53) and (na(best_score) or score53 > best_score * (1 + margin / 100))
        best_score := score53
        best_cagr := cagr53
        best_sharpe := sharpe53
        best_calmar := calmar53
        best_sortino := sortino53
        best_mdd := mdd53
        best_beta := beta53
        best_alpha := alpha53
        best_win_rate := win_rate53
        best_factor := pf53
        best_expectancy := expectancy53
        best_trades := trades53
        best_stop := stop53
        best_dir := dir53
        best_vol_length := 25
        best_vol_factor := 7.0
        best_id := 53
    if not na(score52) and (na(best_score) or score52 > best_score * (1 + margin / 100))
        best_score := score52
        best_cagr := cagr52
        best_sharpe := sharpe52
        best_calmar := calmar52
        best_sortino := sortino52
        best_mdd := mdd52
        best_beta := beta52
        best_alpha := alpha52
        best_win_rate := win_rate52
        best_factor := pf52
        best_expectancy := expectancy52
        best_trades := trades52
        best_stop := stop52
        best_dir := dir52
        best_vol_length := 25
        best_vol_factor := 6.0
        best_id := 52
    if not na(score51) and (na(best_score) or score51 > best_score * (1 + margin / 100))
        best_score := score51
        best_cagr := cagr51
        best_sharpe := sharpe51
        best_calmar := calmar51
        best_sortino := sortino51
        best_mdd := mdd51
        best_beta := beta51
        best_alpha := alpha51
        best_win_rate := win_rate51
        best_factor := pf51
        best_expectancy := expectancy51
        best_trades := trades51
        best_stop := stop51
        best_dir := dir51
        best_vol_length := 25
        best_vol_factor := 5.0
        best_id := 51
    if not na(score50) and (na(best_score) or score50 > best_score * (1 + margin / 100))
        best_score := score50
        best_cagr := cagr50
        best_sharpe := sharpe50
        best_calmar := calmar50
        best_sortino := sortino50
        best_mdd := mdd50
        best_beta := beta50
        best_alpha := alpha50
        best_win_rate := win_rate50
        best_factor := pf50
        best_expectancy := expectancy50
        best_trades := trades50
        best_stop := stop50
        best_dir := dir50
        best_vol_length := 25
        best_vol_factor := 4.5
        best_id := 50
    if not na(score49) and (na(best_score) or score49 > best_score * (1 + margin / 100))
        best_score := score49
        best_cagr := cagr49
        best_sharpe := sharpe49
        best_calmar := calmar49
        best_sortino := sortino49
        best_mdd := mdd49
        best_beta := beta49
        best_alpha := alpha49
        best_win_rate := win_rate49
        best_factor := pf49
        best_expectancy := expectancy49
        best_trades := trades49
        best_stop := stop49
        best_dir := dir49
        best_vol_length := 25
        best_vol_factor := 4.0
        best_id := 49
    if not na(score48) and (na(best_score) or score48 > best_score * (1 + margin / 100))
        best_score := score48
        best_cagr := cagr48
        best_sharpe := sharpe48
        best_calmar := calmar48
        best_sortino := sortino48
        best_mdd := mdd48
        best_beta := beta48
        best_alpha := alpha48
        best_win_rate := win_rate48
        best_factor := pf48
        best_expectancy := expectancy48
        best_trades := trades48
        best_stop := stop48
        best_dir := dir48
        best_vol_length := 25
        best_vol_factor := 3.5
        best_id := 48
    if not na(score47) and (na(best_score) or score47 > best_score * (1 + margin / 100))
        best_score := score47
        best_cagr := cagr47
        best_sharpe := sharpe47
        best_calmar := calmar47
        best_sortino := sortino47
        best_mdd := mdd47
        best_beta := beta47
        best_alpha := alpha47
        best_win_rate := win_rate47
        best_factor := pf47
        best_expectancy := expectancy47
        best_trades := trades47
        best_stop := stop47
        best_dir := dir47
        best_vol_length := 25
        best_vol_factor := 3.0
        best_id := 47
    if not na(score46) and (na(best_score) or score46 > best_score * (1 + margin / 100))
        best_score := score46
        best_cagr := cagr46
        best_sharpe := sharpe46
        best_calmar := calmar46
        best_sortino := sortino46
        best_mdd := mdd46
        best_beta := beta46
        best_alpha := alpha46
        best_win_rate := win_rate46
        best_factor := pf46
        best_expectancy := expectancy46
        best_trades := trades46
        best_stop := stop46
        best_dir := dir46
        best_vol_length := 25
        best_vol_factor := 2.5
        best_id := 46
    if not na(score45) and (na(best_score) or score45 > best_score * (1 + margin / 100))
        best_score := score45
        best_cagr := cagr45
        best_sharpe := sharpe45
        best_calmar := calmar45
        best_sortino := sortino45
        best_mdd := mdd45
        best_beta := beta45
        best_alpha := alpha45
        best_win_rate := win_rate45
        best_factor := pf45
        best_expectancy := expectancy45
        best_trades := trades45
        best_stop := stop45
        best_dir := dir45
        best_vol_length := 25
        best_vol_factor := 2.0
        best_id := 45
    if not na(score44) and (na(best_score) or score44 > best_score * (1 + margin / 100))
        best_score := score44
        best_cagr := cagr44
        best_sharpe := sharpe44
        best_calmar := calmar44
        best_sortino := sortino44
        best_mdd := mdd44
        best_beta := beta44
        best_alpha := alpha44
        best_win_rate := win_rate44
        best_factor := pf44
        best_expectancy := expectancy44
        best_trades := trades44
        best_stop := stop44
        best_dir := dir44
        best_vol_length := 20
        best_vol_factor := 10.0
        best_id := 44
    if not na(score43) and (na(best_score) or score43 > best_score * (1 + margin / 100))
        best_score := score43
        best_cagr := cagr43
        best_sharpe := sharpe43
        best_calmar := calmar43
        best_sortino := sortino43
        best_mdd := mdd43
        best_beta := beta43
        best_alpha := alpha43
        best_win_rate := win_rate43
        best_factor := pf43
        best_expectancy := expectancy43
        best_trades := trades43
        best_stop := stop43
        best_dir := dir43
        best_vol_length := 20
        best_vol_factor := 8.0
        best_id := 43
    if not na(score42) and (na(best_score) or score42 > best_score * (1 + margin / 100))
        best_score := score42
        best_cagr := cagr42
        best_sharpe := sharpe42
        best_calmar := calmar42
        best_sortino := sortino42
        best_mdd := mdd42
        best_beta := beta42
        best_alpha := alpha42
        best_win_rate := win_rate42
        best_factor := pf42
        best_expectancy := expectancy42
        best_trades := trades42
        best_stop := stop42
        best_dir := dir42
        best_vol_length := 20
        best_vol_factor := 7.0
        best_id := 42
    if not na(score41) and (na(best_score) or score41 > best_score * (1 + margin / 100))
        best_score := score41
        best_cagr := cagr41
        best_sharpe := sharpe41
        best_calmar := calmar41
        best_sortino := sortino41
        best_mdd := mdd41
        best_beta := beta41
        best_alpha := alpha41
        best_win_rate := win_rate41
        best_factor := pf41
        best_expectancy := expectancy41
        best_trades := trades41
        best_stop := stop41
        best_dir := dir41
        best_vol_length := 20
        best_vol_factor := 6.0
        best_id := 41
    if not na(score40) and (na(best_score) or score40 > best_score * (1 + margin / 100))
        best_score := score40
        best_cagr := cagr40
        best_sharpe := sharpe40
        best_calmar := calmar40
        best_sortino := sortino40
        best_mdd := mdd40
        best_beta := beta40
        best_alpha := alpha40
        best_win_rate := win_rate40
        best_factor := pf40
        best_expectancy := expectancy40
        best_trades := trades40
        best_stop := stop40
        best_dir := dir40
        best_vol_length := 20
        best_vol_factor := 5.0
        best_id := 40
    if not na(score39) and (na(best_score) or score39 > best_score * (1 + margin / 100))
        best_score := score39
        best_cagr := cagr39
        best_sharpe := sharpe39
        best_calmar := calmar39
        best_sortino := sortino39
        best_mdd := mdd39
        best_beta := beta39
        best_alpha := alpha39
        best_win_rate := win_rate39
        best_factor := pf39
        best_expectancy := expectancy39
        best_trades := trades39
        best_stop := stop39
        best_dir := dir39
        best_vol_length := 20
        best_vol_factor := 4.5
        best_id := 39
    if not na(score38) and (na(best_score) or score38 > best_score * (1 + margin / 100))
        best_score := score38
        best_cagr := cagr38
        best_sharpe := sharpe38
        best_calmar := calmar38
        best_sortino := sortino38
        best_mdd := mdd38
        best_beta := beta38
        best_alpha := alpha38
        best_win_rate := win_rate38
        best_factor := pf38
        best_expectancy := expectancy38
        best_trades := trades38
        best_stop := stop38
        best_dir := dir38
        best_vol_length := 20
        best_vol_factor := 4.0
        best_id := 38
    if not na(score37) and (na(best_score) or score37 > best_score * (1 + margin / 100))
        best_score := score37
        best_cagr := cagr37
        best_sharpe := sharpe37
        best_calmar := calmar37
        best_sortino := sortino37
        best_mdd := mdd37
        best_beta := beta37
        best_alpha := alpha37
        best_win_rate := win_rate37
        best_factor := pf37
        best_expectancy := expectancy37
        best_trades := trades37
        best_stop := stop37
        best_dir := dir37
        best_vol_length := 20
        best_vol_factor := 3.5
        best_id := 37
    if not na(score36) and (na(best_score) or score36 > best_score * (1 + margin / 100))
        best_score := score36
        best_cagr := cagr36
        best_sharpe := sharpe36
        best_calmar := calmar36
        best_sortino := sortino36
        best_mdd := mdd36
        best_beta := beta36
        best_alpha := alpha36
        best_win_rate := win_rate36
        best_factor := pf36
        best_expectancy := expectancy36
        best_trades := trades36
        best_stop := stop36
        best_dir := dir36
        best_vol_length := 20
        best_vol_factor := 3.0
        best_id := 36
    if not na(score35) and (na(best_score) or score35 > best_score * (1 + margin / 100))
        best_score := score35
        best_cagr := cagr35
        best_sharpe := sharpe35
        best_calmar := calmar35
        best_sortino := sortino35
        best_mdd := mdd35
        best_beta := beta35
        best_alpha := alpha35
        best_win_rate := win_rate35
        best_factor := pf35
        best_expectancy := expectancy35
        best_trades := trades35
        best_stop := stop35
        best_dir := dir35
        best_vol_length := 20
        best_vol_factor := 2.5
        best_id := 35
    if not na(score34) and (na(best_score) or score34 > best_score * (1 + margin / 100))
        best_score := score34
        best_cagr := cagr34
        best_sharpe := sharpe34
        best_calmar := calmar34
        best_sortino := sortino34
        best_mdd := mdd34
        best_beta := beta34
        best_alpha := alpha34
        best_win_rate := win_rate34
        best_factor := pf34
        best_expectancy := expectancy34
        best_trades := trades34
        best_stop := stop34
        best_dir := dir34
        best_vol_length := 20
        best_vol_factor := 2.0
        best_id := 34
    if not na(score33) and (na(best_score) or score33 > best_score * (1 + margin / 100))
        best_score := score33
        best_cagr := cagr33
        best_sharpe := sharpe33
        best_calmar := calmar33
        best_sortino := sortino33
        best_mdd := mdd33
        best_beta := beta33
        best_alpha := alpha33
        best_win_rate := win_rate33
        best_factor := pf33
        best_expectancy := expectancy33
        best_trades := trades33
        best_stop := stop33
        best_dir := dir33
        best_vol_length := 15
        best_vol_factor := 10.0
        best_id := 33
    if not na(score32) and (na(best_score) or score32 > best_score * (1 + margin / 100))
        best_score := score32
        best_cagr := cagr32
        best_sharpe := sharpe32
        best_calmar := calmar32
        best_sortino := sortino32
        best_mdd := mdd32
        best_beta := beta32
        best_alpha := alpha32
        best_win_rate := win_rate32
        best_factor := pf32
        best_expectancy := expectancy32
        best_trades := trades32
        best_stop := stop32
        best_dir := dir32
        best_vol_length := 15
        best_vol_factor := 8.0
        best_id := 32
    if not na(score31) and (na(best_score) or score31 > best_score * (1 + margin / 100))
        best_score := score31
        best_cagr := cagr31
        best_sharpe := sharpe31
        best_calmar := calmar31
        best_sortino := sortino31
        best_mdd := mdd31
        best_beta := beta31
        best_alpha := alpha31
        best_win_rate := win_rate31
        best_factor := pf31
        best_expectancy := expectancy31
        best_trades := trades31
        best_stop := stop31
        best_dir := dir31
        best_vol_length := 15
        best_vol_factor := 7.0
        best_id := 31
    if not na(score30) and (na(best_score) or score30 > best_score * (1 + margin / 100))
        best_score := score30
        best_cagr := cagr30
        best_sharpe := sharpe30
        best_calmar := calmar30
        best_sortino := sortino30
        best_mdd := mdd30
        best_beta := beta30
        best_alpha := alpha30
        best_win_rate := win_rate30
        best_factor := pf30
        best_expectancy := expectancy30
        best_trades := trades30
        best_stop := stop30
        best_dir := dir30
        best_vol_length := 15
        best_vol_factor := 6.0
        best_id := 30
    if not na(score29) and (na(best_score) or score29 > best_score * (1 + margin / 100))
        best_score := score29
        best_cagr := cagr29
        best_sharpe := sharpe29
        best_calmar := calmar29
        best_sortino := sortino29
        best_mdd := mdd29
        best_beta := beta29
        best_alpha := alpha29
        best_win_rate := win_rate29
        best_factor := pf29
        best_expectancy := expectancy29
        best_trades := trades29
        best_stop := stop29
        best_dir := dir29
        best_vol_length := 15
        best_vol_factor := 5.0
        best_id := 29
    if not na(score28) and (na(best_score) or score28 > best_score * (1 + margin / 100))
        best_score := score28
        best_cagr := cagr28
        best_sharpe := sharpe28
        best_calmar := calmar28
        best_sortino := sortino28
        best_mdd := mdd28
        best_beta := beta28
        best_alpha := alpha28
        best_win_rate := win_rate28
        best_factor := pf28
        best_expectancy := expectancy28
        best_trades := trades28
        best_stop := stop28
        best_dir := dir28
        best_vol_length := 15
        best_vol_factor := 4.5
        best_id := 28
    if not na(score27) and (na(best_score) or score27 > best_score * (1 + margin / 100))
        best_score := score27
        best_cagr := cagr27
        best_sharpe := sharpe27
        best_calmar := calmar27
        best_sortino := sortino27
        best_mdd := mdd27
        best_beta := beta27
        best_alpha := alpha27
        best_win_rate := win_rate27
        best_factor := pf27
        best_expectancy := expectancy27
        best_trades := trades27
        best_stop := stop27
        best_dir := dir27
        best_vol_length := 15
        best_vol_factor := 4.0
        best_id := 27
    if not na(score26) and (na(best_score) or score26 > best_score * (1 + margin / 100))
        best_score := score26
        best_cagr := cagr26
        best_sharpe := sharpe26
        best_calmar := calmar26
        best_sortino := sortino26
        best_mdd := mdd26
        best_beta := beta26
        best_alpha := alpha26
        best_win_rate := win_rate26
        best_factor := pf26
        best_expectancy := expectancy26
        best_trades := trades26
        best_stop := stop26
        best_dir := dir26
        best_vol_length := 15
        best_vol_factor := 3.5
        best_id := 26
    if not na(score25) and (na(best_score) or score25 > best_score * (1 + margin / 100))
        best_score := score25
        best_cagr := cagr25
        best_sharpe := sharpe25
        best_calmar := calmar25
        best_sortino := sortino25
        best_mdd := mdd25
        best_beta := beta25
        best_alpha := alpha25
        best_win_rate := win_rate25
        best_factor := pf25
        best_expectancy := expectancy25
        best_trades := trades25
        best_stop := stop25
        best_dir := dir25
        best_vol_length := 15
        best_vol_factor := 3.0
        best_id := 25
    if not na(score24) and (na(best_score) or score24 > best_score * (1 + margin / 100))
        best_score := score24
        best_cagr := cagr24
        best_sharpe := sharpe24
        best_calmar := calmar24
        best_sortino := sortino24
        best_mdd := mdd24
        best_beta := beta24
        best_alpha := alpha24
        best_win_rate := win_rate24
        best_factor := pf24
        best_expectancy := expectancy24
        best_trades := trades24
        best_stop := stop24
        best_dir := dir24
        best_vol_length := 15
        best_vol_factor := 2.5
        best_id := 24
    if not na(score23) and (na(best_score) or score23 > best_score * (1 + margin / 100))
        best_score := score23
        best_cagr := cagr23
        best_sharpe := sharpe23
        best_calmar := calmar23
        best_sortino := sortino23
        best_mdd := mdd23
        best_beta := beta23
        best_alpha := alpha23
        best_win_rate := win_rate23
        best_factor := pf23
        best_expectancy := expectancy23
        best_trades := trades23
        best_stop := stop23
        best_dir := dir23
        best_vol_length := 15
        best_vol_factor := 2.0
        best_id := 23
    if not na(score22) and (na(best_score) or score22 > best_score * (1 + margin / 100))
        best_score := score22
        best_cagr := cagr22
        best_sharpe := sharpe22
        best_calmar := calmar22
        best_sortino := sortino22
        best_mdd := mdd22
        best_beta := beta22
        best_alpha := alpha22
        best_win_rate := win_rate22
        best_factor := pf22
        best_expectancy := expectancy22
        best_trades := trades22
        best_stop := stop22
        best_dir := dir22
        best_vol_length := 10
        best_vol_factor := 10.0
        best_id := 22
    if not na(score21) and (na(best_score) or score21 > best_score * (1 + margin / 100))
        best_score := score21
        best_cagr := cagr21
        best_sharpe := sharpe21
        best_calmar := calmar21
        best_sortino := sortino21
        best_mdd := mdd21
        best_beta := beta21
        best_alpha := alpha21
        best_win_rate := win_rate21
        best_factor := pf21
        best_expectancy := expectancy21
        best_trades := trades21
        best_stop := stop21
        best_dir := dir21
        best_vol_length := 10
        best_vol_factor := 8.0
        best_id := 21
    if not na(score20) and (na(best_score) or score20 > best_score * (1 + margin / 100))
        best_score := score20
        best_cagr := cagr20
        best_sharpe := sharpe20
        best_calmar := calmar20
        best_sortino := sortino20
        best_mdd := mdd20
        best_beta := beta20
        best_alpha := alpha20
        best_win_rate := win_rate20
        best_factor := pf20
        best_expectancy := expectancy20
        best_trades := trades20
        best_stop := stop20
        best_dir := dir20
        best_vol_length := 10
        best_vol_factor := 7.0
        best_id := 20
    if not na(score19) and (na(best_score) or score19 > best_score * (1 + margin / 100))
        best_score := score19
        best_cagr := cagr19
        best_sharpe := sharpe19
        best_calmar := calmar19
        best_sortino := sortino19
        best_mdd := mdd19
        best_beta := beta19
        best_alpha := alpha19
        best_win_rate := win_rate19
        best_factor := pf19
        best_expectancy := expectancy19
        best_trades := trades19
        best_stop := stop19
        best_dir := dir19
        best_vol_length := 10
        best_vol_factor := 6.0
        best_id := 19
    if not na(score18) and (na(best_score) or score18 > best_score * (1 + margin / 100))
        best_score := score18
        best_cagr := cagr18
        best_sharpe := sharpe18
        best_calmar := calmar18
        best_sortino := sortino18
        best_mdd := mdd18
        best_beta := beta18
        best_alpha := alpha18
        best_win_rate := win_rate18
        best_factor := pf18
        best_expectancy := expectancy18
        best_trades := trades18
        best_stop := stop18
        best_dir := dir18
        best_vol_length := 10
        best_vol_factor := 5.0
        best_id := 18
    if not na(score17) and (na(best_score) or score17 > best_score * (1 + margin / 100))
        best_score := score17
        best_cagr := cagr17
        best_sharpe := sharpe17
        best_calmar := calmar17
        best_sortino := sortino17
        best_mdd := mdd17
        best_beta := beta17
        best_alpha := alpha17
        best_win_rate := win_rate17
        best_factor := pf17
        best_expectancy := expectancy17
        best_trades := trades17
        best_stop := stop17
        best_dir := dir17
        best_vol_length := 10
        best_vol_factor := 4.5
        best_id := 17
    if not na(score16) and (na(best_score) or score16 > best_score * (1 + margin / 100))
        best_score := score16
        best_cagr := cagr16
        best_sharpe := sharpe16
        best_calmar := calmar16
        best_sortino := sortino16
        best_mdd := mdd16
        best_beta := beta16
        best_alpha := alpha16
        best_win_rate := win_rate16
        best_factor := pf16
        best_expectancy := expectancy16
        best_trades := trades16
        best_stop := stop16
        best_dir := dir16
        best_vol_length := 10
        best_vol_factor := 4.0
        best_id := 16
    if not na(score15) and (na(best_score) or score15 > best_score * (1 + margin / 100))
        best_score := score15
        best_cagr := cagr15
        best_sharpe := sharpe15
        best_calmar := calmar15
        best_sortino := sortino15
        best_mdd := mdd15
        best_beta := beta15
        best_alpha := alpha15
        best_win_rate := win_rate15
        best_factor := pf15
        best_expectancy := expectancy15
        best_trades := trades15
        best_stop := stop15
        best_dir := dir15
        best_vol_length := 10
        best_vol_factor := 3.5
        best_id := 15
    if not na(score14) and (na(best_score) or score14 > best_score * (1 + margin / 100))
        best_score := score14
        best_cagr := cagr14
        best_sharpe := sharpe14
        best_calmar := calmar14
        best_sortino := sortino14
        best_mdd := mdd14
        best_beta := beta14
        best_alpha := alpha14
        best_win_rate := win_rate14
        best_factor := pf14
        best_expectancy := expectancy14
        best_trades := trades14
        best_stop := stop14
        best_dir := dir14
        best_vol_length := 10
        best_vol_factor := 3.0
        best_id := 14
    if not na(score13) and (na(best_score) or score13 > best_score * (1 + margin / 100))
        best_score := score13
        best_cagr := cagr13
        best_sharpe := sharpe13
        best_calmar := calmar13
        best_sortino := sortino13
        best_mdd := mdd13
        best_beta := beta13
        best_alpha := alpha13
        best_win_rate := win_rate13
        best_factor := pf13
        best_expectancy := expectancy13
        best_trades := trades13
        best_stop := stop13
        best_dir := dir13
        best_vol_length := 10
        best_vol_factor := 2.5
        best_id := 13
    if not na(score12) and (na(best_score) or score12 > best_score * (1 + margin / 100))
        best_score := score12
        best_cagr := cagr12
        best_sharpe := sharpe12
        best_calmar := calmar12
        best_sortino := sortino12
        best_mdd := mdd12
        best_beta := beta12
        best_alpha := alpha12
        best_win_rate := win_rate12
        best_factor := pf12
        best_expectancy := expectancy12
        best_trades := trades12
        best_stop := stop12
        best_dir := dir12
        best_vol_length := 10
        best_vol_factor := 2.0
        best_id := 12
    if not na(score11) and (na(best_score) or score11 > best_score * (1 + margin / 100))
        best_score := score11
        best_cagr := cagr11
        best_sharpe := sharpe11
        best_calmar := calmar11
        best_sortino := sortino11
        best_mdd := mdd11
        best_beta := beta11
        best_alpha := alpha11
        best_win_rate := win_rate11
        best_factor := pf11
        best_expectancy := expectancy11
        best_trades := trades11
        best_stop := stop11
        best_dir := dir11
        best_vol_length := 5
        best_vol_factor := 10.0
        best_id := 11
    if not na(score10) and (na(best_score) or score10 > best_score * (1 + margin / 100))
        best_score := score10
        best_cagr := cagr10
        best_sharpe := sharpe10
        best_calmar := calmar10
        best_sortino := sortino10
        best_mdd := mdd10
        best_beta := beta10
        best_alpha := alpha10
        best_win_rate := win_rate10
        best_factor := pf10
        best_expectancy := expectancy10
        best_trades := trades10
        best_stop := stop10
        best_dir := dir10
        best_vol_length := 5
        best_vol_factor := 8.0
        best_id := 10
    if not na(score9) and (na(best_score) or score9 > best_score * (1 + margin / 100))
        best_score := score9
        best_cagr := cagr9
        best_sharpe := sharpe9
        best_calmar := calmar9
        best_sortino := sortino9
        best_mdd := mdd9
        best_beta := beta9
        best_alpha := alpha9
        best_win_rate := win_rate9
        best_factor := pf9
        best_expectancy := expectancy9
        best_trades := trades9
        best_stop := stop9
        best_dir := dir9
        best_vol_length := 5
        best_vol_factor := 7.0
        best_id := 9
    if not na(score8) and (na(best_score) or score8 > best_score * (1 + margin / 100))
        best_score := score8
        best_cagr := cagr8
        best_sharpe := sharpe8
        best_calmar := calmar8
        best_sortino := sortino8
        best_mdd := mdd8
        best_beta := beta8
        best_alpha := alpha8
        best_win_rate := win_rate8
        best_factor := pf8
        best_expectancy := expectancy8
        best_trades := trades8
        best_stop := stop8
        best_dir := dir8
        best_vol_length := 5
        best_vol_factor := 6.0
        best_id := 8
    if not na(score7) and (na(best_score) or score7 > best_score * (1 + margin / 100))
        best_score := score7
        best_cagr := cagr7
        best_sharpe := sharpe7
        best_calmar := calmar7
        best_sortino := sortino7
        best_mdd := mdd7
        best_beta := beta7
        best_alpha := alpha7
        best_win_rate := win_rate7
        best_factor := pf7
        best_expectancy := expectancy7
        best_trades := trades7
        best_stop := stop7
        best_dir := dir7
        best_vol_length := 5
        best_vol_factor := 5.0
        best_id := 7
    if not na(score6) and (na(best_score) or score6 > best_score * (1 + margin / 100))
        best_score := score6
        best_cagr := cagr6
        best_sharpe := sharpe6
        best_calmar := calmar6
        best_sortino := sortino6
        best_mdd := mdd6
        best_beta := beta6
        best_alpha := alpha6
        best_win_rate := win_rate6
        best_factor := pf6
        best_expectancy := expectancy6
        best_trades := trades6
        best_stop := stop6
        best_dir := dir6
        best_vol_length := 5
        best_vol_factor := 4.5
        best_id := 6
    if not na(score5) and (na(best_score) or score5 > best_score * (1 + margin / 100))
        best_score := score5
        best_cagr := cagr5
        best_sharpe := sharpe5
        best_calmar := calmar5
        best_sortino := sortino5
        best_mdd := mdd5
        best_beta := beta5
        best_alpha := alpha5
        best_win_rate := win_rate5
        best_factor := pf5
        best_expectancy := expectancy5
        best_trades := trades5
        best_stop := stop5
        best_dir := dir5
        best_vol_length := 5
        best_vol_factor := 4.0
        best_id := 5
    if not na(score4) and (na(best_score) or score4 > best_score * (1 + margin / 100))
        best_score := score4
        best_cagr := cagr4
        best_sharpe := sharpe4
        best_calmar := calmar4
        best_sortino := sortino4
        best_mdd := mdd4
        best_beta := beta4
        best_alpha := alpha4
        best_win_rate := win_rate4
        best_factor := pf4
        best_expectancy := expectancy4
        best_trades := trades4
        best_stop := stop4
        best_dir := dir4
        best_vol_length := 5
        best_vol_factor := 3.5
        best_id := 4
    if not na(score3) and (na(best_score) or score3 > best_score * (1 + margin / 100))
        best_score := score3
        best_cagr := cagr3
        best_sharpe := sharpe3
        best_calmar := calmar3
        best_sortino := sortino3
        best_mdd := mdd3
        best_beta := beta3
        best_alpha := alpha3
        best_win_rate := win_rate3
        best_factor := pf3
        best_expectancy := expectancy3
        best_trades := trades3
        best_stop := stop3
        best_dir := dir3
        best_vol_length := 5
        best_vol_factor := 3.0
        best_id := 3
    if not na(score2) and (na(best_score) or score2 > best_score * (1 + margin / 100))
        best_score := score2
        best_cagr := cagr2
        best_sharpe := sharpe2
        best_calmar := calmar2
        best_sortino := sortino2
        best_mdd := mdd2
        best_beta := beta2
        best_alpha := alpha2
        best_win_rate := win_rate2
        best_factor := pf2
        best_expectancy := expectancy2
        best_trades := trades2
        best_stop := stop2
        best_dir := dir2
        best_vol_length := 5
        best_vol_factor := 2.5
        best_id := 2
    if not na(score1) and (na(best_score) or score1 > best_score * (1 + margin / 100))
        best_score := score1
        best_cagr := cagr1
        best_sharpe := sharpe1
        best_calmar := calmar1
        best_sortino := sortino1
        best_mdd := mdd1
        best_beta := beta1
        best_alpha := alpha1
        best_win_rate := win_rate1
        best_factor := pf1
        best_expectancy := expectancy1
        best_trades := trades1
        best_stop := stop1
        best_dir := dir1
        best_vol_length := 5
        best_vol_factor := 2.0
        best_id := 1
clr_bull = color.new(color(#00FF00), 0)
clr_bear = color.new(color(#FF0000), 0)
color_line(dir) => dir < 0 ? clr_bull : clr_bear
stop_val = length_logic == 'Manual' ? mstop :
           best_id == 1 ? stop1 : best_id == 2 ? stop2 : best_id == 3 ? stop3 : best_id == 4 ? stop4 : best_id == 5 ? stop5 :
           best_id == 6 ? stop6 : best_id == 7 ? stop7 : best_id == 8 ? stop8 : best_id == 9 ? stop9 : best_id == 10 ? stop10 :
           best_id == 11 ? stop11 : best_id == 12 ? stop12 : best_id == 13 ? stop13 : best_id == 14 ? stop14 : best_id == 15 ? stop15 :
           best_id == 16 ? stop16 : best_id == 17 ? stop17 : best_id == 18 ? stop18 : best_id == 19 ? stop19 : best_id == 20 ? stop20 :
           best_id == 21 ? stop21 : best_id == 22 ? stop22 : best_id == 23 ? stop23 : best_id == 24 ? stop24 : best_id == 25 ? stop25 :
           best_id == 26 ? stop26 : best_id == 27 ? stop27 : best_id == 28 ? stop28 : best_id == 29 ? stop29 : best_id == 30 ? stop30 :
           best_id == 31 ? stop31 : best_id == 32 ? stop32 : best_id == 33 ? stop33 : best_id == 34 ? stop34 : best_id == 35 ? stop35 :
           best_id == 36 ? stop36 : best_id == 37 ? stop37 : best_id == 38 ? stop38 : best_id == 39 ? stop39 : best_id == 40 ? stop40 :
           best_id == 41 ? stop41 : best_id == 42 ? stop42 : best_id == 43 ? stop43 : best_id == 44 ? stop44 : best_id == 45 ? stop45 :
           best_id == 46 ? stop46 : best_id == 47 ? stop47 : best_id == 48 ? stop48 : best_id == 49 ? stop49 : best_id == 50 ? stop50 :
           best_id == 51 ? stop51 : best_id == 52 ? stop52 : best_id == 53 ? stop53 : best_id == 54 ? stop54 : best_id == 55 ? stop55 :
           best_id == 56 ? stop56 : best_id == 57 ? stop57 : best_id == 58 ? stop58 : best_id == 59 ? stop59 : best_id == 60 ? stop60 :
           best_id == 61 ? stop61 : best_id == 62 ? stop62 : best_id == 63 ? stop63 : best_id == 64 ? stop64 : best_id == 65 ? stop65 :
           best_id == 66 ? stop66 : best_id == 67 ? stop67 : best_id == 68 ? stop68 : best_id == 69 ? stop69 : best_id == 70 ? stop70 :
           best_id == 71 ? stop71 : best_id == 72 ? stop72 : best_id == 73 ? stop73 : best_id == 74 ? stop74 : best_id == 75 ? stop75 :
           best_id == 76 ? stop76 : best_id == 77 ? stop77 : best_id == 78 ? stop78 : best_id == 79 ? stop79 : best_id == 80 ? stop80 :
           best_id == 81 ? stop81 : best_id == 82 ? stop82 : best_id == 83 ? stop83 : best_id == 84 ? stop84 : best_id == 85 ? stop85 :
           best_id == 86 ? stop86 : best_id == 87 ? stop87 : best_id == 88 ? stop88 : na
dir_val = length_logic == 'Manual' ? mdir :
           best_id == 1 ? dir1 : best_id == 2 ? dir2 : best_id == 3 ? dir3 : best_id == 4 ? dir4 : best_id == 5 ? dir5 :
           best_id == 6 ? dir6 : best_id == 7 ? dir7 : best_id == 8 ? dir8 : best_id == 9 ? dir9 : best_id == 10 ? dir10 :
           best_id == 11 ? dir11 : best_id == 12 ? dir12 : best_id == 13 ? dir13 : best_id == 14 ? dir14 : best_id == 15 ? dir15 :
           best_id == 16 ? dir16 : best_id == 17 ? dir17 : best_id == 18 ? dir18 : best_id == 19 ? dir19 : best_id == 20 ? dir20 :
           best_id == 21 ? dir21 : best_id == 22 ? dir22 : best_id == 23 ? dir23 : best_id == 24 ? dir24 : best_id == 25 ? dir25 :
           best_id == 26 ? dir26 : best_id == 27 ? dir27 : best_id == 28 ? dir28 : best_id == 29 ? dir29 : best_id == 30 ? dir30 :
           best_id == 31 ? dir31 : best_id == 32 ? dir32 : best_id == 33 ? dir33 : best_id == 34 ? dir34 : best_id == 35 ? dir35 :
           best_id == 36 ? dir36 : best_id == 37 ? dir37 : best_id == 38 ? dir38 : best_id == 39 ? dir39 : best_id == 40 ? dir40 :
           best_id == 41 ? dir41 : best_id == 42 ? dir42 : best_id == 43 ? dir43 : best_id == 44 ? dir44 : best_id == 45 ? dir45 :
           best_id == 46 ? dir46 : best_id == 47 ? dir47 : best_id == 48 ? dir48 : best_id == 49 ? dir49 : best_id == 50 ? dir50 :
           best_id == 51 ? dir51 : best_id == 52 ? dir52 : best_id == 53 ? dir53 : best_id == 54 ? dir54 : best_id == 55 ? dir55 :
           best_id == 56 ? dir56 : best_id == 57 ? dir57 : best_id == 58 ? dir58 : best_id == 59 ? dir59 : best_id == 60 ? dir60 :
           best_id == 61 ? dir61 : best_id == 62 ? dir62 : best_id == 63 ? dir63 : best_id == 64 ? dir64 : best_id == 65 ? dir65 :
           best_id == 66 ? dir66 : best_id == 67 ? dir67 : best_id == 68 ? dir68 : best_id == 69 ? dir69 : best_id == 70 ? dir70 :
           best_id == 71 ? dir71 : best_id == 72 ? dir72 : best_id == 73 ? dir73 : best_id == 74 ? dir74 : best_id == 75 ? dir75 :
           best_id == 76 ? dir76 : best_id == 77 ? dir77 : best_id == 78 ? dir78 : best_id == 79 ? dir79 : best_id == 80 ? dir80 :
           best_id == 81 ? dir81 : best_id == 82 ? dir82 : best_id == 83 ? dir83 : best_id == 84 ? dir84 : best_id == 85 ? dir85 :
           best_id == 86 ? dir86 : best_id == 87 ? dir87 : best_id == 88 ? dir88 : na
bull_stop = dir_val < 0 ? stop_val : na
bear_stop = dir_val > 0 ? stop_val : na
plot_bull = plot(bull_stop, title = 'Plot Bull', style = plot.style_linebr, linewidth = 3, color = clr_bull)
plot_bear = plot(bear_stop, title = 'Plot Bear', style = plot.style_linebr, linewidth = 3, color = clr_bear)
vol_length_final = na(best_vol_length) ? '-' : str.tostring(best_vol_length, '#')
vol_factor_final = na(best_vol_factor) ? '-' : str.tostring(best_vol_factor, '#.#')
sharpe_final = na(best_sharpe) ? '-' : str.tostring(best_sharpe, '#.#')
calmar_final = na(best_calmar) ? '-' : str.tostring(best_calmar, '#.#')
sortino_final = na(best_sortino) ? '-' : str.tostring(best_sortino, '#.#')
mdd_final = na(best_mdd) ? '-' : str.tostring(best_mdd, '#%')
beta_final = na(best_beta) ? '-' : str.tostring(best_beta, '#.#')
alpha_final = na(best_alpha) ? '-' : str.tostring(best_alpha, '#%')
win_final = na(best_win_rate) ? '-' : str.tostring(best_win_rate, '#%')
factor_final = na(best_factor) ? '-' : str.tostring(best_factor, '#.#') + 'x'
expectancy_final = na(best_expectancy) ? '-' : str.tostring(best_expectancy, '#%')
trades_final = na(best_trades) ? '-' : str.tostring(best_trades, '#.#')
var label strat_label_id = na
if barstate.islast
    label.delete(strat_label_id)
    strat_label = 'CAGR = ' + (best_cagr > 0 ? '+' : '') + str.tostring(best_cagr, '#%') + ' (' + (bh_cagr > 0 ? '+' : '') + str.tostring(bh_cagr, '#%') + ')'
    strat_label_id := label.new(x = bar_index + 1, y = close, text = strat_label, style = label.style_label_left, textcolor = color.white, color = best_cagr > 0 ? color.green : color.red)
var table t = table.new(table_position, 2, 12, frame_color = color.white, frame_width = 1, border_color = color.white, border_width = 1)
table.cell(t, 0, 0, text = 'Length', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 1, text = 'Factor', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 2, text = 'Sharpe', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 3, text = 'Sortino', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 4, text = 'Calmar', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 5, text = 'Max DD', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 6, text = 'Beta (β)', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 7, text = 'Alpha (α)', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 8, text = 'Win Rate', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 9, text = 'Profit Factor', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 10, text = 'Expectancy', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 0, 11, text = 'Trades/Year', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(t, 1, 0, text = vol_length_final, width = width_input, text_color = color.white, bgcolor = color.gray)
table.cell(t, 1, 1, text = vol_factor_final, width = width_input, text_color = color.white, bgcolor = color.gray)
table.cell(t, 1, 2, text = sharpe_final, width = width_input, text_color = color.white, bgcolor = best_sharpe > bh_sharpe ? color.green : best_sharpe < bh_sharpe ? color.red : color.gray)
table.cell(t, 1, 3, text = sortino_final, width = width_input, text_color = color.white, bgcolor = best_sortino > bh_sortino ? color.green : best_sortino < bh_sortino ? color.red : color.gray)
table.cell(t, 1, 4, text = calmar_final, width = width_input, text_color = color.white, bgcolor = best_calmar > bh_calmar ? color.green : best_calmar < bh_calmar ? color.red : color.gray)
table.cell(t, 1, 5, text = mdd_final, width = width_input, text_color = color.white, bgcolor = best_mdd > bh_mdd ? color.green : best_mdd < bh_mdd ? color.red : color.gray)
table.cell(t, 1, 6, text = beta_final, width = width_input, text_color = color.white, bgcolor = best_beta < 1 ? color.green : best_beta > 1 ? color.red : color.gray)
table.cell(t, 1, 7, text = alpha_final, width = width_input, text_color = color.white, bgcolor = best_alpha > 0 ? color.green : best_alpha < 0 ? color.red : color.gray)
table.cell(t, 1, 8, text = win_final, width = width_input, text_color = color.white, bgcolor = best_win_rate > 0.5 ? color.green : best_win_rate < 0.5 ? color.red : color.gray)
table.cell(t, 1, 9, text = factor_final, width = width_input, text_color = color.white, bgcolor = best_factor > 2 ? color.green : best_factor < 1 ? color.red : color.gray)
table.cell(t, 1, 10, text = expectancy_final, width = width_input, text_color = color.white, bgcolor = best_expectancy > 0 ? color.green : best_expectancy < 0 ? color.red : color.gray)
table.cell(t, 1, 11, text = trades_final, width = width_input, text_color = color.white, bgcolor = color.gray)
````
