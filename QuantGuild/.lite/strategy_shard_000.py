from __future__ import annotations

import numpy as np
from engine import cross_down, cross_up


def quantguild_sma_7_14_q1_source(features, signal_params):
    fast = features.sma(7)
    slow = features.sma(14)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return cross_up(fast, slow), cross_down(fast, slow), empty, empty


def quantguild_sma_7_14_q2_mirror(features, signal_params):
    fast = features.sma(7)
    slow = features.sma(14)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return empty, empty, cross_down(fast, slow), cross_up(fast, slow)


def quantguild_sma_7_14_q3_contrarian(features, signal_params):
    fast = features.sma(7)
    slow = features.sma(14)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return empty, empty, cross_up(fast, slow), cross_down(fast, slow)


def quantguild_sma_7_14_q4_mirror_contrarian(features, signal_params):
    fast = features.sma(7)
    slow = features.sma(14)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return cross_down(fast, slow), cross_up(fast, slow), empty, empty


STRATEGIES: list[dict] = [
    {
        "source_logic_id": "quantguild_sma_7_14",
        "strategy_id": "quantguild_sma_7_14_q1_source",
        "hypothesis": "Q1_SOURCE",
        "position": "long",
        "source_refs": ["/g/data/QuantGuild/large_v3_turbo_Backtesting_Quant_Strats_in_Python_Quantitative_Research_oqVAtacekr0.txt"],
        "source_summary": "Long on a completed-bar 7-bar SMA crossing above the 14-bar SMA.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "1d", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "source",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": quantguild_sma_7_14_q1_source,
    },
    {
        "source_logic_id": "quantguild_sma_7_14",
        "strategy_id": "quantguild_sma_7_14_q2_mirror",
        "hypothesis": "Q2_MIRROR",
        "position": "short",
        "source_refs": ["/g/data/QuantGuild/large_v3_turbo_Backtesting_Quant_Strats_in_Python_Quantitative_Research_oqVAtacekr0.txt"],
        "source_summary": "Mirror source condition: short on a completed-bar 7-bar SMA crossing below the 14-bar SMA.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "1d", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "mirror",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": quantguild_sma_7_14_q2_mirror,
    },
    {
        "source_logic_id": "quantguild_sma_7_14",
        "strategy_id": "quantguild_sma_7_14_q3_contrarian",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "short",
        "source_refs": ["/g/data/QuantGuild/large_v3_turbo_Backtesting_Quant_Strats_in_Python_Quantitative_Research_oqVAtacekr0.txt"],
        "source_summary": "Contrarian source condition: short on a completed-bar 7-bar SMA crossing above the 14-bar SMA.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "1d", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "source",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": quantguild_sma_7_14_q3_contrarian,
    },
    {
        "source_logic_id": "quantguild_sma_7_14",
        "strategy_id": "quantguild_sma_7_14_q4_mirror_contrarian",
        "hypothesis": "Q4_MIRROR_CONTRARIAN",
        "position": "long",
        "source_refs": ["/g/data/QuantGuild/large_v3_turbo_Backtesting_Quant_Strats_in_Python_Quantitative_Research_oqVAtacekr0.txt"],
        "source_summary": "Contrarian mirror condition: long on a completed-bar 7-bar SMA crossing below the 14-bar SMA.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "1d", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "mirror",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": quantguild_sma_7_14_q4_mirror_contrarian,
    },
]
