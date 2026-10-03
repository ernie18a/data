def generate_entries(features, signal_params):
    n = features.market.size
    rsi_period = signal_params['rsi_period']
    pivot_left_bars = signal_params['pivot_left_bars']
    pivot_right_bars = signal_params['pivot_right_bars']
    rsi_values = features.rsi(rsi_period)
    rsi_pivots = features.pivot_low(pivot_left_bars, pivot_right_bars, rsi_values)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    previous_rsi_pivot = np.nan
    previous_price_low = np.nan
    for t in range(n):
        current_rsi_pivot = rsi_pivots[t]
        if np.isfinite(current_rsi_pivot):
            pivot_index = t - pivot_right_bars
            current_price_low = features.market.lows[pivot_index]
            if np.isfinite(previous_rsi_pivot) and np.isfinite(previous_price_low):
                long_entries[t] = current_rsi_pivot > previous_rsi_pivot and current_price_low < previous_price_low
            previous_rsi_pivot = current_rsi_pivot
            previous_price_low = current_price_low
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 5}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 2}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 10}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 5}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 2}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 10}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 5}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 2}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 10}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 5}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 2}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 10}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 5}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 2}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 10}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 5}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 2}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 10}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 5}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 2}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 10}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 5}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 2}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 10}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 5}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 2}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 10}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'rsi_bullish_divergence__reversion__follow', 'hypothesis': '以 RSI 樞紐低點高於前一次、而對應價格低點低於前一次時做多。', 'position': 'both', 'signal_parameter_names': ['rsi_period', 'pivot_left_bars', 'pivot_right_bars'], 'signal_parameter_specs': [{'name': 'rsi_period', 'family': 'lookback', 'anchor': 14}, {'name': 'pivot_left_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right_bars', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
