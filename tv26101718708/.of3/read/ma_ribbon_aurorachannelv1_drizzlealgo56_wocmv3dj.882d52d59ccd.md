Calculation: Ribbon center = average of the enabled MA(source, lookback, type) values across the four ribbon averages, or close if none are enabled; each average has an independent enable flag, source, lookback, and type (SMA, EMA, RMA, WMA, or VWMA).
Calculation: Smoothed ribbon width = EMA(max of 2 * abs(source - MA(source, lookback, type)) across the enabled ribbon averages, using zero for each disabled average, width lookback).
Calculation: Volume factor = 1 + max(0, volume / SMA(volume, volume lookback) - 1) * volume sensitivity, using a ratio of 1 when SMA(volume, volume lookback) <= 0.
Calculation: Upper wick factor = 1 + asymmetry strength * RMA(max(0, high - max(open, close)), wick lookback) / max(ATR(wick lookback), minimum tick).
Calculation: Lower wick factor = 1 + asymmetry strength * RMA(max(0, min(open, close) - low), wick lookback) / max(ATR(wick lookback), minimum tick).
Calculation: Core half-width = smoothed ribbon width * core multiplier * volume factor / 2.
Calculation: Core upper = EMA(ribbon center + core half-width * upper wick factor, edge smoothing lookback).
Calculation: Core lower = EMA(ribbon center - core half-width * lower wick factor, edge smoothing lookback).
Calculation: Envelope offset = smoothed ribbon width * envelope multiplier * volume factor / 2.
Calculation: Upper expansion envelope = EMA(core upper + envelope offset * upper wick factor, edge smoothing lookback).
Calculation: Lower expansion envelope = EMA(core lower - envelope offset * lower wick factor, edge smoothing lookback).
Long: close crosses above upper expansion envelope.
Short: close crosses below lower expansion envelope.