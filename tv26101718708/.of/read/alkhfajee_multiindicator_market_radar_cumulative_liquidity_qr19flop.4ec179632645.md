Calculation: Daily net liquidity = cumulative sum since the start of the day of volume × close × ((close − low) − (high − close)) / (high − low + a small positive constant).
Calculation: Decision score = sum of the following components, evaluated in the stated order within each component: RSI and MFI each contribute +2 above an upper threshold, +1 above a midpoint, −2 below a lower threshold, −1 below the midpoint, and 0 otherwise; CCI contributes +2 above a positive threshold, +1 above zero, −2 below a negative threshold, −1 below zero, and 0 otherwise; MACD histogram contributes +2 above zero and −2 otherwise; stochastic %K contributes +1 above an upper threshold, +2 above a midpoint, −1 below a lower threshold, −2 below the midpoint, and 0 otherwise; OBV contributes +2 if it increased from the previous bar and −2 otherwise; directional movement contributes +2 if +DI > −DI and ADX exceeds its threshold, +1 if +DI > −DI, −2 if −DI > +DI and ADX exceeds its threshold, and −1 otherwise; relative volume contributes +2 if it reaches its threshold and +DI > −DI, −2 if it reaches its threshold and −DI > +DI, and 0 otherwise; daily net liquidity contributes +2 above zero and −2 otherwise. Relative volume is volume divided by its simple moving average. The upper threshold in each oscillator component exceeds its midpoint, which exceeds its lower threshold.
Long: Daily net liquidity >= 0
Short: Daily net liquidity < 0
Long: RSI > upper RSI display threshold
Short: RSI < lower RSI display threshold
Long: MFI > upper MFI display threshold
Short: MFI < lower MFI display threshold
Long: CCI > positive CCI display threshold
Short: CCI < negative CCI display threshold
Long: MACD histogram > 0
Short: MACD histogram <= 0
Long: stochastic %K > bullish display threshold
Short: stochastic %K <= bullish display threshold
Long: OBV > previous bar's OBV
Short: OBV <= previous bar's OBV
Long: +DI > −DI
Short: −DI > +DI
Long: decision score >= positive decision threshold
Short: decision score < negative decision threshold
Long: shorter-period EMA of close crosses above longer-period EMA of close AND RSI > long-entry RSI threshold
Short: shorter-period EMA of close crosses below longer-period EMA of close AND RSI < short-entry RSI threshold