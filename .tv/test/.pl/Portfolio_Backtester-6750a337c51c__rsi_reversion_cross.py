import numpy as np


def _rsi(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= length:
        return result

    changes = np.diff(closes)
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    if not np.isfinite(changes[:length]).all():
        return result

    average_gain = float(np.mean(gains[:length]))
    average_loss = float(np.mean(losses[:length]))
    result[length] = (
        50.0
        if average_gain == 0.0 and average_loss == 0.0
        else 100.0
        if average_loss == 0.0
        else 100.0 - 100.0 / (1.0 + average_gain / average_loss)
    )

    for index in range(length + 1, closes.size):
        change = changes[index - 1]
        if not np.isfinite(change):
            break
        gain = max(change, 0.0)
        loss = max(-change, 0.0)
        average_gain = (average_gain * (length - 1.0) + gain) / length
        average_loss = (average_loss * (length - 1.0) + loss) / length
        result[index] = (
            50.0
            if average_gain == 0.0 and average_loss == 0.0
            else 100.0
            if average_loss == 0.0
            else 100.0 - 100.0 / (1.0 + average_gain / average_loss)
        )
    return result


def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty, empty.copy(), empty.copy(), empty.copy()

    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    rsi = _rsi(closes, 14)
    previous_rsi = np.roll(rsi, 1)
    previous_rsi[0] = np.nan

    long_entries = (
        np.isfinite(previous_rsi)
        & np.isfinite(rsi)
        & (previous_rsi <= 30.0)
        & (rsi > 30.0)
    )
    short_entries = (
        np.isfinite(previous_rsi)
        & np.isfinite(rsi)
        & (previous_rsi >= 70.0)
        & (rsi < 70.0)
    )
    long_exits = short_entries.copy()
    short_exits = long_entries.copy()

    return (
        np.asarray(long_entries, dtype=np.bool_),
        np.asarray(long_exits, dtype=np.bool_),
        np.asarray(short_entries, dtype=np.bool_),
        np.asarray(short_exits, dtype=np.bool_),
    )


STRATEGY = {
    "strategy_id": "rsi_reversion_cross",
    "hypothesis": "RSI 超買超賣區間反向穿越可捕捉震盪行情的均值回歸。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
