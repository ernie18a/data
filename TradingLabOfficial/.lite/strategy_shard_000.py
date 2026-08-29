from __future__ import annotations

import numpy as np


def tradinglab_bband_rsi_q1_source(features, signal_params):
    middle = features.sma(30)
    deviation = features.std(30)
    closes = features.market.closes
    rsi = features.rsi(13)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return (closes < middle - 2.0 * deviation) & (rsi < 25.0), (closes > middle + 2.0 * deviation) & (rsi > 75.0), empty, empty


def tradinglab_bband_rsi_q2_mirror(features, signal_params):
    middle = features.sma(30)
    deviation = features.std(30)
    closes = features.market.closes
    rsi = features.rsi(13)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return empty, empty, (closes > middle + 2.0 * deviation) & (rsi > 75.0), (closes < middle - 2.0 * deviation) & (rsi < 25.0)


def tradinglab_bband_rsi_q3_contrarian(features, signal_params):
    middle = features.sma(30)
    deviation = features.std(30)
    closes = features.market.closes
    rsi = features.rsi(13)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return empty, empty, (closes < middle - 2.0 * deviation) & (rsi < 25.0), (closes > middle + 2.0 * deviation) & (rsi > 75.0)


def tradinglab_bband_rsi_q4_mirror_contrarian(features, signal_params):
    middle = features.sma(30)
    deviation = features.std(30)
    closes = features.market.closes
    rsi = features.rsi(13)
    empty = np.zeros(features.market.size, dtype=np.bool_)
    return (closes > middle + 2.0 * deviation) & (rsi > 75.0), (closes < middle - 2.0 * deviation) & (rsi < 25.0), empty, empty


STRATEGIES: list[dict] = [
    {
        "source_logic_id": "tradinglab_bband_30_2_rsi_13",
        "strategy_id": "tradinglab_bband_rsi_q1_source",
        "hypothesis": "Q1_SOURCE",
        "position": "long",
        "source_refs": ["/g/data/TradingLabOfficial/large_v3_turbo_Bollinger_Band_RSI_Trading_Strategy_That_Actually_Works_pCmJ8wsAS_w.txt"],
        "source_summary": "Long when close is below the 30-bar, 2-standard-deviation lower Bollinger band and RSI(13) is below 25.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "unspecified_by_source", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "source",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": tradinglab_bband_rsi_q1_source,
    },
    {
        "source_logic_id": "tradinglab_bband_30_2_rsi_13",
        "strategy_id": "tradinglab_bband_rsi_q2_mirror",
        "hypothesis": "Q2_MIRROR",
        "position": "short",
        "source_refs": ["/g/data/TradingLabOfficial/large_v3_turbo_Bollinger_Band_RSI_Trading_Strategy_That_Actually_Works_pCmJ8wsAS_w.txt"],
        "source_summary": "Mirror source condition: short when close is above the 30-bar, 2-standard-deviation upper Bollinger band and RSI(13) is above 75.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "unspecified_by_source", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "mirror",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": tradinglab_bband_rsi_q2_mirror,
    },
    {
        "source_logic_id": "tradinglab_bband_30_2_rsi_13",
        "strategy_id": "tradinglab_bband_rsi_q3_contrarian",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "short",
        "source_refs": ["/g/data/TradingLabOfficial/large_v3_turbo_Bollinger_Band_RSI_Trading_Strategy_That_Actually_Works_pCmJ8wsAS_w.txt"],
        "source_summary": "Contrarian source condition: short when close is below the lower Bollinger band and RSI(13) is below 25.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "unspecified_by_source", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "source",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": tradinglab_bband_rsi_q3_contrarian,
    },
    {
        "source_logic_id": "tradinglab_bband_30_2_rsi_13",
        "strategy_id": "tradinglab_bband_rsi_q4_mirror_contrarian",
        "hypothesis": "Q4_MIRROR_CONTRARIAN",
        "position": "long",
        "source_refs": ["/g/data/TradingLabOfficial/large_v3_turbo_Bollinger_Band_RSI_Trading_Strategy_That_Actually_Works_pCmJ8wsAS_w.txt"],
        "source_summary": "Contrarian mirror condition: long when close is above the upper Bollinger band and RSI(13) is above 75.",
        "entry_conversion": "faithful",
        "proxy_assumptions": [],
        "source_requirements": {"required_bar_interval": "unspecified_by_source", "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "mirror",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": [],
        "signal_parameter_sets": [{}],
        "risk_grid": {"stop_atr": [1.0], "target_r": [1.0], "max_bars": [100]},
        "generate_signals": tradinglab_bband_rsi_q4_mirror_contrarian,
    },
]
