from __future__ import annotations

import numpy as np


def _prior_mean(values: np.ndarray, length: int) -> np.ndarray:
    size = values.size
    result = np.full(size, np.nan, dtype=np.float64)
    if size > length:
        cumulative = np.concatenate(
            (np.zeros(1, dtype=np.float64), np.cumsum(values, dtype=np.float64))
        )
        result[length:] = (
            cumulative[length:size] - cumulative[: size - length]
        ) / float(length)
    return result


def _lag(values: np.ndarray, bars: int) -> np.ndarray:
    result = np.full(values.size, np.nan, dtype=np.float64)
    if bars < values.size:
        result[bars:] = values[:-bars]
    return result


def _pattern_triggers(features, signal_params):
    params = {} if signal_params is None else signal_params
    support_lookback = max(3, int(params.get("support_lookback", 20)))
    volume_lookback = max(1, int(params.get("volume_lookback", 20)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)

    open_1 = _lag(opens, 1)
    low_1 = _lag(lows, 1)
    close_1 = _lag(closes, 1)
    volume_1 = _lag(volumes, 1)
    open_2 = _lag(opens, 2)
    close_2 = _lag(closes, 2)

    support = np.asarray(features.lowest(support_lookback), dtype=np.float64)
    resistance = np.asarray(features.highest(support_lookback), dtype=np.float64)
    support_1 = _lag(support, 1)
    resistance_1 = _lag(resistance, 1)
    prior_volume_mean = _prior_mean(volumes, volume_lookback)
    prior_volume_mean_1 = _lag(prior_volume_mean, 1)

    body_2 = np.abs(close_2 - open_2)
    body_1 = np.abs(close_1 - open_1)
    bullish_engulfing = (
        (close_2 < open_2)
        & (close_1 > open_1)
        & (open_1 <= close_2)
        & (close_1 >= open_2)
        & (body_1 >= body_2)
    )
    bearish_engulfing = (
        (close_2 > open_2)
        & (close_1 < open_1)
        & (open_1 >= close_2)
        & (close_1 <= open_2)
        & (body_1 >= body_2)
    )

    body = np.abs(closes - opens)
    lower_shadow = np.minimum(opens, closes) - lows
    upper_shadow = highs - np.maximum(opens, closes)
    hammer = (
        (closes >= opens)
        & (lower_shadow >= 2.0 * body)
        & (upper_shadow <= body)
    )
    inverted_hammer = (
        (closes <= opens)
        & (upper_shadow >= 2.0 * body)
        & (lower_shadow <= body)
    )

    support_zone = (
        np.isfinite(support_1)
        & np.isfinite(support)
        & (low_1 >= support_1 * 0.995)
        & (low_1 <= support_1 * 1.005)
        & (lows >= support * 0.995)
        & (lows <= support * 1.005)
    )
    resistance_zone = (
        np.isfinite(resistance_1)
        & np.isfinite(resistance)
        & (high_1 >= resistance_1 * 0.995)
        & (high_1 <= resistance_1 * 1.005)
        & (highs >= resistance * 0.995)
        & (highs <= resistance * 1.005)
    )
    dual_volume = (
        np.isfinite(prior_volume_mean_1)
        & np.isfinite(prior_volume_mean)
        & (volume_1 > prior_volume_mean_1)
        & (volumes > prior_volume_mean)
    )
    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
    )
    bullish_trigger = (
        valid
        & bullish_engulfing
        & hammer
        & support_zone
        & dual_volume
    )
    bearish_trigger = (
        valid
        & bearish_engulfing
        & inverted_hammer
        & resistance_zone
        & dual_volume
    )
    return (
        np.asarray(bullish_trigger, dtype=np.bool_),
        np.asarray(bearish_trigger, dtype=np.bool_),
    )


