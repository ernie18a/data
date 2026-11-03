Calculation: EMA50 retest zone = the bar’s low is at or below the upper band around the long-term EMA and its high is at or above the lower band; the band width is a configurable percentage of the EMA
Calculation: Strong bullish candle = close > open AND close - open > (high - low) / 2
Calculation: Strong bearish candle = open > close AND open - close > (high - low) / 2
Calculation: Long counter-score = sum of configured weights for each failed condition among close > long-term EMA, RSI > 50, volume > 1.2 × its lookback SMA, ADX > minimum, EMA50 retest zone, and close > prior high
Calculation: Short counter-score = sum of configured weights for each failed condition among close < long-term EMA, RSI < 50, volume > 1.2 × its lookback SMA, ADX > minimum, EMA50 retest zone, and close < prior low
Calculation: Long swing break = close < the prior bar’s 5-bar lowest low
Calculation: Short swing break = close > the prior bar’s 5-bar highest high
Calculation: Strong long market = close > long-term EMA AND ADX > 25
Calculation: Strong short market = close < long-term EMA AND ADX > 25
Calculation: Long filter count = count of true conditions among close > long-term EMA, RSI > 50, volume > 1.2 × its lookback SMA, ADX > minimum, EMA50 retest zone, and (close > prior high OR breakout filter disabled)
Calculation: Short filter count = count of true conditions among close < long-term EMA, RSI < 50, volume > 1.2 × its lookback SMA, ADX > minimum, EMA50 retest zone, and (close < prior low OR breakout filter disabled)
Long: fast EMA crosses above signal EMA AND EMA50 retest zone AND close > long-term EMA AND RSI > 50 AND volume > 1.2 × its lookback SMA AND (strong bullish candle OR close > fast EMA) AND (close > prior high OR breakout filter disabled) AND ADX > minimum AND position side is not long OR long filter count >= 4 OR (ADX > 30 AND +DI > -DI) OR (ADX > 20 AND ADX <= 30 AND +DI > -DI)
Short: fast EMA crosses below signal EMA AND EMA50 retest zone AND close < long-term EMA AND RSI < 50 AND volume > 1.2 × its lookback SMA AND (strong bearish candle OR close < fast EMA) AND (close < prior low OR breakout filter disabled) AND ADX > minimum AND position side is not short OR short filter count >= 4 OR (ADX > 30 AND -DI > +DI) OR (ADX > 20 AND ADX <= 30 AND -DI > +DI)
Exit: long, long swing break OR (long counter-score >= cancellation threshold AND NOT strong long market)
Exit: short, short swing break OR (short counter-score >= cancellation threshold AND NOT strong short market)