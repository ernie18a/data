Calculation: Yield spread = (instrument A close(T1, still-forming bar) - instrument B close(T1, still-forming bar)) * conversion parameter, using T1 values on chart bars
Long: abs(close - EMA(close, lookback)) <= close * tolerance parameter AND Yield spread >= spread threshold
Calculation: Yield spread = (US 10-year bond yield at T1 - German 10-year bond yield at T1) * 100
Long: Selected comparison timeframe = T1 AND Yield spread >= previous chart-bar yield spread
Short: Selected comparison timeframe = T1 AND Yield spread < previous chart-bar yield spread
Long: Selected comparison timeframe = T2 AND Yield spread >= previous weekly closing yield spread
Short: Selected comparison timeframe = T2 AND Yield spread < previous weekly closing yield spread
Long: ABS(Euro future close - EMA(Euro future close, P1)) <= Euro future close * P2 AND Yield spread >= P3