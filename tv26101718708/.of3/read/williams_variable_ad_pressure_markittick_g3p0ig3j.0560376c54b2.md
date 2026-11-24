Calculation: WVAD = sum over WVAD lookback of volume × (close − open) / (high − low), using 0 when high = low
Calculation: Filtered WVAD = WVAD when no adaptive filter is selected; otherwise the selected SMA, EMA, RMA, double WMA, triple VWMA, HMA, LLAMA, or Kalman filter of WVAD using filter lookback
Calculation: LLAMA(x, lookback) = SMA(x, lookback) + ((x − x[lookback]) / lookback) × (lookback / 2)
Calculation: Kalman(x, lookback) = recursive estimate with q = 1 / lookback, r = 1, initial estimate x and error 1; each bar, predicted error = prior error + q, gain = predicted error / (predicted error + r), estimate = prior estimate + gain × (x − prior estimate), and error = (1 − gain) × predicted error
Calculation: Signal = SMA(Filtered WVAD, signal lookback)
Long: Filtered WVAD >= Signal
Short: Filtered WVAD < Signal
Long: Filtered WVAD[1] crosses above Signal[1] AND (ADX filter disabled OR ADX(ADX lookback)[1] >= ADX threshold) AND (HTF confirmation disabled OR the last completed T1 candle has close > open)
Short: Filtered WVAD[1] crosses below Signal[1] AND (ADX filter disabled OR ADX(ADX lookback)[1] >= ADX threshold) AND (HTF confirmation disabled OR the last completed T1 candle has close < open)
Calculation: Risk unit = ATR(ATR lookback)[1] × stop multiplier, fixed at the entry signal
Exit: Long, low <= entry price − risk unit OR high >= entry price + risk unit × TP1 multiplier OR high >= entry price + risk unit × TP2 multiplier OR high >= entry price + risk unit × TP3 multiplier
Exit: Short, high >= entry price + risk unit OR low <= entry price − risk unit × TP1 multiplier OR low <= entry price − risk unit × TP2 multiplier OR low <= entry price − risk unit × TP3 multiplier