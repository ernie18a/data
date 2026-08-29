from __future__ import annotations

from strategy_shard_000 import ma_contrarian, ma_source, range_breakout_contrarian, range_breakout_source


MA_SOURCE_REF = "large_v3_turbo_Building_a_Quantitative_Edge_From_Idea_to_Algorithm_Strategy_Kvd7gvTHmbk.txt:23-27"
RANGE_SOURCE_REF = "large_v3_turbo_Range_Breakout_Strategy_Enhancing_Results_with_Quant_Analyzer_Npz3zHhv7mw.txt:7-30"
DEFAULT_RISK_GRID = {"stop_atr": [1.0, 2.0], "target_r": [0.0, 2.0], "max_bars": [24, 72]}

STRATEGIES: list[dict] = [
    {
        "source_logic_id": "rational_edge_price_vs_sma",
        "strategy_id": "rational_edge_price_vs_sma_q1_source",
        "hypothesis": "Q1_SOURCE",
        "position": "long_and_short",
        "source_refs": [MA_SOURCE_REF],
        "source_summary": "Buy when close is above SMA and sell short when close is below SMA.",
        "entry_conversion": "proxy",
        "proxy_assumptions": ["The source's tick evaluation is represented by completed-bar evaluation and next-bar-open execution.", "The source's stated example length 10 is used because no production default is disclosed."],
        "source_requirements": {"required_bar_interval": None, "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "source_price_relative_to_sma",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": ["ma_length"],
        "signal_parameter_sets": [{"ma_length": 10}],
        "risk_grid": DEFAULT_RISK_GRID,
        "generate_signals": ma_source,
    },
    {
        "source_logic_id": "rational_edge_price_vs_sma",
        "strategy_id": "rational_edge_price_vs_sma_q3_contrarian",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "long_and_short",
        "source_refs": [MA_SOURCE_REF],
        "source_summary": "Trade against the source direction for the same price-versus-SMA conditions.",
        "entry_conversion": "proxy",
        "proxy_assumptions": ["The source's tick evaluation is represented by completed-bar evaluation and next-bar-open execution.", "The source's stated example length 10 is used because no production default is disclosed."],
        "source_requirements": {"required_bar_interval": None, "session": None, "timezone": None, "data": ["close"], "missing_required_data": []},
        "entry_origin": "contrarian_source_price_relative_to_sma",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": ["ma_length"],
        "signal_parameter_sets": [{"ma_length": 10}],
        "risk_grid": DEFAULT_RISK_GRID,
        "generate_signals": ma_contrarian,
    },
    {
        "source_logic_id": "rational_edge_confirmed_range_breakout",
        "strategy_id": "rational_edge_confirmed_range_breakout_q1_source",
        "hypothesis": "Q1_SOURCE",
        "position": "long_and_short",
        "source_refs": [RANGE_SOURCE_REF],
        "source_summary": "Enter in the breakout direction only when price closes beyond the completed range.",
        "entry_conversion": "proxy",
        "proxy_assumptions": ["The undisclosed intraday range is represented by the previous 12 completed bars.", "The unavailable 18:55 forced close is replaced by the paired opposite breakout and the external risk grid."],
        "source_requirements": {"required_bar_interval": "5m", "session": "undisclosed range inside Asian session", "timezone": None, "data": ["high", "low", "close"], "missing_required_data": ["bar timestamps", "range start", "range end", "session timezone", "forced-close timezone"]},
        "entry_origin": "source_confirmed_range_breakout_bar_proxy",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": ["range_bars"],
        "signal_parameter_sets": [{"range_bars": 12}],
        "risk_grid": DEFAULT_RISK_GRID,
        "generate_signals": range_breakout_source,
    },
    {
        "source_logic_id": "rational_edge_confirmed_range_breakout",
        "strategy_id": "rational_edge_confirmed_range_breakout_q3_contrarian",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "long_and_short",
        "source_refs": [RANGE_SOURCE_REF],
        "source_summary": "Trade against the source direction for each confirmed range breakout.",
        "entry_conversion": "proxy",
        "proxy_assumptions": ["The undisclosed intraday range is represented by the previous 12 completed bars.", "The unavailable 18:55 forced close is replaced by the paired opposite breakout and the external risk grid."],
        "source_requirements": {"required_bar_interval": "5m", "session": "undisclosed range inside Asian session", "timezone": None, "data": ["high", "low", "close"], "missing_required_data": ["bar timestamps", "range start", "range end", "session timezone", "forced-close timezone"]},
        "entry_origin": "contrarian_source_confirmed_range_breakout_bar_proxy",
        "exit_origin": "paired_mirror",
        "signal_parameter_names": ["range_bars"],
        "signal_parameter_sets": [{"range_bars": 12}],
        "risk_grid": DEFAULT_RISK_GRID,
        "generate_signals": range_breakout_contrarian,
    },
]
