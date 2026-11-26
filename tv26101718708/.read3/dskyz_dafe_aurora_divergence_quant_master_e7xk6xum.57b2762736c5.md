Calculation: CloseSlope = LinReg(close, divergence lookback, 0) - LinReg(close, divergence lookback, 1)
Calculation: OBVSlope = LinReg(OBV(close, volume), divergence lookback, 0) - LinReg(OBV(close, volume), divergence lookback, 1)
Calculation: BullDivergence = CloseSlope < 0 AND OBVSlope > 0 AND close > SMA(close, trend lookback)
Calculation: BearDivergence = CloseSlope > 0 AND OBVSlope < 0 AND close < SMA(close, trend lookback)
Calculation: CloseZScore = (close - SMA(close, z-score lookback)) / STDEV(close, z-score lookback)
Calculation: HigherTfTrend = SMA(close, T1 lookback, T1, last completed bar)
Calculation: AtrPercentile = element at zero-based index round(ATR percentile level / 100 * (ATR percentile window - 1)) of the ascending sort of ATR(high, low, close, ATR lookback) over the last ATR percentile window bars
Long: BullDivergence AND BullDivergence[1]
Long: BullDivergence AND BullDivergence[1] AND ATR(high, low, close, ATR lookback) > AtrPercentile AND InSession(datetime, session timezone, session start, session end) AND ABS(CloseZScore) < z-score threshold AND close > HigherTfTrend AND position side is not long
Short: BearDivergence AND BearDivergence[1]
Short: BearDivergence AND BearDivergence[1] AND ATR(high, low, close, ATR lookback) > AtrPercentile AND InSession(datetime, session timezone, session start, session end) AND ABS(CloseZScore) < z-score threshold AND close < HigherTfTrend AND position side is not short
Exit: long, low <= entry price - stop ATR multiplier * ATR(high, low, close, ATR lookback)
Exit: long, high >= entry price + profit ATR multiplier * ATR(high, low, close, ATR lookback)
Exit: long, ATR(high, low, close, ATR lookback) <= AtrPercentile
Exit: short, high >= entry price + stop ATR multiplier * ATR(high, low, close, ATR lookback)
Exit: short, low <= entry price - profit ATR multiplier * ATR(high, low, close, ATR lookback)
Exit: short, ATR(high, low, close, ATR lookback) <= AtrPercentile