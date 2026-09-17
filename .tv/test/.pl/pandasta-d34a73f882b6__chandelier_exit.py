import numpy as np


def generate_signals(features, signal_params):
    size = int(features.market.size)
    closes = np.asarray(features.market.closes, dtype=float)
    atr = np.asarray(features.atr(22), dtype=float)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    long_stops = np.full(size, np.nan, dtype=float)
    short_stops = np.full(size, np.nan, dtype=float)
    direction = 1
    period = 22
    multiplier = 1.5

    for t in range(size):
        if t < period - 1 or not np.isfinite(atr[t]):
            continue

        window = closes[t - period + 1 : t + 1]
        if not np.all(np.isfinite(window)):
            continue

        raw_long_stop = np.max(window) - multiplier * atr[t]
        raw_short_stop = np.min(window) + multiplier * atr[t]

        if t > 0 and np.isfinite(long_stops[t - 1]):
            previous_long_stop = long_stops[t - 1]
        else:
            previous_long_stop = raw_long_stop

        if t > 0 and np.isfinite(short_stops[t - 1]):
            previous_short_stop = short_stops[t - 1]
        else:
            previous_short_stop = raw_short_stop

        if t > 0 and np.isfinite(closes[t - 1]) and closes[t - 1] > previous_long_stop:
            long_stops[t] = max(raw_long_stop, previous_long_stop)
        else:
            long_stops[t] = raw_long_stop

        if t > 0 and np.isfinite(closes[t - 1]) and closes[t - 1] < previous_short_stop:
            short_stops[t] = min(raw_short_stop, previous_short_stop)
        else:
            short_stops[t] = raw_short_stop

        previous_direction = direction
        if closes[t] > previous_short_stop:
            direction = 1
        elif closes[t] < previous_long_stop:
            direction = -1

        if previous_direction == -1 and direction == 1:
            long_entries[t] = True
            short_exits[t] = True
        elif previous_direction == 1 and direction == -1:
            short_entries[t] = True
            long_exits[t] = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "chandelier_exit",
    "hypothesis": "ATR-adjusted rolling closing-price extremes identify trend reversals.",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
