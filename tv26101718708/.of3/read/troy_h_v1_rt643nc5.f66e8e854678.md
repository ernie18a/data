Calculation: RelVolume = volume / SMA(volume, volume lookback)
Calculation: VolWeightedSMMA(x, n, w) = (VolWeightedSMMA(x, n, w)[1] * (n - 1) + x * w) / (n - 1 + w)
Calculation: ShortAvg = VolWeightedSMMA(source, short lookback, RelVolume)
Calculation: LongAvg = VolWeightedSMMA(source, long lookback, RelVolume), with long lookback > short lookback
Calculation: Uptrend = ShortAvg > LongAvg
Calculation: Stretch = VolWeightedSMMA((ShortAvg - LongAvg) / ATR(atr lookback), smoothing lookback, RelVolume)
Calculation: BearRun = BearRun[1] + 1 if not Uptrend, else max(0, BearRun[1] - maturity decay)
Calculation: ProfitZ = ((close - close[pnl lookback]) / ATR(atr lookback) - SMA((close - close[pnl lookback]) / ATR(atr lookback), z lookback)) / STDEV((close - close[pnl lookback]) / ATR(atr lookback), z lookback)
Calculation: LowTrigger = DonchianLow(donchian lookback)[1] - ATR(atr lookback) * multiplier, where multiplier = clamp(sensitivity * mean of the last penetration window values of (DonchianLow(donchian lookback)[1] - low) / ATR(atr lookback), recorded on bars where low < DonchianLow(donchian lookback)[1], minimum multiplier, maximum multiplier) if at least minimum penetration count values are recorded, else default multiplier
Calculation: HighTrigger = DonchianHigh(donchian lookback)[1] + ATR(atr lookback) * multiplier, where multiplier = clamp(sensitivity * mean of the last penetration window values of (high - DonchianHigh(donchian lookback)[1]) / ATR(atr lookback), recorded on bars where high > DonchianHigh(donchian lookback)[1], minimum multiplier, maximum multiplier) if at least minimum penetration count values are recorded, else default multiplier
Calculation: BuySpacingOK = no entry since the last bar with Uptrend OR abs(low - entry price) >= ATR(atr lookback) * buy separation * (1 + min(buy separation max multiplier - 1, max(0, -Stretch) * buy separation scale))
Calculation: BuyCapOK = sells in current cycle > 0 OR buys in current cycle < max buys
Calculation: SellCooldownOK = no sell in current cycle OR bars since last sell >= round(sell cooldown base * (1 + min(sell cooldown max multiplier - 1, max(0, Stretch) * sell cooldown scale)))
Long: low <= LowTrigger AND not Uptrend AND BearRun >= maturity bars AND Stretch <= buy spread threshold AND BuySpacingOK AND BuyCapOK
Long: ProfitZ <= buy Z threshold AND not Uptrend AND BearRun >= maturity bars AND BuySpacingOK AND BuyCapOK
Long: low <= LowTrigger AND not Uptrend AND BearRun >= maturity bars AND Stretch <= buy spread threshold
Long: ProfitZ <= buy Z threshold AND not Uptrend
Long: ProfitZ <= buy Z threshold
Long: PivotLow(low, pivot left, pivot right) < prior PivotLow(low, pivot left, pivot right) AND PivotLow(RSI(close, rsi lookback), pivot left, pivot right) > prior PivotLow(RSI(close, rsi lookback), pivot left, pivot right) AND bars since prior pivot pair <= divergence max lookback
Short: PivotHigh(high, pivot left, pivot right) > prior PivotHigh(high, pivot left, pivot right) AND PivotHigh(RSI(close, rsi lookback), pivot left, pivot right) < prior PivotHigh(RSI(close, rsi lookback), pivot left, pivot right) AND bars since prior pivot pair <= divergence max lookback
Exit: long, high >= HighTrigger AND Uptrend AND Stretch >= sell spread threshold AND SellCooldownOK
Exit: long, ProfitZ >= sell Z threshold AND Uptrend AND SellCooldownOK
Exit: long, high >= HighTrigger AND Uptrend AND Stretch >= sell spread threshold
Exit: long, ProfitZ >= sell Z threshold AND Uptrend
Exit: long, ProfitZ >= sell Z threshold