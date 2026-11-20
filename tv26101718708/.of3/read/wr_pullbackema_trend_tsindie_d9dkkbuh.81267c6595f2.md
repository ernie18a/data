Calculation: Risk offset = EMA(TrueRange, ATR lookback) * ATR multiplier
Calculation: Long stop = Lowest(low, 2) on the entry bar - risk offset on the entry bar
Calculation: Short stop = Highest(high, 2) on the entry bar + risk offset on the entry bar
Calculation: Long target = entry price + (entry price - Long stop) * risk/reward parameter
Calculation: Short target = entry price - (Short stop - entry price) * risk/reward parameter
Long: EMA(fast source, shorter lookback) > EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback) < oversold threshold
Long: EMA(fast source, shorter lookback) > EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback)[1] < oversold threshold AND Williams %R(high, low, close, lookback) > oversold threshold
Long: At bar close, position is flat AND long entry is enabled AND datetime is within the configured date range AND (no sessions are enabled OR datetime is within an enabled session) AND EMA(fast source, shorter lookback) > EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback)[1] < oversold threshold AND Williams %R(high, low, close, lookback) > oversold threshold AND close > EMA(fast source, shorter lookback)
Short: EMA(fast source, shorter lookback) < EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback) > overbought threshold
Short: EMA(fast source, shorter lookback) < EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback)[1] > overbought threshold AND Williams %R(high, low, close, lookback) < overbought threshold
Short: At bar close, position is flat AND short entry is enabled AND datetime is within the configured date range AND (no sessions are enabled OR datetime is within an enabled session) AND EMA(fast source, shorter lookback) < EMA(slow source, longer lookback) AND Williams %R(high, low, close, lookback)[1] > overbought threshold AND Williams %R(high, low, close, lookback) < overbought threshold AND close < EMA(fast source, shorter lookback)
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target