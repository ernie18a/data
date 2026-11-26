Calculation: VW RSI = 100 - 100 / (1 + R), where R = 100 when RMA(weighted loss, RSI lookback) = 0, otherwise RMA(weighted gain, RSI lookback) / RMA(weighted loss, RSI lookback); weighted gain = max(change(close), 0) and weighted loss = max(-change(close), 0), each multiplied by volume / SMA(volume, volume smoothing lookback) when volume weighting is enabled
Long: VW RSI > RSI midpoint
Short: VW RSI <= RSI midpoint
Long: VW RSI crosses above oversold level
Short: VW RSI crosses below overbought level
Long: VW RSI crosses above EMA(VW RSI, signal-line lookback)
Short: VW RSI crosses below EMA(VW RSI, signal-line lookback)
Long: On a bar confirming PivotLow(VW RSI, divergence pivot lookback, divergence pivot lookback), low at its pivot bar is lower and VW RSI at its pivot bar is higher than at the previous confirmed PivotLow
Short: On a bar confirming PivotHigh(VW RSI, divergence pivot lookback, divergence pivot lookback), high at its pivot bar is higher and VW RSI at its pivot bar is lower than at the previous confirmed PivotHigh