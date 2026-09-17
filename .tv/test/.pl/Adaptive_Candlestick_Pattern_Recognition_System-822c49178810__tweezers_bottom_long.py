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

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, np.zeros(size, dtype=np.bool_), short_entries, np.zeros(size, dtype=np.bool_))
    opens = np.asarray(features.market.opens)
    highs = np.asarray(features.market.highs)
    lows = np.asarray(features.market.lows)
    closes = np.asarray(features.market.closes)
    tweezer_tol = float(signal_params.get('i_TweezerTol', 0.025))
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    moving_average = np.asarray(features.sma(ma_length))
    previous_range = highs[:-1] - lows[:-1]
    previous_bullish = closes[:-1] >= opens[:-1]
    latest_bullish = closes[1:] >= opens[1:]
    alternating_colors = previous_bullish != latest_bullish
    matching_lows = np.abs(lows[1:] - lows[:-1]) <= previous_range * tweezer_tol
    downtrend = closes[1:] < moving_average[1:]
    finite = np.isfinite(opens[1:]) & np.isfinite(highs[1:]) & np.isfinite(lows[1:]) & np.isfinite(closes[1:]) & np.isfinite(previous_range) & np.isfinite(moving_average[1:]) & (previous_range >= 0.0)
    long_entries[1:] = alternating_colors & matching_lows & downtrend & finite
    exit_params = dict(signal_params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'tweezers_bottom_long', 'hypothesis': '下行趨勢中的低點近似且顏色交替形態可能帶來多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_TweezerTol', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_TweezerTol': 0.025, 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
