Long: WaveTrend(hlc3, channel lookback, average lookback) crosses above zero
Short: WaveTrend(hlc3, channel lookback, average lookback) crosses below zero
Long: bar is confirmed AND WaveTrend(hlc3, channel lookback, average lookback) crosses above zero AND (EMA filter is disabled OR close > EMA(close, lookback))
Short: bar is confirmed AND WaveTrend(hlc3, channel lookback, average lookback) crosses below zero AND (EMA filter is disabled OR close < EMA(close, lookback))
Exit: long, low <= PSAR(start, increment, maximum) from the most recently available T1 bar, sampled on chart bars (last completed on historical bars, still forming on realtime bars)
Exit: short, high >= PSAR(start, increment, maximum) from the most recently available T1 bar, sampled on chart bars (last completed on historical bars, still forming on realtime bars)