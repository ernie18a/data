Calculation: Fast stochastic = SMA(Stochastic(close, high, low, stochastic lookback), K smoothing)
Calculation: Slow stochastic = SMA(Fast stochastic, D smoothing)
Calculation: Reversal direction = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > stochastic level; -1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < stochastic level; otherwise the prior value, initially 0
Calculation: Volume-flow direction = 1 when EMA(SUM(IF((high - low) * volume > 0, (close - open) / (high - low) * volume, 0), max(flow lookback A, flow lookback B)), max(flow lookback A, flow lookback B)) - EMA(SUM(IF((high - low) * volume > 0, (close - open) / (high - low) * volume, 0), min(flow lookback A, flow lookback B)), min(flow lookback A, flow lookback B)) > 0; -1 when that difference < 0; otherwise the prior value, initially 0
Calculation: Trade direction = 1 when Reversal direction = 1 AND Volume-flow direction = 1; -1 when Reversal direction = -1 AND Volume-flow direction = -1; otherwise 0; invert nonzero values when reverse toggle is enabled
Long: Trade direction = 1
Short: Trade direction = -1
Exit: long, Trade direction = 0
Exit: short, Trade direction = 0