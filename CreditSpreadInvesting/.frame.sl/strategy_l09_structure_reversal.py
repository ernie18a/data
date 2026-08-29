import numpy as np


def _lag(values: np.ndarray, bars: int) -> np.ndarray:
    if bars <= 0:
        return values
    out = np.full(values.size, np.nan, dtype=np.float64)
    if bars < values.size:
        out[bars:] = values[:-bars]
    return out


def _parameter(signal_params, name, default):
    if signal_params is None:
        return default
    return signal_params.get(name, default)


def _bullish_structure(features, signal_params):
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    trend_lookback = max(1, int(_parameter(signal_params, "trend_lookback", 8)))
    pivot_gap = max(1, int(_parameter(signal_params, "pivot_gap", 3)))
    shadow_ratio = max(0.0, float(_parameter(signal_params, "shadow_ratio", 2.0)))
    shadow_atr_ratio = max(0.0, float(_parameter(signal_params, "shadow_atr_ratio", 0.35)))
    support_tolerance_atr = max(0.0, float(_parameter(signal_params, "support_tolerance_atr", 0.5)))
    atr = np.asarray(features.atr(14), dtype=np.float64)

    old_low = _lag(lows, 5 * pivot_gap)
    old_high = _lag(highs, 4 * pivot_gap)
    first_higher_low = _lag(lows, 3 * pivot_gap)
    higher_high = _lag(highs, 2 * pivot_gap)
    final_higher_low = _lag(lows, pivot_gap)
    sequence_start_close = _lag(closes, 5 * pivot_gap)
    prior_close = _lag(closes, 5 * pivot_gap + trend_lookback)

    prior_downtrend = sequence_start_close < prior_close
    higher_low_sequence = first_higher_low > old_low
    higher_high_sequence = higher_high > old_high
    final_higher_low_sequence = final_higher_low > first_higher_low
    support_touch = np.abs(lows - final_higher_low) <= support_tolerance_atr * atr

    body = np.abs(closes - opens)
    lower_shadow = np.minimum(opens, closes) - lows
    long_lower_shadow = (
        (closes >= opens)
        & (lower_shadow >= shadow_ratio * np.maximum(body, np.finfo(np.float64).eps))
        & (lower_shadow >= shadow_atr_ratio * atr)
    )
    entry = (
        prior_downtrend
        & higher_low_sequence
        & higher_high_sequence
        & final_higher_low_sequence
        & support_touch
        & long_lower_shadow
    )
    long_invalidation = closes < final_higher_low - support_tolerance_atr * atr
    short_invalidation = closes > higher_high + support_tolerance_atr * atr
    return entry.astype(np.bool_, copy=False), long_invalidation.astype(np.bool_, copy=False), short_invalidation.astype(np.bool_, copy=False)


def _bearish_structure(features, signal_params):
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    trend_lookback = max(1, int(_parameter(signal_params, "trend_lookback", 8)))
    pivot_gap = max(1, int(_parameter(signal_params, "pivot_gap", 3)))
    shadow_ratio = max(0.0, float(_parameter(signal_params, "shadow_ratio", 2.0)))
    shadow_atr_ratio = max(0.0, float(_parameter(signal_params, "shadow_atr_ratio", 0.35)))
    support_tolerance_atr = max(0.0, float(_parameter(signal_params, "support_tolerance_atr", 0.5)))
    atr = np.asarray(features.atr(14), dtype=np.float64)

    old_high = _lag(highs, 5 * pivot_gap)
    old_low = _lag(lows, 4 * pivot_gap)
    first_lower_high = _lag(highs, 3 * pivot_gap)
    lower_low = _lag(lows, 2 * pivot_gap)
    final_lower_high = _lag(highs, pivot_gap)
    sequence_start_close = _lag(closes, 5 * pivot_gap)
    prior_close = _lag(closes, 5 * pivot_gap + trend_lookback)

    prior_uptrend = sequence_start_close > prior_close
    lower_high_sequence = first_lower_high < old_high
    lower_low_sequence = lower_low < old_low
    final_lower_high_sequence = final_lower_high < first_lower_high
    resistance_touch = np.abs(highs - final_lower_high) <= support_tolerance_atr * atr

    body = np.abs(closes - opens)
    upper_shadow = highs - np.maximum(opens, closes)
    long_upper_shadow = (
        (closes <= opens)
        & (upper_shadow >= shadow_ratio * np.maximum(body, np.finfo(np.float64).eps))
        & (upper_shadow >= shadow_atr_ratio * atr)
    )
    entry = (
        prior_uptrend
        & lower_high_sequence
        & lower_low_sequence
        & final_lower_high_sequence
        & resistance_touch
        & long_upper_shadow
    )
    short_invalidation = closes > final_lower_high + support_tolerance_atr * atr
    long_invalidation = closes < lower_low - support_tolerance_atr * atr
    return entry.astype(np.bool_, copy=False), short_invalidation.astype(np.bool_, copy=False), long_invalidation.astype(np.bool_, copy=False)


