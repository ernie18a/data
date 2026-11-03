Calculation: Short-term EMA = EMA of close with a shorter lookback than the medium-term EMA
Calculation: Medium-term EMA = EMA of close with a longer lookback than the short-term EMA and a shorter lookback than the long-term EMA
Calculation: Long-term EMA = EMA of close with a longer lookback than the medium-term EMA
Calculation: Consecutive closes above medium-term EMA = number of consecutive bars whose close is above the medium-term EMA; reset to zero otherwise
Calculation: Cloud bounces = count over a lookback of bars where low is at or below 2% above the medium-term EMA and close is above the short-term EMA
Calculation: Distance above short-term EMA (%) = (close - short-term EMA) / short-term EMA × 100
Calculation: ATR percentage = ATR / close × 100
Calculation: Percentage above long-lookback low = (close - lowest low over a long lookback) / lowest low over that lookback × 100
Long: close >= short-term EMA AND distance above short-term EMA <= dip-zone threshold AND consecutive closes above medium-term EMA >= minimum threshold AND cloud bounces >= minimum threshold AND short-term EMA > medium-term EMA AND medium-term EMA > long-term EMA AND short-term EMA > its value several bars earlier AND ATR percentage >= minimum threshold AND percentage above long-lookback low >= minimum threshold
Exit: Long, close < medium-term EMA in EMA21 Close mode OR close < short-term EMA in EMA9 Trail mode OR close < either EMA in Both mode