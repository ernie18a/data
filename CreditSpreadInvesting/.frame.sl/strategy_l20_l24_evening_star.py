from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray, bars: int) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=np.float64)
    if values.size > bars:
        result[bars:] = values[:-bars]
    return result


def _lag_bool(values: np.ndarray, bars: int) -> np.ndarray:
    result = np.zeros(values.shape, dtype=np.bool_)
    if values.size > bars:
        result[bars:] = values[:-bars]
    return result


def _parameter(signal_params, name, default):
    if signal_params is None:
        return default
    return signal_params.get(name, default)


def _carry(values: np.ndarray, valid: np.ndarray) -> np.ndarray:
    indices = np.arange(values.size, dtype=np.int64)
    latest = np.maximum.accumulate(np.where(valid, indices, -1))
    safe = np.maximum(latest, 0)
    result = np.full(values.shape, np.nan, dtype=np.float64)
    has_value = latest >= 0
    result[has_value] = values[safe[has_value]]
    return result


def _signal_components(features, signal_params):
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    star_body_ratio = np.clip(
        float(_parameter(signal_params, "star_body_ratio", 0.4)), 0.01, 1.0
    )
    target_pct = np.clip(
        float(_parameter(signal_params, "target_pct", 0.0782608695652174)), 0.0, 0.95
    )

    open_first = _lag(opens, 2)
    high_first = _lag(highs, 2)
    low_first = _lag(lows, 2)
    close_first = _lag(closes, 2)
    open_star = _lag(opens, 1)
    high_star = _lag(highs, 1)
    low_star = _lag(lows, 1)
    close_star = _lag(closes, 1)

    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(open_first)
        & np.isfinite(high_first)
        & np.isfinite(low_first)
        & np.isfinite(close_first)
        & np.isfinite(open_star)
        & np.isfinite(high_star)
        & np.isfinite(low_star)
        & np.isfinite(close_star)
    )
    first_body = np.abs(close_first - open_first)
    star_body = np.abs(close_star - open_star)
    third_body = np.abs(closes - opens)
    first_midpoint = (open_first + close_first) * 0.5
    star_body_top = np.maximum(open_star, close_star)
    star_body_bottom = np.minimum(open_star, close_star)

    base_pattern = valid & (
        (close_first > open_first)
        & (closes < opens)
        & (first_body > 0.0)
        & (third_body >= star_body)
        & (star_body <= first_body * star_body_ratio)
        & (star_body_bottom >= close_first)
        & (closes < first_midpoint)
    )
    mirror_pattern = valid & (
        (close_first < open_first)
        & (closes > opens)
        & (first_body > 0.0)
        & (third_body >= star_body)
        & (star_body <= first_body * star_body_ratio)
        & (star_body_top <= close_first)
        & (closes > first_midpoint)
    )

    base_low = np.minimum(np.minimum(low_first, low_star), lows)
    mirror_high = np.maximum(np.maximum(high_first, high_star), highs)
    previous_close = _lag(closes, 1)
    base_pattern_previous = _lag_bool(base_pattern, 1)
    mirror_pattern_previous = _lag_bool(mirror_pattern, 1)
    base_low_previous = _lag(base_low, 1)
    mirror_high_previous = _lag(mirror_high, 1)

    base_breakdown = base_pattern_previous & np.isfinite(base_low_previous) & (
        np.isfinite(previous_close)
        & (previous_close >= base_low_previous)
        & (closes < base_low_previous)
    )
    mirror_breakout = mirror_pattern_previous & np.isfinite(mirror_high_previous) & (
        np.isfinite(previous_close)
        & (previous_close <= mirror_high_previous)
        & (closes > mirror_high_previous)
    )

    base_low_valid = base_pattern & np.isfinite(base_low)
    mirror_high_valid = mirror_pattern & np.isfinite(mirror_high)
    base_low_anchor = _carry(base_low, base_low_valid)
    mirror_high_anchor = _carry(mirror_high, mirror_high_valid)
    base_short_target = base_low_anchor * (1.0 - target_pct)
    base_long_target = base_low_anchor * (1.0 + target_pct)
    mirror_long_target = mirror_high_anchor * (1.0 + target_pct)
    mirror_short_target = mirror_high_anchor * (1.0 - target_pct)

    return (
        np.asarray(base_breakdown, dtype=np.bool_),
        np.asarray(mirror_breakout, dtype=np.bool_),
        np.asarray(closes <= base_short_target, dtype=np.bool_),
        np.asarray(closes >= mirror_long_target, dtype=np.bool_),
        np.asarray(closes >= base_long_target, dtype=np.bool_),
        np.asarray(closes <= mirror_short_target, dtype=np.bool_),
    )


def generate_signals_l20_l24_evening_star_q1_source(features, signal_params):
    base_breakdown, _, base_short_target, _, _, _ = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), base_breakdown, base_short_target


def generate_signals_l20_l24_evening_star_q2_mirror(features, signal_params):
    _, mirror_breakout, _, mirror_long_target, _, _ = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return mirror_breakout, mirror_long_target, false.copy(), false.copy()


def generate_signals_l20_l24_evening_star_q3_contrarian(features, signal_params):
    base_breakdown, _, _, _, base_long_target, _ = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return base_breakdown, base_long_target, false.copy(), false.copy()


def generate_signals_l20_l24_evening_star_q4_mirror_contrarian(features, signal_params):
    _, mirror_breakout, _, _, _, mirror_short_target = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_breakout, mirror_short_target


