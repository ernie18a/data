Calculation: Momentum wave = EMA((close - close[1]) * volume, wave lookback)
Long: Momentum wave crosses above WMA(Momentum wave, signal lookback) AND Momentum wave < 0
Short: Momentum wave crosses below WMA(Momentum wave, signal lookback) AND Momentum wave > 0
Long: PivotLow(Momentum wave, pivot lookback, pivot lookback) is confirmed AND low[pivot lookback] < low at the previous confirmed Momentum wave pivot AND Momentum wave[pivot lookback] > Momentum wave at the previous confirmed Momentum wave pivot