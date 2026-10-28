Calculation: Short-term moving average = simple moving average of close with a shorter lookback than the long-term moving average
Calculation: Long-term moving average = simple moving average of close with a longer lookback than the short-term moving average
Calculation: Capitulation candle = open > close AND (high - low - abs(close - open)) > abs(close - open) AND volume > its moving average
Calculation: Wave phase = track confirmed swing points, where a swing high has the highest high and a swing low has the lowest low within a symmetric window around the point; transition from no phase to A on a swing high, A to B on a swing low, B to C on a swing high, and C to no phase on a swing low
Long: close < long-term moving average AND wave phase is C AND capitulation candle AND first staged entry has not triggered in the current buy cycle
Long: close crosses above short-term moving average AND first staged entry has triggered AND second staged entry has not triggered in the current buy cycle
Long: short-term moving average crosses above long-term moving average AND second staged entry has triggered AND final staged entry has not triggered in the current buy cycle
Exit: Long, short-term moving average crosses below long-term moving average AND final staged entry has triggered
Calculation: A buy cycle becomes active when close < long-term moving average; after an exit it becomes inactive and staged-entry states reset. The exit trigger resets after close > long-term moving average.