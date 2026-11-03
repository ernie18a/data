Calculation: Bullish 3-candle strike = each of the previous three closes ≤ its open AND current close > previous open
Calculation: Bearish 3-candle strike = each of the previous three closes ≥ its open AND current close < previous open
Calculation: Fast, medium, and slow SMMA = smoothed moving averages of close with successively longer lookbacks
Calculation: Linear-regression trend = absolute value of the smoothed slope of the close linear-regression curve > threshold
Calculation: Daily ATR = RMA of true range on the higher-timeframe daily bars, using the current daily bar, which may still be forming
Calculation: Long stop = the lower of the lowest low over the current and previous three bars minus an ATR-based offset, and the lowest low over those bars; while in a long position, clamp to no lower than the initial stop
Calculation: Short stop = the higher of the highest high over the current and previous three bars plus an ATR-based offset, and the highest high over those bars; while in a short position, clamp to no higher than the initial stop
Calculation: Long target = entry price + reward-risk multiple × (entry price − long stop)
Calculation: Short target = entry price − reward-risk multiple × (short stop − entry price)
Long: Bullish 3-candle strike OR (bullish 3-candle strike AND fast SMMA > medium SMMA AND fast SMMA > its previous value AND linear-regression trend) OR (bullish 3-candle strike AND fast SMMA > slow SMMA AND medium SMMA > slow SMMA AND EMA > fast SMMA AND an EMA/fast-SMMA cross occurred within the shorter recent lookback)
Short: Bearish 3-candle strike OR (bearish 3-candle strike AND fast SMMA < medium SMMA AND fast SMMA < its previous value AND linear-regression trend) OR (bearish 3-candle strike AND fast SMMA < slow SMMA AND medium SMMA < slow SMMA AND EMA < fast SMMA AND an EMA/fast-SMMA cross occurred within the shorter recent lookback)
Exit: Long, bearish 3-candle strike OR low ≤ long stop OR (trailing stop disabled AND high ≥ long target)
Exit: Short, bullish 3-candle strike OR high ≥ short stop OR (trailing stop disabled AND low ≤ short target)