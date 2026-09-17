import numpy as np
from datetime import date, datetime, timezone

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def _period_key(value: object, period: str) -> tuple:
    if hasattr(value, 'to_pydatetime'):
        value = value.to_pydatetime()
    if isinstance(value, datetime):
        day = value.date()
    elif isinstance(value, date):
        day = value
    else:
        day = datetime.fromtimestamp(float(value), tz=timezone.utc).date()
    if period == 'day':
        return (day.year, day.month, day.day)
    if period == 'week':
        iso_year, iso_week, _ = day.isocalendar()
        return (iso_year, iso_week)
    return (day.year, day.month)

def _aggregate_previous_levels(highs: object, lows: object, timestamps: object, period: str, size: int) -> tuple:
    previous_highs = np.full(size, np.nan, dtype=float)
    previous_lows = np.full(size, np.nan, dtype=float)
    current_key = None
    current_high = np.nan
    current_low = np.nan
    completed_high = np.nan
    completed_low = np.nan
    for index in range(size):
        key = _period_key(timestamps[index], period)
        if current_key is None:
            current_key = key
        elif key != current_key:
            completed_high = current_high
            completed_low = current_low
            current_key = key
            current_high = np.nan
            current_low = np.nan
        high = float(highs[index])
        low = float(lows[index])
        current_high = high if np.isnan(current_high) else max(current_high, high)
        current_low = low if np.isnan(current_low) else min(current_low, low)
        previous_highs[index] = completed_high
        previous_lows[index] = completed_low
    return (previous_highs, previous_lows)

def _precomputed_level(market: object, names: tuple, size: int) -> object:
    for name in names:
        if hasattr(market, name):
            value = getattr(market, name)
            if callable(value):
                value = value()
            values = np.asarray(value, dtype=float)
            if values.ndim != 1 or values.size != size:
                raise ValueError(f'{name} must be a one-dimensional series of market size')
            return values
    return None

def _htf_levels(features: object, period: str) -> tuple:
    market = features.market
    size = market.size
    label = {'day': 'day', 'week': 'week', 'month': 'month'}[period]
    highs = _precomputed_level(market, (f'previous_{label}_highs', f'previous_{label}_high', f'prev_{label}_highs', f'prev_{label}_high'), size)
    lows = _precomputed_level(market, (f'previous_{label}_lows', f'previous_{label}_low', f'prev_{label}_lows', f'prev_{label}_low'), size)
    if highs is not None and lows is not None:
        return (highs, lows)
    timestamps = None
    for name in ('timestamps', 'timestamp', 'times', 'time'):
        if hasattr(market, name):
            timestamps = getattr(market, name)
            break
    if timestamps is None:
        raise AttributeError(f'market must provide previous {label} levels or timestamps')
    return _aggregate_previous_levels(market.highs, market.lows, timestamps, period, size)

def generate_signals(features: object, signal_params: dict) -> tuple:
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    htf_levels = tuple((_htf_levels(features, period) for period in ('day', 'week', 'month')))
    for index in range(1, size):
        for previous_highs, previous_lows in htf_levels:
            if closes[index - 1] <= previous_highs[index - 1] and closes[index] > previous_highs[index]:
                long_entries[index] = True
            if closes[index - 1] >= previous_lows[index - 1] and closes[index] < previous_lows[index]:
                short_entries[index] = True
    exit_params = {'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'previous_htf_level_breakout', 'hypothesis': '突破前一個已完成日、週或月的高低點，代表動能延續。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}
