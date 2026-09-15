import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    rsi = features.rsi(14)
    position = 0
    pending_reverse = 0
    scheduled_entry = 0
    scheduled_exit = 0

    for t in range(size):
        if scheduled_exit != 0:
            position = 0
            scheduled_exit = 0

        if scheduled_entry != 0:
            position = scheduled_entry
            scheduled_entry = 0

        if pending_reverse != 0:
            if pending_reverse == 1:
                long_entries[t] = True
            else:
                short_entries[t] = True
            scheduled_entry = pending_reverse
            pending_reverse = 0
            continue

        if not (np.isfinite(rsi[t]) and (t > 0) and np.isfinite(rsi[t - 1])):
            continue

        if position == 1:
            if rsi[t] < 70.0 and rsi[t - 1] >= 70.0:
                long_exits[t] = True
                scheduled_exit = 1
                pending_reverse = -1
        elif position == -1:
            if rsi[t] > 30.0 and rsi[t - 1] <= 30.0:
                short_exits[t] = True
                scheduled_exit = -1
                pending_reverse = 1
        else:
            long_trigger = rsi[t] > 30.0 and rsi[t - 1] <= 30.0
            short_trigger = rsi[t] < 70.0 and rsi[t - 1] >= 70.0
            if long_trigger and not short_trigger:
                long_entries[t] = True
                scheduled_entry = 1
            elif short_trigger and not long_trigger:
                short_entries[t] = True
                scheduled_entry = -1

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'rsi14_threshold_cross',
    'hypothesis': 'RSI14 上穿30做多、下穿70做空，並以反向訊號出場及反向持倉。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
