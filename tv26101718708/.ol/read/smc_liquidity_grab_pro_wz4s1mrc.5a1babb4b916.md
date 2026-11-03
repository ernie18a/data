Calculation: Previous completed higher-timeframe high/low = high/low of the last completed bar on a timeframe higher than the chart timeframe
Calculation: Latest confirmed swing low/high = the most recent chart-timeframe pivot low/high, confirmed using the same swing-lookback length before and after the pivot bar
Calculation: Long stop = latest confirmed swing low at entry
Calculation: Short stop = latest confirmed swing high at entry
Calculation: Long target = entry close + (entry close − long stop) × risk-to-reward ratio
Calculation: Short target = entry close − (short stop − entry close) × risk-to-reward ratio
Long: low < previous completed higher-timeframe low AND close > previous completed higher-timeframe low AND position size = 0
Short: high > previous completed higher-timeframe high AND close < previous completed higher-timeframe high AND position size = 0
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target