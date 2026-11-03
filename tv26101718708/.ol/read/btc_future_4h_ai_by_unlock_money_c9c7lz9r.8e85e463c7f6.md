Calculation: Bullish Supertrend = Supertrend direction < 0
Calculation: Long stop = min(entry price − ATR × ATR stop multiplier, lowest low over the swing lookback × (1 − wick buffer / 100))
Calculation: Short stop = max(entry price + ATR × ATR stop multiplier, highest high over the swing lookback × (1 + wick buffer / 100))
Calculation: Long risk = entry price − long stop
Calculation: Short risk = short stop − entry price
Calculation: Long TP1 = entry price + long risk × TP1 reward/risk ratio
Calculation: Long TP2 = entry price + long risk × TP2 reward/risk ratio
Calculation: Short TP1 = entry price − short risk × TP1 reward/risk ratio
Calculation: Short TP2 = entry price − short risk × TP2 reward/risk ratio
Long: EMA(short-term) > EMA(mid-term) AND EMA(mid-term) > EMA(long-term) AND RSI >= lower long threshold AND RSI <= upper long threshold AND bullish Supertrend now AND bullish Supertrend was false on the previous bar AND volume > moving average of volume
Short: EMA(short-term) < EMA(mid-term) AND EMA(mid-term) < EMA(long-term) AND RSI >= lower short threshold AND RSI <= upper short threshold AND bullish Supertrend now is false AND bullish Supertrend was true on the previous bar AND volume > moving average of volume
Exit: Long, low <= long stop OR high >= long TP1 OR high >= long TP2
Exit: Short, high >= short stop OR low <= short TP1 OR low <= short TP2