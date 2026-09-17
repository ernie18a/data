import numpy as np

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def _ema_update(previous, value, length):
    if not np.isfinite(value):
        return previous
    if not np.isfinite(previous):
        return float(value)
    alpha = 2.0 / (float(length) + 1.0)
    return alpha * float(value) + (1.0 - alpha) * float(previous)

def _counter_series_open(opens, closes, index, bullish, lookback):
    first_open = None
    for offset in range(1, min(index, lookback) + 1):
        candle_up = closes[index - offset] > opens[index - offset]
        candle_down = closes[index - offset] < opens[index - offset]
        if bullish and candle_down or (not bullish and candle_up):
            first_open = float(opens[index - offset])
        else:
            break
    return first_open

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    volumes = np.asarray(features.market.volumes, dtype=float).reshape(-1)
    htf_period = max(3, int(signal_params.get('htf_period', 12)))
    htf_to_ifvg_max = max(1, int(signal_params.get('htf_to_ifvg_max', 80)))
    ifvg_to_cisd_max = max(1, int(signal_params.get('ifvg_to_cisd_max', 20)))
    cisd_lookback = max(1, int(signal_params.get('cisd_lookback', 10)))
    htf_highs = []
    htf_lows = []
    htf_closes = []
    htf_bull_zones = []
    htf_bear_zones = []
    ltf_bull_zones = []
    ltf_bear_zones = []
    current_group = -1
    htf_ema9 = np.nan
    htf_ema21 = np.nan
    htf_close = np.nan
    last_bull_delivery = None
    last_bear_delivery = None
    long_ifvg_bar = None
    short_ifvg_bar = None
    long_cisd_level = None
    short_cisd_level = None
    long_cisd_armed = False
    short_cisd_armed = False
    long_cisd_triggered = False
    short_cisd_triggered = False
    vwap_price_sum = 0.0
    vwap_volume_sum = 0.0
    for t in range(size):
        high = highs[t]
        low = lows[t]
        close = closes[t]
        open_ = opens[t]
        volume = volumes[t]
        if not all((np.isfinite(x) for x in (open_, high, low, close))):
            continue
        if np.isfinite(volume) and volume > 0.0:
            typical = (high + low + close) / 3.0
            vwap_price_sum += typical * volume
            vwap_volume_sum += volume
        vwap = vwap_price_sum / vwap_volume_sum if vwap_volume_sum > 0.0 else np.nan
        group = t // htf_period
        if group != current_group:
            current_group = group
            htf_highs.append(high)
            htf_lows.append(low)
            htf_closes.append(close)
        else:
            htf_highs[-1] = max(htf_highs[-1], high)
            htf_lows[-1] = min(htf_lows[-1], low)
            htf_closes[-1] = close
        if (t + 1) % htf_period == 0:
            htf_index = len(htf_closes) - 1
            htf_close = float(htf_closes[htf_index])
            htf_ema9 = _ema_update(htf_ema9, htf_close, 9)
            htf_ema21 = _ema_update(htf_ema21, htf_close, 21)
            if htf_index >= 2:
                if htf_lows[htf_index] > htf_highs[htf_index - 2]:
                    htf_bull_zones.append([htf_lows[htf_index], htf_highs[htf_index - 2], False])
                if htf_highs[htf_index] < htf_lows[htf_index - 2]:
                    htf_bear_zones.append([htf_lows[htf_index - 2], htf_highs[htf_index], False])
        for i in range(len(htf_bull_zones) - 1, -1, -1):
            top, bottom, delivered = htf_bull_zones[i]
            if close < bottom:
                htf_bull_zones.pop(i)
            elif not delivered and low <= top and (close >= bottom):
                htf_bull_zones[i][2] = True
                last_bull_delivery = t
        for i in range(len(htf_bear_zones) - 1, -1, -1):
            top, bottom, delivered = htf_bear_zones[i]
            if close > top:
                htf_bear_zones.pop(i)
            elif not delivered and high >= bottom and (close <= top):
                htf_bear_zones[i][2] = True
                last_bear_delivery = t
        if long_ifvg_bar is not None and t - long_ifvg_bar > ifvg_to_cisd_max:
            long_cisd_armed = False
        if short_ifvg_bar is not None and t - short_ifvg_bar > ifvg_to_cisd_max:
            short_cisd_armed = False
        new_long_ifvg = False
        new_short_ifvg = False
        for i in range(len(ltf_bull_zones) - 1, -1, -1):
            top, bottom = ltf_bull_zones[i]
            if close < bottom:
                new_short_ifvg = True
                ltf_bull_zones.pop(i)
        for i in range(len(ltf_bear_zones) - 1, -1, -1):
            top, bottom = ltf_bear_zones[i]
            if close > top:
                new_long_ifvg = True
                ltf_bear_zones.pop(i)
        if t >= 2 and low > highs[t - 2]:
            ltf_bull_zones.append([low, highs[t - 2]])
        if t >= 2 and high < lows[t - 2]:
            ltf_bear_zones.append([lows[t - 2], high])
        if new_long_ifvg:
            long_ifvg_bar = t
            long_cisd_level = _counter_series_open(opens, closes, t, True, cisd_lookback)
            long_cisd_armed = long_cisd_level is not None
            long_cisd_triggered = False
        if new_short_ifvg:
            short_ifvg_bar = t
            short_cisd_level = _counter_series_open(opens, closes, t, False, cisd_lookback)
            short_cisd_armed = short_cisd_level is not None
            short_cisd_triggered = False
        htf_bull_bias = np.isfinite(htf_close) and np.isfinite(htf_ema9) and np.isfinite(htf_ema21) and (htf_ema9 > htf_ema21) and (htf_close > htf_ema21)
        htf_bear_bias = np.isfinite(htf_close) and np.isfinite(htf_ema9) and np.isfinite(htf_ema21) and (htf_ema9 < htf_ema21) and (htf_close < htf_ema21)
        long_cross = long_cisd_armed and (not long_cisd_triggered) and (long_ifvg_bar is not None) and (long_cisd_level is not None) and (last_bull_delivery is not None) and (0 <= long_ifvg_bar - last_bull_delivery <= htf_to_ifvg_max) and (0 <= t - long_ifvg_bar <= ifvg_to_cisd_max) and (close > long_cisd_level)
        if long_cross:
            if htf_bull_bias and np.isfinite(vwap) and (close > vwap):
                long_entries[t] = True
            long_cisd_triggered = True
        short_cross = short_cisd_armed and (not short_cisd_triggered) and (short_ifvg_bar is not None) and (short_cisd_level is not None) and (last_bear_delivery is not None) and (0 <= short_ifvg_bar - last_bear_delivery <= htf_to_ifvg_max) and (0 <= t - short_ifvg_bar <= ifvg_to_cisd_max) and (close < short_cisd_level)
        if short_cross:
            if htf_bear_bias and np.isfinite(vwap) and (close < vwap):
                short_entries[t] = True
            short_cisd_triggered = True
    conflict = long_entries & short_entries
    long_entries[conflict] = False
    short_entries[conflict] = False
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(size), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(size))
STRATEGY = {'strategy_id': 'tc_htf_ifvg_cisd', 'hypothesis': 'HTF FVG delivery followed by opposing LTF FVG inversion and CISD can capture trend continuation when HTF EMA and VWAP agree.', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['htf_period', 'htf_to_ifvg_max', 'ifvg_to_cisd_max', 'cisd_lookback', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'htf_period': 12, 'htf_to_ifvg_max': 80, 'ifvg_to_cisd_max': 20, 'cisd_lookback': 10, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
