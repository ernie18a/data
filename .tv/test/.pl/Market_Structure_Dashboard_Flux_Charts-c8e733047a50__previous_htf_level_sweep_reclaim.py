import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _array_value(features, names, size):
    for obj in (features, features.market):
        for name in names:
            if not hasattr(obj, name):
                continue
            value = getattr(obj, name)
            if callable(value):
                value = value()
            array = np.asarray(value)
            if array.ndim == 0:
                return np.full(size, array.item())
            array = array.reshape(-1)
            if array.size == size:
                return array
    return None

def _period_keys(features, size, period):
    explicit_names = {'day': ('session_ids', 'session_id', 'day_ids', 'day_id', 'trading_days'), 'week': ('week_ids', 'week_id', 'trading_weeks'), 'month': ('month_ids', 'month_id', 'trading_months')}[period]
    explicit = _array_value(features, explicit_names, size)
    if explicit is not None:
        return np.asarray([str(value) for value in explicit], dtype=object)
    timestamps = _array_value(features, ('timestamps', 'timestamp', 'times', 'time', 'dates', 'date', 'index'), size)
    if timestamps is None:
        return None
    try:
        values = np.asarray(timestamps)
        if np.issubdtype(values.dtype, np.datetime64):
            days = values.astype('datetime64[D]')
        elif np.issubdtype(values.dtype, np.number):
            finite = values[np.isfinite(values)]
            if finite.size == 0:
                return None
            magnitude = float(np.nanmedian(np.abs(finite)))
            unit = 'ns' if magnitude > 100000000000000.0 else 'ms' if magnitude > 100000000000.0 else 's'
            days = values.astype('datetime64[{}]'.format(unit)).astype('datetime64[D]')
        else:
            days = np.asarray([str(value)[:10] for value in values], dtype='datetime64[D]')
        if period == 'week':
            days = days.astype('datetime64[W]')
        elif period == 'month':
            days = days.astype('datetime64[M]')
        return days.astype(str)
    except (TypeError, ValueError, OverflowError):
        return None

def _derived_levels(highs, lows, keys):
    size = highs.size
    previous_high = np.full(size, np.nan, dtype=float)
    previous_low = np.full(size, np.nan, dtype=float)
    prior_high = np.nan
    prior_low = np.nan
    start = 0
    while start < size:
        end = start + 1
        while end < size and keys[end] == keys[start]:
            end += 1
        previous_high[start:end] = prior_high
        previous_low[start:end] = prior_low
        group_high = highs[start:end]
        group_low = lows[start:end]
        valid_high = group_high[np.isfinite(group_high)]
        valid_low = group_low[np.isfinite(group_low)]
        if valid_high.size:
            prior_high = float(np.max(valid_high))
        if valid_low.size:
            prior_low = float(np.min(valid_low))
        start = end
    return (previous_high, previous_low)

def _float_array(value, size):
    if value is None:
        return np.full(size, np.nan, dtype=float)
    try:
        array = np.asarray(value, dtype=float).reshape(-1)
    except (TypeError, ValueError):
        return np.full(size, np.nan, dtype=float)
    if array.size != size:
        return np.full(size, np.nan, dtype=float)
    return array

def _htf_levels(features, highs, lows, size, period):
    names = {'day': (('previous_day_high', 'prior_day_high', 'prev_day_high', 'pdh'), ('previous_day_low', 'prior_day_low', 'prev_day_low', 'pdl')), 'week': (('previous_week_high', 'prior_week_high', 'prev_week_high', 'pwh'), ('previous_week_low', 'prior_week_low', 'prev_week_low', 'pwl')), 'month': (('previous_month_high', 'prior_month_high', 'prev_month_high', 'pmh'), ('previous_month_low', 'prior_month_low', 'prev_month_low', 'pml'))}[period]
    previous_high = _float_array(_array_value(features, names[0], size), size)
    previous_low = _float_array(_array_value(features, names[1], size), size)
    keys = _period_keys(features, size, period)
    if keys is not None:
        derived_high, derived_low = _derived_levels(highs, lows, keys)
        if not np.any(np.isfinite(previous_high)):
            previous_high = derived_high
        if not np.any(np.isfinite(previous_low)):
            previous_low = derived_low
    return (previous_high, previous_low, keys)

def _entry_events(features, highs, lows, closes, size):
    levels = [_htf_levels(features, highs, lows, size, 'day'), _htf_levels(features, highs, lows, size, 'week'), _htf_levels(features, highs, lows, size, 'month')]
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    low_pending = [False, False, False]
    high_pending = [False, False, False]
    previous_keys = [None, None, None]
    previous_signatures = [None, None, None]
    for t in range(size):
        for index, (previous_high, previous_low, keys) in enumerate(levels):
            key = None if keys is None else keys[t]
            signature = (previous_high[t] if np.isfinite(previous_high[t]) else None, previous_low[t] if np.isfinite(previous_low[t]) else None)
            if previous_keys[index] is not None and key is not None and (key != previous_keys[index]):
                low_pending[index] = False
                high_pending[index] = False
            elif keys is None and previous_signatures[index] is not None and (signature != previous_signatures[index]):
                low_pending[index] = False
                high_pending[index] = False
            previous_keys[index] = key
            previous_signatures[index] = signature
            low_level = previous_low[t]
            high_level = previous_high[t]
            if np.isfinite(lows[t]) and np.isfinite(low_level) and (lows[t] < low_level):
                low_pending[index] = True
            if np.isfinite(highs[t]) and np.isfinite(high_level) and (highs[t] > high_level):
                high_pending[index] = True
            if np.isfinite(closes[t]) and np.isfinite(low_level) and low_pending[index] and (closes[t] > low_level):
                long_entries[t] = True
                low_pending[index] = False
            if np.isfinite(closes[t]) and np.isfinite(high_level) and high_pending[index] and (closes[t] < high_level):
                short_entries[t] = True
                high_pending[index] = False
    return (long_entries, short_entries)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    try:
        highs = _float_array(_array_value(features, ('highs', 'high', 'h'), size), size)
        lows = _float_array(_array_value(features, ('lows', 'low', 'l'), size), size)
        closes = _float_array(_array_value(features, ('closes', 'close', 'c'), size), size)
        long_entries, short_entries = _entry_events(features, highs, lows, closes, size)
    except (AttributeError, TypeError, ValueError):
        pass
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'previous_htf_level_sweep_reclaim', 'hypothesis': '前一已完成日、週或月高低點的流動性 sweep 後 reclaim 可形成反轉進場，並以 ATR 追蹤停損及 reversion 出場管理風險。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'mult'], 'signal_parameter_sets': [{'k_base': 2.0, 'mult': 2.0}]}
