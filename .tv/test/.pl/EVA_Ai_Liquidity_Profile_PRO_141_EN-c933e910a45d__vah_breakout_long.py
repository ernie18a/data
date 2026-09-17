import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=float)
    current_poc = np.asarray(features.currentPoc, dtype=float)
    current_vah = np.asarray(features.currentVah, dtype=float)
    current_val = np.asarray(features.currentVal, dtype=float)

    confirmed = getattr(features, "confirmed", None)
    if confirmed is None:
        confirmed = getattr(features.market, "confirmed", np.ones(size, dtype=bool))
    confirmed = np.asarray(confirmed, dtype=bool)

    previous_close = np.roll(closes, 1)
    previous_vah = np.roll(current_vah, 1)
    valid_levels = np.isfinite(current_poc) & np.isfinite(current_vah) & np.isfinite(current_val)

    long_entries = confirmed & valid_levels & (closes > current_vah) & (previous_close <= previous_vah)
    long_exits = confirmed & (closes <= current_vah) & (closes >= current_val) & (previous_close > previous_vah)
    long_entries[0] = False
    long_exits[0] = False
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "vah_breakout_long",
    "hypothesis": "Long entry on a confirmed crossover above VAH; exit when price returns into the Value Area.",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
