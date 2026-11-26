Calculation: Momentum = (close - close[momentum lookback]) / ATR(atr length)
Calculation: Deviation = (close - SMA(close, base length)) / ATR(atr length)
Calculation: StretchBelow = StretchBelow[1] + (-Deviation - stretch band) if Deviation < -stretch band, otherwise StretchBelow[1] * stretch decay; StretchBelow = 0 before the first bar
Calculation: StretchAbove = StretchAbove[1] + (Deviation - stretch band) if Deviation > stretch band, otherwise StretchAbove[1] * stretch decay; StretchAbove = 0 before the first bar
Calculation: UpPressure = 1 - exp(-StretchBelow / pressure scale)
Calculation: DownPressure = 1 - exp(-StretchAbove / pressure scale)
Calculation: FearThreshold = linearly interpolated percentile at threshold percentile of WVF(fear lookback) over the last threshold window bars including the current bar, undefined while fewer than warm-up count values exist
Calculation: InverseWVF = (high - Lowest(close, fear lookback)) / Lowest(close, fear lookback) * 100
Calculation: GreedThreshold = linearly interpolated percentile at threshold percentile of InverseWVF over the last threshold window bars including the current bar, undefined while fewer than warm-up count values exist
Calculation: BarsSinceEvent = bars since the most recent earlier bar on which the Long condition or the Short condition held
Long: BarsSinceEvent >= cooldown AND (WVF(fear lookback) >= FearThreshold OR WVF(fear lookback)[1] >= FearThreshold[1] OR WVF(fear lookback)[2] >= FearThreshold[2]) AND Lowest(Momentum, arrival window) <= -minimum momentum AND Momentum > Momentum[1] AND UpPressure >= minimum pressure
Short: mirror switch on AND BarsSinceEvent >= cooldown AND InverseWVF >= GreedThreshold AND Highest(Momentum, arrival window) >= minimum momentum AND Momentum < Momentum[1] AND DownPressure >= minimum pressure