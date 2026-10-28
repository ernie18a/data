Calculation: Stochastic RSI = 100 × (RSI(close) − lowest RSI over the lookback) / (highest RSI over the same lookback − lowest RSI over the same lookback)
Calculation: VWAP = session cumulative volume-weighted average of hlc3, including the current bar
Long: Stochastic RSI crosses above its lower threshold AND the shorter-period SMA of close > the longer-period SMA of close AND close < VWAP
Short: Stochastic RSI crosses below its upper threshold AND the shorter-period SMA of close < the longer-period SMA of close AND close > VWAP
Exit: Long, low <= preceding bar close − stop distance OR high >= preceding bar close + target distance
Exit: Short, high >= preceding bar close + stop distance OR low <= preceding bar close − target distance