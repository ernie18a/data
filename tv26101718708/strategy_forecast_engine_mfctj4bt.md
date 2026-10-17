# Strategy Forecast Engine

- url: https://www.tradingview.com/script/MfCTj4bT-Strategy-Forecast-Engine/
- type: indicator
- pine_id: PUB;c37080ada4e941fdbb2d536fb76e72c5
- version: 1.0

## Description

The Strategy Forecast Engine is a regime-based Monte Carlo forecasting tool that estimates the future return distribution of trend-following strategies across different market environments. The model identifies the current market regime, conditions forecasts on historical returns observed during comparable regimes, and generates thousands of potential future price paths using Monte Carlo simulation. The resulting return distribution is presented through percentile projections and a structured, color-coded table that provides a comprehensive assessment of the forecast.

First, the model identifies the current market regime using the selected trend-following strategy. Users can choose between a moving-average crossover strategy, a volatility-based trailing stop strategy, or a combined strategy that incorporates both approaches. Supported moving-average types include the Exponential Moving Average (EMA), Simple Moving Average (SMA), Wilder’s Moving Average (RMA), and Weighted Moving Average (WMA). Supported volatility types include the Average True Range (ATR), Standard Deviation (SD), and Mean Absolute Deviation (MAD). By default, the model applies an asymmetric design in which conflicting signals default to bullish unless neutral regimes are enabled in the menu. Market regimes are determined as follows:

[list]
[*]Bullish Trend Regime = (Fast MA – Slow MA) > (ATR × Trend Margin)
[*]Bearish Trend Regime = (Fast MA – Slow MA) < –(ATR × Trend Margin)
[*]Bullish Volatility Regime = Price > (Highest Price – (Volatility × Stop Factor))
[*]Bearish Volatility Regime = Price < (Lowest Price + (Volatility × Stop Factor))
[*]Bullish Combined Regime = Bullish Trend Regime and Bullish Volatility Regime
[*]Bearish Combined Regime = Bearish Trend Regime and Bearish Volatility Regime
[/list]
Once the current regime has been identified, the model collects all historical logarithmic returns that occurred during the same regime beginning from the selected start date. Only returns from the matching regime are used to generate the forecast, allowing projections to be conditioned on historically comparable market environments rather than treating all historical observations as equally relevant. If duration-adjusted forecast is enabled in the menu, the model further restricts the sample pool to returns from regimes that were at least as mature as the current regime.

The Monte Carlo simulation engine then generates thousands of possible future price paths over the selected forecast horizon. Each simulation randomly samples historical returns from the sample pool associated with the current regime and compounds them forward to generate a potential future price path. This process is repeated for the specified number of simulations to produce a broad range of possible future outcomes. The random seed controls reproducibility, ensuring that identical settings produce identical forecasts. Once all individual simulations have been completed, the resulting return distribution is summarized using percentile projections:

[list]
[*]95% = 5% of simulations ended above this level and 95% ended below it.
[*]75% = 25% of simulations ended above this level and 75% ended below it.
[*]Median = 50% of simulations ended above this level and 50% ended below it.
[*]25% = 25% of simulations ended below this level and 75% ended above it.
[*]5% = 5% of simulations ended below this level and 95% ended above it.
[/list]
The upper quartile (75%) and lower quartile (25%) define the Interquartile Range (IQR), which contains the middle 50% of all simulated outcomes and represents the central range of the projected outcome distribution. The upper and lower tail percentiles can be set to 10% (90% / 10%), 5% (95% / 5%), or 1% (99% / 1%). The default setting is 5%, which captures the middle 90% of simulated outcomes. At 10%, the range captures 80% of simulated outcomes, while at 1%, the range captures 98% of simulated outcomes. To further evaluate the risk/reward characteristics of the forecast, the model includes a built-in table with the following metrics:

