Calculation: Smoothed Stochastic RSI = SMA(SMA(100 × (RSI(close, RSI lookback) − lowest RSI over stochastic lookback) / (highest RSI over stochastic lookback) − lowest RSI over stochastic lookback), K smoothing length), D smoothing length)
Long: smoothed Stochastic RSI < long threshold AND MFI < long threshold AND close < EMA(close, EMA lookback) AND flat
Short: smoothed Stochastic RSI > short threshold AND MFI > short threshold AND close > EMA(close, EMA lookback) AND flat
Exit: long, high >= entry price + take-profit distance OR low <= entry price − stop-loss distance
Exit: short, low <= entry price − take-profit distance OR high >= entry price + stop-loss distance
Exit: long, smoothed Stochastic RSI > short threshold AND MFI > short threshold AND close > EMA(close, EMA lookback)
Exit: short, smoothed Stochastic RSI < long threshold AND MFI < long threshold AND close < EMA(close, EMA lookback)