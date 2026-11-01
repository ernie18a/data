Calculation: Impulse MACD = Let the upper and lower envelope be RMA(high) and RMA(low), and let the center be 2 × EMA(typical price) − EMA(EMA(typical price)); all four averages use the same lookback. If the center is above the upper envelope, return center − upper envelope; if below the lower envelope, return center − lower envelope; otherwise return zero. Its signal is an SMA of Impulse MACD.
Long: MACD line > MACD signal line
Short: MACD line < MACD signal line
Long: Impulse MACD > Impulse MACD signal
Short: Impulse MACD < Impulse MACD signal
Long: Higher-timeframe MACD line > higher-timeframe MACD signal line AND higher-timeframe ATR > 0
Short: Higher-timeframe MACD line < higher-timeframe MACD signal line AND higher-timeframe ATR > 0
Calculation: Higher-timeframe MACD = MACD calculated on higher-timeframe bars using the still-forming bar and the same fast, slow, and signal lengths as the chart-timeframe MACD; the fast EMA has a shorter lookback than the slow EMA.