def generate_signals_l09_structure_reversal_q1_source(features, signal_params):
    long_entry, long_exit, _ = _bullish_structure(features, signal_params)
    empty = np.zeros_like(long_entry, dtype=np.bool_)
    return long_entry, long_exit, empty, empty.copy()


def generate_signals_l09_structure_reversal_q2_mirror(features, signal_params):
    short_entry, short_exit, _ = _bearish_structure(features, signal_params)
    empty = np.zeros_like(short_entry, dtype=np.bool_)
    return empty, empty.copy(), short_entry, short_exit


def generate_signals_l09_structure_reversal_q3_contrarian(features, signal_params):
    short_entry, _, short_exit = _bullish_structure(features, signal_params)
    empty = np.zeros_like(short_entry, dtype=np.bool_)
    return empty, empty.copy(), short_entry, short_exit


def generate_signals_l09_structure_reversal_q4_mirror_contrarian(features, signal_params):
    long_entry, _, long_exit = _bearish_structure(features, signal_params)
    empty = np.zeros_like(long_entry, dtype=np.bool_)
    return long_entry, long_exit, empty, empty.copy()


_SOURCE_REF = "/g/data/CreditSpreadInvesting/.READ5.1.md:9"
_SOURCE_LOGIC_ID = "read5_1_l09_structure_reversal"
_SIGNAL_PARAMETER_NAMES = [
    "trend_lookback",
    "pivot_gap",
    "shadow_ratio",
    "shadow_atr_ratio",
    "support_tolerance_atr",
]
_SIGNAL_PARAMETER_SETS = [
    {
        "trend_lookback": 5,
        "pivot_gap": 2,
        "shadow_ratio": 1.5,
        "shadow_atr_ratio": 0.2,
        "support_tolerance_atr": 0.25,
    },
    {
        "trend_lookback": 8,
        "pivot_gap": 3,
        "shadow_ratio": 2.0,
        "shadow_atr_ratio": 0.35,
        "support_tolerance_atr": 0.5,
    },
    {
        "trend_lookback": 13,
        "pivot_gap": 4,
        "shadow_ratio": 3.0,
        "shadow_atr_ratio": 0.5,
        "support_tolerance_atr": 0.75,
    },
]
_RISK_GRID = {
    "stop_atr": [1.0, 1.5, 2.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [30, 60, 120],
}
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": None,
    "session": None,
    "timezone": None,
    "asset_relation": "underlying price direction proxy of a put credit spread",
    "required_columns": ["open", "high", "low", "close"],
    "unavailable_source_inputs": ["option strikes", "option premium", "probability of profit"],
}
_PROXY_ASSUMPTIONS_BULLISH = [
    "以已完成 bar 的固定等距索引 low0=low[t-5p]、high0=high[t-4p]、low1=low[t-3p]、high1=high[t-2p]、low2=low[t-p] 代理確認後的樞軸序列，p 為 pivot_gap。",
    "以前段 close[t-5p] 小於 close[t-5p-trend_lookback] 代理先前短期下跌趨勢。",
    "以 low[t] 接近 low2 且 abs(low[t]-low2) 不超過 support_tolerance_atr×ATR14 代理支撐觸及。",
    "以 lower_shadow=min(open,close)-low、body=abs(close-open)，並要求 close≥open、lower_shadow≥shadow_ratio×body 及 lower_shadow≥shadow_atr_ratio×ATR14 代理長下影線。",
    "選擇權履約價、權利金與 POP 不在 MarketData，put credit spread 以標的做多方向代理；訊號於收盤可知後由下一根 bar 開盤成交。",
]
_PROXY_ASSUMPTIONS_BEARISH = [
    "以已完成 bar 的固定等距索引 high0=high[t-5p]、low0=low[t-4p]、high1=high[t-3p]、low1=low[t-2p]、high2=high[t-p] 代理鏡像確認後的樞軸序列，p 為 pivot_gap。",
    "以前段 close[t-5p] 大於 close[t-5p-trend_lookback] 代理先前短期上升趨勢。",
    "以 high[t] 接近 high2 且 abs(high[t]-high2) 不超過 support_tolerance_atr×ATR14 代理阻力觸及。",
    "以 upper_shadow=high-max(open,close)、body=abs(close-open)，並要求 close≤open、upper_shadow≥shadow_ratio×body 及 upper_shadow≥shadow_atr_ratio×ATR14 代理長上影線。",
    "鏡像信用價差的選擇權履約價、權利金與 POP 不在 MarketData，以標的做空方向代理；訊號於收盤可知後由下一根 bar 開盤成交。",
]


