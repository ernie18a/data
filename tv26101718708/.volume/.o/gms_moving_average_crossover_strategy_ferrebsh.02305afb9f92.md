Calculation: MA 1 = selected SMA, EMA, WMA, or volume-weighted moving average of close using the first lookback
Calculation: MA 2 = selected SMA, EMA, WMA, or volume-weighted moving average of close using the second lookback
Calculation: Trend SMA = simple moving average of close
Long: MA 1 crosses above MA 2 AND (trend filter disabled OR (filter set above and close > Trend SMA) OR (filter set below and close < Trend SMA))
Short: MA 1 crosses below MA 2 AND (trend filter disabled OR (short-only mode and filter set above and close > Trend SMA) OR (short-only mode and filter set below and close < Trend SMA))
Exit: Long, MA 1 crosses below MA 2 OR close >= entry price + close × profit-target percentage OR close <= entry price − close × absolute stop-loss percentage
Exit: Short, MA 1 crosses above MA 2 OR close <= entry price − close × profit-target percentage OR close >= entry price + close × absolute stop-loss percentage