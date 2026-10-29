Calculation: Daily anchored VWAP = volume-weighted average of hlc3, reset at each daily boundary
Calculation: VWAP bands = daily anchored VWAP plus or minus its anchored standard deviation multiplied by a configurable width
Calculation: VWAP residual = close − daily anchored VWAP
Calculation: Residual lower and upper percentiles = 25th and 75th percentiles of VWAP residual over the signal lookback
Calculation: Expansion ratio = standard deviation of VWAP residual over the signal lookback ÷ standard deviation of close over the same lookback
Calculation: VWAP slope = current linear-regression value of daily anchored VWAP over the signal lookback minus its value one bar earlier
Calculation: Micro flow = average of +1 for each rising close, −1 for each falling close, and 0 for each unchanged close across the configured span of lower-timeframe bars; use completed bars only and exclude the freshest lower-timeframe bar
Long: (expansion ratio < expansion threshold AND VWAP residual ≤ residual lower percentile AND micro flow > positive flow threshold OR expansion ratio ≥ expansion threshold AND close > upper VWAP band AND VWAP slope > 0 AND micro flow > positive flow threshold) AND inside configured session (if enabled) AND configured cooldown elapsed AND long side allowed
Short: (expansion ratio < expansion threshold AND VWAP residual ≥ residual upper percentile AND micro flow < negative flow threshold OR expansion ratio ≥ expansion threshold AND close < lower VWAP band AND VWAP slope < 0 AND micro flow < negative flow threshold) AND inside configured session (if enabled) AND configured cooldown elapsed AND short side allowed
Exit: Long, low ≤ entry price − ATR × stop multiple OR high ≥ entry price + ATR × target multiple OR short-entry condition
Exit: Short, high ≥ entry price + ATR × stop multiple OR low ≤ entry price − ATR × target multiple OR long-entry condition