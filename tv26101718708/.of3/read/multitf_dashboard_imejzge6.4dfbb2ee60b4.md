Calculation: RSI(T) = RSI(close, RSI lookback) on T bars; map to chart bars without lookahead, using the forming T bar in realtime and the last completed T bar historically
Calculation: MACD(T) = MACD(close, fast lookback, slow lookback, signal lookback), with the fast lookback shorter than the slow lookback, on T bars; map to chart bars without lookahead, using the forming T bar in realtime and the last completed T bar historically
Calculation: EMA(T) = EMA(close, EMA lookback) on T bars; compare with close on the same T bar and map to chart bars without lookahead, using the forming T bar in realtime and the last completed T bar historically
Calculation: MACD divergence state(T) = on each newly confirmed T-bar pivot, compare its price and MACD line at the pivot bar (right confirmation bars ago) with the preceding confirmed pivot of the same type; a pivot high of high with a higher price and lower MACD line is regular bearish, while a lower price and higher MACD line is hidden bearish; a pivot low of low with a lower price and higher MACD line is regular bullish, while a higher price and lower MACD line is hidden bullish; apply each only when its respective detection is enabled, and let a qualifying pivot-low classification override a qualifying pivot-high classification on the same bar; map to chart bars without lookahead, using the forming T bar in realtime and the last completed T bar historically
Long: For any T in {T1, T2, T3, T4}, RSI(T) <= lower RSI threshold
Short: For any T in {T1, T2, T3, T4}, RSI(T) >= upper RSI threshold
Long: For any T in {T1, T2, T3, T4}, MACD(T).line > MACD(T).signal
Short: For any T in {T1, T2, T3, T4}, MACD(T).line <= MACD(T).signal
Long: For any T in {T1, T2, T3, T4}, close(T) > EMA(T)
Short: For any T in {T1, T2, T3, T4}, close(T) <= EMA(T)
Long: For any T in {T1, T2, T3, T4}, MACD divergence state(T) is bullish
Short: For any T in {T1, T2, T3, T4}, MACD divergence state(T) is bearish