Calculation: Fast EMA = exponential moving average of close with a shorter lookback than Slow EMA
Calculation: Bullish hammer = lower wick >= 2 x real body AND upper wick <= 0.5 x real body AND real body > 0
Calculation: Inverted hammer = upper wick >= 2 x real body AND lower wick <= 0.5 x real body AND real body > 0
Calculation: Bullish engulfing = previous close < previous open AND current close > current open AND current close >= previous open AND current open <= previous close AND current real body > previous real body
Calculation: Bearish engulfing = previous close > previous open AND current close < current open AND current open >= previous close AND current close <= previous open AND current real body > previous real body
Long: Fast EMA > Slow EMA AND previous Fast EMA <= previous Slow EMA OR bullish hammer OR bullish engulfing OR latest close on either of the two higher timeframes still forming >= open of its third-most-recent bar
Short: Fast EMA < Slow EMA AND previous Fast EMA >= previous Slow EMA OR inverted hammer OR bearish engulfing OR latest close on either of the two higher timeframes still forming < open of its third-most-recent bar