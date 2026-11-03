Calculation: Risk metric = higher-timeframe weekly EMA of the weighted sum of normalized MACD, RSI, and deviation from a long-term SMA on the asset/BTC series, plus enabled Fear & Greed, PMI, and social-risk adjustments; use the last completed weekly bar. Normalized MACD uses a longer lookback than its fast and slow EMAs. Social risk uses chart-timeframe bars.
Long: Risk metric <= buy level 1 threshold
Long: Risk metric <= buy level 2 threshold
Long: Risk metric <= buy level 3 threshold
Exit: long, Risk metric >= sell level 1 threshold AND the level 1 exit has not occurred since the most recent long entry
Exit: long, Risk metric >= sell level 2 threshold AND the level 1 exit has occurred AND the level 2 exit has not occurred since the most recent long entry
Exit: long, Risk metric >= sell level 3 threshold AND the level 2 exit has occurred AND the level 3 exit has not occurred since the most recent long entry