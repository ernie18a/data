Calculation: EMA = exponential moving average of close on the chart timeframe
Calculation: Higher-timeframe support = low of the last completed bar on a higher timeframe
Calculation: Higher-timeframe resistance = high of the last completed bar on a higher timeframe
Long: At least one bar within the recent lookback window had low <= higher-timeframe support × (1 + proximity tolerance) AND close crosses above EMA
Short: At least one bar within the recent lookback window had high >= higher-timeframe resistance × (1 − proximity tolerance) AND close crosses below EMA
Exit: Long, high >= entry price × (1 + take-profit percentage) OR low <= entry price × (1 − stop-loss percentage)
Exit: Short, low <= entry price × (1 − take-profit percentage) OR high >= entry price × (1 + stop-loss percentage)