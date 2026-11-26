Calculation: Fast average = selected moving average(input price series, shorter lookback, selected method, phase) on T1 bars; chart bars use the value from the T1 bar still forming
Calculation: Slow average = selected moving average(Fast average, longer lookback, same method and phase) on T1 bars; chart bars use the value from the T1 bar still forming
Long: Fast average >= Slow average
Short: Fast average < Slow average