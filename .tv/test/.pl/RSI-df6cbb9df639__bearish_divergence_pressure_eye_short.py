import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _number(params, name, default):
    try:
        value = float(params.get(name, default))
    except (AttributeError, TypeError, ValueError):
        value = float(default)
    return value if np.isfinite(value) else float(default)

def _rolling_mean_std(values, length):
    mean = np.full(values.size, np.nan, dtype=float)
    std = np.full(values.size, np.nan, dtype=float)
    for end in range(length - 1, values.size):
        window = values[end - length + 1:end + 1]
        if np.all(np.isfinite(window)):
            mean[end] = np.mean(window)
            std[end] = np.std(window, ddof=0)
    return (mean, std)

def _path_is_clean(values, first_bar, first_value, last_bar, last_value, is_high, tolerance, edge_skip):
    span = last_bar - first_bar
    if span < 2:
        return True
    skip = min(max(0, edge_skip), (span - 1) // 4)
    maximum = max(first_value, last_value)
    minimum = min(first_value, last_value)
    for bar in range(first_bar + 1, last_bar):
        value = values[bar]
        if not np.isfinite(value):
            return False
        line_value = first_value + (last_value - first_value) * ((bar - first_bar) / span)
        middle = bar >= first_bar + 1 + skip and bar <= last_bar - 1 - skip
        if is_high:
            if value > maximum + tolerance or (middle and value > line_value + tolerance):
                return False
        elif value < minimum - tolerance or (middle and value < line_value - tolerance):
            return False
    return True

def _right_price_ok(is_high, endpoint, right_extreme, atr_at_endpoint, tolerance_pct):
    if not np.isfinite(endpoint) or not np.isfinite(right_extreme):
        return False
    percentage_tolerance = abs(endpoint) * tolerance_pct / 100.0
    if np.isfinite(atr_at_endpoint):
        tolerance = max(1e-10, min(percentage_tolerance, atr_at_endpoint * 0.15))
    else:
        tolerance = max(1e-10, percentage_tolerance)
    return right_extreme <= endpoint + tolerance if is_high else right_extreme >= endpoint - tolerance

def _blocked(strict_any, near_price, near_close, near_rsi, pair_price, pair_close, current_price, current_close):
    price_block = (not current_price or (pair_price and near_price)) and (not current_close or (pair_close and near_close))
    return near_rsi or price_block if strict_any else near_rsi and price_block

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if highs.size != size or lows.size != size or closes.size != size:
        raise ValueError('market OHLC arrays must have length market.size')
    rsi_length = max(2, int(round(_number(signal_params, 'rsi_length', 14))))
    pivot_left = max(1, int(round(_number(signal_params, 'pivot_left', 4))))
    pivot_right = max(1, int(round(_number(signal_params, 'pivot_right', 1))))
    min_gap = max(1, int(round(_number(signal_params, 'min_gap', 5))))
    max_gap = max(min_gap, int(round(_number(signal_params, 'max_gap', 60))))
    pivot_lookback = max(1, int(round(_number(signal_params, 'pivot_lookback', 4))))
    eye_length = max(2, int(round(_number(signal_params, 'eye_length', 20))))
    eye_multiplier = max(0.1, _number(signal_params, 'eye_std_multiplier', 2.0))
    edge_skip = max(0, int(round(_number(signal_params, 'edge_skip', 0))))
    rsi_tolerance = max(0.0, _number(signal_params, 'rsi_path_tolerance', 1.5))
    price_tolerance = max(0.0, _number(signal_params, 'price_path_tolerance_pct', 0.5))
    min_rsi_difference = max(0.0, _number(signal_params, 'min_rsi_difference', 0.0))
    strict = bool(signal_params.get('strict', True))
    strict_any = bool(signal_params.get('strict_any', False))
    check_osc_path = bool(signal_params.get('check_osc_path', True))
    check_price_path = bool(signal_params.get('check_price_path', True))
    eye_wick = bool(signal_params.get('eye_wick', True))
    overbought_only = bool(signal_params.get('overbought_only', False))
    rsi = np.asarray(features.rsi(rsi_length), dtype=float).reshape(-1)
    atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
    if rsi.size != size or atr.size != size:
        raise ValueError('feature arrays must have length market.size')
    _, eye_deviation = _rolling_mean_std(closes, eye_length)
    eye_basis, _ = _rolling_mean_std(closes, eye_length)
    eye_upper = eye_basis + eye_multiplier * eye_deviation
    eye_series = highs if eye_wick else closes
    short_entries = np.zeros(size, dtype=np.bool_)
    long_entries = np.zeros(size, dtype=np.bool_)
    eye_origins = set()
    divergence_origins = set()
    emitted_origins = set()
    high_history = []
    eye_active = False
    eye_extreme = np.nan
    eye_extreme_bar = -1
    for t in range(size):
        outside = np.isfinite(eye_series[t]) and np.isfinite(eye_upper[t]) and (eye_series[t] > eye_upper[t])
        was_active = eye_active
        if outside and (not eye_active or not np.isfinite(eye_extreme) or highs[t] > eye_extreme):
            eye_extreme = highs[t]
            eye_extreme_bar = t
        eye_hit = was_active and (not outside)
        eye_origin = eye_extreme_bar if eye_hit else -1
        if eye_hit and eye_origin >= 0:
            eye_origins.add(eye_origin)
        eye_active = outside
        current_bar = t - pivot_right
        divergence = False
        if current_bar >= pivot_left and current_bar + pivot_right == t:
            rsi_window = rsi[current_bar - pivot_left:t + 1]
            if np.all(np.isfinite(rsi_window)):
                current_rsi = rsi[current_bar]
                is_pivot_high = current_rsi >= np.max(rsi_window)
                if is_pivot_high:
                    current_high = highs[current_bar]
                    current_close = closes[current_bar]
                    right_high = np.max(highs[current_bar + 1:t + 1])
                    right_close = np.max(closes[current_bar + 1:t + 1])
                    current_price_ok = _right_price_ok(True, current_high, right_high, atr[current_bar], price_tolerance)
                    current_close_ok = _right_price_ok(True, current_close, right_close, atr[current_bar], price_tolerance)
                    done_regular = not (current_price_ok or current_close_ok)
                    done_hidden = not (current_price_ok or current_close_ok)
                    for old in reversed(high_history):
                        if done_regular and done_hidden:
                            break
                        gap = current_bar - old['bar']
                        if gap > max_gap:
                            break
                        pair_price = current_price_ok and old['price_ok']
                        pair_close = current_close_ok and old['close_ok']
                        pairable = min_gap <= gap <= max_gap
                        old_rsi = old['rsi']
                        regular = False
                        if not done_regular and pairable and (not overbought_only or current_rsi >= 70.0):
                            osc_ok = not check_osc_path or _path_is_clean(rsi, old['bar'], old_rsi, current_bar, current_rsi, True, rsi_tolerance, edge_skip)
                            price_ok = pair_price and current_high > old['high'] and (not check_price_path or _path_is_clean(highs, old['bar'], old['high'], current_bar, current_high, True, abs(old['high']) * price_tolerance / 100.0, edge_skip))
                            close_ok = pair_close and current_close > old['close'] and (not check_price_path or _path_is_clean(closes, old['bar'], old['close'], current_bar, current_close, True, abs(old['close']) * price_tolerance / 100.0, edge_skip))
                            regular = old_rsi > current_rsi and old_rsi - current_rsi >= min_rsi_difference and osc_ok and (price_ok or close_ok)
                        if regular:
                            divergence = True
                            done_regular = True
                            done_hidden = True
                        elif not done_regular and strict:
                            near_price = pair_price and old['high'] > current_high
                            near_close = pair_close and old['close'] > current_close
                            near_rsi = old_rsi < current_rsi
                            if _blocked(strict_any, near_price, near_close, near_rsi, pair_price, pair_close, current_price_ok, current_close_ok):
                                done_regular = True
                        if not done_hidden:
                            hidden = False
                            if pairable:
                                osc_ok = not check_osc_path or _path_is_clean(rsi, old['bar'], old_rsi, current_bar, current_rsi, True, rsi_tolerance, edge_skip)
                                price_ok = pair_price and current_high < old['high'] and (not check_price_path or _path_is_clean(highs, old['bar'], old['high'], current_bar, current_high, True, abs(old['high']) * price_tolerance / 100.0, edge_skip))
                                close_ok = pair_close and current_close < old['close'] and (not check_price_path or _path_is_clean(closes, old['bar'], old['close'], current_bar, current_close, True, abs(old['close']) * price_tolerance / 100.0, edge_skip))
                                hidden = old_rsi < current_rsi and current_rsi - old_rsi >= min_rsi_difference and osc_ok and (price_ok or close_ok)
                            if hidden:
                                divergence = True
                                done_hidden = True
                                done_regular = True
                            elif strict:
                                near_price = pair_price and old['high'] < current_high
                                near_close = pair_close and old['close'] < current_close
                                near_rsi = old_rsi > current_rsi
                                if _blocked(strict_any, near_price, near_close, near_rsi, pair_price, pair_close, current_price_ok, current_close_ok):
                                    done_hidden = True
                    if current_price_ok or current_close_ok:
                        high_history.append({'bar': current_bar, 'high': current_high, 'close': current_close, 'rsi': current_rsi, 'price_ok': current_price_ok, 'close_ok': current_close_ok})
                        if len(high_history) > pivot_lookback:
                            high_history.pop(0)
        if divergence:
            divergence_origins.add(current_bar)
        candidate = current_bar if divergence and current_bar in eye_origins else eye_origin if eye_hit and eye_origin in divergence_origins else -1
        if candidate >= 0 and candidate not in emitted_origins:
            short_entries[t] = True
            emitted_origins.add(candidate)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {**signal_params, 'k_base': 2.0, 'mult': 2.0})
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'bearish_divergence_pressure_eye_short', 'hypothesis': '價格高點與 RSI 頂背離或隱性頂背離，若同一極值又完成連續布林上軌越界的壓力眼，可能代表上行動能衰竭並有利於做空。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_length', 'pivot_left', 'pivot_right', 'min_gap', 'max_gap', 'pivot_lookback', 'eye_length', 'eye_std_multiplier', 'edge_skip', 'rsi_path_tolerance', 'price_path_tolerance_pct', 'min_rsi_difference', 'k_base', 'mult'], 'signal_parameter_sets': [{'rsi_length': 14, 'pivot_left': 4, 'pivot_right': 1, 'min_gap': 5, 'max_gap': 60, 'pivot_lookback': 4, 'eye_length': 20, 'eye_std_multiplier': 2.0, 'edge_skip': 0, 'rsi_path_tolerance': 1.5, 'price_path_tolerance_pct': 0.5, 'min_rsi_difference': 0.0, 'k_base': 2.0, 'mult': 2.0}]}
