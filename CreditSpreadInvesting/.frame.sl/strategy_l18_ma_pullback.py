from __future__ import annotations

import numpy as np


def _slope_up(values: np.ndarray, lookback: int) -> np.ndarray:
    result = np.zeros(values.size, dtype=np.bool_)
    result[lookback:] = values[lookback:] > values[:-lookback]
    return result


def _slope_down(values: np.ndarray, lookback: int) -> np.ndarray:
    result = np.zeros(values.size, dtype=np.bool_)
    result[lookback:] = values[lookback:] < values[:-lookback]
    return result


_SIGNAL_PARAMETER_NAMES = ["slope_lookback", "volatility_lookback"]
_SIGNAL_PARAMETER_SETS = [
    {"slope_lookback": 1, "volatility_lookback": 1},
    {"slope_lookback": 1, "volatility_lookback": 3},
    {"slope_lookback": 1, "volatility_lookback": 5},
    {"slope_lookback": 3, "volatility_lookback": 1},
    {"slope_lookback": 3, "volatility_lookback": 3},
    {"slope_lookback": 3, "volatility_lookback": 5},
    {"slope_lookback": 5, "volatility_lookback": 1},
    {"slope_lookback": 5, "volatility_lookback": 3},
    {"slope_lookback": 5, "volatility_lookback": 5},
]

_RISK_GRID = {
    "stop_atr": [1.5, 2.0, 3.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [30, 60, 120],
}

_SOURCE_LOGIC_ID = "l18_ma_pullback_put_credit_spread"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:18"]
_SOURCE_SUMMARY = "價格回落觸及 200 期移動平均線，20、50、200 期移動平均線斜率均向上且波動率上升，進場賣出 put 信用價差。"
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified",
    "session": "unspecified",
    "timezone": "unspecified",
    "asset_relation": "single underlying",
    "data_requirements": ["high", "low", "close"],
    "period_basis": "bar-based",
}
_PROXY_ASSUMPTIONS = [
    "put 信用價差的看多方向以單一標的 long entry 代理，Frame 不重建選擇權部位。",
    "回落觸及以當根 low <= SMA200 且前一根 close > 前一根 SMA200 表示；鏡像使用當根 high >= SMA200 且前一根 close < 前一根 SMA200。",
    "20、50、200 期均線均使用收盤價 SMA；200 期僅表示 200-bar 計算。",
    "波動率以 20-bar 收盤價 rolling standard deviation 表示，當期值高於 volatility_lookback bars 前的值即為上升。",
    "下一根 bar 開盤成交與 ATR、目標 R、持有 bar 數由 Frame risk overlay 處理。",
]


def generate_signals_l18_ma_pullback_q1_source(features, signal_params):
    size = features.market.size
    slope_lookback = max(1, int(signal_params.get("slope_lookback", 3)))
    volatility_lookback = max(1, int(signal_params.get("volatility_lookback", 3)))
    closes = features.market.closes
    lows = features.market.lows
    sma20 = features.sma(20)
    sma50 = features.sma(50)
    sma200 = features.sma(200)
    volatility = features.std(20)
    prior_above = np.zeros(size, dtype=np.bool_)
    prior_above[1:] = closes[:-1] > sma200[:-1]
    pullback_touch = prior_above & (lows <= sma200)
    slopes_up = (
        _slope_up(sma20, slope_lookback)
        & _slope_up(sma50, slope_lookback)
        & _slope_up(sma200, slope_lookback)
    )
    volatility_up = _slope_up(volatility, volatility_lookback)
    long_entry = pullback_touch & slopes_up & volatility_up
    long_exit = closes < sma200
    short_entry = np.zeros(size, dtype=np.bool_)
    short_exit = np.zeros(size, dtype=np.bool_)
    return long_entry, long_exit, short_entry, short_exit


def generate_signals_l18_ma_pullback_q2_mirror(features, signal_params):
    size = features.market.size
    slope_lookback = max(1, int(signal_params.get("slope_lookback", 3)))
    volatility_lookback = max(1, int(signal_params.get("volatility_lookback", 3)))
    closes = features.market.closes
    highs = features.market.highs
    sma20 = features.sma(20)
    sma50 = features.sma(50)
    sma200 = features.sma(200)
    volatility = features.std(20)
    prior_below = np.zeros(size, dtype=np.bool_)
    prior_below[1:] = closes[:-1] < sma200[:-1]
    rally_touch = prior_below & (highs >= sma200)
    slopes_down = (
        _slope_down(sma20, slope_lookback)
        & _slope_down(sma50, slope_lookback)
        & _slope_down(sma200, slope_lookback)
    )
    volatility_up = _slope_up(volatility, volatility_lookback)
    long_entry = np.zeros(size, dtype=np.bool_)
    long_exit = np.zeros(size, dtype=np.bool_)
    short_entry = rally_touch & slopes_down & volatility_up
    short_exit = closes > sma200
    return long_entry, long_exit, short_entry, short_exit


