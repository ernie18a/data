Calculation: ATR = average true range
Calculation: Trend line = selected moving average of close
Calculation: Trend channel = trend line ± EMA of true range × channel multiplier
Calculation: Trend buffer = ATR × buffer multiplier
Calculation: Bullish locked trend = close is above the upper trend channel plus buffer for the configured number of consecutive bars, with bullish momentum support if required; it remains locked until bearish locked trend is confirmed. Bearish locked trend is the inverse and remains locked until bullish locked trend is confirmed.
Calculation: Bullish momentum support = RSI > 50 OR MACD line > MACD signal line OR bullish volume pressure. Bearish momentum support is the inverse.
Calculation: Bullish volume pressure = volume > its moving average × volume multiplier AND close > open. Bearish volume pressure uses close < open.
Long: bullish locked trend AND close > trend line AND absolute(close − trend line) / ATR ≤ maximum entry distance in ATRs AND bar is confirmed if close confirmation is enabled AND (warning filter is disabled OR bullish warning is true) AND last confirmed signal direction is not long OR RSI > bullish strength threshold AND RSI > prior RSI OR MACD line crosses above MACD signal line OR bullish volume pressure
Short: bearish locked trend AND close < trend line AND absolute(close − trend line) / ATR ≤ maximum entry distance in ATRs AND bar is confirmed if close confirmation is enabled AND (warning filter is disabled OR bearish warning is true) AND last confirmed signal direction is not short OR RSI < bearish weakness threshold AND RSI < prior RSI OR MACD line crosses below MACD signal line OR bearish volume pressure
Exit: long, close < trend line OR bearish warning OR (close − entry price) / ATR ≥ take-profit distance in ATRs
Exit: short, close > trend line OR bullish warning OR (entry price − close) / ATR ≥ take-profit distance in ATRs