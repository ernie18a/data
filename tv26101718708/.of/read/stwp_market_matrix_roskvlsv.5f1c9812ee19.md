Calculation: Close position = (close - low) / (high - low), or 0 when high equals low
Long: Shorter-period EMA of close > longer-period EMA of close
Short: Shorter-period EMA of close <= longer-period EMA of close
Long: Close > session VWAP of typical price
Short: Close <= session VWAP of typical price
Long: SMA of (close - low) > SMA of (high - close), using the same lookback
Short: SMA of (high - close) > SMA of (close - low), using the same lookback
Long: Close > highest high over the lookback ending at the previous bar
Short: Close < lowest low over the lookback ending at the previous bar
Long: High > previous high AND low > previous low
Short: High < previous high AND low < previous low
Long: Shorter-period EMA of close > longer-period EMA of close on the last completed higher-timeframe bar
Short: Shorter-period EMA of close < longer-period EMA of close on the last completed higher-timeframe bar
Long: Close > EMA of close on the last completed bar of a shorter higher timeframe AND close > EMA of close on the last completed bar of a longer higher timeframe, using the same EMA period
Long: Volume > SMA of volume multiplied by a threshold AND close position > an upper threshold
Short: Volume > SMA of volume multiplied by the same threshold AND close position < a lower threshold