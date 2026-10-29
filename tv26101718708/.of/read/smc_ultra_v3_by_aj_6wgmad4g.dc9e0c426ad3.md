Calculation: Average candle body = mean of abs(close - open) over a lookback
Calculation: Average volume = mean(volume) over a lookback
Calculation: Buy volume = volume if close > open, otherwise volume * (close - low) / max(high - low, 0.0001)
Calculation: Sell volume = volume - buy volume
Calculation: Volume delta = buy volume - sell volume
Calculation: Higher-timeframe EMA = 20-period EMA of close on a higher timeframe, using the bar still forming
Long: close > open AND abs(close - open) >= average candle body * strength multiplier
Long: close > open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta > 0
Long: close > open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta > 0 AND RSI < overbought threshold AND higher-timeframe close > higher-timeframe EMA
Long: close > open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta > 0 AND RSI < overbought threshold AND higher-timeframe close > higher-timeframe EMA AND previous bar close < previous bar open
Long: low > high two bars ago
Long: lower wick > abs(close - open) * wick-to-body threshold AND lower wick > upper wick
Short: close < open AND abs(close - open) >= average candle body * strength multiplier
Short: close < open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta < 0
Short: close < open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta < 0 AND RSI > oversold threshold AND higher-timeframe close < higher-timeframe EMA
Short: close < open AND abs(close - open) >= average candle body * strength multiplier AND volume >= average volume * volume multiplier AND volume delta < 0 AND RSI > oversold threshold AND higher-timeframe close < higher-timeframe EMA AND previous bar close > previous bar open
Short: high < low two bars ago
Short: upper wick > abs(close - open) * wick-to-body threshold AND upper wick > lower wick