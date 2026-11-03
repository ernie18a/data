Calculation: Minimum gap size = configurable percentage of the simple moving average of the decision candle’s high minus low over a configurable lookback of chart-timeframe bars
Calculation: Gap up = current decision candle low > previous decision candle high AND current decision candle low - previous decision candle high >= minimum gap size
Calculation: Gap down = current decision candle high < previous decision candle low AND previous decision candle low - current decision candle high >= minimum gap size
Calculation: Daily SMA = simple moving average of correlated-source closes on a higher timeframe, using its bar still forming
Calculation: Long-position target = entry-signal close + (entry-signal close - lowest decision-candle low over a configurable lookback of chart-timeframe bars)
Calculation: Short-position target = entry-signal close - (highest decision-candle high over a configurable lookback of chart-timeframe bars - entry-signal close)
Long: (inverse mode off AND Gap up AND decision candle close > Daily SMA) OR (inverse mode on AND Gap down AND decision candle close < Daily SMA)
Short: (inverse mode off AND Gap down AND decision candle close < Daily SMA) OR (inverse mode on AND Gap up AND decision candle close > Daily SMA)
Exit: long, (inverse mode off AND (Gap down AND decision candle close < Daily SMA OR decision candle high > Long-position target)) OR (inverse mode on AND (Gap up AND decision candle close > Daily SMA OR decision candle low < Short-position target))
Exit: short, (inverse mode off AND (Gap up AND decision candle close > Daily SMA OR decision candle low < Short-position target)) OR (inverse mode on AND (Gap down AND decision candle close < Daily SMA OR decision candle high > Long-position target))