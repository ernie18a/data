Calculation: Earlier higher-timeframe high = high of the completed bar immediately before the last completed higher-timeframe bar
Calculation: Earlier higher-timeframe low = low of the completed bar immediately before the last completed higher-timeframe bar
Calculation: Long stop = last completed higher-timeframe low − (earlier higher-timeframe high − last completed higher-timeframe low) × stop-loss multiplier
Calculation: Short stop = last completed higher-timeframe high + (last completed higher-timeframe high − earlier higher-timeframe low) × stop-loss multiplier
Long: last completed higher-timeframe low < earlier higher-timeframe low AND last completed higher-timeframe close > earlier higher-timeframe low AND chart-bar high > last completed higher-timeframe high AND (volume filter disabled OR current higher-timeframe volume > its simple moving average)
Short: last completed higher-timeframe high > earlier higher-timeframe high AND last completed higher-timeframe close < earlier higher-timeframe high AND chart-bar low < last completed higher-timeframe low AND (volume filter disabled OR current higher-timeframe volume > its simple moving average)
Exit: long, chart-bar low ≤ long stop OR chart-bar high ≥ earlier higher-timeframe high
Exit: short, chart-bar high ≥ short stop OR chart-bar low ≤ earlier higher-timeframe low