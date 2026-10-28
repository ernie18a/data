Calculation: Buyer pressure = 10-bar SMA of (close − low)
Calculation: Seller pressure = 10-bar SMA of (high − close)
Calculation: Close position = (close − low) / (high − low), or 0 when high = low
Calculation: Daily EMA(n) = n-period EMA of close on the last completed daily bar
Calculation: Higher-timeframe EMA = 50-period EMA of close on the last completed bar of each of the two higher timeframes
Long: Fast EMA > Slow EMA OR close > VWAP OR Buyer pressure > Seller pressure OR close > highest high of the preceding 40 bars OR (high > previous high AND low > previous low) OR (Daily EMA(9) > Daily EMA(21) AND Daily EMA(21) > Daily EMA(50) AND Daily EMA(50) > Daily EMA(100) AND Daily EMA(100) > Daily EMA(200)) OR Daily EMA(50) > Daily EMA(200) OR (close > Higher-timeframe EMA 1 AND close > Higher-timeframe EMA 2) OR (volume > 1.5 × 20-bar average volume AND Close position > 0.7)
Short: Fast EMA < Slow EMA OR close < VWAP OR Seller pressure > Buyer pressure OR close < lowest low of the preceding 40 bars OR (high < previous high AND low < previous low) OR (Daily EMA(9) < Daily EMA(21) AND Daily EMA(21) < Daily EMA(50) AND Daily EMA(50) < Daily EMA(100) AND Daily EMA(100) < Daily EMA(200)) OR Daily EMA(50) < Daily EMA(200) OR (volume > 1.5 × 20-bar average volume AND Close position < 0.3)
