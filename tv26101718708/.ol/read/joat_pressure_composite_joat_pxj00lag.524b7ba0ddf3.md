Calculation: Close-location value = (2 × close − low − high) / max(high − low, minimum price increment)
Calculation: Relative volume = volume / its moving average
Calculation: Weighted volume = volume × (relative-volume boost if volume exceeds its moving average, otherwise 1) × (1 + absolute close-location value)
Calculation: Accumulation-distribution flow = cumulative sum of close-location value × weighted volume
Calculation: Pressure z-score = z-score of accumulation-distribution flow minus its smoothing average
Calculation: Volume sigma z-score = z-score of the square root of the EMA of squared log volume returns
Calculation: Effort z-score = z-score of the EMA of close-location value × relative volume
Calculation: Efficiency bias = (close − close from the efficiency lookback bars ago) / sum of absolute close changes over that lookback; use 0 if the path is zero
Calculation: VWAP bias = (close − anchored VWAP) / ATR
Calculation: Composite pressure = weighted sum of pressure z-score, effort z-score, volume sigma z-score, RSI-based momentum bias ((RSI − 50) / 10), efficiency bias, and VWAP bias
Calculation: Signal line = EMA of composite pressure
Calculation: Pressure spread = composite pressure − signal line
Calculation: Regime basis = EMA of composite pressure; regime deviation = standard deviation of composite pressure
Calculation: Upper/lower envelope = regime basis ± regime deviation × envelope multiplier
Calculation: Upper/lower extreme = regime basis ± regime deviation × extreme multiplier
Calculation: Auction skew = average of pressure z-score, effort z-score, and VWAP bias
Calculation: Bull trend = fast EMA of close ≥ slow EMA of close and close ≥ slow EMA; bear trend = fast EMA of close < slow EMA of close and close < slow EMA. The fast EMA uses a shorter length than the slow EMA.
Long: (composite pressure > 0 AND pressure spread > minimum spread AND pressure z-score > 0 AND effort z-score > 0 AND (trend gate disabled OR bull trend) AND (VWAP gate disabled OR close ≥ anchored VWAP) AND (composite pressure > upper envelope OR composite pressure > upper extreme)) OR (pressure z-score > 0 AND effort z-score < 0 AND composite pressure > 0 AND pressure spread < 0) OR (composite pressure > regime basis AND pressure spread > 0 AND auction skew > 0) OR (at a confirmed composite-pressure pivot low, current pivot low > previous composite-pressure pivot low within the divergence scan AND price low at the current pivot < price low at the previous pivot)
Short: (composite pressure < 0 AND pressure spread < −minimum spread AND pressure z-score < 0 AND effort z-score < 0 AND (trend gate disabled OR bear trend) AND (VWAP gate disabled OR close < anchored VWAP) AND (composite pressure < lower envelope OR composite pressure < lower extreme)) OR (pressure z-score < 0 AND effort z-score > 0 AND composite pressure < 0 AND pressure spread > 0) OR (composite pressure < regime basis AND pressure spread < 0 AND auction skew < 0) OR (at a confirmed composite-pressure pivot high, current pivot high < previous composite-pressure pivot high within the divergence scan AND price high at the current pivot > price high at the previous pivot)