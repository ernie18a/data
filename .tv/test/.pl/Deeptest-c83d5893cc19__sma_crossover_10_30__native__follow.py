def generate_signals(features, signal_params):
    n = features.market.size
    fast_period = signal_params['sma_fast_period']
    slow_period = signal_params['sma_slow_period']
    fast_sma = features.sma(fast_period)
    slow_sma = features.sma(slow_period)
    prev_fast_sma = np.concatenate(([np.nan], fast_sma[:-1]))
    prev_slow_sma = np.concatenate(([np.nan], slow_sma[:-1]))
    long_entries = np.asarray((fast_sma > slow_sma) & (prev_fast_sma <= prev_slow_sma), dtype=bool)
    long_exits = np.asarray((fast_sma < slow_sma) & (prev_fast_sma >= prev_slow_sma), dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    short_exits = np.zeros(n, dtype=bool)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

_SIGNAL_PARAMETER_SETS = [{'sma_fast_period': 10, 'sma_slow_period': 30}, {'sma_fast_period': 10, 'sma_slow_period': 15}, {'sma_fast_period': 10, 'sma_slow_period': 60}, {'sma_fast_period': 5, 'sma_slow_period': 30}, {'sma_fast_period': 5, 'sma_slow_period': 15}, {'sma_fast_period': 5, 'sma_slow_period': 60}, {'sma_fast_period': 20, 'sma_slow_period': 30}, {'sma_fast_period': 20, 'sma_slow_period': 60}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'sma_crossover_10_30__native__follow', 'hypothesis': '收盤價的短期 SMA 上穿長期 SMA 時進場，短期 SMA 下穿長期 SMA 時平倉。', 'position': 'long', 'signal_parameter_names': ['sma_fast_period', 'sma_slow_period'], 'signal_parameter_specs': [{'name': 'sma_fast_period', 'family': 'lookback', 'anchor': 10}, {'name': 'sma_slow_period', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['sma_fast_period', 'lt', 'sma_slow_period']]}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