_SOURCE_LOGIC_ID = "l20_l24_evening_star_breakdown"
_SOURCE_REFS = [
    "/g/data/CreditSpreadInvesting/.READ5.1.md:20",
    "/g/data/CreditSpreadInvesting/.READ5.1.md:24",
]
_SOURCE_SUMMARY = (
    "第20與24行皆描述晚星型態完成後價格跌破型態低點，"
    "以標的空方代理賣出 call 信用價差，價格到達較低獲利位時平倉；兩行合併為一個獨立來源邏輯。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified",
    "session": "unspecified_by_source; preserve_dataset_session",
    "timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "data_requirements": ["open", "high", "low", "close"],
    "period_basis": "bar-based",
    "core_trigger": "confirmed evening-star pattern followed by close breakdown below its three-bar pattern low",
    "source_position": "short call credit spread",
    "source_exit": "lower absolute-price profit exit",
    "unavailable_data": [
        "option chain",
        "call strikes",
        "option quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "timestamp and session fields",
    ],
    "execution": "close-confirmed pattern and breakdown signal, next-bar-open fill",
}
_PROXY_ASSUMPTIONS = [
    "晚星以三根已完成K線表示：第一根陽線、第二根小實體且位於第一根收盤之上、第三根陰線且收盤跌入第一根實體中點以下；星體實體不超過第一根實體的 star_body_ratio，第三根實體不小於星體實體。",
    "型態低點門檻以確認晚星三根K線的 rolling low 代理，進場要求前一根收盤仍位於或高於該低點，當根收盤向下穿越後由下一根K線開盤成交；鏡像使用三根K線 rolling high 與向上穿越。",
    "來源固定的型態低點以 rolling 結構取代，來源固定的較低獲利價位以 target_pct 乘以確認型態低點的百分比距離代理；預設 target_pct 為來源兩價位相對距離的百分比近似。",
    "原始 call 信用價差以標的空方部位代理；鏡像改用 bullish morning-star 類型與標的多方，反向假說僅翻轉部位方向，均不捏造選擇權腿或損益。",
    "型態與跌破只使用當根收盤及更早的完成K線；訊號於收盤確認，依 Frame 契約於下一根K線開盤成交。",
    "來源未指定 bar interval、session 或 timezone；保留資料集設定，ATR 停損、R 目標與最大持有 bars 由 Frame risk overlay 統一處理。",
]
_SIGNAL_PARAMETER_NAMES = ["star_body_ratio", "target_pct"]
_SIGNAL_PARAMETER_SETS = [
    {"star_body_ratio": 0.3, "target_pct": 0.05},
    {"star_body_ratio": 0.3, "target_pct": 0.0782608695652174},
    {"star_body_ratio": 0.3, "target_pct": 0.1},
    {"star_body_ratio": 0.4, "target_pct": 0.05},
    {"star_body_ratio": 0.4, "target_pct": 0.0782608695652174},
    {"star_body_ratio": 0.4, "target_pct": 0.1},
    {"star_body_ratio": 0.5, "target_pct": 0.05},
    {"star_body_ratio": 0.5, "target_pct": 0.0782608695652174},
    {"star_body_ratio": 0.5, "target_pct": 0.1},
]
_RISK_GRID = {
    "stop_atr": [1.5, 2.0, 3.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [30, 60, 120],
}


def _record(
    strategy_id,
    hypothesis,
    position,
    direction,
    entry_origin,
    exit_origin,
    function,
):
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
        "required_bar_interval": "unspecified",
        "required_session": "unspecified_by_source; preserve_dataset_session",
        "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
        "entry_origin": entry_origin,
        "exit_origin": exit_origin,
        "inferred_exit": False,
        "signal_parameter_names": list(_SIGNAL_PARAMETER_NAMES),
        "signal_parameter_sets": [dict(values) for values in _SIGNAL_PARAMETER_SETS],
        "risk_grid": {
            "stop_atr": list(_RISK_GRID["stop_atr"]),
            "target_r": list(_RISK_GRID["target_r"]),
            "max_bars": list(_RISK_GRID["max_bars"]),
        },
        "generate_signals": function,
    }


STRATEGIES = [
    _record(
        "l20_l24_evening_star_breakdown_q1_source",
        "Q1_SOURCE",
        "short",
        "bearish",
        "confirmed bearish evening-star breakdown below its rolling three-bar pattern low",
        "source explicit lower-price profit exit converted to a target_pct move below the confirmed pattern low",
        generate_signals_l20_l24_evening_star_q1_source,
    ),
    _record(
        "l20_l24_evening_star_breakdown_q2_mirror",
        "Q2_MIRROR",
        "long",
        "bullish",
        "mirrored bullish morning-star breakout above its rolling three-bar pattern high",
        "source lower-price objective directionally mirrored to a target_pct move above the mirrored pattern high",
        generate_signals_l20_l24_evening_star_q2_mirror,
    ),
    _record(
        "l20_l24_evening_star_breakdown_q3_contrarian",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source bearish evening-star breakdown trigger with contrarian long direction",
        "source bearish objective flipped for the contrarian long thesis to a target_pct move above the bearish pattern low",
        generate_signals_l20_l24_evening_star_q3_contrarian,
    ),
    _record(
        "l20_l24_evening_star_breakdown_q4_mirror_contrarian",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored bullish morning-star breakout trigger with contrarian short direction",
        "mirrored bullish objective flipped for the contrarian short thesis to a target_pct move below the mirrored pattern high",
        generate_signals_l20_l24_evening_star_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l20_l24_evening_star_q1_source",
    "generate_signals_l20_l24_evening_star_q2_mirror",
    "generate_signals_l20_l24_evening_star_q3_contrarian",
    "generate_signals_l20_l24_evening_star_q4_mirror_contrarian",
]
