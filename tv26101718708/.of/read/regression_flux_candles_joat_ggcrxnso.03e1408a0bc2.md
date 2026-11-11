Calculation: Regression open or close = endpoint of a least-squares linear regression fitted to the corresponding price field over its lookback, including the current bar.
Calculation: Bullish timeframe count = number of configured timeframes whose regression close is greater than or equal to their regression open. Use the chart timeframe, the last completed higher-timeframe bar, or the last completed lower-timeframe bar within the chart bar, as applicable.
Long: Regression close >= regression open.
Short: Regression close < regression open.
Long: Regression close crosses above its SMA AND (volume filter disabled OR volume > volume SMA) AND (RSI filter disabled OR RSI of close < upper RSI threshold) AND zero-based bar index >= max(3 * regression lookback, trend EMA lookback + 5).
Short: Regression close crosses below its SMA AND (volume filter disabled OR volume > volume SMA) AND (RSI filter disabled OR RSI of close > lower RSI threshold) AND zero-based bar index >= max(3 * regression lookback, trend EMA lookback + 5).
Long: Regression close >= regression open on a configured timeframe, using the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar, as applicable.
Short: Regression close < regression open on a configured timeframe, using the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar, as applicable.
Long: Bullish timeframe count >= upper count threshold.
Short: Bullish timeframe count <= lower count threshold.