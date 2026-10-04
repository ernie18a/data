import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    rsi_length = signal_params['rsi_length']
    pivot_left_bars = signal_params['pivot_left_bars']
    pivot_right_bars = signal_params['pivot_right_bars']
    rsi = features.rsi(rsi_length)
    rsi_pivot_lows = features.pivot_low(pivot_left_bars, pivot_right_bars, rsi)
    lows = features.market.lows
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    previous_rsi_pivot = np.nan
    previous_price_pivot = np.nan
    for t in range(n):
        if np.isfinite(rsi_pivot_lows[t]):
            if np.isfinite(previous_rsi_pivot) and np.isfinite(previous_price_pivot) and (rsi_pivot_lows[t] > previous_rsi_pivot) and (lows[t - pivot_right_bars] < previous_price_pivot):
                long_entries[t] = True
            previous_rsi_pivot = rsi_pivot_lows[t]
            previous_price_pivot = lows[t - pivot_right_bars]
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bullish_RSI_Divergence__reversion__follow', 'hypothesis': '當已確認的價格 pivot low 下移、而 RSI pivot low 同時上移時，做多以捕捉看漲背離。', 'position': 'both', 'signal_parameter_names': ['rsi_length', 'pivot_left_bars', 'pivot_right_bars'], 'signal_parameter_specs': [{'name': 'rsi_length', 'family': 'lookback', 'anchor': 14}, {'name': 'pivot_left_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right_bars', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'rsi_length': [14, 7, 28], 'pivot_left_bars': [5, 2, 10], 'pivot_right_bars': [5, 2, 10]}}, 'generate_signals': generate_signals}