def generate_signals_l18_ma_pullback_q3_contrarian(features, signal_params):
    size = features.market.size
    slope_lookback = max(1, int(signal_params.get("slope_lookback", 3)))
    volatility_lookback = max(1, int(signal_params.get("volatility_lookback", 3)))
    closes = features.market.closes
    lows = features.market.lows
    sma20 = features.sma(20)
    sma50 = features.sma(50)
    sma200 = features.sma(200)
    volatility = features.std(20)
    prior_above = np.zeros(size, dtype=np.bool_)
    prior_above[1:] = closes[:-1] > sma200[:-1]
    pullback_touch = prior_above & (lows <= sma200)
    slopes_up = (
        _slope_up(sma20, slope_lookback)
        & _slope_up(sma50, slope_lookback)
        & _slope_up(sma200, slope_lookback)
    )
    volatility_up = _slope_up(volatility, volatility_lookback)
    long_entry = np.zeros(size, dtype=np.bool_)
    long_exit = np.zeros(size, dtype=np.bool_)
    short_entry = pullback_touch & slopes_up & volatility_up
    short_exit = closes > sma200
    return long_entry, long_exit, short_entry, short_exit


def generate_signals_l18_ma_pullback_q4_mirror_contrarian(features, signal_params):
    size = features.market.size
    slope_lookback = max(1, int(signal_params.get("slope_lookback", 3)))
    volatility_lookback = max(1, int(signal_params.get("volatility_lookback", 3)))
    closes = features.market.closes
    highs = features.market.highs
    sma20 = features.sma(20)
    sma50 = features.sma(50)
    sma200 = features.sma(200)
    volatility = features.std(20)
    prior_below = np.zeros(size, dtype=np.bool_)
    prior_below[1:] = closes[:-1] < sma200[:-1]
    rally_touch = prior_below & (highs >= sma200)
    slopes_down = (
        _slope_down(sma20, slope_lookback)
        & _slope_down(sma50, slope_lookback)
        & _slope_down(sma200, slope_lookback)
    )
    volatility_up = _slope_up(volatility, volatility_lookback)
    long_entry = rally_touch & slopes_down & volatility_up
    long_exit = closes < sma200
    short_entry = np.zeros(size, dtype=np.bool_)
    short_exit = np.zeros(size, dtype=np.bool_)
    return long_entry, long_exit, short_entry, short_exit


STRATEGIES = [
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l18_ma_pullback_q1_source_long",
        "hypothesis": "Q1_SOURCE",
        "position": "long",
        "source_refs": _SOURCE_REFS,
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "source pullback trigger with bullish put-credit-spread direction proxied as long",
        "exit_origin": "inferred structural failure when close is below SMA200",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l18_ma_pullback_q1_source,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l18_ma_pullback_q2_mirror_short",
        "hypothesis": "Q2_MIRROR",
        "position": "short",
        "source_refs": _SOURCE_REFS,
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "mirrored pullback trigger with opposite bearish direction proxied as short",
        "exit_origin": "inferred structural failure when close is above SMA200",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l18_ma_pullback_q2_mirror,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l18_ma_pullback_q3_contrarian_short",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "short",
        "source_refs": _SOURCE_REFS,
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "source pullback trigger with contrarian bearish direction proxied as short",
        "exit_origin": "inferred structural failure when close is above SMA200",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l18_ma_pullback_q3_contrarian,
    },
    {
        "source_logic_id": _SOURCE_LOGIC_ID,
        "strategy_id": "l18_ma_pullback_q4_mirror_contrarian_long",
        "hypothesis": "Q4_MIRROR_CONTRARIAN",
        "position": "long",
        "source_refs": _SOURCE_REFS,
        "source_summary": _SOURCE_SUMMARY,
        "entry_conversion": "proxy",
        "proxy_assumptions": _PROXY_ASSUMPTIONS,
        "source_requirements": _SOURCE_REQUIREMENTS,
        "entry_origin": "mirrored pullback trigger with contrarian bullish direction proxied as long",
        "exit_origin": "inferred structural failure when close is below SMA200",
        "signal_parameter_names": _SIGNAL_PARAMETER_NAMES,
        "signal_parameter_sets": _SIGNAL_PARAMETER_SETS,
        "risk_grid": _RISK_GRID,
        "generate_signals": generate_signals_l18_ma_pullback_q4_mirror_contrarian,
    },
]
