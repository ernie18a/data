import numpy as np


def _sma(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= period:
        result[period - 1:] = np.convolve(values, np.ones(period), mode='valid') / period
    return result


def generate_signals(features, signal_params):
    size = int(features.market.size)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if closes.size != size:
        raise ValueError('features.market.closes length must equal features.market.size')

    fast_ma = _sma(closes, 10)
    slow_ma = _sma(closes, 30)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size > 1:
        long_entries[1:] = (fast_ma[1:] > slow_ma[1:]) & (fast_ma[:-1] <= slow_ma[:-1])
        long_exits[1:] = (fast_ma[1:] < slow_ma[1:]) & (fast_ma[:-1] >= slow_ma[:-1])

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'sma_crossover_10_30_long',
    'hypothesis': 'Fast SMA crossing above the slow SMA identifies bullish trend entries, while a downward cross exits the long position.',
    'position': 'long',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
