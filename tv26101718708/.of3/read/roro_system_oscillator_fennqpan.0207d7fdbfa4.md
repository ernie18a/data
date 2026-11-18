Calculation: bounded normalization(x) = x / (1 + abs(x))
Calculation: smoothed oscillator = ALMA(clamp((trend weight * bounded normalization(trend scale * ((ALMA(close, short ALMA lookback, ALMA offset, ALMA sigma) - VWMA(close, long VWMA lookback)) / VWMA(close, long VWMA lookback))) + momentum weight * bounded normalization(ROC(close, short momentum lookback) / STDEV(ROC(close, short momentum lookback), longer volatility lookback))) * oscillator scale, -oscillator scale, oscillator scale), short ALMA lookback, ALMA offset, ALMA sigma)
Long: smoothed oscillator > long-entry threshold AND smoothed oscillator[1] <= long-entry threshold
Exit: long, smoothed oscillator < long-exit threshold OR datetime > end-date parameter
Exit: short, datetime > end-date parameter