import numpy as np


def _previous(values):
    previous = np.full(values.shape, np.nan, dtype=np.float64)
    previous[1:] = values[:-1]
    return previous


def _previous_count(condition, window):
    size = condition.size
    index = np.arange(size, dtype=np.int64)
    cumulative = np.concatenate(
        (np.zeros(1, dtype=np.int64), np.cumsum(condition.astype(np.int64), dtype=np.int64))
    )
    left = np.maximum(index - window, 0)
    return cumulative[index] - cumulative[left]


def _signal_components(features, signal_params):
    params = {} if signal_params is None else signal_params
    resistance_lookback = max(2, int(params.get("resistance_lookback", 36)))
    structure_lookback = max(2, int(params.get("structure_lookback", 12)))
    zone_tolerance = max(0.000001, float(params.get("zone_tolerance", 0.004)))
    confirmation_window = max(1, int(params.get("confirmation_window", 6)))
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty.copy(), empty.copy(), empty.copy(), empty.copy(), empty.copy(), empty.copy()

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    resistance = np.asarray(features.highest(resistance_lookback), dtype=np.float64)
    support = np.asarray(features.lowest(structure_lookback), dtype=np.float64)
    previous_highs = _previous(highs)
    previous_lows = _previous(lows)
    previous_closes = _previous(closes)
    previous_resistance = _previous(resistance)
    previous_support = _previous(support)
    valid = np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    resistance_valid = valid & np.isfinite(resistance)
    support_valid = valid & np.isfinite(support)

    resistance_zone = resistance_valid & (
        (highs >= resistance * (1.0 - zone_tolerance))
        & (highs <= resistance * (1.0 + zone_tolerance))
    )
    support_zone = support_valid & (
        (lows >= support * (1.0 - zone_tolerance))
        & (lows <= support * (1.0 + zone_tolerance))
    )
    resistance_zone_before = _previous_count(resistance_zone, confirmation_window) > 0
    support_zone_before = _previous_count(support_zone, confirmation_window) > 0

    lower_high = resistance_valid & np.isfinite(previous_highs) & (
        (highs < previous_highs) & (highs < resistance)
    )
    higher_low = support_valid & np.isfinite(previous_lows) & (
        (lows > previous_lows) & (lows > support)
    )
    qualified_lower_high = lower_high & resistance_zone_before
    qualified_higher_low = higher_low & support_zone_before
    lower_high_before = _previous_count(qualified_lower_high, confirmation_window) > 0
    higher_low_before = _previous_count(qualified_higher_low, confirmation_window) > 0

    rising_support = support_valid & np.isfinite(previous_support) & (support > previous_support)
    falling_resistance = resistance_valid & np.isfinite(previous_resistance) & (
        resistance < previous_resistance
    )
    support_break = (
        support_valid
        & np.isfinite(previous_support)
        & np.isfinite(previous_closes)
        & (closes < support)
        & (previous_closes >= previous_support)
        & rising_support
    )
    resistance_break = (
        resistance_valid
        & np.isfinite(previous_resistance)
        & np.isfinite(previous_closes)
        & (closes > resistance)
        & (previous_closes <= previous_resistance)
        & falling_resistance
    )

    base_trigger = lower_high_before & support_break
    mirror_trigger = higher_low_before & resistance_break
    base_reclaim = (
        support_valid
        & np.isfinite(previous_support)
        & np.isfinite(previous_closes)
        & (closes > support)
        & (previous_closes <= previous_support)
    )
    mirror_reject = (
        resistance_valid
        & np.isfinite(previous_resistance)
        & np.isfinite(previous_closes)
        & (closes < resistance)
        & (previous_closes >= previous_resistance)
    )
    base_breakdown_state = support_valid & (closes < support)
    mirror_breakout_state = resistance_valid & (closes > resistance)
    return (
        np.asarray(base_trigger, dtype=np.bool_),
        np.asarray(mirror_trigger, dtype=np.bool_),
        np.asarray(base_reclaim, dtype=np.bool_),
        np.asarray(mirror_reject, dtype=np.bool_),
        np.asarray(base_breakdown_state, dtype=np.bool_),
        np.asarray(mirror_breakout_state, dtype=np.bool_),
    )


def generate_l10_resistance_breakdown_q1_source(features, signal_params):
    base_trigger, _, base_reclaim, _, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), base_trigger, base_reclaim


def generate_l10_resistance_breakdown_q2_mirror(features, signal_params):
    _, mirror_trigger, _, mirror_reject, _, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return mirror_trigger, mirror_reject, false.copy(), false.copy()


def generate_l10_resistance_breakdown_q3_contrarian(features, signal_params):
    base_trigger, _, _, _, base_breakdown_state, _ = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return base_trigger, base_breakdown_state, false.copy(), false.copy()


def generate_l10_resistance_breakdown_q4_mirror_contrarian(features, signal_params):
    _, mirror_trigger, _, _, _, mirror_breakout_state = _signal_components(features, signal_params)
    false = np.zeros(features.market.size, dtype=np.bool_)
    return false.copy(), false.copy(), mirror_trigger, mirror_breakout_state


