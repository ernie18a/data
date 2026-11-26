Calculation: Trend = JJMA(EMA(sum of current high minus prior highest high over each of three separately parameterized lookbacks, EMA lookback) - EMA(sum of prior lowest low minus current low over each of three separately parameterized lookbacks, EMA lookback), smoothing lookback, phase)
Long: Trend on chart bars > 0
Short: Trend on chart bars < 0
Long: On chart bars carrying Trend values from the still-forming T1 bar, at the selected signal bar, Trend < 0 AND Trend < Trend[1] AND Trend[1] < 0 AND Trend[1] > Trend[2]
Short: On chart bars carrying Trend values from the still-forming T1 bar, at the selected signal bar, Trend < 0 AND Trend > Trend[1] AND Trend[1] < 0 AND Trend[1] < Trend[2]