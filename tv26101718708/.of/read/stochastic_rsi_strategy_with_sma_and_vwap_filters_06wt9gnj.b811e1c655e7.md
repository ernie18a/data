Calculation: Stochastic RSI = 100 × (RSI(close, lookback) − lowest RSI over lookback) / (highest RSI over lookback − lowest RSI over lookback)
Calculation: SMA spread = shorter-lookback SMA(close) − longer-lookback SMA(close)
Long: Stochastic RSI crosses above 30 AND SMA spread > 0 AND close < VWAP
Short: Stochastic RSI crosses below 70 AND SMA spread < 0 AND close > VWAP
Exit: Long, low <= prior close − stop distance OR high >= prior close + take-profit distance
Exit: Short, high >= prior close + stop distance OR low <= prior close − take-profit distance