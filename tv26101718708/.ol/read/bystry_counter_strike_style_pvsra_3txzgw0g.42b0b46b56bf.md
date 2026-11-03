Calculation: Upper breakout level = highest high over the lookback, excluding the current bar, plus the entry buffer multiplied by ATR
Calculation: Lower breakout level = lowest low over the lookback, excluding the current bar, minus the entry buffer multiplied by ATR
Calculation: Channel width = upper breakout level − lower breakout level
Calculation: Volatility score = ATR divided by its longer-lookback average
Calculation: Target distance = maximum of the configured ATR-based target distance, configured fraction of channel width, and minimum price increment
Calculation: Stop distance = maximum of the configured ATR-based stop distance, configured fraction of channel width, and minimum price increment
Long: flat AND channel width > minimum price increment AND (EMA filter disabled OR close > EMA) AND (volatility filter disabled OR volatility score meets its selected threshold) AND ((confirmed-close mode AND current close >= upper breakout level AND previous close < previous upper breakout level) OR (wick-touch mode AND current high >= upper breakout level AND previous high < previous upper breakout level))
Short: flat AND channel width > minimum price increment AND (EMA filter disabled OR close < EMA) AND (volatility filter disabled OR volatility score meets its selected threshold) AND ((confirmed-close mode AND current close <= lower breakout level AND previous close > previous lower breakout level) OR (wick-touch mode AND current low <= lower breakout level AND previous low > previous lower breakout level))
Exit: Long, high >= entry price + target distance OR low <= current stop level
Exit: Short, low <= entry price − target distance OR high >= current stop level