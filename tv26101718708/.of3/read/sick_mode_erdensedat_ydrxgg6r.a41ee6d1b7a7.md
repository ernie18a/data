Long: close crosses above the latest unbroken PivotHigh(high, internal pivot lookback, internal pivot lookback)
Short: close crosses below the latest unbroken PivotLow(low, internal pivot lookback, internal pivot lookback)
Long: close crosses above the latest unbroken PivotHigh(high, external pivot lookback, external pivot lookback), where the external pivot lookback is longer than the internal pivot lookback
Short: close crosses below the latest unbroken PivotLow(low, external pivot lookback, external pivot lookback), where the external pivot lookback is longer than the internal pivot lookback
Long: the most recent internal structure break was upward
Short: the most recent internal structure break was downward
Long: EMA(close, shorter lookback, T1 bars, current still-forming bar sampled on chart bars) > EMA(close, longer lookback, T1 bars, current still-forming bar sampled on chart bars)
Short: EMA(close, shorter lookback, T1 bars, current still-forming bar sampled on chart bars) <= EMA(close, longer lookback, T1 bars, current still-forming bar sampled on chart bars)
Short: high >= an active retained internal PivotHigh(high, internal pivot lookback, internal pivot lookback) liquidity level within the per-side retained-level limit AND close < that level
Long: low <= an active retained internal PivotLow(low, internal pivot lookback, internal pivot lookback) liquidity level within the per-side retained-level limit AND close > that level
Long: low[1] > high[3] AND close[2] > low[2] + ATR(lookback)[2] * FVG threshold
Short: low[3] > high[1] AND close[2] < high[2] - ATR(lookback)[2] * FVG threshold
Long: low < top of an active bullish FVG zone AND close > top of that zone
Short: high > bottom of an active bearish FVG zone AND close < bottom of that zone
Long: low > high[2] AND close[1] > high[2] AND close[2] < open[2]
Short: high < low[2] AND close[1] < low[2] AND close[2] > open[2]
Long: PivotLow(low, internal pivot lookback, internal pivot lookback) confirms AND min(open, close) - low > wick-fraction parameter * (high - low)
Short: PivotHigh(high, internal pivot lookback, internal pivot lookback) confirms AND high - max(open, close) > wick-fraction parameter * (high - low)
Long: a retained bullish OB or RB zone was unmitigated and unretested before this bar, this bar is later than the zone's left bar, and low <= the zone top AND high >= the zone bottom
Short: a retained bearish OB or RB zone was unmitigated and unretested before this bar, this bar is later than the zone's left bar, and high >= the zone bottom AND low <= the zone top
Long: internal trend is bullish AND low <= the latest unswept minor PivotLow(low, minor pivot lookback, minor pivot lookback), where the minor pivot lookback is half the internal pivot lookback rounded down with a one-bar minimum
Short: internal trend is bearish AND high >= the latest unswept minor PivotHigh(high, minor pivot lookback, minor pivot lookback), where the minor pivot lookback is half the internal pivot lookback rounded down with a one-bar minimum