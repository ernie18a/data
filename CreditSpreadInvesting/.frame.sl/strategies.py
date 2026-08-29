from strategy_l09_structure_reversal import STRATEGIES as _L09_STRATEGIES
from strategy_l10_resistance_breakdown import STRATEGIES as _L10_STRATEGIES
from strategy_l18_ma_pullback import STRATEGIES as _L18_STRATEGIES
from strategy_l19_bearish_engulfing import STRATEGIES as _L19_STRATEGIES
from strategy_l20_l24_evening_star import STRATEGIES as _L20_L24_STRATEGIES
from strategy_l26_engulfing_hammer_volume import STRATEGIES as _L26_STRATEGIES
from strategy_l27_range_resistance_engulfing import STRATEGIES as _L27_STRATEGIES
from strategy_l28_support_engulfing_volume import STRATEGIES as _L28_STRATEGIES
from strategy_l29_ma50_morning_star import STRATEGIES as _L29_STRATEGIES
from strategy_l30_trend_engulfing_ma_exit import STRATEGIES as _L30_STRATEGIES
from strategy_l32_trend_hammer_breakout import STRATEGIES as _L32_STRATEGIES
from strategy_l33_5m_support_breakdown import STRATEGIES as _L33_STRATEGIES
from strategy_l34_spx_daily_support_break import STRATEGIES as _L34_STRATEGIES
from strategy_l36_spx_daily_value_reversal import STRATEGIES as _L36_STRATEGIES

STRATEGIES = (
    list(_L09_STRATEGIES)
    + list(_L10_STRATEGIES)
    + list(_L18_STRATEGIES)
    + list(_L19_STRATEGIES)
    + list(_L20_L24_STRATEGIES)
    + list(_L26_STRATEGIES)
    + list(_L27_STRATEGIES)
    + list(_L28_STRATEGIES)
    + list(_L29_STRATEGIES)
    + list(_L30_STRATEGIES)
    + list(_L32_STRATEGIES)
    + list(_L33_STRATEGIES)
    + list(_L34_STRATEGIES)
    + list(_L36_STRATEGIES)
)

STRATEGY_BY_ID = {}
for strategy in STRATEGIES:
    strategy_id = strategy["strategy_id"]
    if strategy_id in STRATEGY_BY_ID:
        raise ValueError(f"duplicate strategy_id: {strategy_id}")
    STRATEGY_BY_ID[strategy_id] = strategy

assert len(STRATEGY_BY_ID) == len(STRATEGIES)

__all__ = ["STRATEGIES", "STRATEGY_BY_ID"]
