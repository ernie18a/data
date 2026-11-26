Long: close > EMA(source, fast lookback)
Short: close <= EMA(source, fast lookback)
Long: close > EMA(source, medium lookback)
Short: close <= EMA(source, medium lookback)
Long: close > EMA(source, trend lookback)
Short: close <= EMA(source, trend lookback)
Long: close > EMA(source, fast lookback) AND close > EMA(source, medium lookback) AND close > EMA(source, trend lookback)
Short: close < EMA(source, fast lookback) AND close < EMA(source, medium lookback) AND close < EMA(source, trend lookback)
Long: EMA(source, fast lookback) > EMA(source, medium lookback) AND EMA(source, medium lookback) > EMA(source, trend lookback)
Short: EMA(source, fast lookback) < EMA(source, medium lookback) AND EMA(source, medium lookback) < EMA(source, trend lookback)
Long: (close > EMA(source, fast lookback) AND close > EMA(source, medium lookback) AND close > EMA(source, trend lookback)) OR (EMA(source, fast lookback) > EMA(source, medium lookback) AND EMA(source, medium lookback) > EMA(source, trend lookback))
Short: (close < EMA(source, fast lookback) AND close < EMA(source, medium lookback) AND close < EMA(source, trend lookback)) OR (EMA(source, fast lookback) < EMA(source, medium lookback) AND EMA(source, medium lookback) < EMA(source, trend lookback))
Long: EMA(source, fast lookback) > EMA(source, medium lookback) AND EMA(source, medium lookback) > EMA(source, trend lookback) AND close > EMA(source, fast lookback) AND close > EMA(source, medium lookback) AND close > EMA(source, trend lookback) AND close > EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values) AND volume > SMA(volume, volume lookback) * volume multiplier AND close > open
Short: EMA(source, fast lookback) < EMA(source, medium lookback) AND EMA(source, medium lookback) < EMA(source, trend lookback) AND close < EMA(source, fast lookback) AND close < EMA(source, medium lookback) AND close < EMA(source, trend lookback) AND close < EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values) AND volume > SMA(volume, volume lookback) * volume multiplier AND close < open
Long: volume > SMA(volume, volume lookback) * volume multiplier AND close > open
Short: volume > SMA(volume, volume lookback) * volume multiplier AND close <= open
Long: close > EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values)
Short: close <= EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values)
Long: crosses above(close, EMA(source, trend lookback))
Short: crosses below(close, EMA(source, trend lookback))
Long: EMA(source, fast lookback) > EMA(source, medium lookback) AND EMA(source, medium lookback) > EMA(source, trend lookback) AND close > EMA(source, fast lookback) AND close > EMA(source, medium lookback) AND close > EMA(source, trend lookback) AND close > EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values) AND volume > SMA(volume, volume lookback) * volume multiplier AND close > open AND crosses above(EMA(source, fast lookback), EMA(source, medium lookback))
Short: EMA(source, fast lookback) < EMA(source, medium lookback) AND EMA(source, medium lookback) < EMA(source, trend lookback) AND close < EMA(source, fast lookback) AND close < EMA(source, medium lookback) AND close < EMA(source, trend lookback) AND close < EMA(close, higher-timeframe lookback, T1, bar still forming; on chart bars using T1 values) AND volume > SMA(volume, volume lookback) * volume multiplier AND close < open AND crosses below(EMA(source, fast lookback), EMA(source, medium lookback))
Long: volume > SMA(volume, volume lookback) * volume multiplier AND close > open AND ((close > EMA(source, fast lookback) AND close > EMA(source, medium lookback) AND close > EMA(source, trend lookback)) OR (EMA(source, fast lookback) > EMA(source, medium lookback) AND EMA(source, medium lookback) > EMA(source, trend lookback)))
Short: volume > SMA(volume, volume lookback) * volume multiplier AND close < open AND ((close < EMA(source, fast lookback) AND close < EMA(source, medium lookback) AND close < EMA(source, trend lookback)) OR (EMA(source, fast lookback) < EMA(source, medium lookback) AND EMA(source, medium lookback) < EMA(source, trend lookback)))