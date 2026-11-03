Long: SMA(20) > SMA(50) AND SMA(50) > SMA(200) AND low < max(SMA(20), VWAP) AND close > max(SMA(20), VWAP) AND close > open OR close > VWAP AND previous close <= previous VWAP
Long: EMA(9) > EMA(21) AND previous EMA(9) <= previous EMA(21)
Short: SMA(20) < SMA(50) AND SMA(50) < SMA(200) AND high > min(SMA(20), VWAP) AND close < min(SMA(20), VWAP) AND close < open OR close < VWAP AND previous close >= previous VWAP
Short: EMA(9) < EMA(21) AND previous EMA(9) >= previous EMA(21)