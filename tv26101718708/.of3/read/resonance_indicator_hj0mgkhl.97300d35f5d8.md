Calculation: Oscillator = (HMA(RSI(close, RSI lookback), RSI smoothing lookback) + EMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing lookback)) / 2
Calculation: Bias(T) = 1 if Slope > 0 and Slope >= Slope[1]; 0.5 if Slope > 0 and Slope < Slope[1]; -1 if Slope < 0 and Slope <= Slope[1]; -0.5 if Slope < 0 and Slope > Slope[1]; otherwise 0, where Slope = HMA(close, trend lookback) - HMA(close, trend lookback)[1], computed on T bars and taken on chart bars from the last completed T bar
Calculation: TrendSum = sum over k from 2 to 7 of Bias(Tk) * duration(T2) / duration(Tk)
Calculation: PivotHighT1 = true if a completed T1 bar since the previous chart bar has PivotHigh(Oscillator on T1 bars, left bars, right bars) > upper level
Calculation: PivotLowT1 = true if a completed T1 bar since the previous chart bar has PivotLow(Oscillator on T1 bars, left bars, right bars) < lower level
Calculation: T1Mark = 1 if PivotHighT1 and TrendSum <= trend threshold; -1 if PivotLowT1 and TrendSum >= -trend threshold; otherwise T1Mark[1]
Calculation: ArmedShort = (PivotHigh(Oscillator, left bars, right bars) > upper level or (ArmedShort[1] and TrendSum[1] > trend threshold)) and not (PivotLow(Oscillator, left bars, right bars) < lower level)
Calculation: ArmedLong = (PivotLow(Oscillator, left bars, right bars) < lower level or (ArmedLong[1] and TrendSum[1] < -trend threshold)) and not (PivotHigh(Oscillator, left bars, right bars) > upper level)
Short: chart timeframe < T2 and PivotHighT1 and TrendSum <= trend threshold and T1Mark[1] != 1
Long: chart timeframe < T2 and PivotLowT1 and TrendSum >= -trend threshold and T1Mark[1] != -1
Short: ArmedShort and TrendSum <= trend threshold
Long: ArmedLong and TrendSum >= -trend threshold