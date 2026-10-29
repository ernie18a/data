Calculation: Open and close moving averages = the selected moving average of higher-timeframe open and close, using the same type and lookback; use the still-forming higher-timeframe bar.
Calculation: Long stop = entry price × (1 − fixed stop %) until any bar’s high exceeds entry price × (1 + activation %); thereafter, the greater of the previous long stop and current high × (1 − trail %).
Calculation: Short stop = entry price × (1 + fixed stop %) until any bar’s low falls below entry price × (1 − activation %); thereafter, the lesser of the previous short stop and current low × (1 + trail %).
Long: Higher-timeframe close moving average crosses above higher-timeframe open moving average AND (ADX filter disabled OR chart-timeframe ADX > its adaptive median over a longer lookback, or > the configured threshold).
Short: Higher-timeframe close moving average crosses below higher-timeframe open moving average AND (ADX filter disabled OR chart-timeframe ADX > its adaptive median over a longer lookback, or > the configured threshold).
Exit: Long, low ≤ long stop OR high ≥ entry price × (1 + take-profit %).
Exit: Short, high ≥ short stop OR low ≤ entry price × (1 − take-profit %).