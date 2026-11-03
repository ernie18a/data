Calculation: Bullish trend = shorter-term EMA > medium-term EMA > longer-term EMA
Calculation: Bearish trend = shorter-term EMA < medium-term EMA < longer-term EMA
Calculation: Bullish RSI = RSI > 50 and RSI < overbought threshold
Calculation: Bearish RSI = RSI < 50 and RSI > oversold threshold
Calculation: Bullish hidden divergence = current low > low 2 chart bars ago, current RSI < RSI 2 chart bars ago, and current RSI < 55
Calculation: Bearish hidden divergence = current high < high 2 chart bars ago, current RSI > RSI 2 chart bars ago, and current RSI > 45
Calculation: Above VWAP = close > VWAP; below VWAP = close < VWAP
Calculation: Volume spike = volume > longer-lookback simple moving average of volume × a multiplier
Calculation: Strong candle = high > low and absolute(close − open) / (high − low) > 0.5
Calculation: Long score = count of true conditions: bullish trend, bullish RSI, close above VWAP, volume spike, bullish hidden divergence, strong candle
Calculation: Short score = count of true conditions: bearish trend, bearish RSI, close below VWAP, volume spike, bearish hidden divergence, strong candle
Long: Long score ≥ minimum score AND long score > prior chart bar's long score AND current chart bar is more than 3 bars after the prior long signal
Short: Short score ≥ minimum score AND short score > prior chart bar's short score AND current chart bar is more than 3 bars after the prior short signal
Exit: long, low ≤ entry price − ATR at entry × stop multiplier OR high ≥ entry price + ATR at entry × target multiplier
Exit: short, high ≥ entry price + ATR at entry × stop multiplier OR low ≤ entry price − ATR at entry × target multiplier