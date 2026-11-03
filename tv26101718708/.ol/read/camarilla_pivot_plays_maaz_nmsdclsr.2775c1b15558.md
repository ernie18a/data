Calculation: Selected session close, high, and low = the previous regular session’s close, high, and low, or the previous extended session’s values when the configured session mode selects extended hours; in automatic mode, select extended hours when the premarket or postmarket range exceeds the regular-session range by a configured fraction of the previous completed daily ATR. Use completed session bars aggregated at the chart timeframe or a lower timeframe.
Calculation: R3 = selected session close + (selected session high − selected session low) × configured Camarilla factor / 4
Calculation: S3 = selected session close − (selected session high − selected session low) × configured Camarilla factor / 4
Calculation: R4 = selected session close + (selected session high − selected session low) × configured Camarilla factor / 2
Calculation: S4 = selected session close − (selected session high − selected session low) × configured Camarilla factor / 2
Calculation: Relative volume = current bar volume / moving average of volume over a configured lookback
Long: current low crosses below S3 AND current close > S3
Short: current high crosses above R3 AND current close < R3
Long: current close crosses above R4 AND current close > current open AND (volume filter disabled OR relative volume ≥ configured threshold)
Short: current close crosses below S4 AND current close < current open AND (volume filter disabled OR relative volume ≥ configured threshold)