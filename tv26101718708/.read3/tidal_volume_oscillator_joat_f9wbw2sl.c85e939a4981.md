Calculation: Momentum = EMA(EMA(close - close[1], smoothing lookback) * EMA(volume / max(SMA(volume, osc lookback), volume floor), smoothing lookback), smoothing lookback)
Calculation: UpMom = EMA(max(Momentum, 0), osc lookback)
Calculation: DownMom = EMA(abs(min(Momentum, 0)), osc lookback)
Calculation: MomRatio = UpMom / DownMom if DownMom > momentum floor; else ratio cap if UpMom > momentum floor; else 1
Calculation: Raw = 100 * (MomRatio - 1) / (MomRatio + 1)
Calculation: DecayAvg = (sum from i = 0 to Fourier window - 1 of Raw[i] * exp(-i / (Fourier window * Fourier decay))) / (sum from i = 0 to Fourier window - 1 of exp(-i / (Fourier window * Fourier decay)))
Calculation: Trend = 1 + max(-trend cap, min(trend cap, trend gain * (SMA(Raw, short trend window) - SMA(Raw, osc lookback)) / STDEV(Raw, osc lookback))) if STDEV(Raw, osc lookback) > 0; else 1, with short trend window shorter than osc lookback
Calculation: Osc = max(-100, min(100, (Raw * (1 - Fourier blend) + DecayAvg * Fourier blend) * Trend))
Calculation: PivotLowPrice(k) = ValueWhen(PivotLow(Osc, pivot left bars, pivot right bars) is not NA, low[pivot right bars], k)
Calculation: PivotLowOsc(k) = ValueWhen(PivotLow(Osc, pivot left bars, pivot right bars) is not NA, Osc[pivot right bars], k)
Calculation: PivotHighPrice(k) = ValueWhen(PivotHigh(Osc, pivot left bars, pivot right bars) is not NA, high[pivot right bars], k)
Calculation: PivotHighOsc(k) = ValueWhen(PivotHigh(Osc, pivot left bars, pivot right bars) is not NA, Osc[pivot right bars], k)
Long: Osc crosses above SMA(Osc, signal lookback)
Long: PivotLow(Osc, pivot left bars, pivot right bars) is not NA AND PivotLowPrice(0) < PivotLowPrice(1) AND PivotLowOsc(0) > PivotLowOsc(1)
Long: PivotLow(Osc, pivot left bars, pivot right bars) is not NA AND PivotLowPrice(0) > PivotLowPrice(1) AND PivotLowOsc(0) < PivotLowOsc(1)
Long: Osc > regime threshold
Short: Osc crosses below SMA(Osc, signal lookback)
Short: PivotHigh(Osc, pivot left bars, pivot right bars) is not NA AND PivotHighPrice(0) > PivotHighPrice(1) AND PivotHighOsc(0) < PivotHighOsc(1)
Short: PivotHigh(Osc, pivot left bars, pivot right bars) is not NA AND PivotHighPrice(0) < PivotHighPrice(1) AND PivotHighOsc(0) > PivotHighOsc(1)
Short: Osc < -regime threshold