from __future__ import annotations

import numpy as np


def _lag(values):
    previous = np.full(values.shape, np.nan, dtype=np.float64)
    previous[1:] = values[:-1]
    return previous


def _signal_components(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        nan_values = np.full(size, np.nan, dtype=np.float64)
        return empty.copy(), empty.copy(), nan_values.copy(), nan_values.copy()

    params = {} if signal_params is None else signal_params
    range_lookback = max(2, int(params.get("range_lookback", 20)))
    max_range_width_pct = max(0.0, float(params.get("max_range_width_pct", 0.04)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    range_high = np.asarray(features.highest(range_lookback), dtype=np.float64)
    range_low = np.asarray(features.lowest(range_lookback), dtype=np.float64)
    range_width = range_high - range_low
    range_scale = np.maximum(np.abs(range_high), np.finfo(np.float64).eps)

    previous_opens = _lag(opens)
    previous_closes = _lag(closes)
    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(previous_opens)
        & np.isfinite(previous_closes)
        & np.isfinite(range_high)
        & np.isfinite(range_low)
    )
    consolidated = valid & (range_width > 0.0) & (
        range_width / range_scale <= max_range_width_pct
    )
    resistance_zone = consolidated & (highs >= range_high - 0.25 * range_width)
    support_zone = consolidated & (lows <= range_low + 0.25 * range_width)

    bearish_engulfing = valid & (
        (previous_closes > previous_opens)
        & (closes < opens)
        & (opens >= previous_closes)
        & (closes <= previous_opens)
    )
    bullish_engulfing = valid & (
        (previous_closes < previous_opens)
        & (closes > opens)
        & (opens <= previous_closes)
        & (closes >= previous_opens)
    )
    return (
        bearish_engulfing & resistance_zone,
        bullish_engulfing & support_zone,
        range_high,
        range_low,
    )


def generate_signals_l27_range_resistance_engulfing_q1_source(features, signal_params):
    bearish_at_resistance, _, range_high, _ = _signal_components(features, signal_params)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    valid_exit = np.isfinite(range_high) & np.isfinite(closes)
    short_exit = valid_exit & (closes > range_high)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_at_resistance, short_exit


def generate_signals_l27_range_resistance_engulfing_q2_mirror(features, signal_params):
    _, bullish_at_support, _, range_low = _signal_components(features, signal_params)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    valid_exit = np.isfinite(range_low) & np.isfinite(closes)
    long_exit = valid_exit & (closes < range_low)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bullish_at_support, long_exit, false.copy(), false.copy()


def generate_signals_l27_range_resistance_engulfing_q3_contrarian(features, signal_params):
    bearish_at_resistance, _, _, range_low = _signal_components(features, signal_params)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    valid_exit = np.isfinite(range_low) & np.isfinite(closes)
    long_exit = valid_exit & (closes < range_low)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bearish_at_resistance, long_exit, false.copy(), false.copy()


def generate_signals_l27_range_resistance_engulfing_q4_mirror_contrarian(features, signal_params):
    _, bullish_at_support, range_high, _ = _signal_components(features, signal_params)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    valid_exit = np.isfinite(range_high) & np.isfinite(closes)
    short_exit = valid_exit & (closes > range_high)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_at_support, short_exit


_SOURCE_LOGIC_ID = "L27_RANGE_RESISTANCE_BEARISH_ENGULFING"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:27"]
_SOURCE_SUMMARY = "整理區的阻力區形成看跌吞沒時，於下一根K線開盤做空；停損設為進場價加上該週期14期ATR。"
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified_by_source",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "market_fields": ["open", "high", "low", "close"],
    "indicators": [
        "rolling highest(high, range_lookback) excluding current bar",
        "rolling lowest(low, range_lookback) excluding current bar",
        "rolling range width percentage",
    ],
    "core_trigger": "bearish engulfing at resistance within a consolidated rolling range",
    "source_position": "short call credit spread",
    "source_stop": "entry price plus one 14-period ATR",
    "option_requirements": [
        "call credit spread legs",
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
    "execution": "signal confirmed at bar close and filled at the next bar open",
}
_PROXY_ASSUMPTIONS = [
    "以 features.highest(range_lookback) 與 features.lowest(range_lookback) 取得不含當根的前段 rolling high/low，兩者差值為整理區寬度。",
    "整理區代理為 rolling range width 除以 rolling high 不超過 max_range_width_pct；阻力區為當根 high 位於 rolling high 下方四分之一區間內，鏡像支撐區則為當根 low 位於 rolling low 上方四分之一區間內。",
    "看跌吞沒明確定義為前一根陽線、當根陰線、當根 open 大於等於前收且當根 close 小於等於前開；鏡像看漲吞沒反向套用相同實體邊界。",
    "原始 call 信用價差以標的空方方向代理，鏡像與反向假說僅按四象限改變吞沒方向與部位方向；Frame 不重建選擇權腿、履約價、權利金或損益。",
    "來源的進場價加一倍14期ATR停損固定反映於 risk_grid.stop_atr=[1.0]，訊號函式不重做停損；target_r 與 max_bars 由第一階段 risk overlay 提供。",
    "來源未指定 bar interval、session 或 timezone；保留資料集設定。訊號只用當根收盤已知資料及排除當根的 rolling 極值，由 Frame 於下一根 bar 開盤成交。",
    "各假說的結構出場為自身部位方向的區間失效：空方收盤突破 rolling high，多方收盤跌破 rolling low；此為來源未明示出場的推導。",
]
_SIGNAL_PARAMETER_NAMES = ["range_lookback", "max_range_width_pct"]
_SIGNAL_PARAMETER_SETS = [
    {"range_lookback": 12, "max_range_width_pct": 0.02},
    {"range_lookback": 12, "max_range_width_pct": 0.04},
    {"range_lookback": 12, "max_range_width_pct": 0.06},
    {"range_lookback": 20, "max_range_width_pct": 0.02},
    {"range_lookback": 20, "max_range_width_pct": 0.04},
    {"range_lookback": 20, "max_range_width_pct": 0.06},
    {"range_lookback": 30, "max_range_width_pct": 0.02},
    {"range_lookback": 30, "max_range_width_pct": 0.04},
    {"range_lookback": 30, "max_range_width_pct": 0.06},
]
_RISK_GRID = {
    "stop_atr": [1.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [30, 60, 120],
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
        "required_bar_interval": "unspecified_by_source",
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
        "L27_RANGE_RESISTANCE_BEARISH_ENGULFING_Q1_SOURCE",
        "Q1_SOURCE",
        "short",
        "bearish",
        "source line 27; consolidated rolling-range resistance bearish engulfing with short underlying proxy",
        "inferred structural failure when close breaks above the prior rolling resistance high",
        generate_signals_l27_range_resistance_engulfing_q1_source,
    ),
    _record(
        "L27_RANGE_RESISTANCE_BEARISH_ENGULFING_Q2_MIRROR",
        "Q2_MIRROR",
        "long",
        "bullish",
        "mirrored consolidated rolling-range support bullish engulfing with long underlying proxy",
        "inferred structural failure when close breaks below the prior rolling support low",
        generate_signals_l27_range_resistance_engulfing_q2_mirror,
    ),
    _record(
        "L27_RANGE_RESISTANCE_BEARISH_ENGULFING_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source bearish engulfing at rolling resistance with contrarian long underlying direction",
        "inferred structural failure when close breaks below the prior rolling support low",
        generate_signals_l27_range_resistance_engulfing_q3_contrarian,
    ),
    _record(
        "L27_RANGE_RESISTANCE_BEARISH_ENGULFING_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored bullish engulfing at rolling support with contrarian short underlying direction",
        "inferred structural failure when close breaks above the prior rolling resistance high",
        generate_signals_l27_range_resistance_engulfing_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l27_range_resistance_engulfing_q1_source",
    "generate_signals_l27_range_resistance_engulfing_q2_mirror",
    "generate_signals_l27_range_resistance_engulfing_q3_contrarian",
    "generate_signals_l27_range_resistance_engulfing_q4_mirror_contrarian",
]
