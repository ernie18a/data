Calculation: Slope = (EMA(close, shortest lookback) - EMA(close, shortest lookback)[slope lookback]) / ATR(atr lookback)
Calculation: Control = sign(DI+(adx lookback) - DI-(adx lookback)) if ADX(adx lookback) >= ADX floor, otherwise 0
Calculation: Impulse = sign(close - open) if abs(close - open) > body factor * SMA(abs(close - open), average lookback) AND RVOL(volume, average lookback) >= RVOL threshold, otherwise 0
Calculation: Opening range high = highest high over the opening window of the current session
Calculation: Opening range low = lowest low over the opening window of the current session
Calculation: Structure = 1 if close crosses above the latest confirmed PivotHigh(high, swing length, swing length) that is at most structure memory bars old; -1 if close crosses below the latest confirmed PivotLow(low, swing length, swing length) that is at most structure memory bars old; otherwise Structure[1]
Calculation: Band expansion = BBW(close, bollinger lookback, bollinger deviation) > expansion factor * SMA(BBW(close, bollinger lookback, bollinger deviation), bollinger lookback) AND BBW(close, bollinger lookback, bollinger deviation) > BBW(close, bollinger lookback, bollinger deviation)[1]
Calculation: Score = sign(EMA(close, shortest lookback) - EMA(close, middle lookback)) + sign(EMA(close, middle lookback) - EMA(close, longest lookback)) + sign(EMA(close, shortest lookback, T1, last completed bar) - EMA(close, middle lookback, T1, last completed bar)) + sign(EMA(close, middle lookback, T1, last completed bar) - EMA(close, longest lookback, T1, last completed bar)) + sign(close - VWAP(typical price, volume, reset at each new T2 bar)) + (1 if Slope > slope threshold, -1 if Slope < -slope threshold, else 0) + Structure + Control + Impulse + (1 if close > Opening range high, -1 if close < Opening range low, else 0)
Calculation: Regime = 0 if Squeeze(close, bollinger lookback, bollinger deviation, keltner lookback, keltner multiplier); else 3 if Score >= high score threshold AND Band expansion; else 2 if Score >= mid score threshold; else 1 if Score > 0; else -3 if Score <= -high score threshold AND Band expansion; else -2 if Score <= -mid score threshold; else -1 if Score < 0; else 0
Long: Regime >= 2 AND EMA(close, shortest lookback, T1, last completed bar) > EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) > EMA(close, longest lookback, T1, last completed bar) AND close > VWAP(typical price, volume, reset at each new T2 bar)
Short: Regime <= -2 AND EMA(close, shortest lookback, T1, last completed bar) < EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) < EMA(close, longest lookback, T1, last completed bar) AND close < VWAP(typical price, volume, reset at each new T2 bar)
Long: Band expansion AND Control > 0 AND Score >= release score threshold
Short: Band expansion AND Control < 0 AND Score <= -release score threshold
Long: Regime >= 1
Short: Regime <= -1
Long: Score >= mid score threshold
Short: Score <= -mid score threshold
Long: EMA(close, shortest lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longest lookback) AND EMA(close, shortest lookback, T1, last completed bar) > EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) > EMA(close, longest lookback, T1, last completed bar)
Short: EMA(close, shortest lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longest lookback) AND EMA(close, shortest lookback, T1, last completed bar) < EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) < EMA(close, longest lookback, T1, last completed bar)
Long: EMA(close, shortest lookback, T1, last completed bar) > EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) > EMA(close, longest lookback, T1, last completed bar)
Short: EMA(close, shortest lookback, T1, last completed bar) < EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) < EMA(close, longest lookback, T1, last completed bar)
Long: close > EMA(close, longest lookback)
Short: close < EMA(close, longest lookback)
Long: Structure > 0
Short: Structure < 0
Long: close > VWAP(typical price, volume, reset at each new T2 bar)
Short: close < VWAP(typical price, volume, reset at each new T2 bar)