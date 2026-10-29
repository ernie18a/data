Calculation: Range high = highest high among completed bars in the daily range window, using bars from a timeframe lower than the chart timeframe
Calculation: Range low = lowest low among completed bars in the daily range window, using bars from a timeframe lower than the chart timeframe
Long: A valid range exists AND the range period has ended AND no trade has been taken today AND the last completed chart-timeframe bar time differs from the range end time AND the last completed chart-timeframe close > range high
Short: A valid range exists AND the range period has ended AND no trade has been taken today AND the last completed chart-timeframe bar time differs from the range end time AND the last completed chart-timeframe close < range low
Exit: long, low <= range low OR high >= range high + (range high - range low) OR time > trading end time
Exit: short, high >= range high OR low <= range low - (range high - range low) OR time > trading end time