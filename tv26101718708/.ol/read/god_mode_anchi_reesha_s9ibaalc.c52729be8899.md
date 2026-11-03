Calculation: EMA trend = fast EMA > middle EMA > slow EMA, with fast, middle, and slow lookbacks in increasing order
Calculation: Bullish RSI = RSI > 50 AND RSI < overbought threshold
Calculation: Bearish RSI = RSI < 50 AND RSI > oversold threshold
Calculation: Volume spike = volume > moving average of volume × volume multiplier
Calculation: Bullish hidden divergence = low > low two bars ago AND RSI < RSI two bars ago AND RSI < 55
Calculation: Bearish hidden divergence = high < high two bars ago AND RSI > RSI two bars ago AND RSI > 45
Calculation: Strong candle = high > low AND absolute(close − open) / (high − low) > 0.5
Calculation: Long score = count of true conditions among bullish EMA trend, bullish RSI, close > VWAP, volume spike, bullish hidden divergence, and strong candle
Calculation: Short score = count of true conditions among bearish EMA trend, bearish RSI, close < VWAP, volume spike, bearish hidden divergence, and strong candle
Long: Long score ≥ minimum score AND long score > previous bar's long score AND current bar index − bar index of last long signal > cooldown length
Short: Short score ≥ minimum score AND short score > previous bar's short score AND current bar index − bar index of last short signal > cooldown length