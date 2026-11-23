Calculation: HtfBull = close(T1, last completed bar) > EMA(close, bias lookback, T1, last completed bar)
Calculation: HtfBear = close(T1, last completed bar) < EMA(close, bias lookback, T1, last completed bar)
Calculation: InstBuy = close > open AND volume > volume multiplier * SMA(volume, volume lookback) AND abs(close - open) > body multiplier * ATR(ATR lookback) AND close > EMA(close, institutional lookback)
Calculation: InstSell = close < open AND volume > volume multiplier * SMA(volume, volume lookback) AND abs(close - open) > body multiplier * ATR(ATR lookback) AND close < EMA(close, institutional lookback)
Calculation: Accumulation = Highest(high, phase lookback) - Lowest(low, phase lookback) < accumulation multiplier * SMA(ATR(ATR lookback), phase lookback)
Long: InstBuy
Short: InstSell
Long: crosses above(EMA(close, shorter lookback), EMA(close, longer lookback)) AND HtfBull AND NOT Accumulation
Short: crosses below(EMA(close, shorter lookback), EMA(close, longer lookback)) AND HtfBear AND NOT Accumulation
Long: HtfBull AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND NOT InstSell
Short: HtfBear AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND NOT InstBuy
Long: close >= VWAP(T2, last completed bar) - (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T2, last completed bar) AND close <= VWAP(T2, last completed bar) - zone gap multiplier * ATR(ATR lookback, T2, last completed bar)
Long: close >= VWAP(T3, last completed bar) - (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T3, last completed bar) AND close <= VWAP(T3, last completed bar) - zone gap multiplier * ATR(ATR lookback, T3, last completed bar)
Long: close >= VWAP(T4, last completed bar) - (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T4, last completed bar) AND close <= VWAP(T4, last completed bar) - zone gap multiplier * ATR(ATR lookback, T4, last completed bar)
Long: close >= VWAP(T5, last completed bar) - (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T5, last completed bar) AND close <= VWAP(T5, last completed bar) - zone gap multiplier * ATR(ATR lookback, T5, last completed bar)
Short: close >= VWAP(T2, last completed bar) + zone gap multiplier * ATR(ATR lookback, T2, last completed bar) AND close <= VWAP(T2, last completed bar) + (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T2, last completed bar)
Short: close >= VWAP(T3, last completed bar) + zone gap multiplier * ATR(ATR lookback, T3, last completed bar) AND close <= VWAP(T3, last completed bar) + (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T3, last completed bar)
Short: close >= VWAP(T4, last completed bar) + zone gap multiplier * ATR(ATR lookback, T4, last completed bar) AND close <= VWAP(T4, last completed bar) + (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T4, last completed bar)
Short: close >= VWAP(T5, last completed bar) + zone gap multiplier * ATR(ATR lookback, T5, last completed bar) AND close <= VWAP(T5, last completed bar) + (zone gap multiplier + 2 * zone width multiplier) * ATR(ATR lookback, T5, last completed bar)
Long: for some n from 1 to order block lookback, close[n] < open[n] AND close[n-1] > open[n-1] AND close[n-1] - open[n-1] > minimum move multiplier * ATR(ATR lookback)[n]
Short: for some n from 1 to order block lookback, close[n] > open[n] AND close[n-1] < open[n-1] AND open[n-1] - close[n-1] > minimum move multiplier * ATR(ATR lookback)[n]