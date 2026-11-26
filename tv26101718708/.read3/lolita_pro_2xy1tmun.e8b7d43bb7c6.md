Long: EMA(close, shorter lookback) crosses above EMA(close, longer channel lookback) + RMA(true range, longer channel lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer channel lookback) - RMA(true range, longer channel lookback)
Exit: Long, take profit is enabled AND high >= entry price + take-profit tick distance
Exit: Long, stop loss is enabled AND low <= entry price - stop-loss tick distance AND (take profit is disabled OR high < entry price + take-profit tick distance)
Exit: Short, take profit is enabled AND low <= entry price - take-profit tick distance
Exit: Short, stop loss is enabled AND high >= entry price + stop-loss tick distance AND (take profit is disabled OR low > entry price - take-profit tick distance)