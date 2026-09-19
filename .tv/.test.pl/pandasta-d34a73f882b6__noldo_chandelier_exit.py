import numpy as np


def _ema(values: np.ndarray, length: int) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=float)
    alpha = 2.0 / (length + 1.0)
    previous = np.nan
    for i, value in enumerate(values):
        if not np.isfinite(value):
            previous = np.nan
            continue
        previous = value if not np.isfinite(previous) else alpha * value + (1.0 - alpha) * previous
        result[i] = previous
    return result


def generate_signals(features, signal_params):
    size = int(features.market.size)
    closes = np.asarray(features.market.closes, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)

    params = signal_params or {}
    atr_length = int(params.get("atr_length", 22))
    atr_multiplier = float(params.get("atr_multiplier", 1.5))
    lookback = int(params.get("lookback", 22))
    if atr_length <= 0 or lookback <= 0 or not np.isfinite(atr_multiplier):
        raise ValueError("atr_length and lookback must be positive and atr_multiplier finite")

    true_range = np.full(size, np.nan, dtype=float)
    for t in range(size):
        if not (np.isfinite(highs[t]) and np.isfinite(lows[t])):
            continue
        if t > 0 and np.isfinite(closes[t - 1]):
            true_range[t] = max(
                highs[t] - lows[t],
                abs(highs[t] - closes[t - 1]),
                abs(lows[t] - closes[t - 1]),
            )
        else:
            true_range[t] = highs[t] - lows[t]

    atr = _ema(true_range, atr_length) * atr_multiplier
    raw_long_stop = np.full(size, np.nan, dtype=float)
    raw_short_stop = np.full(size, np.nan, dtype=float)
    for t in range(lookback - 1, size):
        window = closes[t - lookback + 1 : t + 1]
        if np.all(np.isfinite(window)) and np.isfinite(atr[t]):
            raw_long_stop[t] = np.max(window) - atr[t]
            raw_short_stop[t] = np.min(window) + atr[t]

    long_stop = np.full(size, np.nan, dtype=float)
    short_stop = np.full(size, np.nan, dtype=float)
    direction = np.ones(size, dtype=np.int8)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    for t in range(size):
        previous_direction = direction[t - 1] if t > 0 else 1
        if not (np.isfinite(raw_long_stop[t]) and np.isfinite(raw_short_stop[t])):
            direction[t] = previous_direction
            continue

        if t == 0 or not (np.isfinite(long_stop[t - 1]) and np.isfinite(short_stop[t - 1])):
            long_stop[t] = raw_long_stop[t]
            short_stop[t] = raw_short_stop[t]
            direction[t] = previous_direction
            continue

        long_stop[t] = raw_long_stop[t]
        short_stop[t] = raw_short_stop[t]
        if np.isfinite(closes[t - 1]) and closes[t - 1] > long_stop[t - 1]:
            long_stop[t] = max(long_stop[t], long_stop[t - 1])
        if np.isfinite(closes[t - 1]) and closes[t - 1] < short_stop[t - 1]:
            short_stop[t] = min(short_stop[t], short_stop[t - 1])

        if closes[t] > short_stop[t - 1]:
            direction[t] = 1
        elif closes[t] < long_stop[t - 1]:
            direction[t] = -1
        else:
            direction[t] = previous_direction

        long_entries[t] = previous_direction == -1 and direction[t] == 1
        short_entries[t] = previous_direction == 1 and direction[t] == -1
        long_exits[t] = short_entries[t]
        short_exits[t] = long_entries[t]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "noldo_chandelier_exit",
    "hypothesis": "以 ATR 動態追蹤停損捕捉趨勢反轉。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["atr_length", "atr_multiplier", "lookback"],
    "signal_parameter_sets": [
        {"atr_length": 22, "atr_multiplier": 1.5, "lookback": 22}
    ],
}
