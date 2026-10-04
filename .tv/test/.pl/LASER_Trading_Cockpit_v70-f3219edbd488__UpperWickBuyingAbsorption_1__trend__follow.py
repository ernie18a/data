import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    avg_volume_length = signal_params['avg_volume_length']
    abs_volume_mult = signal_params['abs_volume_mult']
    abs_max_body = signal_params['abs_max_body']
    abs_min_wick = signal_params['abs_min_wick']
    abs_wick_dominance = signal_params['abs_wick_dominance']
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    avg_volume = features.sma(avg_volume_length, 'volumes')
    relative_volume = np.zeros(n, dtype=np.float64)
    valid_avg = avg_volume > 0
    relative_volume[valid_avg] = volumes[valid_avg] / avg_volume[valid_avg]
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    body_pct = np.zeros(n, dtype=np.float64)
    upper_wick_pct = np.zeros(n, dtype=np.float64)
    valid_range = candle_range > 0
    body_pct[valid_range] = candle_body[valid_range] / candle_range[valid_range] * 100.0
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick_pct[valid_range] = upper_wick[valid_range] / candle_range[valid_range] * 100.0
    candle_mid = (highs + lows) / 2.0
    long_entries = ((relative_volume >= abs_volume_mult) & (body_pct <= abs_max_body) & (upper_wick_pct >= abs_min_wick) & (upper_wick >= lower_wick * abs_wick_dominance) & (closes <= candle_mid)).astype(bool)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'UpperWickBuyingAbsorption_1__trend__follow', 'hypothesis': '在成交量放大且已確認的條件下，若 K 棒實體較小、上影線夠長並明顯主導下影線，且收盤位於 K 棒中點以下，則發出 LASER Buying Absorbed 警示。', 'position': 'short', 'signal_parameter_names': ['avg_volume_length', 'abs_volume_mult', 'abs_max_body', 'abs_min_wick', 'abs_wick_dominance'], 'signal_parameter_specs': [{'name': 'avg_volume_length', 'family': 'lookback', 'anchor': 20}, {'name': 'abs_volume_mult', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'abs_max_body', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'abs_min_wick', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'abs_wick_dominance', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'avg_volume_length': [20, 10, 40], 'abs_volume_mult': [1.5, 1.0499999999999998, 2.0999999999999996], 'abs_max_body': [40.0, 30.0, 50.0], 'abs_min_wick': [35.0, 25.0, 45.0], 'abs_wick_dominance': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
