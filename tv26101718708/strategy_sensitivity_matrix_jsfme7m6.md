# Strategy Sensitivity Matrix

- url: https://www.tradingview.com/script/jSfmE7m6-Strategy-Sensitivity-Matrix/
- type: indicator
- pine_id: PUB;5f8a83ea3ab4402085ef026bc2b066af
- version: 5.0

## Description

The Strategy Sensitivity Matrix is an institutional-grade backtesting tool designed to evaluate the robustness and parameter sensitivity of trend-following strategies. It enables users to compare the historical performance of a broad range of parameter combinations across multiple metrics to assess the overall stability of the selected strategy. The model displays the complete backtest landscape in a structured, color-coded matrix that allows investors to quickly identify robust parameter regions and evaluate historical performance stability across parameter combinations.

At its core, the matrix systematically evaluates a wide range of parameter combinations, where every individual cell represents the backtest result for one unique parameter configuration. Users can switch between volatility-based strategies and moving-average strategies. In volatility mode, the matrix rows represent volatility lengths and the matrix columns represent volatility factors. In crossover mode, the rows represent fast moving-average lengths and the columns represent slow moving-average lengths. Supported volatility types include the Average True Range (ATR), Standard Deviation (SD), and Mean Absolute Deviation (MAD). Supported moving-average types include the Exponential Moving Average (EMA), Simple Moving Average (SMA), Wilder’s Moving Average (RMA), and Weighted Moving Average (WMA). Supported display metrics include:

[list]
[*]CAGR = Compounded Annual Growth Rate.
[*]Sharpe = CAGR per unit of standard deviation.
[*]Sortino = CAGR per unit of downside deviation.
[*]Martin = CAGR relative to the Ulcer Index (UI).
[*]Calmar = CAGR relative to maximum drawdown.
[*]Max DD = Largest peak-to-trough decline in value.
[*]Alpha (α) = Excess annualized risk-adjusted returns.
[*]Expectancy = Average expected return per trade.
[*]Profit Factor = Total gross profit per unit of losses.
[*]Win Rate = Ratio of profitable trades to total trades.
[*]Trades/Year = Average number of trades per year.
[/list]
The matrix follows an intuitive percentile-based coloring framework that dynamically compares the relative performance and stability of all parameter combinations. Stronger values above or equal to the matrix median are highlighted in green, with bright green representing the top 10% of all parameter combinations. Weaker values below the matrix median are highlighted in orange, while red represents objectively weak performance based on the selected metric. Broad clusters of consistently strong results generally suggest lower parameter sensitivity and potentially greater robustness, while isolated peaks generally suggest elevated parameter sensitivity.

The summary table displayed above the matrix provides a broader distribution-level statistical overview of results across all parameter combinations. This structure allows investors to evaluate whether strong historical performance appears statistically widespread or narrowly concentrated across the parameter landscape. Stable parameter landscapes generally exhibit lower standard deviation, similar median and average values, and smaller performance gaps between the best and top 10% parameter combinations. The summary table includes the following sections:

[list]
[*]Start = Start month and year of the selected backtest period.
[*]End = End month and year of the selected backtest period.
[*]Metric = Performance metric currently displayed in the matrix.
[*]B&H = Buy-and-hold performance for the selected metric.
[*]Best = Best-performing parameter combination in the matrix.
[*]Top 10% = Average value of the top 10% parameter combinations.
[*]Median = Median value across all parameter combinations.
[*]Average = Average value across all parameter combinations.
[*]Std Dev = Standard deviation of all parameter combinations.
[*]≥ B&H = Percentage of combinations equal or better than B&H.
[/list]
In summary, the Strategy Sensitivity Matrix is a powerful robustness analysis tool designed to help investors make data-driven decisions when evaluating parameter combinations across trend-following strategies. By evaluating the full parameter landscape, investors can quickly determine whether strong historical performance appears broadly distributed across stable parameter regions or narrowly concentrated within isolated parameter combinations. While historical robustness can provide valuable insight into past market behavior over the selected backtest period, users should remain mindful that market structures evolve over time and that historically stable parameter regions may not necessarily persist in future market conditions.

## Source Code

