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
    value_proxy_window = max(2, int(params.get("value_proxy_window", 40)))
    value_area_tolerance = max(0.0, float(params.get("value_area_tolerance", 0.004)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    value_proxy = np.asarray(features.sma(value_proxy_window), dtype=np.float64)
    previous_value_proxy = _lag(value_proxy)
    previous_closes = _lag(closes)
    previous_opens = _lag(opens)

    valid = (
        np.isfinite(opens)
        & np.isfinite(closes)
        & np.isfinite(previous_closes)
        & np.isfinite(previous_opens)
        & np.isfinite(previous_value_proxy)
    )
    value_lower = previous_value_proxy * (1.0 - value_area_tolerance)
    value_upper = previous_value_proxy * (1.0 + value_area_tolerance)
    in_value_area = valid & (closes >= value_lower) & (closes <= value_upper)

    green = closes > opens
    red = closes < opens
    first_green = green & (previous_closes <= previous_opens)
    first_red = red & (previous_closes >= previous_opens)

    base_first_green = in_value_area & first_green
    mirror_first_red = in_value_area & first_red

    base_confirmed = np.zeros(size, dtype=np.bool_)
    mirror_confirmed = np.zeros(size, dtype=np.bool_)
    base_confirmed[1:] = (
        base_first_green[:-1]
        & (opens[1:] > closes[:-1])
        & (closes[1:] > closes[:-1])
    )
    mirror_confirmed[1:] = (
        mirror_first_red[:-1]
        & (opens[1:] < closes[:-1])
        & (closes[1:] < closes[:-1])
    )

    base_failure = valid & (closes < value_lower)
    mirror_failure = valid & (closes > value_upper)
    base_bullish_state = valid & (closes > value_upper)
    mirror_bearish_state = valid & (closes < value_lower)
    return (
        np.asarray(base_confirmed, dtype=np.bool_),
        np.asarray(mirror_confirmed, dtype=np.bool_),
        np.asarray(base_failure, dtype=np.bool_),
        np.asarray(mirror_failure, dtype=np.bool_),
        np.asarray(base_bullish_state, dtype=np.bool_),
        np.asarray(mirror_bearish_state, dtype=np.bool_),
    )


def generate_signals_l36_spx_daily_value_reversal_q1_source(features, signal_params):
    base_confirmed, _, base_failure, _, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return base_confirmed, base_failure, false.copy(), false.copy()


def generate_signals_l36_spx_daily_value_reversal_q2_mirror(features, signal_params):
    _, mirror_confirmed, _, mirror_failure, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_confirmed, mirror_failure


def generate_signals_l36_spx_daily_value_reversal_q3_contrarian(features, signal_params):
    base_confirmed, _, _, _, base_bullish_state, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), base_confirmed, base_bullish_state


def generate_signals_l36_spx_daily_value_reversal_q4_mirror_contrarian(features, signal_params):
    _, mirror_confirmed, _, _, _, mirror_bearish_state = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return mirror_confirmed, mirror_bearish_state, false.copy(), false.copy()


_SOURCE_LOGIC_ID = "l36_spx_daily_value_reversal"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:36"]
_SOURCE_SUMMARY = (
    "SPX日線在4,360附近價值區出現第一根綠色K線，下一交易日開高且收高後做多；"
    "來源部位為賣出4,350、買入4,345的30至45 DTE看跌信用價差。"
)
_SOURCE_REQUIREMENTS = {
    "asset": "SPX",
    "required_bar_interval": "1d",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "market_fields": ["open", "close"],
    "core_trigger": "first green daily candle in the 4,360 value area followed by a next-day higher open and higher close",
    "source_position": "short put credit spread",
    "source_option_legs": {
        "short_put_strike": "4,350",
        "long_put_strike": "4,345",
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
    "execution": "first-green setup is evaluated from completed daily bars; next-day confirmation is known at its close and Frame fills on the following daily bar open",
}
_PROXY_ASSUMPTIONS = [
    "來源一次性4,360價值區以value_proxy_window根已完成日線收盤的rolling SMA代理；訊號bar使用前一根已完成rolling值，value_area_tolerance定義上下容差區間。",
    "第一根綠K以當根close大於open且前一根不是綠K（close小於等於open）的可計算轉折條件代理；鏡像以第一根紅K（close小於open且前一根不是紅K）代理。",
    "原始方向的次日開高收高定義為次日open與close均嚴格高於第一根綠K的close；鏡像方向則均嚴格低於第一根紅K的close。次日收盤才確認，因此訊號寫在次日索引並由Frame於再下一根日線開盤成交。",
    "4,350與4,345履約價、30至45 DTE、權利金、期權鏈、乘數及期權損益不在MarketData，原始看跌信用價差只以SPX標的多方方向proxy表示；不得由訊號函式捏造期權腿或DTE。",
    "Q1多方在收盤跌破rolling價值區下緣時結構失效出場；Q2空方在收盤突破上緣時失效；Q3與Q4反向假說分別在原始多方或鏡像空方狀態延續至區外時出場，均屬inferred_exit。",
    "訊號僅使用當根收盤及此前已知rolling值，不使用未來bar；ATR停損、目標R及最大持有bar由Frame risk overlay統一處理。",
]
_SIGNAL_PARAMETER_NAMES = ["value_proxy_window", "value_area_tolerance"]
_SIGNAL_PARAMETER_SETS = [
    {"value_proxy_window": 20, "value_area_tolerance": 0.002},
    {"value_proxy_window": 20, "value_area_tolerance": 0.004},
    {"value_proxy_window": 20, "value_area_tolerance": 0.008},
    {"value_proxy_window": 40, "value_area_tolerance": 0.002},
    {"value_proxy_window": 40, "value_area_tolerance": 0.004},
    {"value_proxy_window": 40, "value_area_tolerance": 0.008},
    {"value_proxy_window": 60, "value_area_tolerance": 0.002},
    {"value_proxy_window": 60, "value_area_tolerance": 0.004},
    {"value_proxy_window": 60, "value_area_tolerance": 0.008},
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
        "l36_spx_daily_value_reversal_q1_source",
        "Q1_SOURCE",
        "long",
        "bullish",
        "first green daily candle in the prior rolling value proxy zone followed by a next-day higher open and higher close",
        "inferred structural exit when daily close falls below the rolling value proxy lower boundary",
        generate_signals_l36_spx_daily_value_reversal_q1_source,
    ),
    _record(
        "l36_spx_daily_value_reversal_q2_mirror",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored first red daily candle in the prior rolling value proxy zone followed by a next-day lower open and lower close",
        "inferred structural exit when daily close rises above the rolling value proxy upper boundary",
        generate_signals_l36_spx_daily_value_reversal_q2_mirror,
    ),
    _record(
        "l36_spx_daily_value_reversal_q3_contrarian",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source first-green and next-day higher-open/higher-close trigger with contrarian short direction",
        "inferred exit while the source bullish state persists above the rolling value proxy upper boundary",
        generate_signals_l36_spx_daily_value_reversal_q3_contrarian,
    ),
    _record(
        "l36_spx_daily_value_reversal_q4_mirror_contrarian",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored first-red and next-day lower-open/lower-close trigger with contrarian long direction",
        "inferred exit while the mirrored bearish state persists below the rolling value proxy lower boundary",
        generate_signals_l36_spx_daily_value_reversal_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l36_spx_daily_value_reversal_q1_source",
    "generate_signals_l36_spx_daily_value_reversal_q2_mirror",
    "generate_signals_l36_spx_daily_value_reversal_q3_contrarian",
    "generate_signals_l36_spx_daily_value_reversal_q4_mirror_contrarian",
]
