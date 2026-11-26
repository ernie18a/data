Long: crossover(selected moving average(source 1, lookback 1, type 1), selected moving average(source 2, lookback 2, type 2))
Short: crossunder(selected moving average(source 1, lookback 1, type 1), selected moving average(source 2, lookback 2, type 2))
Long: crossover(close, selected moving average(high, lookback 3, type 3))
Exit: long, crossunder(close, selected moving average(low, lookback 3, type 3))
Exit: long, datetime < start time OR datetime >= end time