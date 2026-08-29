from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=np.float64)
    result[1:] = values[:-1]
    return result


def _signal_components(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty.copy(), empty.copy(), empty.copy(), empty.copy(), empty.copy(), empty.copy()

    params = {} if signal_params is None else signal_params
    lookback = max(2, int(params.get("lookback", 24)))

    lows = np.asarray(features.market.lows, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    support = np.asarray(features.lowest(lookback), dtype=np.float64)
    resistance = np.asarray(features.highest(lookback), dtype=np.float64)
    previous_closes = _lag(closes)
    previous_support = _lag(support)
    previous_resistance = _lag(resistance)

    valid = (
        np.isfinite(lows)
        & np.isfinite(highs)
        & np.isfinite(closes)
        & np.isfinite(previous_closes)
    )
    support_valid = valid & np.isfinite(support) & np.isfinite(previous_support)
    resistance_valid = valid & np.isfinite(resistance) & np.isfinite(previous_resistance)

    base_trigger = support_valid & (closes < support) & (previous_closes >= previous_support)
    mirror_trigger = resistance_valid & (closes > resistance) & (previous_closes <= previous_resistance)
    base_reclaim = support_valid & (closes > support) & (previous_closes <= previous_support)
    mirror_reject = resistance_valid & (closes < resistance) & (previous_closes >= previous_resistance)
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


def generate_signals_l33_5m_support_breakdown_q1_source(features, signal_params):
    base_trigger, _, base_reclaim, _, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), base_trigger, base_reclaim


def generate_signals_l33_5m_support_breakdown_q2_mirror(features, signal_params):
    _, mirror_trigger, _, mirror_reject, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return mirror_trigger, mirror_reject, false.copy(), false.copy()


def generate_signals_l33_5m_support_breakdown_q3_contrarian(features, signal_params):
    base_trigger, _, _, _, base_breakdown_state, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return base_trigger, base_breakdown_state, false.copy(), false.copy()


def generate_signals_l33_5m_support_breakdown_q4_mirror_contrarian(features, signal_params):
    _, mirror_trigger, _, _, _, mirror_breakout_state = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_trigger, mirror_breakout_state


_SOURCE_LOGIC_ID = "L33_5M_SUPPORT_BREAKDOWN"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:33"]
_SOURCE_SUMMARY = (
    "5分鐘K線收盤跌破支撐區時進場做空，來源以賣出平值call credit spread表達；"
    "Frame以標的空方方向代理並在下一根bar開盤成交。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "5m",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying price-direction proxy of an at-the-money call credit spread",
    "market_fields": ["low", "high", "close"],
    "period_basis": "5-minute bar-based",
    "indicators": [
        "rolling lowest(low, lookback) excluding current bar",
        "rolling highest(high, lookback) excluding current bar",
    ],
    "core_trigger": "5-minute close crosses down through prior rolling support",
    "source_position": "short at-the-money call credit spread",
    "option_requirements": [
        "at-the-money call credit spread legs",
        "strike prices and option quotes",
        "net credit and option multiplier",
        "option P&L",
    ],
    "unavailable_data": [
        "option chain",
        "strike quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "timestamp and session fields",
    ],
    "execution": "5-minute close-confirmed signal and next-bar-open fill",
}
_PROXY_ASSUMPTIONS = [
    "支撐以lookback根已完成5分鐘bar的rolling low代理，阻力以同一lookback根已完成bar的rolling high代理；兩者均排除當前訊號bar與未來資料。",
    "來源未指定支撐計算窗，lookback以12、24、48根分別代理1、2、4小時的5分鐘結構窗。",
    "原始跌破事件明確定義為close[t]小於support[t]且close[t-1]大於等於support[t-1]；鏡像事件為close[t]向上穿越prior rolling high。",
    "Frame只有標的OHLC，賣出平值call credit spread的平值履約價、期權鏈、權利金、乘數與損益均不可觀測，因此期權腿只作標的空方方向proxy；鏡像與反向假說僅改變標的方向。",
    "來源沒有明示出場；Q1空方以收盤向上收復支撐出場，Q2多方以收盤向下跌回阻力出場，Q3與Q4反向假說分別在原跌破或鏡像突破狀態持續時出場，均屬inferred_exit。",
    "訊號只能使用當根收盤及此前rolling值，依Frame契約於下一根5分鐘bar開盤成交；ATR停損、目標R及最大持有bar由risk overlay統一處理。",
]
_SIGNAL_PARAMETER_NAMES = ["lookback"]
_SIGNAL_PARAMETER_SETS = [
    {"lookback": 12},
    {"lookback": 24},
    {"lookback": 48},
]
_RISK_GRID = {
    "stop_atr": [1.5, 2.0, 3.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [12, 24, 48],
}


def _record(strategy_id, hypothesis, position, direction, entry_origin, exit_origin, function):
    return {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": strategy_id,
        "hypothesis": hypothesis,
        "classification": "proxy",
        "position": position,
        "inferred_entry_direction": direction,
        "source_refs": list(_SOURCE_REFS),
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": list(_PROXY_ASSUMPTIONS),
        "source_requirements": dict(_SOURCE_REQUIREMENTS),
        "required_bar_interval": "5m",
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
        "L33_5M_SUPPORT_BREAKDOWN_Q1_SOURCE",
        "Q1_SOURCE",
        "short",
        "bearish",
        "5-minute close cross-down below prior rolling low support",
        "inferred structural exit when close crosses back above the prior rolling support",
        generate_signals_l33_5m_support_breakdown_q1_source,
    ),
    _record(
        "L33_5M_SUPPORT_BREAKDOWN_Q2_MIRROR",
        "Q2_MIRROR",
        "long",
        "bullish",
        "mirrored 5-minute close cross-up above prior rolling high resistance",
        "inferred structural exit when close crosses back below the prior rolling resistance",
        generate_signals_l33_5m_support_breakdown_q2_mirror,
    ),
    _record(
        "L33_5M_SUPPORT_BREAKDOWN_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source 5-minute support breakdown trigger with contrarian long direction",
        "inferred exit during continued source bearish breakdown below support",
        generate_signals_l33_5m_support_breakdown_q3_contrarian,
    ),
    _record(
        "L33_5M_SUPPORT_BREAKDOWN_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored 5-minute resistance breakout trigger with contrarian short direction",
        "inferred exit during continued mirrored bullish breakout above resistance",
        generate_signals_l33_5m_support_breakdown_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l33_5m_support_breakdown_q1_source",
    "generate_signals_l33_5m_support_breakdown_q2_mirror",
    "generate_signals_l33_5m_support_breakdown_q3_contrarian",
    "generate_signals_l33_5m_support_breakdown_q4_mirror_contrarian",
]
