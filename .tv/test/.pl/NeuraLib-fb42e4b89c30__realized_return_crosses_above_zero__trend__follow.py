import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    closes = np.asarray(features.market.closes, dtype=np.float64)
    prev_close = np.concatenate((np.full(1, np.nan), closes[:-1]))
    prev_prev_close = np.concatenate((np.full(2, np.nan), closes[:-2]))[:n]
    r = (closes - prev_close) / np.maximum(np.abs(prev_close), 1e-07)
    prev_r = (prev_close - prev_prev_close) / np.maximum(np.abs(prev_prev_close), 1e-07)
    long_entries = np.asarray((r > 0) & (prev_r <= 0), dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'realized_return_crosses_above_zero__trend__follow', 'hypothesis': '當本根報酬由非正轉正時做多。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
