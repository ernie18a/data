Calculation: Regular MACD divergence = a confirmed price lower low with a MACD higher low, or a price higher high with a MACD lower high, comparing consecutive price and MACD pivots of the same type
Calculation: Hidden MACD divergence = a confirmed price higher low with a MACD lower low, or a price lower high with a MACD higher high, comparing consecutive pivots of the same type
Calculation: MACD distance from zero in standard deviations = MACD divided by its rolling standard deviation
Long: MACD crosses above its signal line
Short: MACD crosses below its signal line
Long: MACD crosses above its signal line AND higher-timeframe fast EMA > higher-timeframe slow EMA on the last completed higher-timeframe bar AND ADX >= trend threshold AND +DI > -DI AND cooldown has elapsed AND (zero-line filter disabled OR MACD < 0)
Short: MACD crosses below its signal line AND higher-timeframe fast EMA < higher-timeframe slow EMA on the last completed higher-timeframe bar AND ADX >= trend threshold AND -DI > +DI AND cooldown has elapsed AND (zero-line filter disabled OR MACD > 0)
Long: MACD crosses above its signal line AND at least the required number of the five timeframe trends agree bullishly; use the selected trend method (price vs EMA, shorter EMA vs longer EMA, or MACD vs signal) on each timeframe's last completed bar
Short: MACD crosses below its signal line AND at least the required number of the five timeframe trends agree bearishly; use the selected trend method (price vs EMA, shorter EMA vs longer EMA, or MACD vs signal) on each timeframe's last completed bar
Long: MACD crosses above its signal line AND MACD distance from zero in standard deviations <= negative extreme threshold
Short: MACD crosses below its signal line AND MACD distance from zero in standard deviations >= extreme threshold
Long: Regular MACD divergence is confirmed
Short: Regular MACD divergence is confirmed
Long: Hidden MACD divergence is confirmed
Short: Hidden MACD divergence is confirmed
Long: MACD crosses above its signal line AND MACD distance from zero in standard deviations <= negative extreme threshold AND regular bullish MACD divergence occurred within its validity window
Short: MACD crosses below its signal line AND MACD distance from zero in standard deviations >= extreme threshold AND regular bearish MACD divergence occurred within its validity window
Exit: Long, low <= entry price - stop multiple * ATR captured at entry OR high >= entry price + target multiple * ATR captured at entry OR histogram momentum has weakened against the position for the required consecutive bars OR a filtered signal appears
Exit: Short, high >= entry price + stop multiple * ATR captured at entry OR low <= entry price - target multiple * ATR captured at entry OR histogram momentum has weakened against the position for the required consecutive bars OR a filtered signal appears