````pine
// © QuantitativeAlpha
//@version=6
indicator(title = 'Strategy Sensitivity Matrix', shorttitle = 'SSM', overlay = true)
src_type = input.string('Close', 'Price Source', options = ['Close', 'HL2', 'HLC3', 'OHLC4'])
start_month_name = input.string('Jan', title = 'Start Month', options = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
start_year = input.int(2008, title = 'Start Year')
display_metric = input.string('Sharpe', title = 'Display Metric', options = ['CAGR', 'Sharpe', 'Sortino', 'Martin', 'Calmar', 'Max DD', 'Alpha (α)', 'Efficiency', 'Win Rate', 'Profit Factor', 'Expectancy', 'Turnover', 'Exposure'])
strategy_mode = input.string('Volatility', title = 'Strategy Type', options = ['Volatility', 'Crossover'])
ma_type = input.string('EMA', title = 'Crossover Type', options = ['EMA', 'SMA', 'RMA', 'WMA'])
vol_type = input.string('ATR', 'Volatility Type', options = ['ATR', 'SD', 'MAD'])
fee_input = input.float(0.1, title = 'Fees (%)', minval = 0.0)
price_type = input.string('Open', title='Entry/Exit', options=['Open', 'Close'])
show_summary = input.bool(true, title = 'Show Summary Statistics Table')
width_input = input.int(8, title = 'Table Width', minval = 1)
table_input = input.string('Low', title = 'Table Position', options = ['High', 'Middle', 'Low'])
table_position = table_input == 'High' ? position.top_center : table_input == 'Middle' ? position.middle_center : position.bottom_center
start_month = start_month_name == 'Jan' ? 1 : start_month_name == 'Feb' ? 2 : start_month_name == 'Mar' ? 3 : start_month_name == 'Apr' ? 4 : start_month_name == 'May' ? 5 : start_month_name == 'Jun' ? 6 : start_month_name == 'Jul' ? 7 : start_month_name == 'Aug' ? 8 : start_month_name == 'Sep' ? 9 : start_month_name == 'Oct' ? 10 : start_month_name == 'Nov' ? 11 : 12
raw_type = price_type == 'Open' ? open : close
transaction_cost = fee_input / 100.0
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
var int slots = 88
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
var int[] exposure_count_a = array.new_int(slots, 0)
var int[] exposure_total_a = array.new_int(slots, 0)
var float[] cum_turnover_a = array.new_float(slots, 0.0)
var float[] max_src_a = array.new_float(slots, na)
var float[] min_src_a = array.new_float(slots, na)
var bool[] uptrend_a = array.new_bool(slots, true)
var float[] trend_a = array.new_float(slots, na)
var int period_start_bar = na
src = src_type == 'HL2' ? hl2 : src_type == 'HLC3' ? hlc3 : src_type == 'OHLC4' ? ohlc4 : close
ma(source, length) =>
    int len = int(length)
    ma_type == 'SMA'  ? ta.sma(source, len)  : ma_type == 'WMA'  ? ta.wma(source, len)  : ma_type == 'RMA'  ? ta.rma(source, len) : ta.ema(source, len)
if na(period_start_bar) and in_sample_bar
    period_start_bar := bar_index
score_combo(slot, param1, param2) =>
    bool is_long_now = false
    bool long_signal = false
    bool short_signal = false
    float exposure = 0.0
    if strategy_mode == 'Volatility'
        int vol_len = int(param1)
        vol = vol_type == 'SD' ? ta.stdev(src, vol_len) : vol_type == 'MAD' ? ta.sma(math.abs(src - ta.sma(src, vol_len)), vol_len) : ta.atr(vol_len)
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
            long_stop = max_src - param2 * vol
            short_stop = min_src + param2 * vol
            trend := na(trend) ? src : uptrend ? math.max(trend, long_stop) : math.min(trend, short_stop)
            uptrend := src >= trend
            if uptrend != prev_uptrend
                max_src := src
                min_src := src
                trend := uptrend ? max_src - param2 * vol : min_src + param2 * vol
        vol_dir = not na(trend) and not na(prev_trend) and uptrend ? -1 : 1
        exposure := not na(prev_trend) and prev_vol_dir < 0 ? 1.0 : 0.0
        array.set(max_src_a, slot, max_src)
        array.set(min_src_a, slot, min_src)
        array.set(uptrend_a, slot, uptrend)
        array.set(trend_a, slot, trend)
    else
        fast_ma = ma(src, int(param1))
        slow_ma = ma(src, int(param2))
        exposure := not na(fast_ma[1]) and not na(slow_ma[1]) ? (fast_ma[1] > slow_ma[1] ? 1.0 : 0.0) : 0.0
    is_long_now := exposure > 0.0
    was_long = exposure[1] > 0.0
    long_signal := is_long_now and not was_long
    short_signal := not is_long_now and was_long
    raw_ret = exposure[1] * math.log(raw_type / raw_type[1])
    turnover = not na(exposure) and not na(exposure[1]) ? math.abs(exposure - exposure[1]) : 0.0
    cost = turnover * transaction_cost
    strat_ret = raw_ret - cost
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
    exposure_count = array.get(exposure_count_a, slot)
    exposure_total = array.get(exposure_total_a, slot)
    cum_turnover = array.get(cum_turnover_a, slot)
    bh_r = bh_strat_ret
    if in_sample_ret and not na(turnover)
        cum_turnover += turnover
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
    if in_sample_ret
        exposure_total += 1
        if exposure[1] > 0
            exposure_count += 1
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
    turnover_annualized = not na(safe_years) and safe_years > 0 ? cum_turnover / safe_years : na
    exposure_pct = exposure_total > 0 ? exposure_count / exposure_total : na
    efficiency = not na(cagr) and not na(exposure_pct) and exposure_pct > 0 ? cagr / exposure_pct : na
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
    array.set(exposure_count_a, slot, exposure_count)
    array.set(exposure_total_a, slot, exposure_total)
    array.set(cum_turnover_a, slot, cum_turnover)
    current_exposure = is_long_now ? 1.0 : 0.0
    score_metric = display_metric == 'Martin' ? martin : display_metric == 'Calmar' ? calmar : display_metric == 'Sortino' ? sortino : display_metric == 'CAGR' ? cagr : display_metric == 'Max DD' ? mdd : display_metric == 'Alpha (α)' ? alpha : display_metric == 'Win Rate' ? win_rate : display_metric == 'Profit Factor' ? factor : display_metric == 'Expectancy' ? expectancy : display_metric == 'Turnover' ? turnover_annualized : display_metric == 'Efficiency' ? efficiency : display_metric == 'Exposure' ? current_exposure : sharpe
    score = not na(score_metric) ? score_metric : na
    [score, cagr, sharpe, sortino, martin, calmar, mdd, alpha, win_rate, factor, expectancy, turnover_annualized]
score_only(slot, p1, p2) =>
    invalid_ats = strategy_mode == 'Crossover' and (2 * p1) > p2
    if invalid_ats
        na
    else
        [score, cagr, sharpe, sortino, martin, calmar, mdd, alpha, win_rate, factor, expectancy, turnover_annualized] = score_combo(slot, p1, p2)
        score
score1 = score_only(0, 5, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score2 = score_only(1, 5, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score3 = score_only(2, 5, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score4 = score_only(3, 5, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score5 = score_only(4, 5, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score6 = score_only(5, 5, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score7 = score_only(6, 5, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score8 = score_only(7, 5, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score9 = score_only(8, 5, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score10 = score_only(9, 5, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score11 = score_only(10, 5, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score12 = score_only(11, 10, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score13 = score_only(12, 10, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score14 = score_only(13, 10, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score15 = score_only(14, 10, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score16 = score_only(15, 10, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score17 = score_only(16, 10, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score18 = score_only(17, 10, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score19 = score_only(18, 10, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score20 = score_only(19, 10, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score21 = score_only(20, 10, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score22 = score_only(21, 10, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score23 = score_only(22, 15, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score24 = score_only(23, 15, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score25 = score_only(24, 15, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score26 = score_only(25, 15, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score27 = score_only(26, 15, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score28 = score_only(27, 15, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score29 = score_only(28, 15, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score30 = score_only(29, 15, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score31 = score_only(30, 15, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score32 = score_only(31, 15, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score33 = score_only(32, 15, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score34 = score_only(33, 20, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score35 = score_only(34, 20, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score36 = score_only(35, 20, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score37 = score_only(36, 20, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score38 = score_only(37, 20, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score39 = score_only(38, 20, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score40 = score_only(39, 20, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score41 = score_only(40, 20, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score42 = score_only(41, 20, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score43 = score_only(42, 20, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score44 = score_only(43, 20, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score45 = score_only(44, 25, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score46 = score_only(45, 25, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score47 = score_only(46, 25, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score48 = score_only(47, 25, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score49 = score_only(48, 25, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score50 = score_only(49, 25, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score51 = score_only(50, 25, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score52 = score_only(51, 25, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score53 = score_only(52, 25, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score54 = score_only(53, 25, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score55 = score_only(54, 25, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score56 = score_only(55, 30, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score57 = score_only(56, 30, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score58 = score_only(57, 30, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score59 = score_only(58, 30, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score60 = score_only(59, 30, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score61 = score_only(60, 30, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score62 = score_only(61, 30, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score63 = score_only(62, 30, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score64 = score_only(63, 30, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score65 = score_only(64, 30, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score66 = score_only(65, 30, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score67 = score_only(66, 40, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score68 = score_only(67, 40, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score69 = score_only(68, 40, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score70 = score_only(69, 40, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score71 = score_only(70, 40, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score72 = score_only(71, 40, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score73 = score_only(72, 40, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score74 = score_only(73, 40, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score75 = score_only(74, 40, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score76 = score_only(75, 40, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score77 = score_only(76, 40, strategy_mode == 'Volatility' ? 10.0 : 200.0)
score78 = score_only(77, 50, strategy_mode == 'Volatility' ? 2.0 : 10.0)
score79 = score_only(78, 50, strategy_mode == 'Volatility' ? 2.5 : 20.0)
score80 = score_only(79, 50, strategy_mode == 'Volatility' ? 3.0 : 30.0)
score81 = score_only(80, 50, strategy_mode == 'Volatility' ? 3.5 : 40.0)
score82 = score_only(81, 50, strategy_mode == 'Volatility' ? 4.0 : 50.0)
score83 = score_only(82, 50, strategy_mode == 'Volatility' ? 4.5 : 60.0)
score84 = score_only(83, 50, strategy_mode == 'Volatility' ? 5.0 : 80.0)
score85 = score_only(84, 50, strategy_mode == 'Volatility' ? 6.0 : 100.0)
score86 = score_only(85, 50, strategy_mode == 'Volatility' ? 7.0 : 120.0)
score87 = score_only(86, 50, strategy_mode == 'Volatility' ? 8.0 : 150.0)
score88 = score_only(87, 50, strategy_mode == 'Volatility' ? 10.0 : 200.0)
scores = array.from(score1, score2, score3, score4, score5, score6, score7, score8, score9, score10, score11, score12, score13, score14, score15, score16, score17, score18, score19, score20, score21, score22, score23, score24, score25, score26, score27, score28, score29, score30, score31, score32, score33, score34, score35, score36, score37, score38, score39, score40, score41, score42, score43, score44, score45, score46, score47, score48, score49, score50, score51, score52, score53, score54, score55, score56, score57, score58, score59, score60, score61, score62, score63, score64, score65, score66, score67, score68, score69, score70, score71, score72, score73, score74, score75, score76, score77, score78, score79, score80, score81, score82, score83, score84, score85, score86, score87, score88)
metric_round(metric_value) =>
    raw_round = na(metric_value) ? na : display_metric == 'CAGR' or display_metric == 'Max DD' or display_metric == 'Alpha (α)' or display_metric == 'Win Rate' or display_metric == 'Expectancy' or display_metric == 'Efficiency' ? math.round(metric_value * 100) / 100 : math.round(metric_value * 10) / 10
    not na(raw_round) and raw_round == 0 ? 0.0 : raw_round
metric_text(metric_value) =>
    rounded_value = metric_round(metric_value)
    na(rounded_value) ? '-' : display_metric == 'CAGR' or display_metric == 'Max DD' or display_metric == 'Alpha (α)' or display_metric == 'Win Rate' or display_metric == 'Expectancy' or display_metric == 'Efficiency' ? str.tostring(rounded_value, '#%') : display_metric == 'Profit Factor' ? str.tostring(rounded_value, '#.#') + 'x' : display_metric == 'Exposure' ? str.tostring(int(math.round(rounded_value))) : str.tostring(rounded_value, '#.#')
rank_color(metric_value, score_array, median_val) =>
    if na(metric_value)
        color.gray
    else
        rounded_value_bad = metric_round(metric_value)
        bh_mdd_bad = metric_round(bh_mdd)
        is_bad = na(rounded_value_bad) ? false : display_metric == 'CAGR' ? rounded_value_bad <= 0 : display_metric == 'Sharpe' ? rounded_value_bad <= 0 : display_metric == 'Sortino' ? rounded_value_bad <= 0 : display_metric == 'Martin' ? rounded_value_bad <= 0 : display_metric == 'Calmar' ? rounded_value_bad <= 0 : display_metric == 'Max DD' ? not na(bh_mdd_bad) and rounded_value_bad <= bh_mdd_bad : display_metric == 'Alpha (α)' ? rounded_value_bad <= 0 : display_metric == 'Win Rate' ? rounded_value_bad <= 0.50 : display_metric == 'Profit Factor' ? rounded_value_bad <= 1 : display_metric == 'Expectancy' ? rounded_value_bad <= 0 : display_metric == 'Turnover' ? rounded_value_bad >= 10 : display_metric == 'Efficiency' ? rounded_value_bad <= 0 : display_metric == 'Exposure' ? rounded_value_bad == 0 : false
        if is_bad
            color.red
        else
            valid_count = 0
            better_count = 0
            value_rounded = metric_round(metric_value)
            value_rank = display_metric != 'Turnover' ? value_rounded : -value_rounded
            for i = 0 to array.size(score_array) - 1
                x = array.get(score_array, i)
                if not na(x)
                    valid_count += 1
                    x_rounded = metric_round(x)
                    x_rank = display_metric != 'Turnover' ? x_rounded : -x_rounded
                    if x_rank > value_rank
                        better_count += 1
            percentile_rank = valid_count > 1 ? better_count / (valid_count - 1) : 0.5
            median_rounded = metric_round(median_val)
            display_metric == 'Exposure' ? (value_rounded == 1 ? color.green : color.red) : percentile_rank <= 0.10 ? color.rgb(0, 200, 0) : na(median_rounded) ? color.gray : value_rank >= (display_metric != 'Turnover' ? median_rounded : -median_rounded) ? color.green : color.orange
row_offset = show_summary ? 2 : 0
var table matrix = table.new(table_position, 12, 11, frame_color = color.white, frame_width = 1, border_color = color.white, border_width = 1)
table.cell(matrix, 0, row_offset, text = strategy_mode == 'Volatility' ? 'Len/Factor' : 'Fast/Slow', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 1, row_offset, text = strategy_mode == 'Volatility' ? '2.0' : '10', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 2, row_offset, text = strategy_mode == 'Volatility' ? '2.5' : '20', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 3, row_offset, text = strategy_mode == 'Volatility' ? '3.0' : '30', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 4, row_offset, text = strategy_mode == 'Volatility' ? '3.5' : '40', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 5, row_offset, text = strategy_mode == 'Volatility' ? '4.0' : '50', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 6, row_offset, text = strategy_mode == 'Volatility' ? '4.5' : '60', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 7, row_offset, text = strategy_mode == 'Volatility' ? '5.0' : '80', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 8, row_offset, text = strategy_mode == 'Volatility' ? '6.0' : '100', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 9, row_offset, text = strategy_mode == 'Volatility' ? '7.0' : '120', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 10, row_offset, text = strategy_mode == 'Volatility' ? '8.0' : '150', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 11, row_offset, text = strategy_mode == 'Volatility' ? '10.0' : '200', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 1, text = '5', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 2, text = '10', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 3, text = '15', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 4, text = '20', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 5, text = '25', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 6, text = '30', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 7, text = '40', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
table.cell(matrix, 0, row_offset + 8, text = '50', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
valid_scores = array.new_float()
for i = 0 to array.size(scores) - 1
    x = array.get(scores, i)
    if not na(x)
        array.push(valid_scores, x)
summary_count = array.size(valid_scores)
sorted_scores = array.copy(valid_scores)
float summary_max = na
float summary_avg = na
float summary_median = na
float summary_std = na
float summary_iqr = na
float summary_top10 = na
float summary_outperformance = na
bh_val = display_metric == 'CAGR' ? bh_cagr : display_metric == 'Sharpe' ? bh_sharpe : display_metric == 'Sortino' ? bh_sortino : display_metric == 'Martin' ? bh_martin : display_metric == 'Calmar' ? bh_calmar : display_metric == 'Max DD' ? bh_mdd : display_metric == 'Alpha (α)' ? 0.0 : display_metric == 'Efficiency' ? bh_cagr : na
if summary_count > 0 and not na(bh_val)
    outperform_count = 0
    bh_val_rounded = metric_round(bh_val)
    for i = 0 to summary_count - 1
        x = array.get(sorted_scores, i)
        x_rounded = metric_round(x)
        if not na(x_rounded) and not na(bh_val_rounded)
            if display_metric != 'Turnover' ? x_rounded >= bh_val_rounded : x_rounded < bh_val_rounded
                outperform_count += 1
    summary_outperformance := outperform_count / summary_count
if summary_count > 0
    array.sort(sorted_scores, order.ascending)
    summary_max := display_metric != 'Turnover' ? array.get(sorted_scores, summary_count - 1) : array.get(sorted_scores, 0)
    summary_sum = 0.0
    for i = 0 to summary_count - 1
        summary_sum += array.get(sorted_scores, i)
    summary_avg := summary_sum / summary_count
    median_mid = math.floor(summary_count / 2)
    summary_median := summary_count % 2 == 1 ? array.get(sorted_scores, median_mid) : (array.get(sorted_scores, median_mid - 1) + array.get(sorted_scores, median_mid)) / 2.0
    q1_idx = int(math.floor((summary_count - 1) * 0.25))
    q3_idx = int(math.floor((summary_count - 1) * 0.75))
    q1 = array.get(sorted_scores, q1_idx)
    q3 = array.get(sorted_scores, q3_idx)
    summary_iqr := q3 - q1
    summary_var_sum = 0.0
    for i = 0 to summary_count - 1
        x = array.get(sorted_scores, i)
        summary_var_sum += math.pow(x - summary_avg, 2)
    summary_std := summary_count > 1 ? math.sqrt(summary_var_sum / (summary_count - 1)) : na
    top_count = math.max(1, math.ceil(summary_count * 0.10))
    top_sum = 0.0
    for i = 0 to top_count - 1
        top_idx = display_metric != 'Turnover' ? summary_count - 1 - i : i
        top_sum += array.get(sorted_scores, top_idx)
    summary_top10 := top_sum / top_count
for row = 1 to 8
    for col = 1 to 11
        matrix_index = (row - 1) * 11 + (col - 1)
        cell_score = array.get(scores, matrix_index)
        table.cell(matrix, col, row + row_offset, text = metric_text(cell_score), width = width_input, text_color = color.white, bgcolor = rank_color(cell_score, scores, summary_median))
start_month_txt = month(start_ts) < 10 ? '0' + str.tostring(month(start_ts)) : str.tostring(month(start_ts))
end_month_txt = month(time) < 10 ? '0' + str.tostring(month(time)) : str.tostring(month(time))
start_txt = start_month_txt + '/' + str.tostring(year(start_ts))
end_txt = end_month_txt + '/' + str.tostring(year(time))
type_txt = strategy_mode == 'Volatility' ? vol_type : ma_type
if show_summary
    table.cell(matrix, 0, 0, text = 'Type', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 1, 0, text = 'Metric', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 2, 0, text = 'Start', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 3, 0, text = 'End', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 4, 0, text = 'B&H', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 5, 0, text = 'Best', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 6, 0, text = 'Top 10%', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 7, 0, text = 'Median', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 8, 0, text = 'Average', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 9, 0, text = 'IQR', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 10, 0, text = 'Std Dev', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 11, 0, text = '≥ B&H', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
    table.cell(matrix, 0, 1, text = type_txt, width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 1, 1, text = display_metric, width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 2, 1, text = display_metric == 'Exposure' ? '-' : start_txt, width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 3, 1, text = display_metric == 'Exposure' ? '-' : end_txt, width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 4, 1, text = display_metric == 'Exposure' ? '-' : metric_text(bh_val), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 5, 1, text = display_metric == 'Exposure' ? '-' : metric_text(summary_max), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 6, 1, text = display_metric == 'Exposure' ? '-' : metric_text(summary_top10), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 7, 1, text = display_metric == 'Exposure' and not na(summary_median) ? str.tostring(int(math.round(summary_median))) : metric_text(summary_median), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 8, 1, text = display_metric == 'Exposure' and not na(summary_avg) ? str.tostring(summary_avg, '#%') : metric_text(summary_avg), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 9, 1, text = display_metric == 'Exposure' ? '-' : metric_text(summary_iqr), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 10, 1, text = display_metric == 'Exposure' ? '-' : metric_text(summary_std), width = width_input, text_color = color.white, bgcolor = color.gray)
    table.cell(matrix, 11, 1, text = display_metric == 'Exposure' ? '-' : na(summary_outperformance) ? '-' : str.tostring(summary_outperformance, '#%'), width = width_input, text_color = color.white, bgcolor = color.gray)
````
