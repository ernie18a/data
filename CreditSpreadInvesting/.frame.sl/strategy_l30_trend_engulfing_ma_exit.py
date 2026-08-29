from __future__ import annotations

import numpy as np


def _lag(values: np.ndarray, bars: int = 1) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=np.float64)
    if bars < values.size:
        result[bars:] = values[:-bars]
    return result


def _prior_mean(values: np.ndarray, length: int) -> np.ndarray:
    size = values.size
    result = np.full(values.shape, np.nan, dtype=np.float64)
    if values.size > length:
        cumulative = np.concatenate(
            (np.zeros(1, dtype=np.float64), np.cumsum(values, dtype=np.float64))
        )
        result[length:] = (
            cumulative[length:size] - cumulative[: size - length]
        ) / float(length)
    return result


def _signal_components(features, signal_params):
    size = int(features.market.size)
    params = {} if signal_params is None else signal_params
    trend_lookback = max(1, int(params.get("trend_lookback", 5)))
    volume_lookback = max(1, int(params.get("volume_lookback", 20)))

    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    sma20 = np.asarray(features.sma(20), dtype=np.float64)

    previous_opens = _lag(opens)
    previous_closes = _lag(closes)
    previous_sma20 = _lag(sma20)
    prior_trend_sma20 = _lag(sma20, trend_lookback)
    prior_volume_mean = _prior_mean(volumes, volume_lookback)

    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
        & np.isfinite(previous_opens)
        & np.isfinite(previous_closes)
        & np.isfinite(sma20)
        & np.isfinite(previous_sma20)
        & np.isfinite(prior_trend_sma20)
        & np.isfinite(prior_volume_mean)
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
    high_volume = valid & (volumes > prior_volume_mean)
    uptrend = valid & (closes > sma20) & (sma20 > prior_trend_sma20)
    downtrend = valid & (closes < sma20) & (sma20 < prior_trend_sma20)
    bullish_trigger = bullish_engulfing & high_volume & uptrend
    bearish_trigger = bearish_engulfing & high_volume & downtrend

    cross_down_sma20 = valid & (
        (closes < sma20) & (previous_closes >= previous_sma20)
    )
    cross_up_sma20 = valid & (
        (closes > sma20) & (previous_closes <= previous_sma20)
    )
    return (
        np.asarray(bullish_trigger, dtype=np.bool_),
        np.asarray(bearish_trigger, dtype=np.bool_),
        np.asarray(cross_down_sma20, dtype=np.bool_),
        np.asarray(cross_up_sma20, dtype=np.bool_),
    )


def generate_signals_l30_trend_engulfing_ma_exit_q1_source(features, signal_params):
    bullish_trigger, _, cross_down_sma20, _ = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bullish_trigger, cross_down_sma20, false.copy(), false.copy()


def generate_signals_l30_trend_engulfing_ma_exit_q2_mirror(features, signal_params):
    _, bearish_trigger, _, cross_up_sma20 = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bearish_trigger, cross_up_sma20


def generate_signals_l30_trend_engulfing_ma_exit_q3_contrarian(
    features, signal_params
):
    bullish_trigger, _, _, cross_up_sma20 = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), bullish_trigger, cross_up_sma20


def generate_signals_l30_trend_engulfing_ma_exit_q4_mirror_contrarian(
    features, signal_params
):
    _, bearish_trigger, cross_down_sma20, _ = _signal_components(
        features, signal_params
    )
    false = np.zeros(features.market.size, dtype=np.bool_)
    return bearish_trigger, cross_down_sma20, false.copy(), false.copy()


