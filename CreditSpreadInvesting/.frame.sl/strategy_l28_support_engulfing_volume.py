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


def _lag(values: np.ndarray) -> np.ndarray:
    result = np.full(values.size, np.nan, dtype=np.float64)
    result[1:] = values[:-1]
    return result


def _signal_components(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty.copy(), empty.copy()

    params = {} if signal_params is None else signal_params
    support_lookback = max(2, int(params.get("support_lookback", 20)))
    volume_lookback = max(1, int(params.get("volume_lookback", 20)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)

    previous_opens = _lag(opens)
    previous_highs = _lag(highs)
    previous_lows = _lag(lows)
    previous_closes = _lag(closes)
    previous_volumes = _lag(volumes)

    support = np.asarray(features.lowest(support_lookback), dtype=np.float64)
    resistance = np.asarray(features.highest(support_lookback), dtype=np.float64)
    previous_support = _lag(support)
    previous_resistance = _lag(resistance)
    prior_volume_mean = _prior_mean(volumes, volume_lookback)

    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
        & np.isfinite(previous_opens)
        & np.isfinite(previous_highs)
        & np.isfinite(previous_lows)
        & np.isfinite(previous_closes)
        & np.isfinite(previous_volumes)
        & np.isfinite(support)
        & np.isfinite(resistance)
        & np.isfinite(previous_support)
        & np.isfinite(previous_resistance)
        & np.isfinite(prior_volume_mean)
    )

    zone_tolerance = 0.005
    support_zone = valid & (
        (previous_lows >= previous_support * (1.0 - zone_tolerance))
        & (previous_lows <= previous_support * (1.0 + zone_tolerance))
        & (lows >= support * (1.0 - zone_tolerance))
        & (lows <= support * (1.0 + zone_tolerance))
    )
    resistance_zone = valid & (
        (previous_highs >= previous_resistance * (1.0 - zone_tolerance))
        & (previous_highs <= previous_resistance * (1.0 + zone_tolerance))
        & (highs >= resistance * (1.0 - zone_tolerance))
        & (highs <= resistance * (1.0 + zone_tolerance))
    )

    bullish_engulfing = valid & (
        (previous_closes < previous_opens)
        & (closes > opens)
        & (opens <= previous_closes)
        & (closes >= previous_opens)
        & (np.abs(closes - opens) >= np.abs(previous_closes - previous_opens))
    )
    bearish_engulfing = valid & (
        (previous_closes > previous_opens)
        & (closes < opens)
        & (opens >= previous_closes)
        & (closes <= previous_opens)
        & (np.abs(closes - opens) >= np.abs(previous_closes - previous_opens))
    )
    above_prior_average_volume = volumes > prior_volume_mean

    return (
        np.asarray(support_zone & bullish_engulfing & above_prior_average_volume, dtype=np.bool_),
        np.asarray(resistance_zone & bearish_engulfing & above_prior_average_volume, dtype=np.bool_),
    )


def generate_signals_l28_support_engulfing_volume_q1_source(features, signal_params):
    bullish_trigger, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bullish_trigger, false.copy(), false.copy(), false.copy()


def generate_signals_l28_support_engulfing_volume_q2_mirror(features, signal_params):
    _, bearish_trigger = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_trigger, false.copy()


def generate_signals_l28_support_engulfing_volume_q3_contrarian(features, signal_params):
    bullish_trigger, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_trigger, false.copy()


def generate_signals_l28_support_engulfing_volume_q4_mirror_contrarian(features, signal_params):
    _, bearish_trigger = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bearish_trigger, false.copy(), false.copy(), false.copy()


_SOURCE_LOGIC_ID = "read5_1_l28_support_bullish_engulfing_volume"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:28"]
_SOURCE_SUMMARY = (
    "支撐區形成成交量高於此前均量的看漲吞沒，於下一根K線開盤做多；"
    "來源停損為進場價下方1倍該週期14期ATR。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified_by_source",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying price-direction proxy of a put credit spread",
    "market_fields": ["open", "high", "low", "close", "volume"],
    "indicators": [
        "rolling lowest(low, support_lookback) excluding current bar",
        "rolling highest(high, support_lookback) excluding current bar",
        "prior volume mean over volume_lookback bars excluding current bar",
    ],
    "core_trigger": "support-zone bullish engulfing with current volume above prior rolling average",
    "source_position": "bullish long direction",
    "source_stop": "entry price minus one 14-period ATR",
    "option_requirements": [
        "put credit spread legs",
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
    "支撐區以features.lowest(support_lookback)代理，該rolling low排除當前訊號bar；鏡像方向以同一lookback的rolling high代理阻力區。",
    "支撐區要求吞沒前一根與當根low均位於各自此前rolling low的±0.5%內；鏡像阻力區對high採相同±0.5%條件。",
    "看漲吞沒明確定義為前一根收跌、當根收漲、當根open≤前收、當根close≥前開，且當根實體不小於前一根；看跌吞沒反向套用相同實體邊界。",
    "當根吞沒K線的volume必須嚴格大於其此前volume_lookback根K線的算術平均，均量不含判定當根。",
    "Frame只有標的OHLCV，信用價差方向以標的多空部位代理；訊號bar收盤可知後由下一根bar開盤成交。",
    "來源1倍14期ATR停損固定反映於risk_grid.stop_atr=[1.0]，訊號函式不重複計算停損；target_r與max_bars由第一階段risk overlay提供。",
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
        "required_bar_interval": "unspecified_by_source",
        "required_session": "unspecified_by_source; preserve_dataset_session",
        "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
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
        "L28_SUPPORT_BULLISH_ENGULFING_VOLUME_Q1_SOURCE",
        "Q1_SOURCE",
        "long",
        "bullish",
        "source support-zone bullish engulfing with above-prior-average current volume",
        generate_signals_l28_support_engulfing_volume_q1_source,
    ),
    _record(
        "L28_SUPPORT_BULLISH_ENGULFING_VOLUME_Q2_MIRROR",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored resistance-zone bearish engulfing with above-prior-average current volume",
        generate_signals_l28_support_engulfing_volume_q2_mirror,
    ),
    _record(
        "L28_SUPPORT_BULLISH_ENGULFING_VOLUME_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source support-zone bullish engulfing retained with contrarian short underlying direction",
        generate_signals_l28_support_engulfing_volume_q3_contrarian,
    ),
    _record(
        "L28_SUPPORT_BULLISH_ENGULFING_VOLUME_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored resistance-zone bearish engulfing retained with contrarian long underlying direction",
        generate_signals_l28_support_engulfing_volume_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l28_support_engulfing_volume_q1_source",
    "generate_signals_l28_support_engulfing_volume_q2_mirror",
    "generate_signals_l28_support_engulfing_volume_q3_contrarian",
    "generate_signals_l28_support_engulfing_volume_q4_mirror_contrarian",
]
