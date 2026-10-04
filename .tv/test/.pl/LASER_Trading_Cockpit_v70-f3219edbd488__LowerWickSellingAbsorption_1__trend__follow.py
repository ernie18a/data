import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    volumes = features.market.volumes
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    avg_volume = features.sma(signal_params['avg_volume_length'], 'volumes')
    relative_volume = np.divide(volumes, avg_volume, out=np.zeros(n, dtype=np.float64), where=avg_volume > 0)
    candle_range = highs - lows
    body_pct = np.divide(np.abs(closes - opens) * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    lower_wick_pct = np.divide(lower_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    candle_mid = (highs + lows) / 2.0
    long_entries = ((relative_volume >= signal_params['relative_volume_min']) & (body_pct <= signal_params['max_body_pct']) & (lower_wick_pct >= signal_params['min_lower_wick_pct']) & (lower_wick >= upper_wick * signal_params['lower_wick_dominance']) & (closes >= candle_mid)).astype(bool)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'LowerWickSellingAbsorption_1__trend__follow', 'hypothesis': '當成交量達均量的指定倍數、K 線實體占比受限且下影線占比與相對上影線優勢達標時，於收盤位於 K 線中點以上發出吸收賣方警示。', 'position': 'long', 'signal_parameter_names': ['avg_volume_length', 'relative_volume_min', 'max_body_pct', 'min_lower_wick_pct', 'lower_wick_dominance'], 'signal_parameter_specs': [{'name': 'avg_volume_length', 'family': 'lookback', 'anchor': 20}, {'name': 'relative_volume_min', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'max_body_pct', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'min_lower_wick_pct', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'lower_wick_dominance', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'avg_volume_length': [20, 10, 40], 'relative_volume_min': [1.5, 1.0499999999999998, 2.0999999999999996], 'max_body_pct': [40.0, 30.0, 50.0], 'min_lower_wick_pct': [35.0, 25.0, 45.0], 'lower_wick_dominance': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
