Calculation: Chart-timeframe moving average = selected moving-average type of the selected source over a lookback; the long lookback is used for the monthly-source average and the shorter lookback for the chart-source average
Calculation: Monthly source = selected source from the last completed bar of the higher monthly timeframe
Long: Chart-source average crosses above monthly-source average AND current year is on or after the configured start year AND datetime is within the configured strategy date range
Short: Monthly-source average crosses above chart-source average AND current year is on or after the configured start year AND datetime is within the configured strategy date range
Exit: Long, monthly-source average crosses above chart-source average
Exit: Short, chart-source average crosses above monthly-source average