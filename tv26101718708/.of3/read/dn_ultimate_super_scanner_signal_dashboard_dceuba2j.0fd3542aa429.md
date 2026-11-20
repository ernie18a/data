Calculation: Bull trend = EMA(close, shorter trend lookback) > EMA(close, intermediate trend lookback) AND EMA(close, intermediate trend lookback) > EMA(close, longer trend lookback)
Calculation: Bear trend = EMA(close, shorter trend lookback) < EMA(close, intermediate trend lookback) AND EMA(close, intermediate trend lookback) < EMA(close, longer trend lookback)
Calculation: High volume = volume > SMA(volume, volume-average lookback) * high-volume multiplier
Calculation: Panel bullish stack = EMA(close, shorter panel lookback) > EMA(close, intermediate panel lookback) AND EMA(close, intermediate panel lookback) > EMA(close, longer panel lookback) AND close > SMA(close, longest panel lookback)
Calculation: Panel bearish stack = EMA(close, shorter panel lookback) < EMA(close, intermediate panel lookback) AND EMA(close, intermediate panel lookback) < EMA(close, longer panel lookback) AND close < SMA(close, longest panel lookback)
Calculation: RVOL = volume / SMA(volume, volume-average lookback) when SMA(volume, volume-average lookback) > 0, otherwise undefined
Calculation: Long trail = highest close from entry through current bar - ATR(ATR lookback, entry bar) * trail multiplier
Calculation: Short trail = lowest close from entry through current bar + ATR(ATR lookback, entry bar) * trail multiplier
Long: Bull trend
Short: Bear trend
Long: Panel bullish stack
Short: Panel bearish stack
Long: close > VWAP(close)
Short: close < VWAP(close)
Long: RSI(close, RSI lookback) > 55
Short: RSI(close, RSI lookback) < 45
Long: chart timeframe is T1, T2, T3, or T4 AND Bull trend AND close > VWAP(close) AND High volume AND close > open AND RSI(close, RSI lookback) > 55
Short: chart timeframe is T1, T2, T3, or T4 AND Bear trend AND close < VWAP(close) AND High volume AND close < open AND RSI(close, RSI lookback) < 45
Long: chart timeframe is T1, T2, T3, or T4 AND Bull trend AND close > VWAP(close) AND low <= EMA(close, shorter trend lookback) AND close > EMA(close, shorter trend lookback) AND volume > SMA(volume, volume-average lookback) AND RSI(close, RSI lookback) > 50
Short: chart timeframe is T1, T2, T3, or T4 AND Bear trend AND close < VWAP(close) AND high >= EMA(close, shorter trend lookback) AND close < EMA(close, shorter trend lookback) AND volume > SMA(volume, volume-average lookback) AND RSI(close, RSI lookback) < 50
Long: chart timeframe is not T1, T2, T3, or T4 AND Bull trend AND close > EMA(close, shorter trend lookback) AND High volume AND close > open AND RSI(close, RSI lookback) > 50
Short: chart timeframe is not T1, T2, T3, or T4 AND Bear trend AND close < EMA(close, shorter trend lookback) AND High volume AND close < open AND RSI(close, RSI lookback) < 50
Long: chart timeframe is not T1, T2, T3, or T4 AND Bull trend AND low <= EMA(close, shorter trend lookback) AND close > EMA(close, shorter trend lookback) AND volume > SMA(volume, volume-average lookback) AND RSI(close, RSI lookback) > 50
Short: chart timeframe is not T1, T2, T3, or T4 AND Bear trend AND high >= EMA(close, shorter trend lookback) AND close < EMA(close, shorter trend lookback) AND volume > SMA(volume, volume-average lookback) AND RSI(close, RSI lookback) < 50
Long: chart timeframe is T1, T2, T3, or T4 AND close > highest(high[1], breakout lookback) AND High volume AND close > VWAP(close)
Short: chart timeframe is T1, T2, T3, or T4 AND close < lowest(low[1], breakout lookback) AND High volume AND close < VWAP(close)
Long: Panel bullish stack AND NOT Panel bullish stack on previous chart bar AND (RVOL filter disabled OR RVOL >= minimum RVOL)
Short: Panel bearish stack AND NOT Panel bearish stack on previous chart bar AND (RVOL filter disabled OR RVOL >= minimum RVOL)
Exit: long, close < Long trail
Exit: short, close > Short trail