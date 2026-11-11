Calculation: Buyer flux = percentage of bars in a lookback whose close is greater than their open.
Calculation: Volume delta = sum over a lookback of volume × (2 × close − high − low) / (high − low); use 1 as the denominator when high equals low and use 1 for missing volume.
Calculation: VWAP distance = (close − session VWAP of close) / session VWAP of close.
Long: On the previous bar, close crossed above Supertrend AND close > EMA AND ADX > threshold AND (RSI filter disabled OR RSI > midpoint).
Short: On the previous bar, close crossed below Supertrend AND close < EMA AND ADX > threshold AND (RSI filter disabled OR RSI < midpoint).
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: RSI on the bar preceding the most recent long or short signal >= midpoint.
Short: RSI on the bar preceding the most recent long or short signal < midpoint.
Long: Buyer flux > upper threshold.
Short: Buyer flux < lower threshold.
Long: Highest high of the recent shorter lookback >= highest high of the preceding longer lookback AND lowest low of the recent shorter lookback >= lowest low of the preceding longer lookback.
Short: (Highest high of the recent shorter lookback < highest high of the preceding longer lookback OR lowest low of the recent shorter lookback < lowest low of the preceding longer lookback) AND highest high of the recent shorter lookback <= highest high of the preceding longer lookback AND lowest low of the recent shorter lookback <= lowest low of the preceding longer lookback.
Long: Volume delta > positive threshold.
Short: Volume delta < negative threshold.
Long: VWAP distance > positive threshold.
Short: VWAP distance < negative threshold.