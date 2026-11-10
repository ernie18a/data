Calculation: Bullish pin bar = high > low AND min(open, close) - low >= lower-wick fraction × (high - low) AND abs(close - open) <= body fraction × (high - low)
Calculation: Bearish pin bar = high > low AND high - max(open, close) >= upper-wick fraction × (high - low) AND abs(close - open) <= body fraction × (high - low)
Calculation: Long setup = high two bars ago < low OR (previous close < previous open AND close > previous high) OR previous bar is a bullish pin bar
Calculation: Short setup = low two bars ago > high OR (previous close > previous open AND close < previous low) OR previous bar is a bearish pin bar
Long: Long setup
Short: Short setup AND long setup is false
Long: Bullish pin bar
Short: Bearish pin bar
Long: Position is flat AND (UTC hour >= first session start AND UTC hour < first session end OR UTC hour >= second session start AND UTC hour < second session end) AND close > longer-period EMA of close AND shorter-period EMA of close > longer-period EMA of close AND (VWAP filter disabled OR close > daily VWAP) AND RSI of close < overbought threshold AND long setup
Short: Position is flat AND (UTC hour >= first session start AND UTC hour < first session end OR UTC hour >= second session start AND UTC hour < second session end) AND close < longer-period EMA of close AND shorter-period EMA of close < longer-period EMA of close AND (VWAP filter disabled OR close < daily VWAP) AND RSI of close > oversold threshold AND short setup
Exit: Long, low <= entry-signal bar close - stop multiplier × ATR on entry-signal bar OR high >= entry-signal bar close + target multiplier × ATR on entry-signal bar
Exit: Short, high >= entry-signal bar close + stop multiplier × ATR on entry-signal bar OR low <= entry-signal bar close - target multiplier × ATR on entry-signal bar