Calculation: Prior swing high = highest high over the lookback completed bars, excluding the current bar
Calculation: Prior swing low = lowest low over the lookback completed bars, excluding the current bar
Calculation: Long setup quality = weighted score for bullish trend, bullish RSI momentum, close at or above VWMA, ATR/close at or above a volatility floor, volume at or above its moving average, and a long trigger
Calculation: Short setup quality = weighted score for bearish trend, bearish RSI momentum, close at or below VWMA, ATR/close at or above a volatility floor, volume at or above its moving average, and a short trigger
Calculation: Long trigger = (close > short-term EMA AND previous close <= previous short-term EMA) OR (close > prior swing high AND close > open)
Calculation: Short trigger = (close < short-term EMA AND previous close >= previous short-term EMA) OR (close < prior swing low AND close < open)
Calculation: Long stop = lower of prior swing low and entry price minus ATR times a stop multiplier
Calculation: Short stop = higher of prior swing high and entry price plus ATR times a stop multiplier
Calculation: Second long target = entry price plus (entry price minus long stop) times a second-target R multiple
Calculation: Second short target = entry price minus (short stop minus entry price) times a second-target R multiple
Long: short-term EMA > long-term EMA AND close > long-term EMA AND RSI > bullish lower threshold AND RSI < bullish upper threshold AND long trigger AND ATR/close >= volatility floor AND long setup quality >= minimum quality
Short: short-term EMA < long-term EMA AND close < long-term EMA AND RSI < bearish upper threshold AND RSI > bearish lower threshold AND short trigger AND ATR/close >= volatility floor AND short setup quality >= minimum quality
Exit: Long, low <= long stop OR high >= second long target OR bars since entry > plan duration OR a new valid long or short setup
Exit: Short, high >= short stop OR low <= second short target OR bars since entry > plan duration OR a new valid long or short setup