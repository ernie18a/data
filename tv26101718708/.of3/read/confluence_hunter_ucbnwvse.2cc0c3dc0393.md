Calculation: Bar delta = (high > low ? (2 * (close - low) / (high - low) - 1) : 0) * volume
Calculation: Bullish liquidity sweep = a latest confirmed pivot low(low, swing lookback, swing lookback) exists AND low < that pivot low AND close > that pivot low AND (high > low ? (min(open, close) - low) / (high - low) : 0) >= minimum wick ratio
Calculation: Bearish liquidity sweep = a latest confirmed pivot high(high, swing lookback, swing lookback) exists AND high > that pivot high AND close < that pivot high AND (high > low ? (high - max(open, close)) / (high - low) : 0) >= minimum wick ratio
Calculation: Session volume profile POC = midpoint of the highest-volume bin in the active session profile; on each chart bar, split its volume equally among the bins its low-high range intersects, with bins spanning the session low-high range as of that bar and using the profile row count; map the highest-volume bin midpoint to the current session low-high range
Calculation: Bullish factor count = number of true conditions among (EMA(close, shortest EMA lookback) > EMA(close, next-shortest EMA lookback) > EMA(close, next-longer EMA lookback) > EMA(close, longest EMA lookback); close > Session VWAP(hlc3, current session); bullish liquidity sweep; EMA(Bar delta, order-flow lookback) > 0; close > Session volume profile POC; RSI(close, RSI lookback) > upper RSI threshold)
Calculation: Bearish factor count = number of true conditions among (EMA(close, shortest EMA lookback) < EMA(close, next-shortest EMA lookback) < EMA(close, next-longer EMA lookback) < EMA(close, longest EMA lookback); close < Session VWAP(hlc3, current session); bearish liquidity sweep AND NOT bullish liquidity sweep; EMA(Bar delta, order-flow lookback) < 0; close < Session volume profile POC; RSI(close, RSI lookback) < lower RSI threshold)
Long: EMA(close, shortest EMA lookback) > EMA(close, next-shortest EMA lookback) > EMA(close, next-longer EMA lookback) > EMA(close, longest EMA lookback)
Short: EMA(close, shortest EMA lookback) < EMA(close, next-shortest EMA lookback) < EMA(close, next-longer EMA lookback) < EMA(close, longest EMA lookback)
Long: close > Session VWAP(hlc3, current session)
Short: close < Session VWAP(hlc3, current session)
Long: bullish liquidity sweep
Short: bearish liquidity sweep
Long: EMA(Bar delta, order-flow lookback) > 0
Short: EMA(Bar delta, order-flow lookback) < 0
Long: Bar delta > 0 AND abs(Bar delta) > strong-delta multiplier * EMA(abs(Bar delta), order-flow lookback)
Short: Bar delta < 0 AND abs(Bar delta) > strong-delta multiplier * EMA(abs(Bar delta), order-flow lookback)
Long: close > Session volume profile POC
Short: close < Session volume profile POC
Long: RSI(close, RSI lookback) > upper RSI threshold
Short: RSI(close, RSI lookback) < lower RSI threshold
Long: Bullish factor count - Bearish factor count >= minimum agreeing factor count
Short: Bullish factor count - Bearish factor count <= -minimum agreeing factor count
Long: Bullish factor count >= minimum agreeing factor count AND Bearish factor count <= maximum opposing factor count
Short: Bearish factor count >= minimum agreeing factor count AND Bullish factor count <= maximum opposing factor count