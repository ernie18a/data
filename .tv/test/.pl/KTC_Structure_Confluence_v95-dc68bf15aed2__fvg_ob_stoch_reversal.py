import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    volumes = np.asarray(market.volumes, dtype=np.float64)
    del volumes, signal_params

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    atr = np.asarray(features.atr(14), dtype=np.float64)
    ema50 = np.asarray(features.ema(50), dtype=np.float64)
    ema100 = np.asarray(features.ema(100), dtype=np.float64)
    ema200 = np.asarray(features.ema(200), dtype=np.float64)

    def sma(values, length):
        result = np.full(size, np.nan, dtype=np.float64)
        for index in range(length - 1, size):
            window = values[index - length + 1:index + 1]
            if np.all(np.isfinite(window)):
                result[index] = np.mean(window)
        return result

    k_raw = np.full(size, np.nan, dtype=np.float64)
    for t in range(8, size):
        window_high = np.max(highs[t - 8:t + 1])
        window_low = np.min(lows[t - 8:t + 1])
        denominator = window_high - window_low
        if denominator > 0.0 and np.isfinite(denominator):
            k_raw[t] = 100.0 * (closes[t] - window_low) / denominator
    k_line = sma(k_raw, 3)
    d_line = sma(k_line, 3)

    fvg_top = []
    fvg_bottom = []
    fvg_bull = []
    fvg_arm = []
    ob_top = []
    ob_bottom = []
    ob_bull = []
    ob_breaker = []
    ob_frozen = []
    ob_has_left = []
    ob_was_in = []
    ob_retests = []
    ob_source = []

    sr_price = []
    sr_body = []
    sr_type = []
    sr_state = []
    sr_break_bar = []
    sr_created = []

    trade_dir = 0
    trade_signal_bar = -1
    trade_entry = 0.0
    trade_stop = 0.0
    trade_be = 0.0
    trade_tp1 = 0.0
    trade_tp3 = 0.0
    trade_be_on = False

    for t in range(size):
        current_atr = atr[t] if t < size else np.nan

        if t >= 2 and np.isfinite(current_atr):
            bull_gap = lows[t] - highs[t - 2]
            bear_gap = lows[t - 2] - highs[t]
            if lows[t] > highs[t - 2] and bull_gap >= 0.20 * current_atr:
                fvg_top.append(lows[t])
                fvg_bottom.append(highs[t - 2])
                fvg_bull.append(True)
                fvg_arm.append(-1)
            if highs[t] < lows[t - 2] and bear_gap >= 0.20 * current_atr:
                fvg_top.append(lows[t - 2])
                fvg_bottom.append(highs[t])
                fvg_bull.append(False)
                fvg_arm.append(-1)

        next_fvg_top = []
        next_fvg_bottom = []
        next_fvg_bull = []
        next_fvg_arm = []
        for i in range(len(fvg_top)):
            top = fvg_top[i]
            bottom = fvg_bottom[i]
            is_bull = fvg_bull[i]
            arm_bar = fvg_arm[i]
            touched = lows[t] <= top and highs[t] >= bottom
            if touched:
                arm_bar = t
            if is_bull:
                if lows[t] < top and lows[t] > bottom:
                    top = lows[t]
                if lows[t] <= bottom:
                    continue
            else:
                if highs[t] > bottom and highs[t] < top:
                    bottom = highs[t]
                if highs[t] >= top:
                    continue
            next_fvg_top.append(top)
            next_fvg_bottom.append(bottom)
            next_fvg_bull.append(is_bull)
            next_fvg_arm.append(arm_bar)
        fvg_top = next_fvg_top
        fvg_bottom = next_fvg_bottom
        fvg_bull = next_fvg_bull
        fvg_arm = next_fvg_arm

        if t >= 2 and np.isfinite(current_atr):
            classic_bull = closes[t - 2] < opens[t - 2] and closes[t - 1] > opens[t - 1] and lows[t] > highs[t - 2]
            classic_bear = closes[t - 2] > opens[t - 2] and closes[t - 1] < opens[t - 1] and highs[t] < lows[t - 2]
            narrow = (highs[t - 2] - lows[t - 2]) < 2.0 * current_atr
            if narrow and classic_bull:
                ob_top.append(highs[t - 2])
                ob_bottom.append(lows[t - 2])
                ob_bull.append(True)
                ob_breaker.append(False)
                ob_frozen.append(False)
                ob_has_left.append(False)
                ob_was_in.append(False)
                ob_retests.append(0)
                ob_source.append(t)
            if narrow and classic_bear:
                ob_top.append(highs[t - 2])
                ob_bottom.append(lows[t - 2])
                ob_bull.append(False)
                ob_breaker.append(False)
                ob_frozen.append(False)
                ob_has_left.append(False)
                ob_was_in.append(False)
                ob_retests.append(0)
                ob_source.append(t)

        best_bull_top = np.nan
        best_bull_bottom = np.nan
        best_bear_top = np.nan
        best_bear_bottom = np.nan
        in_bull_ob = False
        in_bear_ob = False
        for i in range(len(ob_top)):
            if ob_frozen[i]:
                continue
            top = ob_top[i]
            bottom = ob_bottom[i]
            is_bull = ob_bull[i]
            touched = lows[t] <= top and highs[t] >= bottom
            active = ob_has_left[i] and touched
            if active and is_bull:
                in_bull_ob = True
                if not in_bull_ob or np.isnan(best_bull_bottom) or bottom > best_bull_bottom:
                    best_bull_top = top
                    best_bull_bottom = bottom
            elif active and not is_bull:
                in_bear_ob = True
                if np.isnan(best_bear_top) or top < best_bear_top:
                    best_bear_top = top
                    best_bear_bottom = bottom

            new_retest = touched and not ob_was_in[i]
            if new_retest:
                ob_retests[i] += 1
            ob_was_in[i] = touched
            if t > ob_source[i] and not touched:
                ob_has_left[i] = True

            invalid = closes[t] < bottom if is_bull else closes[t] > top
            if invalid and ob_has_left[i]:
                if not ob_breaker[i]:
                    ob_bull[i] = not is_bull
                    ob_breaker[i] = True
                    ob_retests[i] = 0
                    ob_was_in[i] = False
                    ob_has_left[i] = False
                else:
                    ob_frozen[i] = True

        bull_box_ok = (
            not np.isnan(best_bull_top) and not np.isnan(best_bull_bottom)
            and best_bull_top - best_bull_bottom >= 75.0 * 0.01
        )
        bear_box_ok = (
            not np.isnan(best_bear_top) and not np.isnan(best_bear_bottom)
            and best_bear_top - best_bear_bottom >= 75.0 * 0.01
        )

        touching_support = False
        touching_resistance = False
        if t >= 14 and np.isfinite(current_atr):
            pivot = t - 7
            pivot_window_high = highs[t - 14:t + 1]
            pivot_window_low = lows[t - 14:t + 1]
            if highs[pivot] == np.max(pivot_window_high):
                body_high = max(opens[pivot], closes[pivot])
                merged = -1
                for i in range(len(sr_price)):
                    if sr_type[i] == -1 and sr_state[i] == 0 and abs(sr_price[i] - highs[pivot]) <= current_atr * 0.20:
                        merged = i
                        break
                if merged >= 0:
                    sr_price[merged] = max(sr_price[merged], highs[pivot])
                    sr_body[merged] = max(sr_body[merged], body_high)
                else:
                    sr_price.append(highs[pivot])
                    sr_body.append(body_high)
                    sr_type.append(-1)
                    sr_state.append(0)
                    sr_break_bar.append(-1)
                    sr_created.append(pivot)
            if lows[pivot] == np.min(pivot_window_low):
                body_low = min(opens[pivot], closes[pivot])
                merged = -1
                for i in range(len(sr_price)):
                    if sr_type[i] == 1 and sr_state[i] == 0 and abs(sr_price[i] - lows[pivot]) <= current_atr * 0.20:
                        merged = i
                        break
                if merged >= 0:
                    sr_price[merged] = min(sr_price[merged], lows[pivot])
                    sr_body[merged] = min(sr_body[merged], body_low)
                else:
                    sr_price.append(lows[pivot])
                    sr_body.append(body_low)
                    sr_type.append(1)
                    sr_state.append(0)
                    sr_break_bar.append(-1)
                    sr_created.append(pivot)

        i = len(sr_price) - 1
        while i >= 0:
            price = sr_price[i]
            body_level = sr_body[i]
            level_type = sr_type[i]
            state = sr_state[i]
            break_level = (price + body_level) / 2.0
            break_buffer = current_atr * 0.10
            retest_tolerance = current_atr * 0.15
            body_ok = current_atr > 0.0 and abs(closes[t] - opens[t]) >= current_atr * 0.20
            if state == 0:
                resistance_broken = level_type == -1 and closes[t] > break_level + break_buffer and body_ok
                support_broken = level_type == 1 and closes[t] < break_level - break_buffer and body_ok
                touch = lows[t] <= body_level + retest_tolerance and highs[t] >= body_level - retest_tolerance
                if resistance_broken or support_broken:
                    sr_state[i] = 1
                    sr_break_bar[i] = t
                elif touch:
                    if level_type == 1:
                        touching_support = True
                    else:
                        touching_resistance = True
            else:
                if t - sr_break_bar[i] > 25:
                    del sr_price[i], sr_body[i], sr_type[i], sr_state[i], sr_break_bar[i], sr_created[i]
                    i -= 1
                    continue
                if t > sr_break_bar[i]:
                    touch = lows[t] <= body_level + retest_tolerance and highs[t] >= body_level - retest_tolerance
                    if level_type == -1 and touch and closes[t] > break_level:
                        sr_type[i] = 1
                        sr_state[i] = 0
                        sr_created[i] = t
                    elif level_type == 1 and touch and closes[t] < break_level:
                        sr_type[i] = -1
                        sr_state[i] = 0
                        sr_created[i] = t
            i -= 1

        for level_type in (1, -1):
            indices = [i for i in range(len(sr_price)) if sr_type[i] == level_type]
            while len(indices) > 4:
                oldest = min(indices, key=lambda index: sr_created[index])
                del sr_price[oldest], sr_body[oldest], sr_type[oldest], sr_state[oldest], sr_break_bar[oldest], sr_created[oldest]
                indices = [i for i in range(len(sr_price)) if sr_type[i] == level_type]

        stoch_bull = False
        stoch_bear = False
        if t >= 13 and np.isfinite(k_line[t]) and np.isfinite(d_line[t]) and np.isfinite(k_line[t - 1]) and np.isfinite(d_line[t - 1]):
            recent_k = k_line[t - 4:t + 1]
            if np.all(np.isfinite(recent_k)):
                stoch_bull = k_line[t] > d_line[t] and k_line[t - 1] <= d_line[t - 1] and np.min(recent_k) <= 20.0
                stoch_bear = k_line[t] < d_line[t] and k_line[t - 1] >= d_line[t - 1] and np.max(recent_k) >= 80.0

        bull_fvg_ready = any(fvg_bull[i] and 1 <= t - fvg_arm[i] <= 3 for i in range(len(fvg_top)) if fvg_arm[i] >= 0)
        bear_fvg_ready = any((not fvg_bull[i]) and 1 <= t - fvg_arm[i] <= 3 for i in range(len(fvg_top)) if fvg_arm[i] >= 0)
        bull_trend = t >= 199 and np.isfinite(ema200[t]) and np.isfinite(ema50[t]) and np.isfinite(ema100[t]) and closes[t] > ema200[t] and ema50[t] > ema100[t]
        bear_trend = t >= 199 and np.isfinite(ema200[t]) and np.isfinite(ema50[t]) and np.isfinite(ema100[t]) and closes[t] < ema200[t] and ema50[t] < ema100[t]

        bull_pa = False
        bear_pa = False
        if t >= 1:
            bull_pa = (closes[t] > opens[t] and closes[t - 1] < opens[t - 1] and closes[t] >= opens[t - 1] and opens[t] <= closes[t - 1])
            bear_pa = (closes[t] < opens[t] and closes[t - 1] > opens[t - 1] and closes[t] <= opens[t - 1] and opens[t] >= closes[t - 1])
            candle_range = highs[t] - lows[t]
            if candle_range > 0.0:
                bull_pa = bull_pa or (min(opens[t], closes[t]) - lows[t] >= candle_range * 0.55 and highs[t] - max(opens[t], closes[t]) <= candle_range * 0.20)
                bear_pa = bear_pa or (highs[t] - max(opens[t], closes[t]) >= candle_range * 0.55 and min(opens[t], closes[t]) - lows[t] <= candle_range * 0.20)
        if t >= 2:
            middle_body = abs(closes[t - 1] - opens[t - 1])
            middle_range = highs[t - 1] - lows[t - 1]
            doji = middle_range > 0.0 and middle_body <= middle_range * 0.25
            bull_pa = bull_pa or (closes[t - 2] < opens[t - 2] and doji and closes[t] > opens[t] and closes[t] >= opens[t - 2] + (closes[t - 2] - opens[t - 2]) * -0.60)
            bear_pa = bear_pa or (closes[t - 2] > opens[t - 2] and doji and closes[t] < opens[t] and closes[t] <= opens[t - 2] + (closes[t - 2] - opens[t - 2]) * -0.60)

        bull_core = bull_fvg_ready and in_bull_ob and bull_box_ok and stoch_bull
        bear_core = bear_fvg_ready and in_bear_ob and bear_box_ok and stoch_bear
        bull_rank = (1 + int(bull_trend) + int(touching_support) + int(bull_pa)) if bull_core else 0
        bear_rank = (1 + int(bear_trend) + int(touching_resistance) + int(bear_pa)) if bear_core else 0

        if trade_dir != 0 and t > trade_signal_bar:
            if trade_dir == 1 and highs[t] >= trade_tp1:
                trade_be_on = True
            if trade_dir == -1 and lows[t] <= trade_tp1:
                trade_be_on = True
            stop_now = trade_be if trade_be_on else trade_stop
            hit_stop = (lows[t] <= stop_now) if trade_dir == 1 else (highs[t] >= stop_now)
            hit_tp3 = (highs[t] >= trade_tp3) if trade_dir == 1 else (lows[t] <= trade_tp3)
            if hit_stop or hit_tp3:
                if trade_dir == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                trade_dir = 0

        if bull_rank > bear_rank:
            long_entries[t] = True
            trade_dir = 1
            trade_signal_bar = t
            trade_entry = best_bull_top
            trade_stop = best_bull_bottom
            trade_be = trade_entry + 0.50
            risk = abs(trade_entry - trade_stop)
            trade_tp1 = trade_entry + risk
            trade_tp3 = trade_entry + risk * 3.0
            trade_be_on = False
        elif bear_rank > bull_rank:
            short_entries[t] = True
            trade_dir = -1
            trade_signal_bar = t
            trade_entry = best_bear_bottom
            trade_stop = best_bear_top
            trade_be = trade_entry - 0.50
            risk = abs(trade_entry - trade_stop)
            trade_tp1 = trade_entry - risk
            trade_tp3 = trade_entry - risk * 3.0
            trade_be_on = False

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    'strategy_id': 'fvg_ob_stoch_reversal',
    'hypothesis': 'A prior fair-value-gap interaction, a retested order block, and an oversold or overbought stochastic reversal identify directional reversals.',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
