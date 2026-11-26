Calculation: SuperTrend line = SuperTrend(source, ATR lookback, base ATR multiplier adjusted by a separate low-regime factor in the Low volatility regime and high-regime factor in the High volatility regime, unchanged otherwise)
Calculation: Volatility regime = Low, Normal, or High from ATR(ATR lookback) and its separate lower and upper linearly interpolated percentiles over a regime lookback, with a hysteresis buffer: from Low, switch to High above the buffered upper threshold, otherwise to Normal above the buffered lower exit threshold; from High, switch to Low below the buffered lower threshold, otherwise to Normal below the buffered upper exit threshold; from Normal, switch to Low below the buffered lower threshold, High above the buffered upper threshold, otherwise remain Normal
Calculation: Participation ratio = volume / SMA(volume, participation lookback)
Calculation: Low participation = participation classification is disabled OR participation ratio < high-participation threshold
Calculation: High participation = participation classification is enabled AND participation ratio >= high-participation threshold
Calculation: Exhaustion risk = SuperTrend flip AND exhaustion tagging is enabled AND High participation AND volatility regime is High
Calculation: SuperTrend flip = SuperTrend trend changes direction, restricted to confirmed bars when close confirmation is enabled
Long: SuperTrend trend is bullish
Short: SuperTrend trend is bearish
Long: SuperTrend flip AND SuperTrend trend becomes bullish AND selected time-window filter passes AND selected participation mode passes (Low Participation Only requires Low participation; High Participation Only requires High participation; All Non-Exhaustion requires NOT Exhaustion risk; All Flips always passes) AND (exhaustion exclusion is disabled OR NOT Exhaustion risk)
Short: SuperTrend flip AND SuperTrend trend becomes bearish AND selected time-window filter passes AND selected participation mode passes (Low Participation Only requires Low participation; High Participation Only requires High participation; All Non-Exhaustion requires NOT Exhaustion risk; All Flips always passes) AND (exhaustion exclusion is disabled OR NOT Exhaustion risk)
Long: SuperTrend flip AND SuperTrend trend becomes bullish AND Low participation
Short: SuperTrend flip AND SuperTrend trend becomes bearish AND Low participation
Long: SuperTrend flip AND SuperTrend trend becomes bullish AND High participation AND NOT Exhaustion risk
Short: SuperTrend flip AND SuperTrend trend becomes bearish AND High participation AND NOT Exhaustion risk
Long: Exhaustion risk AND SuperTrend trend is bullish
Short: Exhaustion risk AND SuperTrend trend is bearish
Exit: long, confirmed close below SuperTrend line