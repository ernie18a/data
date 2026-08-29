from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray) -> np.ndarray:
    previous = np.full(values.shape, np.nan, dtype=np.float64)
    previous[1:] = values[:-1]
    return previous


def _signal_components(features, signal_params):
    params = {} if signal_params is None else signal_params
    support_lookback = max(2, int(params.get("support_lookback", 40)))
    zone_tolerance = max(0.0, float(params.get("zone_tolerance", 0.004)))

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    support = np.asarray(features.lowest(support_lookback), dtype=np.float64)
    resistance = np.asarray(features.highest(support_lookback), dtype=np.float64)
    previous_support = _lag(support)
    previous_resistance = _lag(resistance)
    previous_close = _lag(closes)

    valid = np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    support_valid = valid & np.isfinite(support)
    resistance_valid = valid & np.isfinite(resistance)
    previous_support_valid = np.isfinite(previous_support) & np.isfinite(previous_close)
    previous_resistance_valid = np.isfinite(previous_resistance) & np.isfinite(previous_close)

    support_zone_before = previous_support_valid & (
        (previous_close >= previous_support * (1.0 - zone_tolerance))
        & (previous_close <= previous_support * (1.0 + zone_tolerance))
    )
    resistance_zone_before = previous_resistance_valid & (
        (previous_close >= previous_resistance * (1.0 - zone_tolerance))
        & (previous_close <= previous_resistance * (1.0 + zone_tolerance))
    )

    base_trigger = support_valid & support_zone_before & (previous_close >= previous_support) & (
        closes < support
    )
    mirror_trigger = resistance_valid & resistance_zone_before & (
        (previous_close <= previous_resistance) & (closes > resistance)
    )

    support_reclaim_level = support * (1.0 + zone_tolerance)
    previous_support_reclaim_level = previous_support * (1.0 + zone_tolerance)
    resistance_reject_level = resistance * (1.0 - zone_tolerance)
    previous_resistance_reject_level = previous_resistance * (1.0 - zone_tolerance)

    base_reclaim = support_valid & np.isfinite(previous_support_reclaim_level) & (
        (previous_close <= previous_support_reclaim_level)
        & (closes > support_reclaim_level)
    )
    mirror_reject = resistance_valid & np.isfinite(previous_resistance_reject_level) & (
        (previous_close >= previous_resistance_reject_level)
        & (closes < resistance_reject_level)
    )
    base_breakdown_state = support_valid & (closes < support)
    mirror_breakout_state = resistance_valid & (closes > resistance)

    return (
        np.asarray(base_trigger, dtype=np.bool_),
        np.asarray(mirror_trigger, dtype=np.bool_),
        np.asarray(base_reclaim, dtype=np.bool_),
        np.asarray(mirror_reject, dtype=np.bool_),
        np.asarray(base_breakdown_state, dtype=np.bool_),
        np.asarray(mirror_breakout_state, dtype=np.bool_),
    )


def generate_l34_spx_daily_support_break_q1_source(features, signal_params):
    base_trigger, _, base_reclaim, _, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), base_trigger, base_reclaim


def generate_l34_spx_daily_support_break_q2_mirror(features, signal_params):
    _, mirror_trigger, _, mirror_reject, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return mirror_trigger, mirror_reject, false.copy(), false.copy()


def generate_l34_spx_daily_support_break_q3_contrarian(features, signal_params):
    base_trigger, _, _, _, base_breakdown_state, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return base_trigger, base_breakdown_state, false.copy(), false.copy()


def generate_l34_spx_daily_support_break_q4_mirror_contrarian(features, signal_params):
    _, mirror_trigger, _, _, _, mirror_breakout_state = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_trigger, mirror_breakout_state