[list]
[*]Regime = Current market regime based on the selected strategy configuration.
[*]Duration = Percentile rank of current regime duration relative to past regimes.
[*]Forecast = Percentile rank of current duration including the forecast horizon.
[*]Win Rate = Percentage of profitable simulations relative to total simulations.
[*]Profit Factor = Ratio of total simulated profits to total simulated losses.
[*]Expectancy = Average expected percentage return across all simulations.
[*]Reward/Risk = Ratio of upper quartile return to lower quartile return.
[*]Asymmetry = Ratio of selected upper tail return to selected lower tail return.
[*]Skewness = Ratio of upside potential to downside risk relative to the median.
[*]Sample Size = Number of historical returns available for the current regime.
[*]Frequency = Percentage of historical returns belonging to the current regime.
[/list]
In summary, the Strategy Forecast Engine is a comprehensive forecasting tool designed to help investors evaluate the return distribution of trend-following strategies based on the current market regime. By combining regime detection with Monte Carlo simulation, the model conditions forecasts on historical returns observed during comparable market regimes to estimate the distribution of potential outcomes and their associated risk/reward characteristics. While the model provides valuable insight into historical return patterns, investors should remain mindful that historical market behavior may not necessarily persist under future market conditions.

## Source Code

````pine
// © QuantitativeAlpha
//@version=6
indicator(title = 'Strategy Forecast Engine', shorttitle = 'SFE', overlay = true, max_polylines_count = 100)
src_type = input.string('Close', 'Price Source', options = ['Close', 'HL2', 'HLC3', 'OHLC4'])
strategy_type = input.string('Combined', title = 'Strategy Type', options = ['Crossover', 'Volatility', 'Combined'])
cross_type = input.string('EMA', title = 'Crossover Type', options = ['EMA', 'SMA', 'RMA', 'WMA'])
fast_len = input.int(30, title = 'Fast Length', minval = 1)
slow_len = input.int(60, title = 'Slow Length', minval = 1)
cross_margin = input.float(0.3, title = 'Trend Margin', minval = 0.0)
vol_type = input.string('ATR', title = 'Volatility Type', options = ['ATR', 'SD', 'MAD'])
vol_length = input.int(10, title = 'Stop Length', minval = 1)
vol_factor = input.float(3.0, title = 'Stop Factor', minval = 0.1)
start_month_name = input.string('Jan', title = 'Start Month', options = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
start_year = input.int(2008, title = 'Start Year')
allow_neutral = input.bool(false, title = 'Enable Neutral Regimes')
age_conditioned = input.bool(false, title = 'Duration-Adjusted Forecast')
forecast_bars = input.int(50, title = 'Forecast Bars', minval = 1)
simulation_count = input.int(5000, title = 'Simulations', minval = 10)
tail_percentile = input.string('5%', title = 'Tail Percentile', options = ['1%', '5%', '10%'])
simulation_seed = input.int(1, title = 'Random Seed', minval = 1)
show_simulations = input.bool(true, title = 'Show Individual Simulations')
display_table = input.bool(true, title = 'Show Forecast Metrics Table')
width_input = input.int(10, title = 'Table Width', minval = 1)
table_input = input.string('Low', title = 'Table Position', options = ['High', 'Middle', 'Low'])
table_position = table_input == 'High' ? position.top_right : table_input == 'Middle' ? position.middle_right : position.bottom_right
src = src_type == 'HL2' ? hl2 : src_type == 'HLC3' ? hlc3 : src_type == 'OHLC4' ? ohlc4 : close
tail_value = tail_percentile == '1%' ? 1.0 : tail_percentile == '5%' ? 5.0 : 10.0
upper_percentile = 100.0 - tail_value
lower_percentile = tail_value
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
ready = strategy_type == 'Crossover' ? ready_cross : strategy_type == 'Volatility' ? ready_vol : ready_cross and ready_vol
total_score = strategy_type == 'Crossover' ? cross_score : strategy_type == 'Volatility' ? vol_score : ready ? cross_score + vol_score : na
regime_bull = ready and (allow_neutral ? total_score > 0 : total_score >= 0)
regime_bear = ready and total_score < 0
regime_neutral = ready and allow_neutral and total_score == 0
regime_state = regime_bull ? 1 : regime_bear ? -1 : regime_neutral ? 0 : na
start_month = start_month_name == 'Jan' ? 1 : start_month_name == 'Feb' ? 2 : start_month_name == 'Mar' ? 3 : start_month_name == 'Apr' ? 4 : start_month_name == 'May' ? 5 : start_month_name == 'Jun' ? 6 : start_month_name == 'Jul' ? 7 : start_month_name == 'Aug' ? 8 : start_month_name == 'Sep' ? 9 : start_month_name == 'Oct' ? 10 : start_month_name == 'Nov' ? 11 : 12
user_start_ts = timestamp(start_year, start_month, 1)
var int ipo_ts = na
if na(ipo_ts)
    ipo_ts := time
start_ts = math.max(user_start_ts, ipo_ts)
raw_start_bar = time >= start_ts
in_sample_bar = raw_start_bar and ready
in_sample_ret = in_sample_bar and in_sample_bar[1]
var float[] bull_returns = array.new_float()
var float[] neutral_returns = array.new_float()
var float[] bear_returns = array.new_float()
var int[] bull_return_ages = array.new_int()
var int[] neutral_return_ages = array.new_int()
var int[] bear_return_ages = array.new_int()
var int current_regime = na
var int current_regime_duration = 0
var int[] bull_durations = array.new_int()
var int[] neutral_durations = array.new_int()
var int[] bear_durations = array.new_int()
if barstate.isconfirmed and in_sample_bar and not na(regime_state)
    if na(current_regime)
        current_regime := regime_state
        current_regime_duration := 1
    else if regime_state == current_regime
        current_regime_duration += 1
    else
        if current_regime == 1
            array.push(bull_durations, current_regime_duration)
        else if current_regime == 0
            array.push(neutral_durations, current_regime_duration)
        else if current_regime == -1
            array.push(bear_durations, current_regime_duration)
        current_regime := regime_state
        current_regime_duration := 1
log_ret = math.log(close / close[1])
if barstate.isconfirmed and in_sample_ret and not na(log_ret) and not na(regime_state[1]) and not na(current_regime_duration[1])
    return_age = current_regime_duration[1]
    if regime_state[1] == 1
        array.push(bull_returns, log_ret)
        array.push(bull_return_ages, return_age)
    else if regime_state[1] == 0
        array.push(neutral_returns, log_ret)
        array.push(neutral_return_ages, return_age)
    else if regime_state[1] == -1
        array.push(bear_returns, log_ret)
        array.push(bear_return_ages, return_age)
type simulation_path
    array<float> prices
random_index(seed, max_index) =>
    max_index <= 0 ? 0 : int(math.floor(math.random(0, max_index + 1, seed)))
array_percentile(values, percentile) =>
    sorted = array.copy(values)
    array.sort(sorted, order.ascending)
    int n = array.size(sorted)
    index = int(math.round((percentile / 100.0) * (n - 1)))
    n > 0 ? array.get(sorted, index) : na
duration_percentile(durations, current_duration) =>
    int n = array.size(durations)
    int count = 0
    if n > 0
        for i = 0 to n - 1
            if array.get(durations, i) <= current_duration
                count += 1
    n > 0 ? count / n : na
get_active_returns(returns, ages, min_age) =>
    active_returns = array.new_float()
    int n = array.size(returns)
    if n > 0
        for i = 0 to n - 1
            if not age_conditioned or array.get(ages, i) >= min_age
                array.push(active_returns, array.get(returns, i))
    active_returns
var label median_label = na
var label p75_label = na
var label p25_label = na
var label upper_tail_label = na
var label lower_tail_label = na
changeLabel(value) =>
    change = value / close - 1.0
    sign = change > 0 ? '+' : change < 0 ? '-' : ''
    '(' + sign + str.tostring(math.abs(change), '#%') + ')'
label_text(name, value) =>
    name + ' = ' + str.tostring(value, '#') + ' ' + changeLabel(value)
var polyline forecast_cloud = na
var polyline median_path = na
var polyline p75_path = na
var polyline p25_path = na
var polyline upper_tail_path = na
var polyline lower_tail_path = na
var polyline[] simulation_paths = array.new<polyline>()
clear_simulations() =>
    if array.size(simulation_paths) > 0
        for i = 0 to array.size(simulation_paths) - 1
            polyline.delete(array.get(simulation_paths, i))
        array.clear(simulation_paths)
if barstate.islast
    if not na(forecast_cloud)
        polyline.delete(forecast_cloud)
    if not na(median_path)
        polyline.delete(median_path)
    if not na(p75_path)
        polyline.delete(p75_path)
    if not na(p25_path)
        polyline.delete(p25_path)
    if not na(upper_tail_path)
        polyline.delete(upper_tail_path)
    if not na(lower_tail_path)
        polyline.delete(lower_tail_path)
    label.delete(median_label)
    label.delete(p75_label)
    label.delete(p25_label)
    label.delete(upper_tail_label)
    label.delete(lower_tail_label)
    clear_simulations()
    if ready
        active_returns = regime_state == 1 ? get_active_returns(bull_returns, bull_return_ages, current_regime_duration) : regime_state == -1 ? get_active_returns(bear_returns, bear_return_ages, current_regime_duration) : get_active_returns(neutral_returns, neutral_return_ages, current_regime_duration)
        active_sample_count = array.size(active_returns)
        if active_sample_count > 1
            int win_count = 0
            int loss_count = 0
            float gross_win = 0.0
            float gross_loss = 0.0
            full_paths = array.new<simulation_path>()
            for sim = 0 to simulation_count - 1
                sim_values = array.new_float()
                sim_price = close
                for step = 1 to forecast_bars
                    seed = simulation_seed + sim * forecast_bars + step
                    sampled_return = array.get(active_returns, random_index(seed, active_sample_count - 1))
                    sim_price := sim_price * math.exp(nz(sampled_return, 0.0))
                    array.push(sim_values, sim_price)
                array.push(full_paths, simulation_path.new(sim_values))
                terminal_return = sim_price / close - 1.0
                if terminal_return > 0
                    win_count += 1
                    gross_win += terminal_return
                else if terminal_return < 0
                    loss_count += 1
                    gross_loss += math.abs(terminal_return)
            median_points = array.new<chart.point>()
            p75_points = array.new<chart.point>()
            p25_points = array.new<chart.point>()
            upper_tail_points = array.new<chart.point>()
            lower_tail_points = array.new<chart.point>()
            array.push(median_points, chart.point.from_index(bar_index, close))
            array.push(p75_points, chart.point.from_index(bar_index, close))
            array.push(p25_points, chart.point.from_index(bar_index, close))
            array.push(upper_tail_points, chart.point.from_index(bar_index, close))
            array.push(lower_tail_points, chart.point.from_index(bar_index, close))
            float final_median_value = na
            float final_p75_value = na
            float final_p25_value = na
            float final_upper_tail_value = na
            float final_lower_tail_value = na
            for step = 0 to forecast_bars - 1
                vertical_values = array.new_float()
                for sim = 0 to simulation_count - 1
                    path_values = array.get(full_paths, sim).prices
                    array.push(vertical_values, array.get(path_values, step))
                median_value = array_percentile(vertical_values, 50)
                p75_value = array_percentile(vertical_values, 75)
                p25_value = array_percentile(vertical_values, 25)
                upper_tail_value = array_percentile(vertical_values, upper_percentile)
                lower_tail_value = array_percentile(vertical_values, lower_percentile)
                if step == forecast_bars - 1
                    final_median_value := median_value
                    final_p75_value := p75_value
                    final_p25_value := p25_value
                    final_upper_tail_value := upper_tail_value
                    final_lower_tail_value := lower_tail_value
                x = bar_index + step + 1
                array.push(median_points, chart.point.from_index(x, median_value))
                array.push(p75_points, chart.point.from_index(x, p75_value))
                array.push(p25_points, chart.point.from_index(x, p25_value))
                array.push(upper_tail_points, chart.point.from_index(x, upper_tail_value))
                array.push(lower_tail_points, chart.point.from_index(x, lower_tail_value))
            int plotted_simulations = 0
            if show_simulations
                for sim = 0 to simulation_count - 1
                    if plotted_simulations < 90
                        path_values = array.get(full_paths, sim).prices
                        bool inside_range = true
                        for path_step = 0 to forecast_bars - 1
                            path_value = array.get(path_values, path_step)
                            upper_value = array.get(upper_tail_points, path_step + 1).price
                            lower_value = array.get(lower_tail_points, path_step + 1).price
                            if path_value > upper_value or path_value < lower_value
                                inside_range := false
                        if inside_range
                            sim_points = array.new<chart.point>()
                            array.push(sim_points, chart.point.from_index(bar_index, close))
                            for path_step = 0 to forecast_bars - 1
                                array.push(sim_points, chart.point.from_index(bar_index + path_step + 1, array.get(path_values, path_step)))
                            sim_poly = polyline.new(sim_points, line_color = color.new(color.gray, 80))
                            array.push(simulation_paths, sim_poly)
                            plotted_simulations += 1
            outer_points = array.new<chart.point>()
            array.push(outer_points, chart.point.from_index(bar_index, close))
            for i = 1 to array.size(upper_tail_points) - 1
                array.push(outer_points, array.get(upper_tail_points, i))
            for i = array.size(lower_tail_points) - 1 to 1
                array.push(outer_points, array.get(lower_tail_points, i))
            array.push(outer_points, chart.point.from_index(bar_index, close))
            forecast_cloud := polyline.new(outer_points, line_color = color.new(color.gray, 100), fill_color = color.new(color.gray, 90))
            median_path := polyline.new(median_points, line_color = color.white, line_width = 1, line_style = line.style_dashed)
            p75_path := polyline.new(p75_points, line_color = color.green, line_width = 1)
            p25_path := polyline.new(p25_points, line_color = color.red, line_width = 1)
            upper_tail_path := polyline.new(upper_tail_points, line_color = color.green, line_width = 1)
            lower_tail_path := polyline.new(lower_tail_points, line_color = color.red, line_width = 1)
            upper_tail_label := label.new(bar_index + forecast_bars, final_upper_tail_value, label_text(str.tostring(int(upper_percentile)) + '%', final_upper_tail_value), style = label.style_label_left, color = color.green, textcolor = color.white)
            p75_label := label.new(bar_index + forecast_bars, final_p75_value, label_text('75%', final_p75_value), style = label.style_label_left, color = color.green, textcolor = color.white)
            median_label := label.new(bar_index + forecast_bars, final_median_value, label_text('Median', final_median_value), style = label.style_label_left, color = final_median_value > close ? color.green : final_median_value < close ? color.red : color.gray, textcolor = color.white)
            p25_label := label.new(bar_index + forecast_bars, final_p25_value, label_text('25%', final_p25_value), style = label.style_label_left, color = color.red, textcolor = color.white)
            lower_tail_label := label.new(bar_index + forecast_bars, final_lower_tail_value, label_text(str.tostring(int(lower_percentile)) + '%', final_lower_tail_value), style = label.style_label_left, color = color.red, textcolor = color.white)
            durations = regime_state == 1 ? bull_durations : regime_state == -1 ? bear_durations : neutral_durations  
            duration_pct = duration_percentile(durations, current_regime_duration)
            forecast_pct = duration_percentile(durations, current_regime_duration + forecast_bars)
            total_sample_count = array.size(bull_returns) + array.size(neutral_returns) + array.size(bear_returns)
            frequency = total_sample_count > 0 ? active_sample_count / total_sample_count : na
            win_rate = simulation_count > 0 ? win_count / simulation_count : na
            loss_rate = simulation_count > 0 ? loss_count / simulation_count : na
            avg_win = win_count > 0 ? gross_win / win_count : 0.0
            avg_loss = loss_count > 0 ? gross_loss / loss_count : 0.0
            profit_factor = loss_count == 0 and win_count > 0 ? 99 : gross_loss > 0 ? gross_win / gross_loss : na
            expectancy = not na(win_rate) and not na(loss_rate) ? (win_rate * avg_win) - (loss_rate * avg_loss) : na
            p75_return = final_p75_value / close - 1.0
            p25_return = final_p25_value / close - 1.0
            upper_tail_return = final_upper_tail_value / close - 1.0
            lower_tail_return = final_lower_tail_value / close - 1.0
            reward_risk = p25_return < 0 ? p75_return / math.abs(p25_return) : p75_return > 0 ? 99 : na
            asymmetry = lower_tail_return < 0 ? upper_tail_return / math.abs(lower_tail_return) : upper_tail_return > 0 ? 99 : na
            upper_skewness = final_upper_tail_value - final_median_value
            lower_skewness = final_median_value - final_lower_tail_value
            skewness = lower_skewness > 0 ? upper_skewness / lower_skewness : na
            regime_text = regime_state == 1 ? 'Bullish' : regime_state == -1 ? 'Bearish' : 'Neutral'
            duration_text = na(duration_pct) ? '-' : str.tostring(duration_pct, '#%')
            win_rate_text = na(win_rate) ? '-' : str.tostring(win_rate, '#%')
            profit_factor_text = na(profit_factor) ? '-' : str.tostring(profit_factor, '#.#') + 'x'
            expectancy_text = na(expectancy) ? '-' : str.tostring(expectancy, '#%')
            forecast_text = na(forecast_pct) ? '-' : str.tostring(forecast_pct, '#%')
            reward_risk_text = na(reward_risk) ? '-' : str.tostring(reward_risk, '#.#') + 'x'
            asymmetry_text = na(asymmetry) ? '-' : str.tostring(asymmetry, '#.#') + 'x'
            skewness_text = na(skewness) ? '-' : str.tostring(skewness, '#.#') + 'x'
            samples_text = str.tostring(active_sample_count, '#')
            frequency_text = na(frequency) ? '-' : str.tostring(frequency, '#%')
            if display_table
                var table t = table.new(table_position, 2, 11, frame_color = color.white, frame_width = 1, border_color = color.white, border_width = 1)
                table.cell(t, 0, 0, 'Regime', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 0, regime_text, width = width_input, text_color = color.white, bgcolor = regime_state == 1 ? color.green : regime_state == -1 ? color.red : color.gray)
                table.cell(t, 0, 1, 'Duration', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 1, duration_text, width = width_input, text_color = color.white, bgcolor = duration_pct < 0.5 ? color.green : duration_pct > 0.9 ? color.red : color.gray)
                table.cell(t, 0, 2, 'Forecast', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 2, forecast_text, width = width_input, text_color = color.white, bgcolor = forecast_pct < 0.5 ? color.green : forecast_pct > 0.9 ? color.red : color.gray)
                table.cell(t, 0, 3, 'Win Rate', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 3, win_rate_text, width = width_input, text_color = color.white, bgcolor = win_rate > 0.5 ? color.green : win_rate < 0.5 ? color.red : color.gray)
                table.cell(t, 0, 4, 'Profit Factor', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 4, profit_factor_text, width = width_input, text_color = color.white, bgcolor = profit_factor > 1 ? color.green : profit_factor < 1 ? color.red : color.gray)
                table.cell(t, 0, 5, 'Expectancy', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 5, expectancy_text, width = width_input, text_color = color.white, bgcolor = expectancy > 0 ? color.green : expectancy < 0 ? color.red : color.gray)
                table.cell(t, 0, 6, 'Reward/Risk', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 6, reward_risk_text, width = width_input, text_color = color.white, bgcolor = reward_risk > 1 ? color.green : reward_risk < 1 ? color.red : color.gray)
                table.cell(t, 0, 7, 'Asymmetry', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 7, asymmetry_text, width = width_input, text_color = color.white, bgcolor = asymmetry > 1.2 ? color.green : asymmetry < 0.8 ? color.red : color.gray)
                table.cell(t, 0, 8, 'Skewness', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 8, skewness_text, width = width_input, text_color = color.white, bgcolor = skewness > 1.2 ? color.green : skewness < 0.8 ? color.red : color.gray)
                table.cell(t, 0, 9, 'Sample Size', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 9, samples_text, width = width_input, text_color = color.white, bgcolor = active_sample_count > 500 ? color.green : active_sample_count < 100 ? color.red : color.gray)
                table.cell(t, 0, 10, 'Frequency', width = width_input, text_color = color.white, bgcolor = color.rgb(0, 0, 0))
                table.cell(t, 1, 10, frequency_text, width = width_input, text_color = color.white, bgcolor = color.gray)
````
