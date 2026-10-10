import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    volume_avg_length = signal_params['volumeAvgLength']
    abs_volume_mult = signal_params['absVolumeMult']
    abs_max_body = signal_params['absMaxBody']
    abs_min_wick = signal_params['absMinWick']
    abs_wick_dominance = signal_params['absWickDominance']
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    volumes = features.market.volumes
    avg_volume = features.sma(volume_avg_length, 'volumes')
    relative_volume = np.divide(volumes, avg_volume, out=np.zeros(n, dtype=np.float64), where=avg_volume > 0)
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    body_pct = np.divide(candle_body * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick_pct = np.divide(upper_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    lower_wick_pct = np.divide(lower_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    candle_mid = (highs + lows) / 2.0
    common = (relative_volume >= abs_volume_mult) & (body_pct <= abs_max_body)
    long_entries = (common & (lower_wick_pct >= abs_min_wick) & (lower_wick >= upper_wick * abs_wick_dominance) & (closes >= candle_mid)).astype(bool)
    short_entries = (common & (upper_wick_pct >= abs_min_wick) & (upper_wick >= lower_wick * abs_wick_dominance) & (closes <= candle_mid)).astype(bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'high_volume_wick_absorption_1__trend', 'hypothesis': '以高相對成交量、較小實體與占優影線辨識吸收，並依收盤位於 K 棒中點上方或下方決定做多或做空。', 'position': 'both', 'signal_parameter_names': ['volumeAvgLength', 'absVolumeMult', 'absMaxBody', 'absMinWick', 'absWickDominance'], 'signal_parameter_specs': [{'name': 'volumeAvgLength', 'family': 'lookback', 'anchor': 20}, {'name': 'absVolumeMult', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'absMaxBody', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'absMinWick', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'absWickDominance', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'volumeAvgLength': [20, 10, 40], 'absVolumeMult': [1.5, 1.0499999999999998, 2.0999999999999996], 'absMaxBody': [40.0, 30.0, 50.0], 'absMinWick': [35.0, 25.0, 45.0], 'absWickDominance': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
