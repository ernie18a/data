Calculation: EMA trend = fast EMA (shorter lookback) > mid EMA > slow EMA (longer lookback) for bullish trend; reverse all inequalities for bearish trend
Calculation: RSI momentum = RSI > 50 and RSI < overbought threshold for bullish momentum; RSI < 50 and RSI > oversold threshold for bearish momentum
Calculation: Bullish hidden divergence = low > low two bars ago AND RSI < RSI two bars ago AND RSI < 55
Calculation: Bearish hidden divergence = high < high two bars ago AND RSI > RSI two bars ago AND RSI > 45
Calculation: VWAP position = close > VWAP for above VWAP; close < VWAP for below VWAP
Calculation: Volume spike = volume > volume moving average × volume multiplier
Calculation: Strong candle = high > low AND abs(close − open) / (high − low) > 0.5
Calculation: Long score = count of bullish EMA trend, bullish RSI momentum, above VWAP, volume spike, bullish hidden divergence, and strong candle conditions that are true
Calculation: Short score = count of bearish EMA trend, bearish RSI momentum, below VWAP, volume spike, bearish hidden divergence, and strong candle conditions that are true
Long: Long score ≥ minimum score AND long score > prior bar's long score AND more than 3 bars since the most recent prior long signal
Short: Short score ≥ minimum score AND short score > prior bar's short score AND more than 3 bars since the most recent prior short signal