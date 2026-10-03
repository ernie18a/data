import numpy as np

def generate_entries(features, signal_params):
    range_lookback = signal_params['range_lookback']
    sma_lookback = signal_params['sma_lookback']
    linreg_lookback = signal_params['linreg_lookback']
    linreg_offset = signal_params['linreg_offset']
    n = features.market.size
    closes = features.market.closes
    range_mid = (features.highest(range_lookback) + features.lowest(range_lookback)) / 2.0
    center = (range_mid + features.sma(sma_lookback)) / 2.0
    source = closes - center
    regression = features.linreg(linreg_lookback, source).astype(np.float64, copy=True)
    length = linreg_lookback
    x = np.arange(length, dtype=np.float64)
    denominator = np.sum((x - np.mean(x)) ** 2)
    for t in range(length - 1, n):
        window = source[t - length + 1:t + 1]
        if np.all(np.isfinite(window)) and np.isfinite(regression[t]):
            slope = np.sum((x - np.mean(x)) * window) / denominator
            regression[t] -= slope * linreg_offset
        else:
            regression[t] = np.nan
    short_entries = np.zeros(n, dtype=bool)
    short_entries[1:] = (regression[1:] < 0.0) & (regression[:-1] >= 0.0)
    long_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 20, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 10, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 20, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 10, 'linreg_lookback': 40, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 20, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 10, 'linreg_offset': 2}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 1}, {'range_lookback': 40, 'sma_lookback': 40, 'linreg_lookback': 40, 'linreg_offset': 2}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'sqz_momentum_cross_down__reversion__follow', 'hypothesis': '當價格相對於近期高低區間中點與收盤均線的偏差線向下穿越零軸時做空。', 'position': 'both', 'signal_parameter_names': ['range_lookback', 'sma_lookback', 'linreg_lookback', 'linreg_offset'], 'signal_parameter_specs': [{'name': 'range_lookback', 'family': 'lookback', 'anchor': 20}, {'name': 'sma_lookback', 'family': 'lookback', 'anchor': 20}, {'name': 'linreg_lookback', 'family': 'lookback', 'anchor': 20}, {'name': 'linreg_offset', 'family': 'count', 'anchor': 1}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
