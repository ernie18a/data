Calculation: opening-range high = running highest high from the first chart bar of each configured RTH session through the opening-range duration, then held fixed for that session; the duration in bars is floored and clamped to at least one bar
Calculation: opening-range low = running lowest low from the first chart bar of each configured RTH session through the opening-range duration, then held fixed for that session; the duration in bars is floored and clamped to at least one bar
Calculation: opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: premarket high = highest high from the start of each day through the bar before the configured RTH session, frozen at that session's start
Calculation: premarket low = lowest low from the start of each day through the bar before the configured RTH session, frozen at that session's start
Long: during the configured RTH session, after the opening range completes, close crosses above opening-range high AND (the MACD filter is disabled OR MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal); fast lookback is shorter than slow lookback
Short: during the configured RTH session, after the opening range completes, close crosses below opening-range low AND (the MACD filter is disabled OR MACD(close, fast lookback, slow lookback, signal lookback).line <= MACD(close, fast lookback, slow lookback, signal lookback).signal); fast lookback is shorter than slow lookback
Long: close crosses above premarket high
Short: close crosses below premarket low
Long: EMA(close, shortest of five ordered lookbacks) > EMA(close, next-shortest lookback) > EMA(close, middle lookback) > EMA(close, next-longest lookback) > EMA(close, longest lookback)
Short: EMA(close, shortest of five ordered lookbacks) < EMA(close, next-shortest lookback) < EMA(close, middle lookback) < EMA(close, next-longest lookback) < EMA(close, longest lookback)
Long: the ordered EMA stack condition first becomes true on the current chart bar
Short: the reverse ordered EMA stack condition first becomes true on the current chart bar
Long: close > opening-range midpoint AND MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal
Short: close < opening-range midpoint AND MACD(close, fast lookback, slow lookback, signal lookback).line <= MACD(close, fast lookback, slow lookback, signal lookback).signal
Long: MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal AND close of the current T1 bar (still forming), sampled on chart bars, > EMA(close, T1 EMA lookback, calculated on T1 bars including the bar still forming and sampled on chart bars)
Short: MACD(close, fast lookback, slow lookback, signal lookback).line <= MACD(close, fast lookback, slow lookback, signal lookback).signal AND close of the current T1 bar (still forming), sampled on chart bars, <= EMA(close, T1 EMA lookback, calculated on T1 bars including the bar still forming and sampled on chart bars)
Long: MACD(close, fast lookback, slow lookback, signal lookback).line > 0 AND MACD(close, fast lookback, slow lookback, signal lookback).signal > 0 AND MACD(close, fast lookback, slow lookback, signal lookback).histogram > 0
Long: MACD(close, fast lookback, slow lookback, signal lookback).line > 0 AND MACD(close, fast lookback, slow lookback, signal lookback).signal > 0 AND MACD(close, fast lookback, slow lookback, signal lookback).histogram > 0, first true on the current chart bar
Short: MACD(close, fast lookback, slow lookback, signal lookback).line <= 0
Short: MACD(close, fast lookback, slow lookback, signal lookback).signal <= 0
Short: MACD(close, fast lookback, slow lookback, signal lookback).histogram <= 0
Short: MACD(close, fast lookback, slow lookback, signal lookback).line <= 0 OR MACD(close, fast lookback, slow lookback, signal lookback).signal <= 0 OR MACD(close, fast lookback, slow lookback, signal lookback).histogram <= 0