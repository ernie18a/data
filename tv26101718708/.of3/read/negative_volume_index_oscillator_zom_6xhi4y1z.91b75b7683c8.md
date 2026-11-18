Calculation: Smoothed NVI = EMA(NVI(close, volume), NVI smoothing lookback)
Calculation: NVI baseline = EMA(Smoothed NVI, NVI baseline lookback)
Calculation: NVI oscillator = if NVI baseline is nonzero then (Smoothed NVI - NVI baseline) / NVI baseline else 0
Calculation: Signal line = selected MA (EMA, SMA, RMA, or WMA)(NVI oscillator, signal lookback)
Long: NVI oscillator crosses above Signal line
Long: Confirmed pivot low of NVI oscillator (left and right width = divergence pivot lookback) is higher than the previous confirmed pivot low AND low at the current pivot bar is lower than low at the previous pivot bar AND lowest(NVI oscillator, divergence range) equals the current pivot low value
Short: NVI oscillator crosses below Signal line
Short: Confirmed pivot high of NVI oscillator (left and right width = divergence pivot lookback) is lower than the previous confirmed pivot high AND high at the current pivot bar is higher than high at the previous pivot bar AND highest(NVI oscillator, divergence range) equals the current pivot high value