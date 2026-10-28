Calculation: TRAX = 10,000 × the change in a triple-smoothed VWMA of log(close), using the same lookback for all three VWMA calculations
Calculation: DPO = close from (floor(period/2) + 1) bars ago minus the current SMA(close, period)
Long: current DPO > current TRAX AND previous DPO <= previous TRAX AND current TRAX < 0 AND current close > current SMA(close, confirmation lookback)
Short: current DPO < current TRAX AND previous DPO >= previous TRAX AND current TRAX > 0 AND current close < current SMA(close, confirmation lookback)