Calculation: MACD = EMA(close, shorter MACD lookback) - EMA(close, longer MACD lookback)
Calculation: Volume Oscillator = 100 * (EMA(volume, shorter volume-oscillator lookback) - EMA(volume, longer volume-oscillator lookback)) / EMA(volume, longer volume-oscillator lookback)
Long: MACD crosses above 0 AND Volume Oscillator > 0 AND volume > volume[1] * volume threshold
Short: MACD crosses below 0 AND Volume Oscillator > 0 AND volume < volume[1] * volume threshold
Exit: Long, high >= entry price + stop-loss distance * reward multiple OR low <= entry price - stop-loss distance
Exit: Short, low <= entry price - stop-loss distance * reward multiple OR high >= entry price + stop-loss distance