STRATEGIES = [
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l09_structure_reversal_q1_source",
        "hypothesis": "Q1_SOURCE",
        "position": "long",
        "source_refs": [_SOURCE_REF],
        "source_summary": "前段短線下跌後依序形成較高低點、較高高點及下一個較高低點，支撐出現長下影線時賣出 put credit spread 做多。",
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS_BULLISH,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "source_ref line 9; bullish structure and long lower-shadow proxy",
        "exit_origin": "inferred_exit; close below final higher-low support proxy",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l09_structure_reversal_q1_source,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l09_structure_reversal_q2_mirror",
        "hypothesis": "Q2_MIRROR",
        "position": "short",
        "source_refs": [_SOURCE_REF],
        "source_summary": "鏡像代理為前段短線上升後依序形成較低高點、較低低點及下一個較低高點，阻力出現長上影線時作空。",
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS_BEARISH,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "inferred_mirror; bearish structure and long upper-shadow proxy",
        "exit_origin": "inferred_exit; close above final lower-high resistance proxy",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l09_structure_reversal_q2_mirror,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l09_structure_reversal_q3_contrarian",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "short",
        "source_refs": [_SOURCE_REF],
        "source_summary": "原始多頭結構與長下影線代理成立時採反向作空，以測試結構訊號方向反轉的假說。",
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS_BULLISH,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "inferred_contrarian; original bullish structure with short position",
        "exit_origin": "inferred_exit; close above the prior higher-high resistance proxy",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l09_structure_reversal_q3_contrarian,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l09_structure_reversal_q4_mirror_contrarian",
        "hypothesis": "Q4_MIRROR_CONTRARIAN",
        "position": "long",
        "source_refs": [_SOURCE_REF],
        "source_summary": "鏡像空頭結構與長上影線代理成立時採反向做多，以測試鏡像訊號方向反轉的假說。",
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS_BEARISH,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "inferred_mirror_contrarian; mirrored bearish structure with long position",
        "exit_origin": "inferred_exit; close below the prior lower-low support proxy",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l09_structure_reversal_q4_mirror_contrarian,
    },
]
