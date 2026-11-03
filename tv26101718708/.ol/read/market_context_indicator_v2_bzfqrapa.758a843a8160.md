Calculation: Short-term EMA = EMA of close with a shorter lookback than the long-term EMA
Calculation: Bullish FVG = current low is above the high two bars ago by at least the configured minimum gap
Calculation: Bearish FVG = current high is below the low two bars ago by at least the configured minimum gap
Calculation: HIPL level = a prior close with at least the configured minimum number of closes within the configured tick tolerance in its surrounding five-bar windows; discard levels within tolerance of an existing level
Calculation: HIPL tests = initial count of nearby closes; increment when a bar closes within tolerance and its volume meets the configured multiple of reference volume
Calculation: Bullish order block = the low-to-midpoint range of a bullish candle at a confirmed volume pivot high; remains valid until a later low falls below its bottom
Calculation: Bearish order block = the midpoint-to-high range of a non-bullish candle at a confirmed volume pivot high; remains valid until a later high rises above its top
Long: Short-term EMA > long-term EMA
Long: Short-term EMA crosses above long-term EMA
Long: Bullish FVG
Long: Close > HIPL level AND HIPL tests >= configured minimum
Long: Confirmed volume pivot high AND pivot candle close > pivot candle open
Short: Short-term EMA < long-term EMA
Short: Short-term EMA crosses below long-term EMA
Short: Bearish FVG
Short: Close <= HIPL level AND HIPL tests >= configured minimum
Short: Confirmed volume pivot high AND pivot candle close <= pivot candle open