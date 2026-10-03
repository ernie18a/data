import numpy as np

def generate_entries(features, signal_params):
    rsi_period = signal_params['rsi_period']
    pivot_left_bars = signal_params['pivot_left_bars']
    pivot_right_bars = signal_params['pivot_right_bars']
    prior_pivot_occurrence = signal_params['prior_pivot_occurrence']
    n = features.market.size
    rsi_values = np.asarray(features.rsi(rsi_period), dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    pivot_values = features.pivot_low(pivot_left_bars, pivot_right_bars, rsi_values)
    pivot_events = ~np.isnan(pivot_values)
    rsi_at_pivot = np.full(n, np.nan, dtype=np.float64)
    low_at_pivot = np.full(n, np.nan, dtype=np.float64)
    if pivot_right_bars == 0:
        rsi_at_pivot[:] = rsi_values
        low_at_pivot[:] = lows
    elif pivot_right_bars < n:
        rsi_at_pivot[pivot_right_bars:] = rsi_values[:-pivot_right_bars]
        low_at_pivot[pivot_right_bars:] = lows[:-pivot_right_bars]
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    prior_events = []
    for t in range(n):
        if pivot_events[t]:
            if len(prior_events) >= prior_pivot_occurrence:
                prior_t = prior_events[-prior_pivot_occurrence]
                long_entries[t] = rsi_at_pivot[t] > rsi_at_pivot[prior_t] and low_at_pivot[t] < low_at_pivot[prior_t]
            prior_events.append(t)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 14, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 7, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 5, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 2, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 5, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 2, 'prior_pivot_occurrence': 2}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 1}, {'rsi_period': 28, 'pivot_left_bars': 10, 'pivot_right_bars': 10, 'prior_pivot_occurrence': 2}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'rsi_bull_divergence__trend__reverse', 'hypothesis': '當價格形成更低低點、而 RSI 樞紐低點形成更高低點時做多。', 'position': 'both', 'signal_parameter_names': ['rsi_period', 'pivot_left_bars', 'pivot_right_bars', 'prior_pivot_occurrence'], 'signal_parameter_specs': [{'name': 'rsi_period', 'family': 'lookback', 'anchor': 14}, {'name': 'pivot_left_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'prior_pivot_occurrence', 'family': 'count', 'anchor': 1}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
