Calculation: DI Delta = DI+(DMI length) - DI-(DMI length)
Long: close(T1, current forming bar) > EMA(close, lookback, T1, current forming bar)
Short: close(T1, current forming bar) <= EMA(close, lookback, T1, current forming bar)
Long: close(T2, current forming bar) > EMA(close, lookback, T2, current forming bar)
Short: close(T2, current forming bar) <= EMA(close, lookback, T2, current forming bar)
Long: close(T3, current forming bar) > EMA(close, lookback, T3, current forming bar)
Short: close(T3, current forming bar) <= EMA(close, lookback, T3, current forming bar)
Long: DI Delta(T1, current forming bar) > 0; comparison on chart bars sampling T1 values
Short: DI Delta(T1, current forming bar) < 0; comparison on chart bars sampling T1 values
Long: DI Delta(T2, current forming bar) > 0; comparison on chart bars sampling T2 values
Short: DI Delta(T2, current forming bar) < 0; comparison on chart bars sampling T2 values
Long: DI Delta(T3, current forming bar) > 0; comparison on chart bars sampling T3 values
Short: DI Delta(T3, current forming bar) < 0; comparison on chart bars sampling T3 values
Long: ADX(DMI length, ADX smoothing lookback, T1, current forming bar) > ADX(DMI length, ADX smoothing lookback, T1, slope lookback bars ago); comparison on chart bars sampling T1 values
Short: ADX(DMI length, ADX smoothing lookback, T1, current forming bar) < ADX(DMI length, ADX smoothing lookback, T1, slope lookback bars ago); comparison on chart bars sampling T1 values
Long: ADX(DMI length, ADX smoothing lookback, T2, current forming bar) > ADX(DMI length, ADX smoothing lookback, T2, slope lookback bars ago); comparison on chart bars sampling T2 values
Short: ADX(DMI length, ADX smoothing lookback, T2, current forming bar) < ADX(DMI length, ADX smoothing lookback, T2, slope lookback bars ago); comparison on chart bars sampling T2 values
Long: ADX(DMI length, ADX smoothing lookback, T3, current forming bar) > ADX(DMI length, ADX smoothing lookback, T3, slope lookback bars ago); comparison on chart bars sampling T3 values
Short: ADX(DMI length, ADX smoothing lookback, T3, current forming bar) < ADX(DMI length, ADX smoothing lookback, T3, slope lookback bars ago); comparison on chart bars sampling T3 values
Long: WaveTrend(HLC3, channel lookback, average lookback, T1, current forming bar).WT1 > SMA(WT1, smoothing lookback, T1, current forming bar); comparison on chart bars sampling T1 values
Short: WaveTrend(HLC3, channel lookback, average lookback, T1, current forming bar).WT1 <= SMA(WT1, smoothing lookback, T1, current forming bar); comparison on chart bars sampling T1 values
Long: WaveTrend(HLC3, channel lookback, average lookback, T2, current forming bar).WT1 > SMA(WT1, smoothing lookback, T2, current forming bar); comparison on chart bars sampling T2 values
Short: WaveTrend(HLC3, channel lookback, average lookback, T2, current forming bar).WT1 <= SMA(WT1, smoothing lookback, T2, current forming bar); comparison on chart bars sampling T2 values
Long: WaveTrend(HLC3, channel lookback, average lookback, T3, current forming bar).WT1 > SMA(WT1, smoothing lookback, T3, current forming bar); comparison on chart bars sampling T3 values
Short: WaveTrend(HLC3, channel lookback, average lookback, T3, current forming bar).WT1 <= SMA(WT1, smoothing lookback, T3, current forming bar); comparison on chart bars sampling T3 values
Long: RSI(close, lookback, chart bars) <= T1 oversold threshold OR (RSI(close, lookback, chart bars) > midline threshold AND RSI(close, lookback, chart bars) < T1 overbought threshold)
Short: RSI(close, lookback, chart bars) >= T1 overbought threshold OR (RSI(close, lookback, chart bars) > T1 oversold threshold AND RSI(close, lookback, chart bars) <= midline threshold)
Long: RSI(close, lookback, chart bars) <= T2 oversold threshold OR (RSI(close, lookback, chart bars) > midline threshold AND RSI(close, lookback, chart bars) < T2 overbought threshold)
Short: RSI(close, lookback, chart bars) >= T2 overbought threshold OR (RSI(close, lookback, chart bars) > T2 oversold threshold AND RSI(close, lookback, chart bars) <= midline threshold)
Long: RSI(close, lookback, chart bars) <= T3 oversold threshold OR (RSI(close, lookback, chart bars) > midline threshold AND RSI(close, lookback, chart bars) < T3 overbought threshold)
Short: RSI(close, lookback, chart bars) >= T3 overbought threshold OR (RSI(close, lookback, chart bars) > T3 oversold threshold AND RSI(close, lookback, chart bars) <= midline threshold)
Long: close(T1, current forming bar) > EMA(close, lookback, T1, current forming bar) AND DI Delta(T1, current forming bar) > 0 AND ADX(DMI length, ADX smoothing lookback, T1, current forming bar) > ADX(DMI length, ADX smoothing lookback, T1, slope lookback bars ago) AND at least two of WaveTrend(HLC3, channel lookback, average lookback, T1/T2/T3, current forming bar).WT1 > SMA(WT1, smoothing lookback, T1/T2/T3, current forming bar), with WaveTrend comparisons on chart bars sampling current forming timeframe values, AND close - lowest(low, low lookback) <= ATR(ATR lookback) * ATR multiplier on chart bars
Short: close(T1, current forming bar) < EMA(close, lookback, T1, current forming bar) AND DI Delta(T1, current forming bar) < 0 AND ADX(DMI length, ADX smoothing lookback, T1, current forming bar) < ADX(DMI length, ADX smoothing lookback, T1, slope lookback bars ago) AND at least two of WaveTrend(HLC3, channel lookback, average lookback, T1/T2/T3, current forming bar).WT1 < SMA(WT1, smoothing lookback, T1/T2/T3, current forming bar), with WaveTrend comparisons on chart bars sampling current forming timeframe values, AND close - lowest(low, low lookback) <= ATR(ATR lookback) * ATR multiplier on chart bars