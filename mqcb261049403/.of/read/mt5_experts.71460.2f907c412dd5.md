Calculation: Range high = highest high of completed bars on a timeframe lower than the chart timeframe during the daily range interval
Calculation: Range low = lowest low of completed bars on a timeframe lower than the chart timeframe during the daily range interval
Long: Range high > 0 AND Range low > 0 AND current datetime > range end AND last completed chart-timeframe bar's datetime != range end AND last completed chart-timeframe bar's close > Range high
Short: Range high > 0 AND Range low > 0 AND current datetime > range end AND last completed chart-timeframe bar's datetime != range end AND last completed chart-timeframe bar's close < Range low
Exit: long, low <= Range low OR high >= Range high + (Range high - Range low) OR current datetime > trading end
Exit: short, high >= Range high OR low <= Range low - (Range high - Range low) OR current datetime > trading end