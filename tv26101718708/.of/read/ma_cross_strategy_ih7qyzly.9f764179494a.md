Calculation: Risk distance = 2 × ATR from the last completed bar of a higher timeframe, captured when close crosses the moving average in either direction
Calculation: Reference price = close of the most recent bar where close crosses the moving average in either direction
Long: close > moving average AND previous close <= previous moving average AND bar datetime is within the configured backtest window
Short: close < moving average AND previous close >= previous moving average AND bar datetime is within the configured backtest window
Exit: Long, high >= reference price + risk distance OR low <= reference price - risk distance OR (position has been reduced by 1% after the profit limit was reached AND low <= previous bar's reference price)
Exit: Short, low <= reference price - risk distance OR high >= reference price + risk distance OR (position has been reduced by 1% after the profit limit was reached AND high >= previous bar's reference price)