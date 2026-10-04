import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    volumes = features.market.volumes
    avg_volume = features.sma(signal_params['avg_volume_length'], 'volumes')
    relative_volume = np.divide(volumes, avg_volume, out=np.zeros(n, dtype=np.float64), where=avg_volume > 0)
    candle_range = highs - lows
    body_pct = np.divide(np.abs(closes - opens) * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick_pct = np.divide(lower_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    upper_wick_pct = np.divide(upper_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    candle_mid = (highs + lows) / 2.0
    common = (relative_volume >= signal_params['relative_volume_threshold']) & (body_pct <= signal_params['max_body_pct'])
    long_entries = (common & (lower_wick_pct >= signal_params['min_wick_pct']) & (lower_wick >= upper_wick * signal_params['dominant_wick_multiplier']) & (closes >= candle_mid)).astype(bool)
    short_entries = (common & (upper_wick_pct >= signal_params['min_wick_pct']) & (upper_wick >= lower_wick * signal_params['dominant_wick_multiplier']) & (closes <= candle_mid)).astype(bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'high_volume_absorption_0__reversion__follow', 'hypothesis': '當成交量高於 20 根均量的 1.5 倍、K 棒實體較小且一側影線足夠長並占優勢時，依收盤位置辨識買方或賣方吸收訊號。', 'position': 'both', 'signal_parameter_names': ['avg_volume_length', 'relative_volume_threshold', 'max_body_pct', 'min_wick_pct', 'dominant_wick_multiplier'], 'signal_parameter_specs': [{'name': 'avg_volume_length', 'family': 'lookback', 'anchor': 20}, {'name': 'relative_volume_threshold', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'max_body_pct', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'min_wick_pct', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'dominant_wick_multiplier', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'avg_volume_length': [20, 10, 40], 'relative_volume_threshold': [1.5, 1.0499999999999998, 2.0999999999999996], 'max_body_pct': [40.0, 30.0, 50.0], 'min_wick_pct': [35.0, 25.0, 45.0], 'dominant_wick_multiplier': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
