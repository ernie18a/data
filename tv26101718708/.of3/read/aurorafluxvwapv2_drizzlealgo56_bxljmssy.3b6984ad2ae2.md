Calculation: Center = VWMA(median price, window), window = bars since session start in session mode or last rolling length bars in rolling mode
Calculation: Spread = sqrt(max(VWMA(squared median price, window) - Center^2, 0))
Calculation: Multiplier = base multiplier * (1 + max(0, volume / SMA(volume, volume length) - 1) * volume expansion factor) * (1 + ADX(DI length, ADX smoothing length) / 100 * ADX band multiplier)
Calculation: UpperBand = EMA(Center + Multiplier * Spread, band smoothing length)
Calculation: LowerBand = EMA(Center - Multiplier * Spread, band smoothing length)
Calculation: WickShare = SMA(WickVolume / TotalVolume, wick smoothing length), where for each chart bar over its T1 bars: WickVolume = sum of T1 volume * share of the T1 bar's range outside the chart bar's real body (between open and close), TotalVolume = sum of T1 volume
Calculation: Intensity = clamp((WickShare - wick floor) / (1 - wick floor), 0, 1) * ADX gate, where ADX gate = low gate if ADX filter is enabled and ADX(DI length, ADX smoothing length) < ADX filter threshold, else 1
Calculation: UpperIntensity = Intensity if high > UpperBand + zone offset * Spread, else 0
Calculation: LowerIntensity = Intensity if low < LowerBand - zone offset * Spread, else 0
Calculation: UpperSessionMean = mean of UpperIntensity from session start through current bar
Calculation: LowerSessionMean = mean of LowerIntensity from session start through current bar
Long: LowerIntensity > alert intensity threshold AND WickShare >= wick threshold
Short: UpperIntensity > alert intensity threshold AND WickShare >= wick threshold
Long: LowerIntensity > marking intensity threshold
Short: UpperIntensity > marking intensity threshold
Long: LowerSessionMean > session mean threshold
Short: UpperSessionMean > session mean threshold
Long: +DI(DI length) > -DI(DI length)
Short: -DI(DI length) >= +DI(DI length)