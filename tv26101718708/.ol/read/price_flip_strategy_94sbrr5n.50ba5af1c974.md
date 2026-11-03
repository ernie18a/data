Calculation: Inverted price = rolling highest high + rolling lowest low − close, using separately configured lookbacks
Long: Previous bar close > current inverted price AND fast moving average of close crosses above the slow moving average of close (fast uses a shorter lookback than slow) AND close > slow moving average AND datetime is within the configured date range
Short: Previous bar close < current inverted price AND fast moving average of close crosses below the slow moving average of close (fast uses a shorter lookback than slow) AND close < slow moving average AND datetime is within the configured date range
Exit: Long, short condition
Exit: Short, long condition