_SOURCE_LOGIC_ID = "L10_RESISTANCE_BREAKDOWN"
_SOURCE_REFS = ["/g/data/CreditSpreadInvesting/.READ5.1.md:10"]
_SOURCE_SUMMARY = (
    "第10行描述5分鐘K線在約45.80阻力區形成較低高點，"
    "跌破上升結構支撐且收盤位於支撐下方後做空；選擇權腿為賣出45.70看漲、"
    "買入45.75看漲，並聲稱虧損100美元停損。"
)
_PROXY_ASSUMPTIONS = [
    "required_bar_interval 保留為5m；Frame沒有時間戳或重採樣能力，故以5分鐘資料列為單一bar，36、12、6根bar分別近似3小時、1小時、30分鐘。",
    "約45.80的絕對阻力價區以先前36根bar的rolling最高價為阻力代理，當前高點落在±0.4%區間即視為進入阻力區；鏡像以rolling最低價建立支撐區。",
    "較低高點必須發生在近期阻力區之後，並於確認窗內先於跌破；上升結構支撐以先前12根bar的rolling最低價且該支撐高於前值代理，收盤向下穿越為突破事件。",
    "Frame只有標的OHLCV，無法觀測45.70/45.75履約價、期權鏈、權利金、乘數或期權損益；原始信用價差以標的空方部位代理，鏡像與反向假說只改變標的方向。",
    "100美元期權損失停損不轉換為標的價格停損；原始空方以收盤重新站回被跌破支撐作結構失效出場，鏡像多方以跌回被突破阻力出場，反向假說以原事件延續狀態出場。",
    "來源未指定session或timezone，MarketData也沒有時間欄位；required_session與required_timezone標示未指定並保留資料集設定，不添加虛構時段過濾。訊號於bar收盤確認，依Frame契約下一bar開盤成交。",
]
_SOURCE_REQUIREMENTS = {
    "required_bar_interval": "5m",
    "required_session": "unspecified_by_source; preserve_dataset_session",
    "required_timezone": "unspecified_by_source; preserve_dataset_timezone",
    "market_fields": ["high", "low", "close"],
    "indicators": [
        "rolling highest(high, 36) excluding current bar",
        "rolling lowest(low, 12) excluding current bar",
    ],
    "core_trigger": "enter resistance zone near 45.80, form lower high, then close below rising structural support",
    "source_position": "short call credit spread",
    "option_requirements": [
        "short call strike = 45.70 USD",
        "long call strike = 45.75 USD",
        "claimed stop = 100 USD option-trade loss",
    ],
    "unavailable_data": [
        "option chain",
        "strike quotes",
        "option multiplier",
        "net credit",
        "option P&L",
        "timestamp and session fields",
    ],
    "execution": "5m close signal, next-bar-open fill",
}
_SIGNAL_PARAMETER_NAMES = [
    "resistance_lookback",
    "structure_lookback",
    "zone_tolerance",
    "confirmation_window",
]
_SIGNAL_PARAMETER_SETS = [
    {
        "resistance_lookback": 36,
        "structure_lookback": 12,
        "zone_tolerance": 0.004,
        "confirmation_window": 6,
    }
]
_RISK_GRID = {
    "stop_atr": [1.5, 2.0, 3.0],
    "target_r": [0.0, 1.0, 2.0],
    "max_bars": [12, 24, 48],
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
        "required_bar_interval": "5m",
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
        "L10_RESISTANCE_BREAKDOWN_Q1_SOURCE",
        "Q1_SOURCE",
        "short",
        "bearish",
        "rolling resistance-zone touch, lower-high confirmation, and close cross-down below rising support",
        "inferred structural exit when close crosses back above the broken rising support",
        generate_l10_resistance_breakdown_q1_source,
    ),
    _record(
        "L10_RESISTANCE_BREAKDOWN_Q2_MIRROR",
        "Q2_MIRROR",
        "long",
        "bullish",
        "rolling support-zone touch, higher-low confirmation, and close cross-up above falling resistance",
        "inferred structural exit when close crosses back below the broken falling resistance",
        generate_l10_resistance_breakdown_q2_mirror,
    ),
    _record(
        "L10_RESISTANCE_BREAKDOWN_Q3_CONTRARIAN",
        "Q3_CONTRARIAN",
        "long",
        "bullish",
        "source bearish breakdown trigger with contrarian long direction",
        "inferred structural exit while the source bearish breakdown remains below support",
        generate_l10_resistance_breakdown_q3_contrarian,
    ),
    _record(
        "L10_RESISTANCE_BREAKDOWN_Q4_MIRROR_CONTRARIAN",
        "Q4_MIRROR_CONTRARIAN",
        "short",
        "bearish",
        "mirrored bullish breakout trigger with contrarian short direction",
        "inferred structural exit while the mirrored bullish breakout remains above resistance",
        generate_l10_resistance_breakdown_q4_mirror_contrarian,
    ),
]


__all__ = [
    "STRATEGIES",
    "generate_l10_resistance_breakdown_q1_source",
    "generate_l10_resistance_breakdown_q2_mirror",
    "generate_l10_resistance_breakdown_q3_contrarian",
    "generate_l10_resistance_breakdown_q4_mirror_contrarian",
]
