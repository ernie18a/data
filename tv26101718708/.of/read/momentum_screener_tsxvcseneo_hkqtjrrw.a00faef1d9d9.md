Calculation: SMA = simple moving average of close
Calculation: AvgVol = simple moving average of volume
Calculation: VolRatio = volume / AvgVol
Calculation: Spike = VolRatio >= spike multiplier
Calculation: Ignition = VolRatio >= ignition multiplier (ignition multiplier greater than spike multiplier)
Calculation: Extended = (close - SMA) / SMA > extension threshold
Calculation: SMARising = SMA > SMA from k bars earlier
Calculation: TightBase = (highest high - lowest low) / lowest low over the base lookback <= tightness threshold
Calculation: HigherLows = low > low m bars earlier AND low m bars earlier > low 2m bars earlier
Calculation: Delta = (+1 if close > (high+low)/2 else -1) * volume * |close-open| / (high-low); 0 if high = low
Calculation: DeltaPositive = SMA of Delta over a short lookback > 0
Calculation: DeltaWeak = Delta < 0 on each of the last n consecutive bars (including the current bar)
Calculation: Reclaim = close > SMA AND previous close <= previous SMA
Long: (TightBase AND Spike AND close > SMA AND DeltaPositive AND HigherLows AND NOT Extended AND close > highest high over the base lookback as of the previous bar) OR (close > SMA * f1 AND close < highest close over a recent lookback (including the current bar) * f2 AND volume < AvgVol AND DeltaPositive AND SMARising AND HigherLows AND NOT DeltaWeak, with f1 and f2 both below 1) OR (Ignition AND close > open AND close > highest close over the base lookback as of the previous bar AND AvgVol < a fixed low-liquidity volume threshold) OR (SMARising AND close > SMA AND Reclaim AND Spike AND DeltaPositive AND NOT Extended)
Exit: long, DeltaWeak