Calculation: Blended = weighted mean of CCI(CCI source, CCI lookback), normalized RSI(RSI source, RSI lookback), normalized StochRSI K(close, StochRSI RSI lookback, StochRSI lookback, K smoothing), and normalized Fisher Transform(high, low, close, Fisher lookback); always include CCI and include each other component only when enabled, using separate component weights; normalized RSI = (RSI - RSI midpoint) / (RSI overbought - RSI midpoint) * upper level; normalized StochRSI K = (K - StochRSI midpoint) / StochRSI midpoint * upper level; normalized Fisher Transform = Fisher Transform * upper level / Fisher overbought
Calculation: Signal average = selected moving average method(Blended, signal lookback, method-specific parameters)
Calculation: Bullish blended divergence = a newly confirmed PivotLow(Blended, divergence lookback, divergence lookback) is above the previous confirmed pivot low by more than the blended divergence threshold, and its paired price low is below the previous paired price low; pair each oscillator pivot with PivotLow(low, divergence lookback, divergence lookback) when present, otherwise low[divergence lookback]
Calculation: Bearish blended divergence = a newly confirmed PivotHigh(Blended, divergence lookback, divergence lookback) is below the previous confirmed pivot high by more than the blended divergence threshold, and its paired price high is above the previous paired price high; pair each oscillator pivot with PivotHigh(high, divergence lookback, divergence lookback) when present, otherwise high[divergence lookback]
Calculation: Bullish RSI divergence = a newly confirmed PivotLow(RSI(RSI source, RSI lookback), divergence lookback, divergence lookback) is above the previous confirmed RSI pivot low by more than the RSI divergence threshold, and its paired price low is below the previous paired price low; pair each RSI pivot with PivotLow(low, divergence lookback, divergence lookback) when present, otherwise low[divergence lookback]
Calculation: Bearish RSI divergence = a newly confirmed PivotHigh(RSI(RSI source, RSI lookback), divergence lookback, divergence lookback) is below the previous confirmed RSI pivot high by more than the RSI divergence threshold, and its paired price high is above the previous paired price high; pair each RSI pivot with PivotHigh(high, divergence lookback, divergence lookback) when present, otherwise high[divergence lookback]
Long: Blended >= Signal average AND (zero-line option enabled AND Blended crosses above zero OR RSI enabled AND RSI crosses above RSI oversold OR StochRSI enabled AND StochRSI K crosses above StochRSI oversold OR Fisher enabled AND Fisher Transform crosses above Fisher oversold)
Short: Blended < Signal average AND (zero-line option enabled AND Blended crosses below zero OR RSI enabled AND RSI crosses below RSI overbought OR StochRSI enabled AND StochRSI K crosses below StochRSI overbought OR Fisher enabled AND Fisher Transform crosses below Fisher overbought)
Long: Blended > upper level AND Blended >= Signal average
Short: Blended < lower level AND Blended < Signal average
Long: Blended crosses above zero
Short: Blended crosses below zero
Long: Blended >= Signal average
Short: Blended < Signal average
Long: Blended > zero
Short: Blended <= zero
Long: RSI enabled AND RSI crosses above its midpoint
Short: RSI enabled AND RSI crosses below its midpoint
Long: StochRSI enabled AND StochRSI K crosses above StochRSI oversold
Short: StochRSI enabled AND StochRSI K crosses below StochRSI overbought
Long: StochRSI enabled AND StochRSI K crosses above StochRSI D
Short: StochRSI enabled AND StochRSI K crosses below StochRSI D
Long: Fisher enabled AND Fisher Transform crosses above Fisher oversold
Short: Fisher enabled AND Fisher Transform crosses below Fisher overbought
Long: Fisher enabled AND Fisher Transform crosses above zero
Short: Fisher enabled AND Fisher Transform crosses below zero
Long: Heikin Ashi close >= Heikin Ashi open
Short: Heikin Ashi close < Heikin Ashi open
Long: Heikin Ashi turns bullish
Short: Heikin Ashi turns bearish
Long: Bullish blended divergence
Short: Bearish blended divergence
Long: Bullish RSI divergence
Short: Bearish RSI divergence
Long: Bullish blended divergence AND Bullish RSI divergence
Short: Bearish blended divergence AND Bearish RSI divergence