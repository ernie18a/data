Calculation: Recursive MA trail = MA(close, macro lookback) when no prior value exists; otherwise max(MA(close, macro lookback), prior Recursive MA trail) when core Supertrend is up, or min(MA(close, macro lookback), prior Recursive MA trail) when it is down.
Long: Core Supertrend direction is up.
Short: Core Supertrend direction is down.
Long: Core Supertrend direction changes from down to up.
Short: Core Supertrend direction changes from up to down.
Long: Impulse Supertrend direction changes from down to up.
Short: Impulse Supertrend direction changes from up to down.
Long: Impulse Supertrend direction changes from down to up AND the most recent Order Block is bullish AND no matching impulse alert has fired since that Order Block.
Short: Impulse Supertrend direction changes from up to down AND the most recent Order Block is bearish AND no matching impulse alert has fired since that Order Block.
Long: low > high[2] AND close[1] > high[2] AND close[2] < open[2].
Short: high < low[2] AND close[1] < low[2] AND close[2] > open[2].
Long: PivotLow(low, rejection pivot lookback, rejection pivot lookback) is confirmed AND lower wick > (high - low) * 0.5.
Short: PivotHigh(high, rejection pivot lookback, rejection pivot lookback) is confirmed AND upper wick > (high - low) * 0.5.
Long: low[1] > high[3] AND close[2] > low[2] + ATR(200)[2] * FVG threshold.
Short: low[3] > high[1] AND close[2] < high[2] - ATR(200)[2] * FVG threshold.
Long: On chart bars, for any enabled T timeframe, low < low(T, last completed bar) AND close > low(T, last completed bar).
Short: On chart bars, for any enabled T timeframe, high > high(T, last completed bar) AND close < high(T, last completed bar) AND no enabled T timeframe has low < low(T, last completed bar) AND close > low(T, last completed bar).
Long: The configured BOS break price (close in close-confirmation mode, otherwise high) > the latest confirmed, unbroken PivotHigh(high, floor((BOS fractal length + 1) / 2), floor((BOS fractal length + 1) / 2)).
Short: The configured BOS break price (close in close-confirmation mode, otherwise low) < the latest confirmed, unbroken PivotLow(low, floor((BOS fractal length + 1) / 2), floor((BOS fractal length + 1) / 2)).
Long: close > Recursive MA trail.
Short: close <= Recursive MA trail.