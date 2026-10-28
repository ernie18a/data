Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows in the pivot lookback bars on both sides; becomes available after the right-side bars complete.
Calculation: Bullish pivot trend = at least two confirmed pivot lows exist and the latest pivot low > the preceding pivot low.
Calculation: Bearish pivot trend = at least two confirmed pivot highs exist and the latest pivot high < the preceding pivot high.
Calculation: Bullish EMA alignment = close > shorter-period EMA and shorter-period EMA > longer-period EMA.
Calculation: Bearish EMA alignment = close < shorter-period EMA and shorter-period EMA < longer-period EMA.
Calculation: Strong trend = ADX >= its threshold.
Calculation: Volume spike = volume >= its moving average × its multiplier.
Calculation: Bullish score = count of true conditions: bullish pivot trend; bullish EMA alignment; RSI > 50; strong trend; volume spike AND close > open.
Calculation: Bearish score = count of true conditions: bearish pivot trend; bearish EMA alignment; RSI < 50; strong trend; volume spike AND close < open.
Calculation: Bullish wave structure = at least three confirmed pivot highs and lows exist; let L3, L2, L1 be the third most recent, second most recent, and latest pivot lows, and H3, H2, H1 the corresponding pivot highs; bullish pivot trend; H2 > H3 AND L2 > L3 AND L1 > H3.
Calculation: Bearish wave structure = at least three confirmed pivot highs and lows exist; with H3, H2, H1 and L3, L2, L1 defined as above; bearish pivot trend AND NOT bullish pivot trend; L2 < L3 AND H2 < H3 AND H1 < L3.
Calculation: Hammer = high > low AND lower wick >= 2 × absolute(close − open) AND upper wick <= 0.5 × absolute(close − open), where lower wick = min(open, close) − low and upper wick = high − max(open, close).
Calculation: Shooting star = high > low AND upper wick >= 2 × absolute(close − open) AND lower wick <= 0.5 × absolute(close − open), with wicks defined above.
Calculation: Bullish divergence = a confirmed pivot low in price and RSI on the same bar, with price pivot low < preceding price pivot low AND RSI pivot low > preceding RSI pivot low.
Calculation: Bearish divergence = a confirmed pivot high in price and RSI on the same bar, with price pivot high > preceding price pivot high AND RSI pivot high < preceding RSI pivot high.
Long: bullish score >= 3 OR bullish wave structure OR Hammer OR bullish divergence
Short: bearish score >= 3 OR bearish wave structure OR Shooting star OR bearish divergence