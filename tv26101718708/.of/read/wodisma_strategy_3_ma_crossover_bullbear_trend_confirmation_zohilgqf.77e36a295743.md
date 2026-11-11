Calculation: Trend moving averages = independently selected SMA, EMA, RMA, WMA, or VWMA of a selected price source; the short-term, mid-term, long-term, and bull-bear roles can select any of these averages. Each average can use the chart timeframe, a higher timeframe using its last completed bar, or a lower timeframe using the last completed lower-timeframe bar within the chart bar.
Calculation: Volatility = 100 × (highest close over the lookback − lowest close over the lookback) / lowest close over the lookback.
Long: Long entries enabled AND volatility > threshold AND short-term moving average > long-term moving average AND mid-term moving average crosses above long-term moving average AND (bull-bear filter disabled OR long-term moving average > bull-bear moving average).
Short: Short entries enabled AND volatility > threshold AND short-term moving average < long-term moving average AND mid-term moving average crosses below long-term moving average AND (bull-bear filter disabled OR long-term moving average < bull-bear moving average).
Exit: long, bull-bear filter enabled AND long-term moving average < bull-bear moving average.
Exit: short, bull-bear filter enabled AND long-term moving average > bull-bear moving average.
Exit: long, volatility > threshold AND short-term moving average < long-term moving average AND mid-term moving average crosses below long-term moving average AND ((bull-bear filter enabled AND long-term moving average > bull-bear moving average) OR (bull-bear filter disabled AND at least one entry direction disabled)).
Exit: short, volatility > threshold AND short-term moving average > long-term moving average AND mid-term moving average crosses above long-term moving average AND ((bull-bear filter enabled AND long-term moving average < bull-bear moving average) OR (bull-bear filter disabled AND at least one entry direction disabled)).
Exit: long, low <= average entry price × (1 − stop-loss fraction).
Exit: short, high >= average entry price × (1 + stop-loss fraction).
Exit: long, short entry condition is true.
Exit: short, long entry condition is true.