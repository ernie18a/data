Calculation: VWAP component = clamp(VWAP-location coefficient × sign(close − daily-anchored VWAP) + VWAP-slope coefficient × sign(VWAP − VWAP[one chart bar ago]), component-score range); calculate on chart bars and reset the VWAP anchor at each day boundary.
Calculation: TICK component = clamp(EMA(configured TICK-series close at chart timeframe, TICK smoothing lookback) / TICK scale, component-score range); include only when its enable toggle is on and the value is available.
Calculation: VOLD component = clamp(z-score(configured up-volume-series close − configured down-volume-series close, shared z-score lookback) / shared z-score scale, component-score range); include only when its enable toggle is on and both values are available.
Calculation: ADD component = clamp(configured advance-decline-series close at chart timeframe / ADD scale, component-score range); include only when its enable toggle is on and the value is available.
Calculation: CVD = cumulative sum on chart bars of volume when close > open, negative volume when close < open, or zero when equal or volume is unavailable; reset at each day boundary.
Calculation: CVD component = clamp(z-score(CVD − CVD[CVD-change lookback], shared z-score lookback) / shared z-score scale, component-score range); include when volume is available and positive.
Calculation: MACD component = clamp(MACD histogram(close, fast lookback, slow lookback, signal lookback) / (ATR(ATR lookback) × MACD-to-ATR scale), component-score range); include when the histogram is available.
Calculation: MFI component = clamp((MFI(hlc3, MFI lookback) − MFI midpoint) / MFI scale, component-score range); include when volume is available and positive and MFI is available.
Calculation: low-VIX regime = configured volatility-index series close at chart timeframe < VIX threshold when its enable toggle is on and its value is available; otherwise true.
Calculation: RSI component = positive extreme score when RSI(close, RSI lookback) < extreme-oversold threshold; negative extreme score when it > extreme-overbought threshold; positive moderate score when it < oversold threshold; negative moderate score when it > overbought threshold; otherwise zero. Include only in the low-VIX regime.
Calculation: master score = weighted mean of the VWAP, TICK, VOLD, ADD, CVD, MACD, MFI, and RSI components, using a separate weight parameter for each; include only components meeting their stated availability, enable, and regime conditions, and return zero when the total included weight is zero.
Calculation: buffer = ATR-buffer multiple × ATR(ATR lookback) in ATR mode, otherwise point buffer.
Calculation: put short strike = floor-to-strike-increment(close − buffer); call short strike = ceil-to-strike-increment(close + buffer).
Calculation: sigma = max(expected-move input when positive, otherwise ATR(ATR lookback) × sqrt(max(one chart bar, POP horizon in chart bars)), positive sigma floor).
Calculation: drift = master score × directional-drift factor × sigma.
Calculation: put POP percent = 100 × standard-normal-CDF((close + drift − put short strike) / sigma).
Calculation: call POP percent = 100 × standard-normal-CDF((call short strike − close − drift) / sigma).
Long: VWAP component > component-arrow threshold
Short: VWAP component < negative component-arrow threshold
Long: TICK component > component-arrow threshold
Short: TICK component < negative component-arrow threshold
Long: VOLD component > component-arrow threshold
Short: VOLD component < negative component-arrow threshold
Long: ADD component > component-arrow threshold
Short: ADD component < negative component-arrow threshold
Long: CVD component > component-arrow threshold
Short: CVD component < negative component-arrow threshold
Long: MACD component > component-arrow threshold
Short: MACD component < negative component-arrow threshold
Long: MFI component > component-arrow threshold
Short: MFI component < negative component-arrow threshold
Long: RSI component > component-arrow threshold
Short: RSI component < negative component-arrow threshold
Long: master score > score threshold
Short: master score < negative score threshold
Long: master score crosses above score threshold AND put POP percent >= minimum POP
Short: master score crosses below negative score threshold AND call POP percent >= minimum POP
Long: master score > negative score threshold AND put POP percent >= minimum POP
Short: master score < score threshold AND call POP percent >= minimum POP