_SOURCE_LOGIC_ID = "l34_spx_daily_support_break"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:34"]
_SOURCE_SUMMARY = (
    "SPX日線在一次性4,530前支撐位形成跌破且收盤低於該位後做空，"
    "原文以賣出4,610、買入4,615的30至45 DTE看漲信用價差表達空方部位。"
)
_SOURCE_REQUIREMENTS = {
    "asset": "SPX",
    "required_bar_interval": "1d",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "market_fields": ["high", "low", "close"],
    "core_trigger": "daily close breakdown below a previously established support level",
    "source_position": "short call credit spread",
    "source_option_legs": {
        "short_call_strike": "4,610",
        "long_call_strike": "4,615",
        "dte": "30-45",
    },
    "unavailable_source_inputs": [
        "option chain",
        "option strikes and quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "DTE and expiration",
        "timestamp and session fields",
    ],
    "execution": "daily close signal, next-bar-open fill",
}
_PROXY_ASSUMPTIONS = [
    "來源的一次性4,530支撐價不直接作為訊號常數，以前一段support_lookback根日線的rolling最低價代理；鏡像以相同窗口的rolling最高價代理阻力。",
    "zone_tolerance只用於判斷前一根收盤是否位於rolling支撐或阻力附近，突破本身仍要求當根收盤嚴格越過不含當根資料的rolling水準。",
    "rolling最低價與最高價由Frame既有函式排除當前bar，前一根收盤與當根收盤均為收盤時可知資料；訊號依契約於下一根日線開盤成交。",
    "4,610與4,615履約價、30至45 DTE、權利金、乘數及期權損益不在MarketData，原始看漲信用價差只以SPX標的空方方向proxy表示。",
    "鏡像以rolling阻力向上突破及SPX標的多方proxy表示；反向假說保留各自原始或鏡像價格事件而翻轉部位方向，不把期權腿轉成標的價格訊號。",
    "來源沒有明示出場；Q1與Q2使用各自突破水準的結構失效，Q3與Q4在原始或鏡像突破狀態延續時退出；ATR停損、R目標與最大持有bar由Frame risk overlay統一處理。",
]
_SIGNAL_PARAMETER_NAMES = ["support_lookback", "zone_tolerance"]
_SIGNAL_PARAMETER_SETS = [
    {"support_lookback": 20, "zone_tolerance": 0.002},
    {"support_lookback": 20, "zone_tolerance": 0.004},
    {"support_lookback": 20, "zone_tolerance": 0.008},
    {"support_lookback": 40, "zone_tolerance": 0.002},
    {"support_lookback": 40, "zone_tolerance": 0.004},
    {"support_lookback": 40, "zone_tolerance": 0.008},
    {"support_lookback": 60, "zone_tolerance": 0.002},
    {"support_lookback": 60, "zone_tolerance": 0.004},
    {"support_lookback": 60, "zone_tolerance": 0.008},
]
_RISK_GRID = {
    "stop_atr": [1.0, 1.5, 2.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [10, 20, 40],
}


def _record(strategy_id, hypothesis, position, direction, entry_origin, exit_origin, function):
    return {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": strategy_id,
        "hypothesis": hypothesis,
        "classification": "proxy",
        "asset": "SPX",
        "position": position,
        "inferred_entry_direction": direction,
        "source_refs": list(_SOURCE_REFS),
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": list(_PROXY_ASSUMPTIONS),
        "source_requirements": dict(_SOURCE_REQUIREMENTS),
        "required_bar_interval": "1d",
        "required_session": "unspecified_by_source; preserve_dataset_session",
        "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
        "entry_origin": entry_origin,
        "exit_origin": exit_origin,
        "inferred_exit": True,
        "signal_parameter_names": list(_SIGNAL_PARAMETER_NAMES),
        "signal_parameter_sets": list(map(dict, _SIGNAL_PARAMETER_SETS)),
        "risk_grid": {
            "stop_atr": list(_RISK_GRID["stop_atr"]),
            "target_r": list(_RISK_GRID["target_r"]),
            "max_bars": list(_RISK_GRID["max_bars"]),
        },
        "generate_signals": function,
    }


STRATEGIES = [
    _record(
        "l34_spx_daily_support_break_q1_source",
        "Q1_SOURCE",
        "short",
        "bearish",
        "rolling support-zone proximity followed by a daily close cross-down below prior rolling support",
        "inferred structural exit when the daily close crosses back above the broken support zone",
        generate_l34_spx_daily_support_break_q1_source,
    ),
    _record(
        "l34_spx_daily_support_break_q2_mirror",
        "Q2_MIRROR",
        "long",
        "bullish",
        "mirrored rolling resistance-zone proximity followed by a daily close cross-up above prior rolling resistance",
        "inferred structural exit when the daily close crosses back below the broken resistance zone",
        generate_l34_spx_daily_support_break_q2_mirror,
    ),
    _record(
        "l34_spx_daily_support_break_q3_contrarian",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source bearish rolling-support breakdown trigger with contrarian long direction",
        "inferred structural exit during persistence of the source bearish breakdown below rolling support",
        generate_l34_spx_daily_support_break_q3_contrarian,
    ),
    _record(
        "l34_spx_daily_support_break_q4_mirror_contrarian",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored bullish rolling-resistance breakout trigger with contrarian short direction",
        "inferred structural exit during persistence of the mirrored bullish breakout above rolling resistance",
        generate_l34_spx_daily_support_break_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_l34_spx_daily_support_break_q1_source",
    "generate_l34_spx_daily_support_break_q2_mirror",
    "generate_l34_spx_daily_support_break_q3_contrarian",
    "generate_l34_spx_daily_support_break_q4_mirror_contrarian",
]
