Calculation: body = |close - open|; range = high - low; lowerWick = min(open, close) - low; upperWick = high - max(open, close)
Calculation: SwingBar = body < k1 * range AND body < k2 * ATR (k1 < 0.5, small fractions)
Calculation: HTFOpen, HTFLow = open and running low of the still-forming higher-timeframe bar that contains the current bar
Calculation: +DI, -DI, ADX = standard Wilder DMI (DI length and ADX smoothing length may be equal); strongThr and weakThr are two ADX thresholds with weakThr < strongThr
Long: ADX > weakThr AND +DI > -DI (covers both strong and weak ADX states)
Short: ADX > weakThr AND +DI <= -DI
Long: EMA(close, short) > EMA(close, medium) AND EMA(close, medium) > EMA(close, long) AND close > EMA(close, short) AND close > EMA(close, medium) (short < medium < long lookback)
Short: EMA(close, short) <= EMA(close, medium) AND EMA(close, medium) <= EMA(close, long) AND close < EMA(close, short) AND close < EMA(close, medium)
Long: close > SMA(close, shorter) AND close > SMA(close, longer) AND close > open AND body > k3 * range (k3 >= 0.5 fraction, larger than the k1 fraction in SwingBar)
Short: (close < SMA(close, shorter) AND close < SMA(close, longer) AND close < open AND body > k3 * range) OR (close < open AND lowerWick > k4 * upperWick AND NOT SwingBar) (k4 > 1; the shorter SMA is the same one used in the Long lines)
Long: close > HTFOpen AND close > SMA(close, shorter) (HTF is higher than chart timeframe; SMA is the same shorter SMA as above)
Short: close < HTFLow AND close < SMA(close, shorter)