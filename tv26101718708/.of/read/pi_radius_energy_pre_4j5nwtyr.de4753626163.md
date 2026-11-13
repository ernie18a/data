Calculation: OBVMom = signed square root of the percent rate of change of OBV over a lookback, i.e. sign(roc)*sqrt(|roc|)
Calculation: Energy = EMA of the rolling min-max normalization (0 to 100, 50 if max equals min, over a rolling lookback) of (pi * ATR^2 * OBVMom)
Calculation: EnergyAvg = EMA of Energy with a lookback shorter than the EMA smoothing used for Energy, plus a constant offset
Calculation: EnergyTrend = EMA of Energy with a lookback much longer than every other lookback used
Calculation: Spread = Energy - EnergyAvg
Calculation: RecentSqueeze = true if, on the current bar or any of the previous 6 bars, stdev(Energy, L) < f * SMA(stdev(Energy, L), L), where f < 1 and both L are the same lookback
Calculation: MomZ = (ROC(close, short lookback) - its SMA over a longer lookback) / its stdev over the same longer lookback (0 if stdev is 0)
Calculation: Filter = percent rank of ATR over a rolling lookback >= a minimum threshold AND percent rank of volume over the same lookback >= a minimum threshold AND MomZ >= a minimum threshold
Long: Filter AND Energy > EnergyTrend AND RecentSqueeze AND lowest Energy over the last 8 bars including the current bar < bottom threshold AND Energy > previous Energy AND previous Energy <= Energy two bars ago AND OBVMom > previous OBVMom
Long: Filter AND Energy > EnergyTrend AND Energy crosses above EnergyAvg (previous Energy <= previous EnergyAvg AND Energy > EnergyAvg) AND RecentSqueeze
Long: Filter AND Energy > EnergyTrend AND Spread >= a positive strength threshold AND Energy > previous Energy AND OBVMom > previous OBVMom
Long: Spread > 0
Long: Energy > EnergyTrend
Short: Spread < 0