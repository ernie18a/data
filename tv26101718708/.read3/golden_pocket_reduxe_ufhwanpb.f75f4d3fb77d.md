Calculation: Pivot pair = latest Pivot High(high, pivot lookback, pivot lookback) and latest Pivot Low(low, pivot lookback, pivot lookback). Chart profiles calculate on chart bars; overlay profiles calculate on T1 bars, using the current T1 bar, and chart bars read the current T1 values.
Calculation: Quick range = Highest(high, quick lookback) and Lowest(low, quick lookback). For overlays, calculate on T1 bars using the current T1 bar; chart bars use the returned values and update zones only on confirmed chart bars.
Calculation: Bull GP zone = [H - (H - L) * Fib1, H - (H - L) * Fib2], where H and L are the pivot pair or Quick range. Chart and overlay profiles share Fib1 and Fib2.
Calculation: Bear GP zone = [L + (H - L) * Fib1, L + (H - L) * Fib2], where H and L are the pivot pair or Quick range. Chart and overlay profiles share Fib1 and Fib2.
Calculation: Bull GP extension zone = [H + (H - L) * Fib1, H + (H - L) * Fib2]. Bear GP extension zone = [L - (H - L) * Fib2, L - (H - L) * Fib1]. Pivot and Quick profiles share Fib1 and Fib2; each persistent T1, T2, and T3 range has its own Fib1 and Fib2.
Calculation: Persistent range for T1, T2, or T3 = high[1] and low[1] of that timeframe, using its last completed bar; chart bars read these values.
Calculation: Bullish GP MA filter = true when disabled; in Trend Direction mode, the selected trend condition is met using either Fast MA > Fast MA[1] or Fast MA > Slow MA, with the selected with-trend or against-trend bias; in Price Position mode, both pivot prices are above Fast MA, or above both Fast and Slow MAs with Fast MA > Slow MA when both lines are selected. Bearish GP MA filter uses the corresponding below conditions. Fast and Slow MA types are independently SMA or EMA, with separate lookbacks and the Fast lookback shorter than the Slow lookback. Chart profiles calculate on chart bars; overlay profiles calculate on T1 bars using the current T1 bar and chart bars read the current T1 values.
Calculation: Bull FVG zone = [high[gap lag], low]. Bear FVG zone = [high, low[gap lag]]. FVGs use chart bars and are created only after the current bar closes.
Long: A new confirmed pivot high forms, the latest pivot high is above the latest pivot low, and the bullish GP MA filter passes.
Short: A new confirmed pivot low forms, the latest pivot high is above the latest pivot low, and the bearish GP MA filter passes.
Long: A new confirmed pivot high forms and the latest pivot high is above the latest pivot low, when bull GP extensions are enabled.
Short: A new confirmed pivot low forms and the latest pivot high is above the latest pivot low, when bear GP extensions are enabled.
Long: Quick range high is above Quick range low on a confirmed chart bar, when Quick profiles are enabled.
Short: Quick range high is above Quick range low on a confirmed chart bar, when Quick profiles are enabled.
Long: The last completed T1, T2, or T3 high is above its low, and its bullish GP extension is enabled.
Short: The last completed T1, T2, or T3 high is above its low, and its bearish GP extension is enabled.
Long: Absolute value of close - open > ATR(S/D ATR lookback) * impulse multiplier, close > open, a prior bearish candle exists within the order-block lookback, and either the structure filter is disabled or close > Highest(high, order-block lookback)[1]. If bar-close confirmation is enabled, the bar is confirmed.
Short: Absolute value of close - open > ATR(S/D ATR lookback) * impulse multiplier, close < open, a prior bullish candle exists within the order-block lookback, and either the structure filter is disabled or close < Lowest(low, order-block lookback)[1]. If bar-close confirmation is enabled, the bar is confirmed.
Long: low > high[gap lag] and low - high[gap lag] >= ATR(FVG ATR lookback) * minimum gap ATR, on a confirmed chart bar.
Short: high < low[gap lag] and low[gap lag] - high >= ATR(FVG ATR lookback) * minimum gap ATR, on a confirmed chart bar.
Long: For an active bullish pivot GP, Quick GP, bullish GP extension, persistent bullish GP extension, or bullish FVG zone, low <= zone top AND low[1] > zone top OR high >= zone bottom AND high[1] < zone bottom.
Short: For an active bearish pivot GP, Quick GP, bearish GP extension, persistent bearish GP extension, or bearish FVG zone, low <= zone top AND low[1] > zone top OR high >= zone bottom AND high[1] < zone bottom.
Long: For an active demand zone, low <= zone top AND low[1] > zone top.
Short: For an active supply zone, high >= zone bottom AND high[1] < zone bottom.