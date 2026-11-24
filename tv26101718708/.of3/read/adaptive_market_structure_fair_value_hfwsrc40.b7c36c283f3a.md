Calculation: Pivot high candidate = high > highest(high[1], left lookback)
Calculation: Pivot low candidate = low < lowest(low[1], left lookback)
Calculation: Adaptive right bars = clamp(round(minimum right bars + (maximum right bars - minimum right bars) * (1 - EMA(ER(close, pivot ER lookback), pivot ER smoothing lookback))), minimum right bars, maximum right bars), using the candidate bar’s value
Calculation: Confirmed pivot high = a pivot high candidate whose high is not exceeded during its adaptive right bars, confirmed when those bars complete
Calculation: Confirmed pivot low = a pivot low candidate whose low is not undercut during its adaptive right bars, confirmed when those bars complete
Long: Pivot low candidate
Short: Pivot high candidate
Long: Confirmed pivot low
Short: Confirmed pivot high
Long: On a confirmed bar, close > an unbroken confirmed pivot high at any selected structural depth from newest through selected depth
Short: On a confirmed bar, close < an unbroken confirmed pivot low at any selected structural depth from newest through selected depth
Calculation: Smoothed KAMA efficiency = EMA(ER(close, KAMA ER lookback), KAMA ER smoothing lookback)
Calculation: KAMA raw state = range when smoothed KAMA efficiency is below the transition threshold; otherwise bullish or bearish according to whether the linear-regression progression of KAMA(close, smoothed KAMA efficiency, fast response, slow lookback) over the slope lookback is positive or negative, classified as transition, directional, or high-efficiency by the transition, directional, and high-efficiency thresholds
Calculation: KAMA state = KAMA raw state when the filter is disabled; when enabled, accept bullish states from neutral only if close exceeds the highest close since the confirmed state began, and bearish states from neutral only if close falls below the lowest close since it began; accept bullish-to-bearish changes only below that lowest close and bearish-to-bullish changes only above that highest close; accept same-direction state changes and range immediately; otherwise retain the confirmed state; reset close extrema when the state changes and extend them otherwise
Long: KAMA state is bullish
Short: KAMA state is bearish
Calculation: Session VWAP displacement lookback = long lookback when chart timeframe <= T1, medium lookback when chart timeframe > T1 and <= T2, and short lookback when chart timeframe > T2, where long > medium > short
Calculation: VWAP noise gate = max(ATR(true-range lookback) * noise multiplier, minimum tick size * tick multiplier)
Calculation: VWAP displacement strength = (session VWAP - session VWAP[displacement lookback]) / (VWAP noise gate * sqrt(displacement lookback))
Calculation: VWAP trend state = when volume is available and the selected session is active, use bullish if VWAP displacement strength > standard deviation of that strength over the strength lookback * strength multiplier and VWAP ER > its qualification threshold, or bearish if it is below the negative of that threshold and VWAP ER > its qualification threshold, once VWAP ER and strength history are ready; before both are ready, use the sign of VWAP displacement strength
Long: Selected session active AND volume available AND VWAP trend state is bullish AND close > session VWAP
Short: Selected session active AND volume available AND VWAP trend state is bearish AND close < session VWAP
Long: Selected session active AND confirmed chart bar AND KAMA crosses above session VWAP
Short: Selected session active AND confirmed chart bar AND KAMA crosses below session VWAP