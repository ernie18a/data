Calculation: RSI trend MA = selected EMA, SMA, WMA, or VWMA of RSI over a longer lookback
Calculation: RSI short MA = selected EMA, SMA, WMA, or VWMA of RSI over a shorter lookback than the RSI trend MA
Calculation: Close MA = selected EMA, SMA, WMA, or VWMA of close
Long: RSI crosses above RSI trend MA AND datetime is within the configured start-inclusive, end-exclusive range
Exit: long, RSI crosses below RSI trend MA AND datetime is within the configured range
Long: RSI short MA crosses above RSI trend MA AND datetime is within the configured range
Exit: long, RSI short MA crosses below RSI trend MA AND datetime is within the configured range
Long: RSI crosses above RSI trend MA AND RSI short MA crosses above RSI trend MA on the same bar AND datetime is within the configured range
Exit: long, RSI crosses below RSI trend MA AND RSI short MA crosses below RSI trend MA on the same bar AND datetime is within the configured range
Long: RSI trend MA crosses above 50 AND datetime is within the configured range
Exit: long, RSI trend MA crosses below 50 AND datetime is within the configured range
Long: RSI crosses above 50 AND datetime is within the configured range
Exit: long, RSI crosses below 50 AND datetime is within the configured range
Long: RSI was below the oversold threshold on the current bar or one of the prior five bars AND RSI crosses above RSI trend MA AND datetime is within the configured range
Exit: long, RSI was above the overbought threshold on the current bar or one of the prior five bars AND RSI short MA crosses below RSI trend MA AND datetime is within the configured range
Long: RSI crosses above the oversold threshold AND datetime is within the configured range
Exit: long, RSI crosses below the overbought threshold OR RSI crosses below the oversold threshold, AND datetime is within the configured range
Long: close crosses above Close MA AND RSI crosses above RSI trend MA AND datetime is within the configured range
Exit: long, close crosses below Close MA AND RSI crosses below RSI trend MA AND datetime is within the configured range
Exit: long, low <= entry price × (1 − stop-loss percentage) OR high >= entry price × (1 + take-profit percentage)
Exit: long, datetime is before the configured start time OR datetime is at or after the configured end time