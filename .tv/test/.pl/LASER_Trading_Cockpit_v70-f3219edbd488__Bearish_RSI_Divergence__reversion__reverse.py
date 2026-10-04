import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    rsi_length = int(signal_params['rsi_length'])
    pivot_left_bars = int(signal_params['pivot_left_bars'])
    pivot_right_bars = int(signal_params['pivot_right_bars'])
    rsi = features.rsi(rsi_length)
    rsi_pivot_highs = features.pivot_high(pivot_left_bars, pivot_right_bars, rsi)
    pivot_price_highs = np.full(n, np.nan, dtype=np.float64)
    if pivot_right_bars < n:
        pivot_price_highs[pivot_right_bars:] = features.market.highs[:n - pivot_right_bars]
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    has_previous_pivot = False
    previous_rsi_pivot = np.nan
    previous_price_pivot = np.nan
    for t in range(n):
        if np.isfinite(rsi_pivot_highs[t]):
            current_rsi_pivot = rsi_pivot_highs[t]
            current_price_pivot = pivot_price_highs[t]
            if has_previous_pivot:
                short_entries[t] = current_rsi_pivot < previous_rsi_pivot and current_price_pivot > previous_price_pivot
            previous_rsi_pivot = current_rsi_pivot
            previous_price_pivot = current_price_pivot
            has_previous_pivot = True
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bearish_RSI_Divergence__reversion__reverse', 'hypothesis': '價格創出較高的已確認高點而 RSI 創出較低的已確認高點時做空，並以 RSI 背離作為輔助確認。', 'position': 'both', 'signal_parameter_names': ['rsi_length', 'pivot_left_bars', 'pivot_right_bars'], 'signal_parameter_specs': [{'name': 'rsi_length', 'family': 'lookback', 'anchor': 14}, {'name': 'pivot_left_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right_bars', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'rsi_length': [14, 7, 28], 'pivot_left_bars': [5, 2, 10], 'pivot_right_bars': [5, 2, 10]}}, 'generate_signals': generate_signals}
