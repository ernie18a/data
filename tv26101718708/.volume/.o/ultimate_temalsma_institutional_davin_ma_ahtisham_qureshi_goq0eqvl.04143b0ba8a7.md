Calculation: TEMA = 3 × EMA(EMA(EMA(close, short lookback), short lookback), short lookback) − 3 × EMA(EMA(close, short lookback), short lookback) + EMA(EMA(EMA(close, short lookback), short lookback), short lookback)
Calculation: LSMA = least-squares linear regression of close over a lookback, evaluated at the current bar
Calculation: ATR = average true range over a lookback
Calculation: VWAP = volume-weighted average price of close
Calculation: Long-term and short-term simple moving averages = SMA(close, longer lookback) and SMA(close, shorter lookback)
Calculation: Volume average = SMA(volume, lookback)
Calculation: Institutional swing high and low = highest high and lowest low over a lookback
Long: close is between the institutional swing low and that low plus ATR × zone-width multiplier
Long: close is below the long-term simple moving average and above the short-term simple moving average while flat OR the percentage decline from the highest high over a lookback exceeds a threshold while flat
Long: low is below the last confirmed pivot low AND close is above the previous bar's high AND the distance from low to the previous bar's high exceeds ATR × minimum-sweep multiplier AND close is above EMA(close, lookback) AND volume exceeds its moving average times a multiplier
Long: close retests the last bullish EMA break level within a percentage tolerance AND close is above open AND TEMA is above LSMA AND volume exceeds its moving average times a multiplier
Long: price is in an oversold zone, close is above EMA(close, lookback), TEMA is above LSMA, and volume exceeds its moving average times a multiplier; oversold means the mean percentage distance of TEMA, LSMA, and EMA from close is below a threshold
Long: close is above EMA(close, lookback) AND its EMA over a lookback is rising AND (ADX exceeds a threshold OR positive directional movement exceeds negative directional movement) AND at least three of RSI above 50, stochastic above 50 or above its signal, stochastic RSI above 50, MACD above its signal, Williams %R above −50, and CCI above zero AND volume exceeds its moving average times a multiplier
Long: (all of TEMA, LSMA, and EMA slopes are rising OR TEMA is above LSMA and close is above EMA) AND TEMA crosses above LSMA AND volume exceeds its moving average times a multiplier
Short: close is between the institutional swing high minus ATR × zone-width multiplier and the institutional swing high
Short: close retests the last bearish EMA break level within a percentage tolerance AND close is below open AND TEMA is below LSMA AND volume exceeds its moving average times a multiplier
Short: high is below the last pivot high and above the previous bar's high AND the mean percentage distance of TEMA, LSMA, and EMA from close is in an overbought zone AND TEMA is below LSMA
Short: the EMA has been tested at least the maximum test count, close is below EMA, TEMA is below LSMA, and close crosses below EMA
Short: close is below EMA(close, lookback) AND its EMA over a lookback is falling AND (ADX exceeds a threshold OR negative directional movement exceeds positive directional movement) AND at least three of RSI below 50, stochastic below 50 or below its signal, stochastic RSI below 50, MACD below its signal, Williams %R below −50, and CCI below zero AND volume exceeds its moving average times a multiplier
Short: (all of TEMA, LSMA, and EMA slopes are falling OR TEMA is below LSMA and close is below EMA) AND TEMA crosses below LSMA AND volume exceeds its moving average times a multiplier
Exit: long, close is above the short-term simple moving average AND (lower-close exit is disabled OR close is below the previous bar's low)
Exit: long, close is at least 15% below the recorded Davin entry price
Exit: long, low reaches the stop at entry price minus ATR × stop multiplier (institutional signal: ×1.5) OR high reaches the target at entry price plus ATR × target multiplier (institutional signal: ×1.2) OR the ATR trailing stop is reached after price advances by its ATR offset OR bars since entry reach the maximum trade duration
Exit: short, high reaches the stop at entry price plus ATR × stop multiplier (institutional signal: ×1.5) OR low reaches the target at entry price minus ATR × target multiplier (institutional signal: ×1.2) OR the ATR trailing stop is reached after price declines by its ATR offset OR bars since entry reach the maximum trade duration