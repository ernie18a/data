Calculation: Flow(series) = 2 * (percent of the previous N CCI(series) values that are lower than the current CCI(series) value - 50), on chart-timeframe bars, N a fixed lookback; CCI uses a shorter window than N
Calculation: OBV = cumulative sum of sign(close - previous close) * volume
Calculation: AD = cumulative sum of ((close - low) - (high - close)) / (high - low) * volume, with the term 0 when high == low
Calculation: Fitted = A * |A / M|, where A = mean(Flow(OBV), Flow(AD), Flow(ohlc4)), M = mean of the absolute values of those three Flows, and Fitted = 0 when M == 0
Long: Fitted <= -(extreme threshold close to 100)
Short: Fitted >= +(extreme threshold close to 100)