_SOURCE_LOGIC_ID = "L30_TREND_BULLISH_ENGULFING_MA_EXIT"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:30"]
_SOURCE_SUMMARY = (
    "上升趨勢中出現相對此前均量較大的看漲吞沒，於下一根K線開盤做多；"
    "持倉價格穿越20期均線時出場。"
)
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified_by_source; preserve_dataset_bar_interval",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "asset_relation": "single underlying",
    "market_fields": ["open", "high", "low", "close", "volume"],
    "period_basis": "bar-based",
    "indicators": ["20-period SMA on close", "prior-volume arithmetic mean"],
    "core_trigger": "uptrend bullish engulfing with volume above the prior average",
    "source_position": "long underlying direction",
    "source_exit": "price crossing the 20-period SMA",
    "execution": "signal confirmed at bar close and filled at the next bar open",
}
_PROXY_ASSUMPTIONS = [
    "Frame以單一標的long方向代理來源的做多交易，無法重建任何選擇權腿、權利金或選擇權損益。",
    "上升趨勢明確定義為當根close高於SMA20且SMA20高於trend_lookback根前的SMA20；鏡像下降趨勢反向定義。",
    "看漲吞沒定義為前一根陰線、當根陽線、當根open不高於前收、當根close不低於前開，且當根實體不小於前一根實體。",
    "鏡像看跌吞沒反轉K線方向與實體邊界條件；成交量條件不因鏡像而反轉。",
    "成交量較大明確定義為當根volume嚴格大於此前volume_lookback根K線的算術平均，均量排除當根及所有未來資料。",
    "來源的持倉價格穿越SMA20依部位方向解讀：多方為close由上向下穿越，空方為close由下向上穿越；各假說分別使用其部位失效方向。",
    "SMA20固定忠實保留來源的20期設定；trend_lookback與volume_lookback是未指定週期的可測代理參數。",
    "訊號僅在當根收盤確認，依Frame契約於下一根K線開盤成交；ATR停損、目標R與最大持有bars由risk overlay統一處理。",
]
_SIGNAL_PARAMETER_NAMES = ["trend_lookback", "volume_lookback"]
_SIGNAL_PARAMETER_SETS = [
    {"trend_lookback": 3, "volume_lookback": 10},
    {"trend_lookback": 3, "volume_lookback": 20},
    {"trend_lookback": 3, "volume_lookback": 40},
    {"trend_lookback": 5, "volume_lookback": 10},
    {"trend_lookback": 5, "volume_lookback": 20},
    {"trend_lookback": 5, "volume_lookback": 40},
    {"trend_lookback": 10, "volume_lookback": 10},
    {"trend_lookback": 10, "volume_lookback": 20},
    {"trend_lookback": 10, "volume_lookback": 40},
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
        "required_bar_interval": "unspecified_by_source; preserve_dataset_bar_interval",
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
        "L30_TREND_BULLISH_ENGULFING_MA_EXIT_Q1_SOURCE",
        "Q1_SOURCE",
        "long",
        "bullish",
        "source uptrend bullish engulfing with above-prior-average volume",
        "source directional interpretation: close crosses down through SMA20 for long-position exit",
        generate_signals_l30_trend_engulfing_ma_exit_q1_source,
    ),
    _record(
        "L30_TREND_BULLISH_ENGULFING_MA_EXIT_Q2_MIRROR",
        "Q2_MIRROR",
        "short",
        "bearish",
        "mirrored downtrend bearish engulfing with above-prior-average volume",
        "mirrored directional interpretation: close crosses up through SMA20 for short-position exit",
        generate_signals_l30_trend_engulfing_ma_exit_q2_mirror,
    ),
    _record(
        "L30_TREND_BULLISH_ENGULFING_MA_EXIT_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "short",
        "bearish",
        "source uptrend bullish engulfing with contrarian short direction",
        "thesis-consistent short invalidation: close crosses up through SMA20",
        generate_signals_l30_trend_engulfing_ma_exit_q3_contrarian,
    ),
    _record(
        "L30_TREND_BULLISH_ENGULFING_MA_EXIT_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "long",
        "bullish",
        "mirrored downtrend bearish engulfing with contrarian long direction",
        "thesis-consistent long invalidation: close crosses down through SMA20",
        generate_signals_l30_trend_engulfing_ma_exit_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_signals_l30_trend_engulfing_ma_exit_q1_source",
    "generate_signals_l30_trend_engulfing_ma_exit_q2_mirror",
    "generate_signals_l30_trend_engulfing_ma_exit_q3_contrarian",
    "generate_signals_l30_trend_engulfing_ma_exit_q4_mirror_contrarian",
]
