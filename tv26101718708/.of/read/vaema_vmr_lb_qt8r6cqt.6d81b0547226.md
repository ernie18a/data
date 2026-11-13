Calculation: HybridLine = EMA(close) * w + (EMA(close) + Drift) * (1 - w), where 0<w<1, Drift = ZScore * ATR * k, ZScore = (close - EMA(close)) / StdDev(close) (0 if StdDev is 0). StdDev lookback is shorter than EMA lookback.
Calculation: VolRatio = volume / SMA(volume) (1 if SMA is 0), clamped between a fixed lower floor below 1 and a fixed upper cap above 1
Calculation: BaseWidth = a * StdDev(close) + (1 - a) * ATR, with 0<a<1
Calculation: UpperWidth = BaseWidth * (upBase + (VolRatio - 1) * upVolImpact); LowerWidth = BaseWidth * (dnBase + (VolRatio - 1) * dnVolImpact)
Calculation: UpperBand1 = HybridLine + UpperWidth; LowerBand1 = HybridLine - LowerWidth; UpperBand2 = HybridLine + UpperWidth * mU; LowerBand2 = HybridLine - LowerWidth * mL, with mU>1 and mL>1 (Band2 is farther from HybridLine than Band1)
Long: close crosses above UpperBand1 (close > UpperBand1 AND previous close <= previous UpperBand1) AND HybridLine > previous HybridLine
Short: close crosses below LowerBand1 (close < LowerBand1 AND previous close >= previous LowerBand1) AND HybridLine < previous HybridLine
Exit: long, (close > UpperBand2 AND low > UpperBand1) is true on this bar AND was not true on the previous bar (take-profit event)
Exit: short, (close < LowerBand2 AND high < LowerBand1) is true on this bar AND was not true on the previous bar (take-profit event)