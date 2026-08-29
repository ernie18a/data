from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray, bars: int = 1) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=np.float64)
    if bars < values.size:
        result[bars:] = values[:-bars]
    return result


def _lag_bool(values: np.ndarray) -> np.ndarray:
    result = np.zeros(values.shape, dtype=np.bool_)
    if values.size > 1:
        result[1:] = values[:-1]
    return result


def _event_level(events: np.ndarray, values: np.ndarray) -> np.ndarray:
    if values.size == 0:
        return np.empty(0, dtype=np.float64)
    indexes = np.arange(values.size, dtype=np.int64)
    last_event = np.maximum.accumulate(np.where(events, indexes, -1))
    safe_indexes = np.maximum(last_event, 0)
    levels = np.take(values, safe_indexes)
    return np.where(last_event >= 0, levels, np.nan)


def _signal_components(features, signal_params):
    params = {} if signal_params is None else signal_params
    trend_lookback = max(2, int(params.get("trend_lookback", 200)))
    support_lookback = max(2, int(params.get("support_lookback", 20)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    size = int(features.market.size)

    trend_average = np.asarray(features.sma(trend_lookback), dtype=np.float64)
    trend_slope_bars = max(1, trend_lookback // 10)
    prior_trend_average = _lag(trend_average, trend_slope_bars)
    support_level = np.asarray(features.lowest(support_lookback), dtype=np.float64)
    resistance_level = np.asarray(features.highest(support_lookback), dtype=np.float64)

    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
    )
    trend_valid = valid & np.isfinite(trend_average) & np.isfinite(prior_trend_average)
    uptrend = trend_valid & (closes > trend_average) & (trend_average > prior_trend_average)
    downtrend = trend_valid & (closes < trend_average) & (trend_average < prior_trend_average)

    support_scale = np.maximum(np.abs(support_level), np.finfo(np.float64).eps)
    resistance_scale = np.maximum(np.abs(resistance_level), np.finfo(np.float64).eps)
    support_zone = (
        valid
        & np.isfinite(support_level)
        & (np.abs(lows - support_level) <= support_scale * 0.02)
    )
    resistance_zone = (
        valid
        & np.isfinite(resistance_level)
        & (np.abs(highs - resistance_level) <= resistance_scale * 0.02)
    )

    candle_range = highs - lows
    body = np.abs(closes - opens)
    lower_shadow = np.minimum(opens, closes) - lows
    upper_shadow = highs - np.maximum(opens, closes)
    candle_valid = valid & (candle_range > 0.0) & (body > 0.0)
    hammer = candle_valid & (
        (body <= candle_range * 0.5)
        & (lower_shadow >= body * 2.0)
        & (upper_shadow <= body)
    )
    mirrored_hammer = candle_valid & (
        (body <= candle_range * 0.5)
        & (upper_shadow >= body * 2.0)
        & (lower_shadow <= body)
    )

    bullish_setup = uptrend & support_zone & hammer
    bearish_setup = downtrend & resistance_zone & mirrored_hammer
    previous_high = _lag(highs)
    previous_low = _lag(lows)
    valid_breakout = valid & np.isfinite(previous_high) & np.isfinite(previous_low)
    bullish_breakout = valid_breakout & _lag_bool(bullish_setup) & (
        (highs > previous_high) & (closes > previous_high)
    )
    bearish_breakout = valid_breakout & _lag_bool(bearish_setup) & (
        (lows < previous_low) & (closes < previous_low)
    )

    bullish_hammer_low = _event_level(bullish_setup, lows)
    bullish_hammer_high = _event_level(bullish_setup, highs)
    bearish_hammer_low = _event_level(bearish_setup, lows)
    bearish_hammer_high = _event_level(bearish_setup, highs)
    return (
        np.asarray(bullish_breakout, dtype=np.bool_),
        np.asarray(bearish_breakout, dtype=np.bool_),
        bullish_hammer_low,
        bullish_hammer_high,
        bearish_hammer_low,
        bearish_hammer_high,
        size,
    )


def generate_signals_l32_trend_hammer_breakout_q1_source(features, signal_params):
    bullish_breakout, _, hammer_low, _, _, _, size = _signal_components(
        features, signal_params
    )
    closes = np.asarray(features.market.closes, dtype=np.float64)
    long_exit = np.isfinite(hammer_low) & np.isfinite(closes) & (closes < hammer_low)
    false = np.zeros(size, dtype=np.bool_)
    return bullish_breakout, long_exit, false.copy(), false.copy()


def generate_signals_l32_trend_hammer_breakout_q2_mirror(features, signal_params):
    _, bearish_breakout, _, _, _, hammer_high, size = _signal_components(
        features, signal_params
    )
    closes = np.asarray(features.market.closes, dtype=np.float64)
    short_exit = np.isfinite(hammer_high) & np.isfinite(closes) & (closes > hammer_high)
    false = np.zeros(size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_breakout, short_exit


def generate_signals_l32_trend_hammer_breakout_q3_contrarian(features, signal_params):
    bullish_breakout, _, _, hammer_high, _, _, size = _signal_components(
        features, signal_params
    )
    closes = np.asarray(features.market.closes, dtype=np.float64)
    short_exit = np.isfinite(hammer_high) & np.isfinite(closes) & (closes > hammer_high)
    false = np.zeros(size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_breakout, short_exit


def generate_signals_l32_trend_hammer_breakout_q4_mirror_contrarian(
    features, signal_params
):
    _, bearish_breakout, _, _, hammer_low, _, size = _signal_components(
        features, signal_params
    )
    closes = np.asarray(features.market.closes, dtype=np.float64)
    long_exit = np.isfinite(hammer_low) & np.isfinite(closes) & (closes < hammer_low)
    false = np.zeros(size, dtype=np.bool_)
    return bearish_breakout, long_exit, false.copy(), false.copy()


_SOURCE_LOGIC_ID = "L32_LONG_TERM_TREND_SUPPORT_HAMMER_BREAKOUT"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:32"]
_SOURCE_SUMMARY = (
    "長期上升趨勢中價格回撤至支撐區形成鎚頭線，下一根K線突破前一根高點時做多；"
    "價格跌破鎚頭線低點停損，來源部位為put信用價差。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified_by_source; preserve_dataset_bar_interval",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "market_fields": ["open", "high", "low", "close"],
    "period_basis": "bar-based proxy; source does not specify an interval or day count",
    "indicators": [
        "long-term rolling SMA and its prior slope",
        "prior rolling support or resistance extreme",
        "single-bar hammer or mirrored hammer geometry",
    ],
    "core_trigger": (
        "long-term trend and support retracement hammer followed by a close-confirmed "
        "break above the hammer high"
    ),
    "source_position": "long underlying proxy for put credit spread",
    "source_exit": "price falls below the hammer low",
    "execution": "breakout confirmed at bar close and filled at the next bar open",
    "unavailable_data": [
        "option chain",
        "put spread strikes",
        "strike quotes",
        "net credit",
        "option multiplier",
        "option P&L",
        "timestamp and session fields",
    ],
}
_PROXY_ASSUMPTIONS = [
    "選擇權put信用價差以單一標的多方方向代理，Frame不重建履約價、權利金、乘數或選擇權損益。",
    "長期上升趨勢代理為收盤SMA(trend_lookback)高於trend_lookback/10根前的SMA且當根收盤高於SMA；鏡像下降趨勢反向套用。",
    "支撐區代理為當根鎚頭線最低價與不含當根的support_lookback期rolling最低價相差不超過2%；鏡像阻力區以rolling最高價及最高價反向套用。",
    "鎚頭線定義為非零實體、實體不超過全幅50%、下影線至少為實體兩倍且上影線不超過實體；鏡像鎚頭線反轉上下影線條件。",
    "突破訊號只在鎚頭線後一根K線收盤高於前一根高點時成立，並由Frame於下一根K線開盤成交；鏡像訊號要求收盤低於前一根低點。",
    "鎚頭低點以最近已確認setup的固定值向前傳遞，僅使用當時或更早資料，作為來源明示失效位的無逐Bar狀態代理；鏡像短方用鏡像鎚頭高點。",
    "反向假說不共用方向相反的失效位：原始setup反向做空以突破鎚頭高點作空方失效，鏡像setup反向做多以鏡像鎚頭低點作多方失效。",
    "來源未指定週期、session或timezone；所有週期均是明示bar-based代理並保留資料集設定，ATR停損、目標R與最大持有bars由risk overlay統一套用。",
]
_SIGNAL_PARAMETER_NAMES = ["trend_lookback", "support_lookback"]
_SIGNAL_PARAMETER_SETS = [
    {"trend_lookback": 100, "support_lookback": 10},
    {"trend_lookback": 100, "support_lookback": 20},
    {"trend_lookback": 100, "support_lookback": 40},
    {"trend_lookback": 200, "support_lookback": 10},
    {"trend_lookback": 200, "support_lookback": 20},
    {"trend_lookback": 200, "support_lookback": 40},
    {"trend_lookback": 300, "support_lookback": 10},
    {"trend_lookback": 300, "support_lookback": 20},
    {"trend_lookback": 300, "support_lookback": 40},
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
    inferred_exit,
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
        "required_bar_interval": "unspecified_by_source; preserve_dataset_bar_interval",
        "required_session": "unspecified_by_source; preserve_dataset_session",
        "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
        "entry_origin": entry_origin,
        "exit_origin": exit_origin,
        "inferred_exit": inferred_exit,
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
        "L32_LONG_TERM_TREND_SUPPORT_HAMMER_BREAKOUT_Q1_SOURCE",
        "Q1_SOURCE",
        "long",
        "bullish",
        "source long-term uptrend support hammer followed by close-confirmed break above the hammer high",
        "source stop: close below the latest confirmed hammer low",
        False,
        generate_signals_l32_trend_hammer_breakout_q1_source,
    ),
    _record(
        "L32_LONG_TERM_TREND_SUPPORT_HAMMER_BREAKOUT_Q2_MIRROR",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored long-term downtrend resistance upper-shadow candle followed by close-confirmed break below its low",
        "mirrored stop proxy: close above the latest confirmed mirrored candle high",
        True,
        generate_signals_l32_trend_hammer_breakout_q2_mirror,
    ),
    _record(
        "L32_LONG_TERM_TREND_SUPPORT_HAMMER_BREAKOUT_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source bullish trend-support hammer breakout retained with contrarian short direction",
        "contrarian short invalidation proxy: close above the latest confirmed bullish hammer high",
        True,
        generate_signals_l32_trend_hammer_breakout_q3_contrarian,
    ),
    _record(
        "L32_LONG_TERM_TREND_SUPPORT_HAMMER_BREAKOUT_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored bearish trend-resistance candle breakdown retained with contrarian long direction",
        "mirror-contrarian long invalidation proxy: close below the latest confirmed mirrored candle low",
        True,
        generate_signals_l32_trend_hammer_breakout_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l32_trend_hammer_breakout_q1_source",
    "generate_signals_l32_trend_hammer_breakout_q2_mirror",
    "generate_signals_l32_trend_hammer_breakout_q3_contrarian",
    "generate_signals_l32_trend_hammer_breakout_q4_mirror_contrarian",
]
