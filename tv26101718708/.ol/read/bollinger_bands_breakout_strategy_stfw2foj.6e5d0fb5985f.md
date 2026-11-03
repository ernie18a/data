Calculation: Bollinger Bands = a moving average of close with upper and lower bands offset by configured standard deviations
Calculation: Trend moving average = configured EMA, SMA, RMA, or WMA of close
Calculation: Volatility = rolling standard deviation of close
Calculation: Volatility average = a moving average of volatility
Calculation: Rate of change = (close − last completed higher-timeframe daily close) / last completed higher-timeframe daily close × 100
Long: close crosses above the upper Bollinger Band AND (trend filter disabled OR close > trend moving average) AND (volatility filter disabled OR volatility > volatility average) AND datetime is within the configured date range AND (rate-of-change filter disabled OR rate of change > configured threshold)
Short: close crosses below the lower Bollinger Band AND (trend filter disabled OR close < trend moving average) AND (volatility filter disabled OR volatility > volatility average) AND datetime is within the configured date range AND (rate-of-change filter disabled OR rate of change > configured threshold)
Exit: Long, close crosses below the lower Bollinger Band OR low reaches the entry-price-based stop loss OR high reaches the entry-price-based take profit OR low reaches the active trailing stop
Exit: Short, close crosses above the upper Bollinger Band OR high reaches the entry-price-based stop loss OR low reaches the entry-price-based take profit OR high reaches the active trailing stop