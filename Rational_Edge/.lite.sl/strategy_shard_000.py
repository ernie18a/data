from __future__ import annotations

from collections.abc import Mapping
from typing import Any

import numpy as np


def ma_source(features: Any, signal_params: Mapping[str, Any]) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    average = features.sma(int(signal_params["ma_length"]))
    above = features.market.closes > average
    below = features.market.closes < average
    return above, below, below, above


def ma_contrarian(features: Any, signal_params: Mapping[str, Any]) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    average = features.sma(int(signal_params["ma_length"]))
    above = features.market.closes > average
    below = features.market.closes < average
    return below, above, above, below


def range_breakout_source(features: Any, signal_params: Mapping[str, Any]) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    range_bars = int(signal_params["range_bars"])
    range_high = features.highest(range_bars)
    range_low = features.lowest(range_bars)
    upper_break = (features.market.highs > range_high) & (features.market.closes > range_high)
    lower_break = (features.market.lows < range_low) & (features.market.closes < range_low)
    return upper_break, lower_break, lower_break, upper_break


def range_breakout_contrarian(features: Any, signal_params: Mapping[str, Any]) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    range_bars = int(signal_params["range_bars"])
    range_high = features.highest(range_bars)
    range_low = features.lowest(range_bars)
    upper_break = (features.market.highs > range_high) & (features.market.closes > range_high)
    lower_break = (features.market.lows < range_low) & (features.market.closes < range_low)
    return lower_break, upper_break, upper_break, lower_break