def generate_signals_l26_engulfing_hammer_volume_q1_source(features, signal_params):
    bullish_trigger, _ = _pattern_triggers(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bullish_trigger, false.copy(), false.copy(), false.copy()


def generate_signals_l26_engulfing_hammer_volume_q2_mirror(features, signal_params):
    _, bearish_trigger = _pattern_triggers(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_trigger, false.copy()


def generate_signals_l26_engulfing_hammer_volume_q3_contrarian(features, signal_params):
    bullish_trigger, _ = _pattern_triggers(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_trigger, false.copy()


def generate_signals_l26_engulfing_hammer_volume_q4_mirror_contrarian(features, signal_params):
    _, bearish_trigger = _pattern_triggers(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bearish_trigger, false.copy(), false.copy(), false.copy()


_SOURCE_LOGIC_ID = "read5_1_l26_support_bullish_engulfing_hammer_dual_volume"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:26"]
_SOURCE_SUMMARY = (
    "支撐區出現看漲吞沒後的鎚頭線，且吞沒與鎚頭兩根K線成交量均高於此前均量，"
    "於鎚頭線後下一根K線開盤做多；來源停損為進場價下方1倍該週期14期ATR。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified",
    "session": "unspecified",
    "timezone": "unspecified",
    "asset_relation": "single underlying price-direction proxy of a put credit spread",
    "data_requirements": ["open", "high", "low", "close", "volume"],
    "period_basis": "bar-based",
    "core_trigger": "support-zone bullish engulfing followed by hammer with dual above-prior-average volume",
    "source_position": "bullish long direction",
    "source_stop": "entry price minus one 14-period ATR",
}
_PROXY_ASSUMPTIONS = [
    "支撐區以features.lowest(support_lookback)代理，該rolling low排除當前訊號bar；鏡像方向以同樣lookback的rolling high代理阻力區。",
    "看漲吞沒定義為前一根前的K線收跌、前一根K線收漲，且open[前一根]≤close[前二根]、close[前一根]≥open[前二根]、前一根實體不小於前二根；鏡像反轉所有方向條件。",
    "鎚頭線定義為close≥open、下影線=min(open,close)-low≥2×實體、上影線=high-max(open,close)≤實體；鏡像採close≤open、上影線≥2×實體、下影線≤實體。",
    "吞沒線與鎚頭線各自的volume都必須大於其自身之前volume_lookback根K線的算術平均，均量不含被判定的當根K線。",
    "Frame只有標的OHLCV，信用價差方向以標的多空部位代理；訊號bar收盤可知後由下一根bar開盤成交。",
    "來源1倍14期ATR停損由risk_grid交給Frame runner套用，訊號函式不重複計算停損。",
]
_SIGNAL_PARAMETER_NAMES = ["support_lookback", "volume_lookback"]
_SIGNAL_PARAMETER_SETS = [
    {"support_lookback": 10, "volume_lookback": 10},
    {"support_lookback": 10, "volume_lookback": 20},
    {"support_lookback": 10, "volume_lookback": 40},
    {"support_lookback": 20, "volume_lookback": 10},
    {"support_lookback": 20, "volume_lookback": 20},
    {"support_lookback": 20, "volume_lookback": 40},
    {"support_lookback": 40, "volume_lookback": 10},
    {"support_lookback": 40, "volume_lookback": 20},
    {"support_lookback": 40, "volume_lookback": 40},
]
_RISK_GRID = {
    "stop_atr": [1.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [30, 60, 120],
}


def _record(strategy_id, hypothesis, position, direction, entry_origin, function):
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
        "required_session": "unspecified",
        "required_timezone": "unspecified",
        "entry_origin": entry_origin,
        "exit_origin": "risk overlay only: source 1x ATR stop; no additional source signal exit",
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
        "L26_ENGULFING_HAMMER_VOLUME_Q1_SOURCE",
        "Q1_SOURCE",
        "long",
        "bullish",
        "source bullish engulfing followed by hammer at rolling-low support with dual above-prior-average volume",
        generate_signals_l26_engulfing_hammer_volume_q1_source,
    ),
    _record(
        "L26_ENGULFING_HAMMER_VOLUME_Q2_MIRROR",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored bearish engulfing followed by inverted hammer at rolling-high resistance with dual above-prior-average volume",
        generate_signals_l26_engulfing_hammer_volume_q2_mirror,
    ),
    _record(
        "L26_ENGULFING_HAMMER_VOLUME_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source bullish support pattern retained with contrarian short direction",
        generate_signals_l26_engulfing_hammer_volume_q3_contrarian,
    ),
    _record(
        "L26_ENGULFING_HAMMER_VOLUME_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored bearish resistance pattern retained with contrarian long direction",
        generate_signals_l26_engulfing_hammer_volume_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l26_engulfing_hammer_volume_q1_source",
    "generate_signals_l26_engulfing_hammer_volume_q2_mirror",
    "generate_signals_l26_engulfing_hammer_volume_q3_contrarian",
    "generate_signals_l26_engulfing_hammer_volume_q4_mirror_contrarian",
]
