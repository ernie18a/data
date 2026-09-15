import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    fast = features.sma(10)
    slow = features.sma(30)

    if size >= 2:
        valid = np.isfinite(fast) & np.isfinite(slow)
        long_entries[1:] = (
            valid[1:]
            & valid[:-1]
            & (fast[1:] > slow[1:])
            & (fast[:-1] <= slow[:-1])
        )
        long_exits[1:] = (
            valid[1:]
            & valid[:-1]
            & (fast[1:] < slow[1:])
            & (fast[:-1] >= slow[:-1])
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "sma_crossover_long",
    "hypothesis": "SMA(10) 向上穿越 SMA(30) 時做多，向下穿越時平多。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}