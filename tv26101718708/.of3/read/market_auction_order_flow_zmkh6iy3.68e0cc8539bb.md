Calculation: Bar delta = on chart bars, sum volume from current T1 bars within each chart bar, positive when close >= open and negative otherwise; include a forming T1 bar and use signed chart-bar volume if T1 data is unavailable
Calculation: VWAP band 1 = VWAP(source, anchor period) ± band 1 multiplier × (anchored VWAP standard-deviation distance in standard-deviation mode, otherwise 1% of VWAP)
Calculation: PVSRA spread-volume = selected-source volume × (selected-source high - selected-source low)
Long: crosses above zero(EMA(bar delta, delta smoothing lookback))
Short: crosses below zero(EMA(bar delta, delta smoothing lookback))
Long: close > VWAP upper band 1
Short: close < VWAP lower band 1
Long: low < VWAP lower band 1 AND VWAP lower band 1 - low >= VWAP lower band 1 × minimum penetration percentage / 100 AND bars since prior same-side failed-breakout marker >= failed-breakout cooldown
Short: high > VWAP upper band 1 AND high - VWAP upper band 1 >= VWAP upper band 1 × minimum penetration percentage / 100 AND bars since prior same-side failed-breakout marker >= failed-breakout cooldown
Long: close crosses above VWAP(source, anchor period)
Short: close crosses below VWAP(source, anchor period)
Long: selected-source close > selected-source open AND (selected-source volume >= SMA(selected-source volume, average volume lookback) × level-1 multiple OR selected-source volume >= SMA(selected-source volume, average volume lookback) × level-2 multiple OR spread-volume override enabled AND PVSRA spread-volume >= Highest(PVSRA spread-volume, average volume lookback))
Short: selected-source close <= selected-source open AND (selected-source volume >= SMA(selected-source volume, average volume lookback) × level-1 multiple OR selected-source volume >= SMA(selected-source volume, average volume lookback) × level-2 multiple OR spread-volume override enabled AND PVSRA spread-volume >= Highest(PVSRA spread-volume, average volume lookback))
Long: no pending signal AND SSL Channel bullish crossover AND bars since last confirmed long signal >= signal cooldown AND (alternating mode disabled OR last confirmed signal was not long)
Short: no pending signal AND SSL Channel bearish crossover AND bars since last confirmed short signal >= signal cooldown AND (alternating mode disabled OR last confirmed signal was not short)
Long: pending SSL long AND pending age <= signal expiry AND (delta confirmation disabled OR delta module disabled OR (exhaustion mode disabled AND EMA(bar delta, delta smoothing lookback) > 0) OR (exhaustion mode enabled AND EMA(bar delta, delta smoothing lookback) crosses above zero AND Lowest(EMA(bar delta, delta smoothing lookback), exhaustion lookback)[1] <= -exhaustion threshold))
Short: pending SSL short AND pending age <= signal expiry AND (delta confirmation disabled OR delta module disabled OR (exhaustion mode disabled AND EMA(bar delta, delta smoothing lookback) < 0) OR (exhaustion mode enabled AND EMA(bar delta, delta smoothing lookback) crosses below zero AND Highest(EMA(bar delta, delta smoothing lookback), exhaustion lookback)[1] >= exhaustion threshold))