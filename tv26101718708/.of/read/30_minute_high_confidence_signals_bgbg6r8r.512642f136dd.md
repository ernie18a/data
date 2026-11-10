Calculation: Relative volume = volume divided by the simple moving average of volume, or zero if that average is not positive.
Calculation: Bullish EMA condition = close > longer-period EMA of close AND shorter-period EMA of close > longer-period EMA of close AND shorter-period EMA of close > its previous value.
Calculation: Bearish EMA condition = close < longer-period EMA of close AND shorter-period EMA of close < longer-period EMA of close AND shorter-period EMA of close < its previous value.
Calculation: Bullish RSI condition = RSI >= bullish lower threshold AND RSI <= bullish upper threshold AND RSI > its previous value.
Calculation: Bearish RSI condition = RSI >= bearish lower threshold AND RSI <= bearish upper threshold AND RSI < its previous value.
Calculation: Bullish momentum RSI condition = RSI > bullish momentum threshold AND RSI > its previous value.
Calculation: Bearish momentum RSI condition = RSI < bearish momentum threshold AND RSI < its previous value.
Calculation: Bullish MACD condition = MACD line > signal line AND histogram > zero AND histogram >= its previous value.
Calculation: Bearish MACD condition = MACD line < signal line AND histogram < zero AND histogram <= its previous value.
Calculation: Bullish ADX condition = ADX >= minimum threshold AND positive DI > negative DI.
Calculation: Bearish ADX condition = ADX >= minimum threshold AND negative DI > positive DI.
Calculation: Bullish higher-timeframe condition = last completed higher-timeframe close > its longer-period EMA of close AND that EMA > its value on the preceding higher-timeframe bar; the EMA uses the same length as the chart-timeframe longer-period EMA.
Calculation: Bearish higher-timeframe condition = last completed higher-timeframe close < its longer-period EMA of close AND that EMA < its value on the preceding higher-timeframe bar; the EMA uses the same length as the chart-timeframe longer-period EMA.
Calculation: Candle body fraction = absolute value of close minus open divided by high minus low, or zero if high minus low is not positive.
Calculation: Bullish candle condition = close > open AND candle body fraction >= minimum threshold.
Calculation: Bearish candle condition = close < open AND candle body fraction >= minimum threshold.
Calculation: Bullish primary score = count of true conditions among bullish EMA, bullish RSI, bullish MACD, bullish ADX, relative volume >= primary volume threshold, bullish higher-timeframe and bullish candle.
Calculation: Bearish primary score = count of true conditions among bearish EMA, bearish RSI, bearish MACD, bearish ADX, relative volume >= primary volume threshold, bearish higher-timeframe and bearish candle.
Calculation: Bullish breakout score = count of true conditions among bullish EMA, bullish momentum RSI, bullish MACD, bullish ADX, bullish higher-timeframe and bullish candle.
Calculation: Bearish breakout score = count of true conditions among bearish EMA, bearish momentum RSI, bearish MACD, bearish ADX, bearish higher-timeframe and bearish candle.
Calculation: Last confirmed signal direction = direction of the most recent emitted confirmed long or short signal, initially neither; if both are emitted on the same bar, set it to short.
Long: Last confirmed signal direction != long AND ((Supertrend direction = bullish AND bars since the most recent bearish-to-bullish Supertrend flip <= confirmation window AND bullish primary score >= primary score threshold) OR (close > highest high over the preceding breakout lookback bars AND relative volume >= breakout volume threshold AND bullish breakout score >= breakout score threshold)).
Short: Last confirmed signal direction != short AND ((Supertrend direction = bearish AND bars since the most recent bullish-to-bearish Supertrend flip <= confirmation window AND bearish primary score >= primary score threshold) OR (close < lowest low over the preceding breakout lookback bars AND relative volume >= breakout volume threshold AND bearish breakout score >= breakout score threshold)).