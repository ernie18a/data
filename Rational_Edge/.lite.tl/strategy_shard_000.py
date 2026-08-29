from __future__ import annotations

from collections.abc import Mapping
from typing import Any

import numpy as np

from engine import FeatureStore


def building_sma_q1_source_long(
    features: FeatureStore, signal_params: Mapping[str, Any]
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    closes = features.market.closes
    average = features.sma(int(signal_params["sma_length"]))
    inactive = np.zeros(features.market.size, dtype=np.bool_)
    return closes > average, closes < average, inactive.copy(), inactive


def building_sma_q2_mirror_short(
    features: FeatureStore, signal_params: Mapping[str, Any]
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    closes = features.market.closes
    average = features.sma(int(signal_params["sma_length"]))
    inactive = np.zeros(features.market.size, dtype=np.bool_)
    return inactive.copy(), inactive, closes < average, closes > average


def building_sma_q3_contrarian_short(
    features: FeatureStore, signal_params: Mapping[str, Any]
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    closes = features.market.closes
    average = features.sma(int(signal_params["sma_length"]))
    inactive = np.zeros(features.market.size, dtype=np.bool_)
    return inactive.copy(), inactive, closes > average, closes < average


def building_sma_q4_mirror_contrarian_long(
    features: FeatureStore, signal_params: Mapping[str, Any]
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    closes = features.market.closes
    average = features.sma(int(signal_params["sma_length"]))
    inactive = np.zeros(features.market.size, dtype=np.bool_)
    return closes < average, closes > average, inactive.copy(), inactive


SOURCE_REFS = [
    "/g/data/Rational_Edge/large_v3_turbo_Building_a_Quantitative_Edge_From_Idea_to_Algorithm_Strategy_Kvd7gvTHmbk.txt:L23-L27",
    "/g/data/Rational_Edge/large_v3_turbo_Building_a_Quantitative_Edge_From_Idea_to_Algorithm_Strategy_Kvd7gvTHmbk.txt:L37",
]
SOURCE_REQUIREMENTS = {
    "required_bar_interval": "unspecified_by_source",
    "session": "unspecified_by_source",
    "timezone": "unspecified_by_source",
    "data": ["close"],
    "missing_required_data": [
        "authoritative SMA period/default",
        "tick-level prices and intrabar timing",
    ],
}
PROXY_ASSUMPTIONS = [
    "Source price is represented by the completed signal bar close.",
    "The source's SMA optimization example value 10 is used as the sole finite length; it is not treated as an authoritative default.",
    "Tick evaluation is represented by bar-close evaluation followed by Frame next-bar-open execution.",
]
SIGNAL_PARAMETER_SETS = [{"sma_length": 10}]
RISK_GRID = {
    "stop_atr": [1.0, 2.0],
    "target_r": [0.0, 2.0],
    "max_bars": [20, 50],
}


STRATEGIES = [
    {
        "source_logic_id": "building_sma_price_relation",
        "strategy_id": "building_sma_q1_source_long",
        "hypothesis": "Q1_SOURCE",
        "position": "long",
        "source_refs": SOURCE_REFS,
        "source_summary": "The source says to buy when price is above its SMA; completed-bar close is the price proxy.",
        "entry_conversion": "proxy",
        "proxy_assumptions": PROXY_ASSUMPTIONS,
        "source_requirements": SOURCE_REQUIREMENTS,
        "entry_origin": "source_explicit_price_above_sma",
        "exit_origin": "structural_mirror_price_below_sma",
        "signal_parameter_names": ["sma_length"],
        "signal_parameter_sets": SIGNAL_PARAMETER_SETS,
        "risk_grid": RISK_GRID,
        "generate_signals": building_sma_q1_source_long,
    },
    {
        "source_logic_id": "building_sma_price_relation",
        "strategy_id": "building_sma_q2_mirror_short",
        "hypothesis": "Q2_MIRROR",
        "position": "short",
        "source_refs": SOURCE_REFS,
        "source_summary": "The semantic mirror sells when price is below its SMA; completed-bar close is the price proxy.",
        "entry_conversion": "proxy",
        "proxy_assumptions": PROXY_ASSUMPTIONS,
        "source_requirements": SOURCE_REQUIREMENTS,
        "entry_origin": "semantic_mirror_price_below_sma",
        "exit_origin": "structural_source_price_above_sma",
        "signal_parameter_names": ["sma_length"],
        "signal_parameter_sets": SIGNAL_PARAMETER_SETS,
        "risk_grid": RISK_GRID,
        "generate_signals": building_sma_q2_mirror_short,
    },
    {
        "source_logic_id": "building_sma_price_relation",
        "strategy_id": "building_sma_q3_contrarian_short",
        "hypothesis": "Q3_CONTRARIAN",
        "position": "short",
        "source_refs": SOURCE_REFS,
        "source_summary": "The contrarian hypothesis sells on the source price-above-SMA condition; completed-bar close is the price proxy.",
        "entry_conversion": "proxy",
        "proxy_assumptions": PROXY_ASSUMPTIONS,
        "source_requirements": SOURCE_REQUIREMENTS,
        "entry_origin": "source_condition_contrarian_position",
        "exit_origin": "structural_mirror_price_below_sma",
        "signal_parameter_names": ["sma_length"],
        "signal_parameter_sets": SIGNAL_PARAMETER_SETS,
        "risk_grid": RISK_GRID,
        "generate_signals": building_sma_q3_contrarian_short,
    },
    {
        "source_logic_id": "building_sma_price_relation",
        "strategy_id": "building_sma_q4_mirror_contrarian_long",
        "hypothesis": "Q4_MIRROR_CONTRARIAN",
        "position": "long",
        "source_refs": SOURCE_REFS,
        "source_summary": "The mirror-contrarian hypothesis buys on price below its SMA; completed-bar close is the price proxy.",
        "entry_conversion": "proxy",
        "proxy_assumptions": PROXY_ASSUMPTIONS,
        "source_requirements": SOURCE_REQUIREMENTS,
        "entry_origin": "mirror_condition_original_position",
        "exit_origin": "structural_source_price_above_sma",
        "signal_parameter_names": ["sma_length"],
        "signal_parameter_sets": SIGNAL_PARAMETER_SETS,
        "risk_grid": RISK_GRID,
        "generate_signals": building_sma_q4_mirror_contrarian_long,
    },
]
