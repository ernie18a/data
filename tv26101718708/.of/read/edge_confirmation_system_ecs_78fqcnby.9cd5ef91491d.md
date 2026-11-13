Calculation: EMA_fast, EMA_slow, EMA_base = exponential moving averages of close on the chart timeframe, with lengths fast < slow < base
Calculation: MomRaw = (EMA_short(close) - EMA_long(close)) / EMA_long(close) * 100, with a shorter and a longer EMA length
Calculation: MomNorm = 2 * (MomRaw - lowest(MomRaw, N)) / (highest(MomRaw, N) - lowest(MomRaw, N)) - 1, or 0 if highest equals lowest; N is a lookback window longer than the EMA lengths used for MomRaw
Calculation: MomSignal = EMA of MomNorm with a short smoothing length
Calculation: VolSurge = volume >= k * SMA(volume, M), with k > 1
Long: close > EMA_base AND EMA_fast > EMA_slow AND MomNorm > 0 AND MomNorm > MomSignal AND MomNorm < positive overbought level AND VolSurge AND close > open AND the most recent previous Long or Short signal was not a Long (or there was none)
Short: close < EMA_base AND EMA_fast < EMA_slow AND MomNorm < 0 AND MomNorm < MomSignal AND MomNorm > negative oversold level AND VolSurge AND close < open AND the most recent previous Long or Short signal was not a Short (or there was none)