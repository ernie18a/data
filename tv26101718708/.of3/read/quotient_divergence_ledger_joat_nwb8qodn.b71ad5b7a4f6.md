Calculation: composite flow = (first weight * (EMA(IF(close > open, volume, volume * off-direction fraction), wave length) - EMA(IF(close < open, volume, volume * off-direction fraction), wave length)) + second weight * EMA(volume * ((close - low) - (high - close)) / MAX(high - low, minimum price increment), wave length) + third weight * EMA(volume * (close - open) / MAX(high - low, minimum price increment), wave length)) / EMA(MAX(volume, volume floor), wave length)
Calculation: flow = EMA(composite flow, smoothing length)
Calculation: flow signal = EMA(flow, signal length)
Calculation: signal slope = flow signal - flow signal[1]
Calculation: bull streak = IF(flow > 0, bull streak[1] + 1, 0)
Calculation: bear streak = IF(flow < 0, bear streak[1] + 1, 0)
Calculation: low pivot = PivotLow(flow, pivot length, pivot length)
Calculation: prior low pivot value = last non-NA value of low pivot before the current bar
Calculation: prior low pivot price = low[pivot length] at the bar where the prior low pivot was confirmed
Calculation: bars since prior low pivot = bars elapsed since the last non-NA value of low pivot before the current bar
Calculation: high pivot = PivotHigh(flow, pivot length, pivot length)
Calculation: prior high pivot value = last non-NA value of high pivot before the current bar
Calculation: prior high pivot price = high[pivot length] at the bar where the prior high pivot was confirmed
Calculation: bars since prior high pivot = bars elapsed since the last non-NA value of high pivot before the current bar
Long: low[pivot length] < prior low pivot price AND low pivot > prior low pivot value AND low pivot - prior low pivot value >= minimum oscillator move AND bars since prior low pivot >= minimum gap AND (prior low pivot price - low[pivot length]) / ATR(ATR length)[pivot length] >= minimum price move in ATR
Long: low[pivot length] > prior low pivot price AND low pivot < prior low pivot value AND prior low pivot value - low pivot >= minimum oscillator move AND bars since prior low pivot >= minimum gap AND (low[pivot length] - prior low pivot price) / ATR(ATR length)[pivot length] >= minimum price move in ATR
Short: high[pivot length] > prior high pivot price AND high pivot < prior high pivot value AND prior high pivot value - high pivot >= minimum oscillator move AND bars since prior high pivot >= minimum gap AND (high[pivot length] - prior high pivot price) / ATR(ATR length)[pivot length] >= minimum price move in ATR
Short: high[pivot length] < prior high pivot price AND high pivot > prior high pivot value AND high pivot - prior high pivot value >= minimum oscillator move AND bars since prior high pivot >= minimum gap AND (prior high pivot price - high[pivot length]) / ATR(ATR length)[pivot length] >= minimum price move in ATR
Long: flow crosses above zero
Short: flow crosses below zero
Long: flow crosses above flow signal
Short: flow crosses below flow signal
Long: flow >= upper threshold
Short: flow <= lower threshold
Long: bull streak >= streak level AND bull streak[1] < streak level
Short: bear streak >= streak level AND bear streak[1] < streak level
Long: flow >= flow signal
Short: flow < flow signal
Long: flow > 0 AND signal slope >= 0
Long: flow > 0 AND signal slope < 0 AND flow > absorption fraction * upper threshold
Short: flow < 0 AND signal slope <= 0
Short: flow < 0 AND signal slope > 0 AND flow < absorption fraction * lower threshold
Long: bull streak > bear streak
Short: bear streak > bull streak