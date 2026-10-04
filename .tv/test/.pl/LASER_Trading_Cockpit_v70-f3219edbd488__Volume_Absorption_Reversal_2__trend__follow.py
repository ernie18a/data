import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    volume = features.market.volumes
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    avg_volume = features.sma(signal_params['avg_volume_length'], 'volumes')
    relative_volume = np.divide(volume, avg_volume, out=np.zeros(n, dtype=np.float64), where=avg_volume > 0)
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    body_pct = np.divide(candle_body * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick_pct = np.divide(upper_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    lower_wick_pct = np.divide(lower_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    candle_mid = (highs + lows) / 2.0
    active_volume = relative_volume >= signal_params['abs_volume_mult']
    small_body = body_pct <= signal_params['abs_max_body']
    min_wick = signal_params['abs_min_wick']
    wick_dominance = signal_params['abs_wick_dominance']
    long_entries = (active_volume & small_body & (lower_wick_pct >= min_wick) & (lower_wick >= upper_wick * wick_dominance) & (closes >= candle_mid)).astype(bool)
    short_entries = (active_volume & small_body & (upper_wick_pct >= min_wick) & (upper_wick >= lower_wick * wick_dominance) & (closes <= candle_mid)).astype(bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Volume_Absorption_Reversal_2__trend__follow', 'hypothesis': '在相對成交量放大時，將小實體且單側影線明顯占優的蠟燭視為賣方或買方遭吸收的訊號。', 'position': 'both', 'signal_parameter_names': ['avg_volume_length', 'abs_volume_mult', 'abs_max_body', 'abs_min_wick', 'abs_wick_dominance'], 'signal_parameter_specs': [{'name': 'avg_volume_length', 'family': 'lookback', 'anchor': 20}, {'name': 'abs_volume_mult', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'abs_max_body', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'abs_min_wick', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'abs_wick_dominance', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'avg_volume_length': [20, 10, 40], 'abs_volume_mult': [1.5, 1.0499999999999998, 2.0999999999999996], 'abs_max_body': [40.0, 30.0, 50.0], 'abs_min_wick': [35.0, 25.0, 45.0], 'abs_wick_dominance': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
