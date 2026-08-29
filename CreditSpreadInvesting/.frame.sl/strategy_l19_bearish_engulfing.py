from __future__ import annotations

import numpy as np


def _pattern_components(features):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)

    previous_opens = np.full(size, np.nan, dtype=np.float64)
    previous_highs = np.full(size, np.nan, dtype=np.float64)
    previous_lows = np.full(size, np.nan, dtype=np.float64)
    previous_closes = np.full(size, np.nan, dtype=np.float64)
    previous_opens[1:] = opens[:-1]
    previous_highs[1:] = highs[:-1]
    previous_lows[1:] = lows[:-1]
    previous_closes[1:] = closes[:-1]

    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(previous_opens)
        & np.isfinite(previous_highs)
        & np.isfinite(previous_lows)
        & np.isfinite(previous_closes)
    )
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
    prior_two_bar_high = np.asarray(features.highest(2), dtype=np.float64)
    prior_two_bar_low = np.asarray(features.lowest(2), dtype=np.float64)
    close_above_prior_high = np.isfinite(prior_two_bar_high) & (closes > prior_two_bar_high)
    close_below_prior_low = np.isfinite(prior_two_bar_low) & (closes < prior_two_bar_low)
    return bearish_engulfing, bullish_engulfing, close_above_prior_high, close_below_prior_low


def generate_signals_l19_bearish_engulfing_q1_source(features, signal_params):
    bearish_engulfing, _, close_above_prior_high, _ = _pattern_components(features)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_engulfing, close_above_prior_high


def generate_signals_l19_bearish_engulfing_q2_mirror(features, signal_params):
    _, bullish_engulfing, _, close_below_prior_low = _pattern_components(features)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bullish_engulfing, close_below_prior_low, false.copy(), false.copy()


def generate_signals_l19_bearish_engulfing_q3_contrarian(features, signal_params):
    bearish_engulfing, _, _, close_below_prior_low = _pattern_components(features)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bearish_engulfing, close_below_prior_low, false.copy(), false.copy()


def generate_signals_l19_bearish_engulfing_q4_mirror_contrarian(features, signal_params):
    _, bullish_engulfing, close_above_prior_high, _ = _pattern_components(features)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_engulfing, close_above_prior_high


_SOURCE_LOGIC_ID = "L19_BEARISH_ENGULFING"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:19"]
_SOURCE_SUMMARY = "出現 bearish engulfing 型態時，於該K線開盤進場賣出 call 信用價差。"
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified",
    "session": "unspecified_by_source; preserve_dataset_session",
    "timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "data_requirements": ["open", "high", "low", "close"],
    "period_basis": "bar-based",
    "core_trigger": "confirmed bearish engulfing candlestick pattern",
    "source_position": "short call credit spread",
    "option_requirements": [
        "call credit spread legs",
        "strike prices and option quotes",
        "net credit and option multiplier",
    ],
    "unavailable_data": [
        "option chain",
        "strike quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "timestamp and session fields",
    ],
    "execution": "source claims same-pattern-bar open; Frame uses close-confirmed signal and next-bar-open fill",
}
_PROXY_ASSUMPTIONS = [
    "bearish engulfing 以前一根陽線、當根陰線，且當根實體開盤價不低於前收、收盤價不高於前開表示；等號納入吞沒邊界。",
    "鏡像方向以 bullish engulfing 表示：以前一根陰線、當根陽線，且當根實體反向吞沒前根實體。",
    "型態必須等當根收盤才能確認；來源聲稱於該K線開盤進場在當時不可知，因此訊號於確認收盤產生並由 Frame 下一根 bar 開盤成交，entry_conversion 明確為 proxy。",
    "Frame 僅有標的 OHLCV，無法重建 call 信用價差的選擇權腿、履約價、權利金、乘數或損益；原始 call 信用價差以標的 short 代理，鏡像與反向假說改變標的方向。",
    "來源未提供出場；各假說以符合自身方向的結構失效推導出場：多方在收盤跌破前兩根 bar 的 rolling low，空方在收盤突破前兩根 bar 的 rolling high。",
    "來源未指定 bar interval、session 或 timezone；保留資料集設定，訊號只使用當根及已完成前根資料，rolling 極值排除當根。",
]
_SIGNAL_PARAMETER_NAMES = []
_SIGNAL_PARAMETER_SETS = [{}]
_RISK_GRID = {
    "stop_atr": [1.5, 2.0, 3.0],
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
        "L19_BEARISH_ENGULFING_Q1_SOURCE",
        "Q1_SOURCE",
        "short",
        "bearish",
        "confirmed bearish engulfing with short underlying proxy for the source call credit spread",
        "inferred structural failure when close breaks above the prior two-bar rolling high",
        generate_signals_l19_bearish_engulfing_q1_source,
    ),
    _record(
        "L19_BEARISH_ENGULFING_Q2_MIRROR",
        "Q2_MIRROR",
        "long",
        "bullish",
        "mirrored bullish engulfing with long underlying proxy",
        "inferred structural failure when close breaks below the prior two-bar rolling low",
        generate_signals_l19_bearish_engulfing_q2_mirror,
    ),
    _record(
        "L19_BEARISH_ENGULFING_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source bearish engulfing trigger with contrarian long underlying proxy",
        "inferred structural failure when close breaks below the prior two-bar rolling low",
        generate_signals_l19_bearish_engulfing_q3_contrarian,
    ),
    _record(
        "L19_BEARISH_ENGULFING_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored bullish engulfing trigger with contrarian short underlying proxy",
        "inferred structural failure when close breaks above the prior two-bar rolling high",
        generate_signals_l19_bearish_engulfing_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l19_bearish_engulfing_q1_source",
    "generate_signals_l19_bearish_engulfing_q2_mirror",
    "generate_signals_l19_bearish_engulfing_q3_contrarian",
    "generate_signals_l19_bearish_engulfing_q4_mirror_contrarian",
]
