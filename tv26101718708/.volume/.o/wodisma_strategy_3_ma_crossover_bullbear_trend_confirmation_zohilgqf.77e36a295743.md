Calculation: Volatility = 100 × (highest close over the lookback − lowest close over the lookback) / lowest close over the lookback
Long: Long entries enabled AND Volatility > threshold AND (bull-bear filter disabled OR long-term MA > bull-bear MA) AND short-term MA > long-term MA AND mid-term MA crosses above long-term MA
Short: Short entries enabled AND Volatility > threshold AND (bull-bear filter disabled OR long-term MA < bull-bear MA) AND short-term MA < long-term MA AND mid-term MA crosses below long-term MA
Exit: Long, low ≤ entry price × (1 − stop-loss percentage)
Exit: Short, high ≥ entry price × (1 + stop-loss percentage)
Exit: Long, bull-bear filter enabled AND long-term MA > bull-bear MA AND short-term MA < long-term MA AND mid-term MA crosses below long-term MA AND Volatility > threshold
Exit: Short, bull-bear filter enabled AND long-term MA < bull-bear MA AND short-term MA > long-term MA AND mid-term MA crosses above long-term MA AND Volatility > threshold
Exit: Long, bull-bear filter enabled AND long-term MA < bull-bear MA
Exit: Short, bull-bear filter enabled AND long-term MA > bull-bear MA
Exit: Long, bull-bear filter disabled AND short-term MA < long-term MA AND mid-term MA crosses below long-term MA AND Volatility > threshold
Exit: Short, bull-bear filter disabled AND short-term MA > long-term MA AND mid-term MA crosses above long-term MA AND Volatility > threshold

Short-, mid-, and long-term moving averages use respectively shorter, intermediate, and longer lookbacks. The bull-bear MA has its own configurable lookback. Each uses its selected source, MA type, and timeframe; a higher-timeframe MA uses that timeframe’s bar still forming.