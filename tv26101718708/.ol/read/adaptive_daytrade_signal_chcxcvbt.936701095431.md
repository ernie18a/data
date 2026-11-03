Calculation: EMA pullback zone = fast EMA × pullback percentage
Calculation: Long stop = minimum of the lowest low over the swing lookback and entry price − ATR × stop multiplier
Calculation: Short stop = maximum of the highest high over the swing lookback and entry price + ATR × stop multiplier
Calculation: Long TP2 = entry price + (entry price − long stop) × TP2 risk multiple
Calculation: Short TP2 = entry price − (short stop − entry price) × TP2 risk multiple
Long: (ADX ≥ trend threshold AND fast EMA > slow EMA AND trend EMA > its value 3 bars ago AND close > trend EMA AND low ≥ fast EMA − EMA pullback zone AND low ≤ fast EMA + EMA pullback zone AND close > open AND close > VWAP) OR (ADX < trend threshold AND close ≤ lower Bollinger Band AND RSI ≤ oversold threshold AND close > open), AND volume ≥ its moving average × volume multiplier, AND last signal direction is not long
Short: (ADX ≥ trend threshold AND fast EMA < slow EMA AND trend EMA < its value 3 bars ago AND close < trend EMA AND high ≥ fast EMA − EMA pullback zone AND high ≤ fast EMA + EMA pullback zone AND close < open AND close < VWAP) OR (ADX < trend threshold AND close ≥ upper Bollinger Band AND RSI ≥ overbought threshold AND close < open), AND volume ≥ its moving average × volume multiplier, AND last signal direction is not short
Exit: long, low ≤ long stop OR high ≥ long TP2
Exit: short, high ≥ short stop OR low ≤ short TP2