Calculation: RSI turning up from oversold = RSI < oversold threshold AND RSI > previous bar RSI
Calculation: MACD bullish = MACD histogram > 0 OR MACD line crosses above signal line
Calculation: Williams %R turning up from oversold = Williams %R < oversold threshold AND Williams %R > previous bar Williams %R
Calculation: Price below Bollinger Band = close < lower band OR previous bar close < previous bar lower band
Calculation: RSI turning down from overbought = RSI > overbought threshold AND RSI < previous bar RSI
Calculation: MACD bearish = MACD histogram < 0 OR MACD line crosses below signal line
Calculation: Williams %R turning down from overbought = Williams %R > overbought threshold AND Williams %R < previous bar Williams %R
Calculation: Price above Bollinger Band = close > upper band OR previous bar close > previous bar upper band
Calculation: Volume spike = volume > moving average of volume * volume multiplier
Calculation: Bullish reversal candle = close > open AND close - open > 2 * (high - close) AND open - low > 0.6 * (high - low)
Calculation: Bearish reversal candle = close < open AND open - close > 2 * (close - low) AND high - open > 0.6 * (high - low)
Long: bearish indicator count >= minimum aligned indicators AND (divergence requirement disabled OR active bearish divergence) AND (volume confirmation disabled OR volume spike) AND (reversal candle requirement disabled OR bearish reversal candle) AND (NY session filter disabled OR within NY session)
Short: bullish indicator count >= minimum aligned indicators AND (divergence requirement disabled OR active bullish divergence) AND (volume confirmation disabled OR volume spike) AND (reversal candle requirement disabled OR bullish reversal candle) AND (NY session filter disabled OR within NY session)
Exit: long, short decision OR close <= entry price * (1 - stop loss percentage) OR close >= entry price * (1 + take profit percentage)
Exit: short, long decision OR close >= entry price * (1 + stop loss percentage) OR close <= entry price * (1 - take profit percentage)