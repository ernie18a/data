Calculation: Prior swing high/low = highest high / lowest low over the configured lookback, excluding the current bar
Calculation: Long trigger = (close > fast EMA AND previous close <= previous fast EMA) OR (close > prior swing high AND close > open)
Calculation: Short trigger = (close < fast EMA AND previous close >= previous fast EMA) OR (close < prior swing low AND close < open)
Calculation: Long/short quality = weighted sum of, respectively: bullish/bearish trend, bullish/bearish RSI momentum, close above/below VWMA, ATR-to-close volatility above its floor, volume above its moving average, and the corresponding trigger; compare with a configurable minimum quality
Calculation: Long stop = min(prior swing low, entry price - ATR × stop multiplier); short stop = max(prior swing high, entry price + ATR × stop multiplier)
Calculation: Long TP2 = entry price + (entry price - long stop) × target-2 R multiple; short TP2 = entry price - (short stop - entry price) × target-2 R multiple
Long: bar closes AND fast EMA > slow EMA AND close > slow EMA AND RSI is in the configured bullish momentum range AND long trigger AND ATR / close >= configured volatility floor AND long quality >= configured minimum AND (short setup conditions are false OR long quality >= short quality)
Short: bar closes AND fast EMA < slow EMA AND close < slow EMA AND RSI is in the configured bearish momentum range AND short trigger AND ATR / close >= configured volatility floor AND short quality >= configured minimum AND long setup conditions are false
Exit: long, low <= long stop OR high >= long TP2 OR bars since entry > configured plan duration
Exit: short, high >= short stop OR low <= short TP2 OR bars since entry > configured plan duration