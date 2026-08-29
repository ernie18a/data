from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray, bars: int) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=np.float64)
    if values.size > bars:
        result[bars:] = values[:-bars]
    return result


def _parameter(signal_params, name, default):
    if signal_params is None:
        return default
    return signal_params.get(name, default)


def _signal_components(features, signal_params):
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    size = features.market.size
    level_lookback = max(2, int(_parameter(signal_params, "level_lookback", 20)))
    level_tolerance = np.clip(
        float(_parameter(signal_params, "level_tolerance", 0.01)), 0.0, 0.25
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

    morning_star = valid & (
        (close_first < open_first)
        & (closes > opens)
        & (first_body > 0.0)
        & (third_body >= star_body)
        & (star_body <= first_body * 0.4)
        & (star_body_top <= close_first)
        & (closes >= first_midpoint)
    )
    evening_star = valid & (
        (close_first > open_first)
        & (closes < opens)
        & (first_body > 0.0)
        & (third_body >= star_body)
        & (star_body <= first_body * 0.4)
        & (star_body_bottom >= close_first)
        & (closes <= first_midpoint)
    )

    sma50 = features.sma(50)
    sma50_prior = _lag(sma50, 1)
    uptrend = (
        np.isfinite(sma50)
        & np.isfinite(sma50_prior)
        & (closes > sma50)
        & (sma50 > sma50_prior)
    )
    downtrend = (
        np.isfinite(sma50)
        & np.isfinite(sma50_prior)
        & (closes < sma50)
        & (sma50 < sma50_prior)
    )

    prior_resistance = _lag(features.highest(level_lookback), 2)
    prior_support = _lag(features.lowest(level_lookback), 2)
    resistance_tolerance = np.abs(prior_resistance) * level_tolerance
    support_tolerance = np.abs(prior_support) * level_tolerance
    pattern_low = np.minimum(np.minimum(low_first, low_star), lows)
    pattern_high = np.maximum(np.maximum(high_first, high_star), highs)
    resistance_zone = (
        np.isfinite(prior_resistance)
        & (np.abs(sma50 - prior_resistance) <= resistance_tolerance)
        & (pattern_low <= prior_resistance + resistance_tolerance)
        & (closes >= prior_resistance - resistance_tolerance)
    )
    support_zone = (
        np.isfinite(prior_support)
        & (np.abs(sma50 - prior_support) <= support_tolerance)
        & (pattern_high >= prior_support - support_tolerance)
        & (closes <= prior_support + support_tolerance)
    )
    base_signal = morning_star & uptrend & resistance_zone
    mirror_signal = evening_star & downtrend & support_zone
    return (
        np.asarray(base_signal, dtype=np.bool_),
        np.asarray(mirror_signal, dtype=np.bool_),
        sma50,
        closes,
        size,
    )


def generate_signals_l29_ma50_morning_star_q1_source(features, signal_params):
    base_signal, _, sma50, closes, size = _signal_components(features, signal_params)
    false = np.zeros(size, dtype=np.bool_)
    return base_signal, closes < sma50, false.copy(), false.copy()


def generate_signals_l29_ma50_morning_star_q2_mirror(features, signal_params):
    _, mirror_signal, sma50, closes, size = _signal_components(features, signal_params)
    false = np.zeros(size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_signal, closes > sma50


def generate_signals_l29_ma50_morning_star_q3_contrarian(features, signal_params):
    base_signal, _, sma50, closes, size = _signal_components(features, signal_params)
    false = np.zeros(size, dtype=np.bool_)
    return false.copy(), false.copy(), base_signal, closes > sma50


def generate_signals_l29_ma50_morning_star_q4_mirror_contrarian(features, signal_params):
    _, mirror_signal, sma50, closes, size = _signal_components(features, signal_params)
    false = np.zeros(size, dtype=np.bool_)
    return mirror_signal, closes < sma50, false.copy(), false.copy()


_SOURCE_LOGIC_ID = "l29_ma50_morning_star_retest"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:29"]
_SOURCE_SUMMARY = (
    "上升趨勢中，SMA50 位於前阻力轉支撐區並形成晨星，於訊號後下一根 K 線開盤做多。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified",
    "session": "unspecified_by_source; preserve_dataset_session",
    "timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "data_requirements": ["open", "high", "low", "close"],
    "period_basis": "bar-based",
    "core_trigger": "uptrend, SMA50 at prior resistance turned support, confirmed three-bar morning star",
    "source_position": "long underlying proxy for bullish direction",
    "source_exit": "not specified",
    "unavailable_data": [
        "option chain",
        "put spread strikes",
        "option quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "timestamp and session fields",
    ],
    "execution": "close-confirmed pattern signal, next-bar-open fill",
}
_PROXY_ASSUMPTIONS = [
    "SMA50 使用收盤價 50-bar SMA；上升趨勢定義為訊號收盤高於 SMA50 且 SMA50 高於前一根 SMA50，鏡像下降趨勢反向定義。",
    "前阻力以訊號前三根以前、由 level_lookback 個已知 high 的 rolling maximum 代理；前支撐以對應 rolling minimum 代理，rolling 極值不含當根及晨星三根K線。",
    "阻力轉支撐要求 SMA50 與前阻力的絕對差不超過 level_tolerance 乘以前阻力絕對值，晨星三根最低價觸及該容差帶且第三根收盤位於帶內或上方；鏡像對支撐轉阻力反向套用。",
    "晨星固定為三根已完成K線：第一根陰線且實體大於零，第二根實體不超過第一根40%且其實體頂不高於第一根收盤，第三根陽線、實體不小於第二根且收盤不低於第一根實體中點；晚星為所有方向條件鏡像。",
    "來源未指定退出規則；多方以收盤跌破 SMA50、空方以收盤突破 SMA50 作結構失效退出，並由 Frame risk overlay 統一處理 ATR 停損、R 目標與最大持有 bars。",
    "來源未指定 bar interval、session 或 timezone；保留資料集設定，選擇權部位以單一標的方向代理。",
]
_SIGNAL_PARAMETER_NAMES = ["level_lookback", "level_tolerance"]
_SIGNAL_PARAMETER_SETS = [
    {"level_lookback": 20, "level_tolerance": 0.005},
    {"level_lookback": 20, "level_tolerance": 0.01},
    {"level_lookback": 20, "level_tolerance": 0.02},
    {"level_lookback": 40, "level_tolerance": 0.005},
    {"level_lookback": 40, "level_tolerance": 0.01},
    {"level_lookback": 40, "level_tolerance": 0.02},
    {"level_lookback": 60, "level_tolerance": 0.005},
    {"level_lookback": 60, "level_tolerance": 0.01},
    {"level_lookback": 60, "level_tolerance": 0.02},
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
        "inferred_exit": True,
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
        "l29_ma50_morning_star_retest_q1_source_long",
        "Q1_SOURCE",
        "long",
        "bullish",
        "uptrend SMA50 prior-resistance retest with confirmed bullish morning star",
        "inferred structural failure when close falls below SMA50",
        generate_signals_l29_ma50_morning_star_q1_source,
    ),
    _record(
        "l29_ma50_morning_star_retest_q2_mirror_short",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored downtrend SMA50 prior-support retest with confirmed bearish evening star",
        "inferred structural failure when close rises above SMA50",
        generate_signals_l29_ma50_morning_star_q2_mirror,
    ),
    _record(
        "l29_ma50_morning_star_retest_q3_contrarian_short",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source bullish morning-star retest trigger with contrarian short direction",
        "inferred structural failure when close rises above SMA50",
        generate_signals_l29_ma50_morning_star_q3_contrarian,
    ),
    _record(
        "l29_ma50_morning_star_retest_q4_mirror_contrarian_long",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored bearish evening-star retest trigger with contrarian long direction",
        "inferred structural failure when close falls below SMA50",
        generate_signals_l29_ma50_morning_star_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l29_ma50_morning_star_q1_source",
    "generate_signals_l29_ma50_morning_star_q2_mirror",
    "generate_signals_l29_ma50_morning_star_q3_contrarian",
    "generate_signals_l29_ma50_morning_star_q4_mirror_contrarian",
]
