Calculation: Bullish EMA filter = close > long-term EMA AND short-term EMA > long-term EMA AND short-term EMA rising
Calculation: Bearish EMA filter = close < long-term EMA AND short-term EMA < long-term EMA AND short-term EMA falling
Calculation: Bullish RSI filter = RSI within configured bullish bounds AND RSI rising
Calculation: Bearish RSI filter = RSI within configured bearish bounds AND RSI falling
Calculation: Bullish momentum RSI = RSI above configured bullish momentum threshold AND RSI rising
Calculation: Bearish momentum RSI = RSI below configured bearish momentum threshold AND RSI falling
Calculation: Bullish MACD filter = MACD line > signal line AND histogram > 0 AND histogram >= prior histogram
Calculation: Bearish MACD filter = MACD line < signal line AND histogram < 0 AND histogram <= prior histogram
Calculation: Bullish ADX/DMI filter = ADX >= configured minimum AND positive DI > negative DI
Calculation: Bearish ADX/DMI filter = ADX >= configured minimum AND negative DI > positive DI
Calculation: Relative volume = current volume / moving average of volume
Calculation: Bullish higher-timeframe trend = last completed higher-timeframe close > its long-term EMA AND that EMA > its value on the preceding completed higher-timeframe bar
Calculation: Bearish higher-timeframe trend = last completed higher-timeframe close < its long-term EMA AND that EMA < its value on the preceding completed higher-timeframe bar
Calculation: Bullish candle = close > open AND absolute(close - open) / (high - low) >= configured body fraction
Calculation: Bearish candle = close < open AND absolute(close - open) / (high - low) >= configured body fraction
Calculation: Bullish primary score = count of true conditions: bullish EMA filter, bullish RSI filter, bullish MACD filter, bullish ADX/DMI filter, relative volume >= configured minimum, bullish higher-timeframe trend, bullish candle
Calculation: Bearish primary score = count of true conditions: bearish EMA filter, bearish RSI filter, bearish MACD filter, bearish ADX/DMI filter, relative volume >= configured minimum, bearish higher-timeframe trend, bearish candle
Calculation: Bullish breakout score = count of true conditions: bullish EMA filter, bullish momentum RSI, bullish MACD filter, bullish ADX/DMI filter, bullish higher-timeframe trend, bullish candle
Calculation: Bearish breakout score = count of true conditions: bearish EMA filter, bearish momentum RSI, bearish MACD filter, bearish ADX/DMI filter, bearish higher-timeframe trend, bearish candle
Calculation: Bullish flash score = count of true conditions: close > highest high of prior breakout-lookback bars, bullish momentum RSI, bullish MACD filter, positive DI > negative DI, bullish candle
Calculation: Bearish flash score = count of true conditions: close < lowest low of prior breakout-lookback bars, bearish momentum RSI, bearish MACD filter, negative DI > positive DI, bearish candle
Long: (bullish Supertrend and a bullish Supertrend flip within the configured confirmation window and bullish primary score >= configured minimum and bar is confirmed) OR (close > highest high of prior breakout-lookback bars and relative volume >= configured breakout minimum and bullish breakout score >= configured minimum and bar is confirmed) OR (bar is forming and close > open and absolute(close - open) / ATR >= configured minimum and (high - low) / ATR >= configured minimum and relative volume >= configured minimum and bullish flash score >= configured minimum)
Short: (bearish Supertrend and a bearish Supertrend flip within the configured confirmation window and bearish primary score >= configured minimum and bar is confirmed) OR (close < lowest low of prior breakout-lookback bars and relative volume >= configured breakout minimum and bearish breakout score >= configured minimum and bar is confirmed) OR (bar is forming and close < open and absolute(close - open) / ATR >= configured minimum and (high - low) / ATR >= configured minimum and relative volume >= configured minimum and bearish flash score >= configured minimum)