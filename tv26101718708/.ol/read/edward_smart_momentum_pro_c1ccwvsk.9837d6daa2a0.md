Calculation: Upper band = (high + low) / 2 + ATR × volatility multiplier
Calculation: Lower band = (high + low) / 2 − ATR × volatility multiplier
Calculation: Trend = bullish if close is above the previous bar’s upper band; bearish if close is below the previous bar’s lower band; otherwise retain the previous trend (initially bullish)
Long: trend is bullish AND shorter-period EMA of close > longer-period EMA of close AND close > the previous bar’s highest high over the breakout lookback AND RSI > its bullish threshold AND volume > its longer-lookback average
Short: trend is bearish AND shorter-period EMA of close < longer-period EMA of close AND close < the previous bar’s lowest low over the breakout lookback AND RSI < its bearish threshold AND volume > its longer-lookback average