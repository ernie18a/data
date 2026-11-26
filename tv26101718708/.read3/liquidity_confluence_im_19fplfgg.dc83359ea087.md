Calculation: BullBOS = close crosses above the latest confirmed PivotHigh(high, pivot length, pivot length), first crossing since that PivotHigh was confirmed
Calculation: BearBOS = close crosses below the latest confirmed PivotLow(low, pivot length, pivot length), first crossing since that PivotLow was confirmed
Long: BullBOS
Short: BearBOS
Long: close crosses above POC(high, low, volume, lookback, rows)
Short: close crosses below POC(high, low, volume, lookback, rows)
Long: close > VAH(high, low, volume, lookback, rows, value area percent)
Short: close < VAL(high, low, volume, lookback, rows, value area percent)
Long: low > high[2] AND (VAL(high, low, volume, lookback, rows, value area percent) <= (low + high[2]) / 2 <= VAH(high, low, volume, lookback, rows, value area percent) OR inside-VA-only flag is off)
Short: high < low[2] AND (VAL(high, low, volume, lookback, rows, value area percent) <= (high + low[2]) / 2 <= VAH(high, low, volume, lookback, rows, value area percent) OR inside-VA-only flag is off)