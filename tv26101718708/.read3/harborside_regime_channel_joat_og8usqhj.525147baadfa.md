Calculation: Pivot mid = average(last PivotHigh(high, pivot lookback, pivot lookback) else high, last PivotLow(low, pivot lookback, pivot lookback) else low)
Calculation: Mid = EMA(Pivot mid, center smoothing lookback)
Calculation: Upper band = EMA(Mid + ATR(atr lookback) * band multiplier, band smoothing lookback)
Calculation: Lower band = EMA(Mid - ATR(atr lookback) * band multiplier, band smoothing lookback)
Calculation: Band width = (Upper band - Lower band) / ATR(atr lookback)
Calculation: Volume impulse = volume / EMA(volume, volume lookback)
Calculation: HTF bull = bias filter on AND EMA(close, shorter lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter lookback, T1, last completed bar)
Calculation: HTF bear = bias filter on AND EMA(close, shorter lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, shorter lookback, T1, last completed bar)
Calculation: Regime = close crosses above Upper band AND (bias filter off OR HTF bull) ? 1 : close crosses below Lower band AND (bias filter off OR HTF bear) ? -1 : Regime[1] is set ? Regime[1] : close >= Mid ? 1 : -1
Long: close crosses above Upper band AND (bias filter off OR HTF bull) AND Regime[1] != 1
Long: Regime[1] is unset AND close >= Mid
Short: close crosses below Lower band AND (bias filter off OR HTF bear) AND Regime[1] != -1
Short: Regime[1] is unset AND close < Mid
Long: close crosses above Mid
Short: close crosses below Mid
Long: close crosses above Upper band AND Band width <= SMA(Band width, compression lookback) * compression threshold
Short: close crosses below Lower band AND Band width <= SMA(Band width, compression lookback) * compression threshold
Long: HTF bull
Short: HTF bear
Long: Regime == 1 AND close > Mid + ATR(atr lookback) * projection ATR multiplier
Short: Regime == -1 AND close < Mid - ATR(atr lookback) * projection ATR multiplier
Long: Regime == 1 AND Volume impulse >= volume impulse threshold
Short: Regime == -1 AND Volume impulse >= volume impulse threshold
Long: Regime == 1 AND bars since (Regime != 1) >= trend confirm bars
Short: Regime == -1 AND bars since (Regime != -1) >= trend confirm bars