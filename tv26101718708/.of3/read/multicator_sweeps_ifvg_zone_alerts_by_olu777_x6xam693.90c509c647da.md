Calculation: Zero-lag trend state(T) = on T bars, bullish after close crosses above EMA(close + (close - close[floor((zero-lag length - 1) / 2)]), zero-lag length) + highest(ATR(zero-lag length), volatility lookback) * band multiplier; bearish after close crosses below the corresponding lower band; otherwise retain the previous state
Long: zero-lag trend state is bullish on chart bars taking current, still-forming values from T1, T2, T3, T4, or T5
Short: zero-lag trend state is bearish on chart bars taking current, still-forming values from T1, T2, T3, T4, or T5
Calculation: Bullish liquidity sweep = an unbroken confirmed pivot low is pierced by low and reclaimed by close, when the sweep mode includes wicks, or a previously close-broken confirmed pivot high is retested by low and held by close, when the sweep mode includes breakout retests; pivot confirmation uses the sweep lookback on both sides
Calculation: Bearish liquidity sweep = an unbroken confirmed pivot high is pierced by high and rejected by close, when the sweep mode includes wicks, or a previously close-broken confirmed pivot low is retested by high and rejected by close, when the sweep mode includes breakout retests; pivot confirmation uses the sweep lookback on both sides
Long: bullish liquidity sweep
Short: bearish liquidity sweep
Long: high reaches the top of an active bullish sweep zone before its first touch
Short: high reaches the top of an active bearish sweep zone before its first touch
Calculation: Active bullish FVG = a prior zone with top = low and bottom = high[2] from a bar where low > high[2] and low - high[2] > ATR(IFVG ATR lookback) * IFVG volatility multiplier, retained until close < bottom or its age exceeds the FVG validity parameter
Calculation: Active bearish FVG = a prior zone with top = low[2] and bottom = high from a bar where high < low[2] and low[2] - high > ATR(IFVG ATR lookback) * IFVG volatility multiplier, retained until close > top or its age exceeds the FVG validity parameter
Long: an active bearish FVG has high > bottom and close <= top, or close > top
Short: an active bullish FVG has low < top and close >= bottom, or close < bottom
Long: a bullish FVG forms on chart bars taking current, still-forming values from T1, T2, T3, T4, or T5, where low > high[2] and low - high[2] >= ATR(MTF FVG ATR lookback, T) * MTF minimum-gap multiplier
Short: a bearish FVG forms on chart bars taking current, still-forming values from T1, T2, T3, T4, or T5, where high < low[2] and low[2] - high >= ATR(MTF FVG ATR lookback, T) * MTF minimum-gap multiplier
Calculation: Bullish CISD = a bullish liquidity sweep with close above its swept pivot low arms the signal at that bar's high; a later close above that high within the CISD validity parameter triggers it
Calculation: Bearish CISD = a bearish liquidity sweep with close below its swept pivot high arms the signal at that bar's low; a later close below that low within the CISD validity parameter triggers it
Long: bullish CISD triggers
Short: bearish CISD triggers
Calculation: Bullish order block = the previous bar is bearish and has low[1] < low[2], the current bar is bullish with body size >= ATR(order-block ATR lookback) * displacement multiplier, low > high[2] with low - high[2] >= ATR(order-block ATR lookback) * FVG multiplier, and close > the latest confirmed pivot high using the order-block swing lookback
Calculation: Bearish order block = the previous bar is bullish and has high[1] > high[2], the current bar is bearish with body size >= ATR(order-block ATR lookback) * displacement multiplier, high < low[2] with low[2] - high >= ATR(order-block ATR lookback) * FVG multiplier, and close < the latest confirmed pivot low using the order-block swing lookback
Long: bullish order block forms
Short: bearish order block forms
Long: price range first overlaps an active, unmitigated bullish order-block zone
Short: price range first overlaps an active, unmitigated bearish order-block zone
Calculation: Active chart S/R zones = zones centered on confirmed pivot highs or lows with half-width ATR(S/R ATR lookback) at the pivot bar * zone-width multiplier; merge active zones whose ranges overlap or whose midpoints are within current ATR(S/R ATR lookback) * merge multiplier; classify each zone as support when close >= its midpoint and resistance otherwise
Long: an active chart S/R support zone is rejected, with high >= zone bottom, low <= zone top, and close > zone top
Short: an active chart S/R resistance zone is rejected, with high >= zone bottom, low <= zone top, and close < zone bottom
Calculation: HTF S/R zones(T) = on T bars, confirmed pivot highs and lows using the S/R swing lookback, each centered at its pivot with half-width ATR(S/R ATR lookback) * its timeframe-specific zone-width parameter; on chart bars taking current, still-forming T values, classify each zone as support when close >= its midpoint and resistance otherwise
Long: close >= the midpoint of an active displayed chart S/R or HTF S/R zone
Short: close < the midpoint of an active displayed chart S/R or HTF S/R zone
Calculation: Recent sweep direction = direction of the latest bullish or bearish liquidity sweep, retained for the sweep-status validity parameter bars, then 0
Calculation: Recent IFVG direction = direction of the latest bullish or bearish IFVG completion, retained for the IFVG-status validity parameter bars, then 0
Calculation: Recent order-block direction = direction of the latest bullish or bearish order-block formation, retained for the order-block formation validity parameter bars; a strong order-block tap replaces it for the order-block tap validity parameter bars; otherwise 0
Calculation: S/R direction = latest chart S/R rejection direction retained for the S/R status validity parameter bars, or the current selected S/R direction when no rejection status is active, otherwise 0
Calculation: CISD direction = direction of the latest bullish or bearish CISD, retained for the CISD validity parameter bars, then 0
Calculation: Confluence score = CISD direction + recent IFVG direction + recent order-block direction + S/R direction + recent sweep direction
Long: confluence score >= bias threshold
Short: confluence score <= negative bias threshold