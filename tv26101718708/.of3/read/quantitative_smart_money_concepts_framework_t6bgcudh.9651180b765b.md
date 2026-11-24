Calculation: Major pivots = confirmed PivotHigh(high, major pivot lookback, major pivot lookback) and PivotLow(low, major pivot lookback, major pivot lookback) in fixed-window mode; in adaptive mode, ZigZag pivots confirmed after a reversal of ATR(ATR lookback) * pivot reversal multiplier
Calculation: Minor pivots = PivotHigh(high, minor pivot lookback, minor pivot lookback) and PivotLow(low, minor pivot lookback, minor pivot lookback)
Long: close crosses above the latest unbroken major pivot high
Short: close crosses below the latest unbroken major pivot low
Long: close crosses above the latest unbroken minor pivot high
Short: close crosses below the latest unbroken minor pivot low
Long: low < the most recent eligible minor pivot low within the pivot reference scan depth AND close > that pivot low AND lower wick >= ATR(ATR lookback) * minimum wick ATR multiple AND lower wick / (high - low) >= minimum wick share AND bars since the previous bullish sweep > same-direction cooldown
Short: high > the most recent eligible minor pivot high within the pivot reference scan depth AND close < that pivot high AND upper wick >= ATR(ATR lookback) * minimum wick ATR multiple AND upper wick / (high - low) >= minimum wick share AND bars since the previous bearish sweep > same-direction cooldown
Long: low > high[gap lookback] AND the intervening bar's close > high[gap lookback] AND low - high[gap lookback] >= ATR(ATR lookback) * minimum gap-size multiplier
Short: high < low[gap lookback] AND the intervening bar's close < low[gap lookback] AND low[gap lookback] - high >= ATR(ATR lookback) * minimum gap-size multiplier
Calculation: Bullish order block origin = the bearish candle with the lowest low in the prior structural scan window whose body / range >= minimum body ratio, whose range < ATR(current bar) * maximum candle-range multiple, and whose volume >= SMA(volume, volume-average lookback) * volume multiplier when the volume filter is enabled
Calculation: Bearish order block origin = the bullish candle with the highest high in the prior structural scan window whose body / range >= minimum body ratio, whose range < ATR(current bar) * maximum candle-range multiple, and whose volume >= SMA(volume, volume-average lookback) * volume multiplier when the volume filter is enabled
Calculation: Order block score = min((zone height / max(ATR(ATR lookback), denominator floor)) / size-score normalization, score cap) * size-score weight + min(abs(close - open) / max(ATR(ATR lookback) * displacement normalization, denominator floor), score cap) * displacement-score weight + above-average-volume contribution when volume > SMA(volume, volume-average lookback), otherwise regular-volume contribution + FVG-overlap contribution when an existing same-direction FVG overlaps the zone
Long: close crosses above the latest unbroken major pivot high AND a bullish order block origin exists AND its order block score >= minimum score
Short: close crosses below the latest unbroken major pivot low AND a bearish order block origin exists AND its order block score >= minimum score
Calculation: Minor structure bias = bullish after close crosses above the latest confirmed minor pivot high, bearish after close crosses below the latest confirmed minor pivot low, and unchanged otherwise
Long: minor structure bias is bullish
Short: minor structure bias is bearish