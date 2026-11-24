Calculation: ALMA-SD regime(price source, ALMA length, offset, sigma, SD length, factor, T) = on T bars, A=ALMA(price source, ALMA length, offset, sigma), D=StDev(price source, SD length), raw upper=A+factor*D, raw lower=A-factor*D; upper=raw upper if raw upper<upper[1] or price source[1]>upper[1], else upper[1] (initial upper[1]=0); lower=raw lower if raw lower>lower[1] or price source[1]<lower[1], else lower[1] (initial lower[1]=0); direction=+1 if D[1] is unavailable, else -1 if prior supertrend=upper[1] and price source>upper, +1 if prior supertrend=upper[1] and price source<=upper, +1 if prior supertrend!=upper[1] and price source<lower, else -1; supertrend=lower if direction=-1, else upper; T values taken on chart bars use lookahead_off (last completed T bar historically, forming T bar in realtime). Let T1-T5 denote the five source timeframes in increasing duration.
Calculation: Current run length(S,T) = consecutive T bars through the evaluated bar whose ALMA-SD regime is S, computed on T bars and taken on chart bars using lookahead_off (last completed T bar historically, forming T bar in realtime).
Calculation: Average run length(S,T,W) = arithmetic mean of completed S-regime run lengths ending within the last W bars of T, computed on T bars and taken on chart bars using lookahead_off (last completed T bar historically, forming T bar in realtime).
Long: ALMA-SD regime(price source, T1 ALMA length, T1 offset, T1 sigma, T1 SD length, T1 factor, T1) has direction < 0.
Short: ALMA-SD regime(price source, T1 ALMA length, T1 offset, T1 sigma, T1 SD length, T1 factor, T1) has direction > 0.
Long: ALMA-SD regime(price source, T2 ALMA length, T2 offset, T2 sigma, T2 SD length, T2 factor, T2) has direction < 0.
Short: ALMA-SD regime(price source, T2 ALMA length, T2 offset, T2 sigma, T2 SD length, T2 factor, T2) has direction > 0.
Long: ALMA-SD regime(price source, T3 ALMA length, T3 offset, T3 sigma, T3 SD length, T3 factor, T3) has direction < 0.
Short: ALMA-SD regime(price source, T3 ALMA length, T3 offset, T3 sigma, T3 SD length, T3 factor, T3) has direction > 0.
Long: ALMA-SD regime(price source, T4 ALMA length, T4 offset, T4 sigma, T4 SD length, T4 factor, T4) has direction < 0.
Short: ALMA-SD regime(price source, T4 ALMA length, T4 offset, T4 sigma, T4 SD length, T4 factor, T4) has direction > 0.
Long: ALMA-SD regime(price source, T5 ALMA length, T5 offset, T5 sigma, T5 SD length, T5 factor, T5) has direction < 0.
Short: ALMA-SD regime(price source, T5 ALMA length, T5 offset, T5 sigma, T5 SD length, T5 factor, T5) has direction > 0.
Long: when the chart timeframe is the selected bar-coloring source, ALMA-SD regime(price source, chart-duration-selected ALMA length, offset, sigma, SD length, factor, chart timeframe) has direction < 0.
Short: when the chart timeframe is the selected bar-coloring source, ALMA-SD regime(price source, chart-duration-selected ALMA length, offset, sigma, SD length, factor, chart timeframe) has direction > 0.
Long: ALMA(price source, T1 ALMA length, T1 offset, T1 sigma, T1) >= ALMA(price source, T2 ALMA length, T2 offset, T2 sigma, T2).
Short: ALMA(price source, T1 ALMA length, T1 offset, T1 sigma, T1) < ALMA(price source, T2 ALMA length, T2 offset, T2 sigma, T2).
Long: ALMA(price source, T2 ALMA length, T2 offset, T2 sigma, T2) >= ALMA(price source, T3 ALMA length, T3 offset, T3 sigma, T3).
Short: ALMA(price source, T2 ALMA length, T2 offset, T2 sigma, T2) < ALMA(price source, T3 ALMA length, T3 offset, T3 sigma, T3).
Long: ALMA(price source, T3 ALMA length, T3 offset, T3 sigma, T3) >= ALMA(price source, T4 ALMA length, T4 offset, T4 sigma, T4).
Short: ALMA(price source, T3 ALMA length, T3 offset, T3 sigma, T3) < ALMA(price source, T4 ALMA length, T4 offset, T4 sigma, T4).
Long: ALMA(price source, T4 ALMA length, T4 offset, T4 sigma, T4) >= ALMA(price source, T5 ALMA length, T5 offset, T5 sigma, T5).
Short: ALMA(price source, T4 ALMA length, T4 offset, T4 sigma, T4) < ALMA(price source, T5 ALMA length, T5 offset, T5 sigma, T5).
Long: T1 regime is bullish AND Current run length(bullish,T1) > T1 multiplier * Average run length(bullish,T1,T1 average window).
Short: T1 regime is bearish AND Current run length(bearish,T1) > T1 multiplier * Average run length(bearish,T1,T1 average window).
Long: T2 regime is bullish AND Current run length(bullish,T2) > T2 multiplier * Average run length(bullish,T2,T2 average window).
Short: T2 regime is bearish AND Current run length(bearish,T2) > T2 multiplier * Average run length(bearish,T2,T2 average window).
Long: T3 regime is bullish AND Current run length(bullish,T3) > T3 multiplier * Average run length(bullish,T3,T3 average window).
Short: T3 regime is bearish AND Current run length(bearish,T3) > T3 multiplier * Average run length(bearish,T3,T3 average window).
Long: T4 regime is bullish AND Current run length(bullish,T4) > T4 multiplier * Average run length(bullish,T4,T4 average window).
Short: T4 regime is bearish AND Current run length(bearish,T4) > T4 multiplier * Average run length(bearish,T4,T4 average window).
Long: T5 regime is bullish AND Current run length(bullish,T5) > T5 multiplier * Average run length(bullish,T5,T5 average window).
Short: T5 regime is bearish AND Current run length(bearish,T5) > T5 multiplier * Average run length(bearish,T5,T5 average window).
Long: MTF overheat labels are enabled AND either reversal-only mode is disabled and at least K selected T1-T5 have a bullish regime with Current run length(bullish,Ti) > Ti multiplier * Average run length(bullish,Ti,Ti average window), or reversal-only mode is enabled and at least K selected T1-T5 met that condition on the previous chart bar and the chart-timeframe regime changed from bullish to bearish on the current bar.
Short: MTF overheat labels are enabled AND either reversal-only mode is disabled and at least K selected T1-T5 have a bearish regime with Current run length(bearish,Ti) > Ti multiplier * Average run length(bearish,Ti,Ti average window), or reversal-only mode is enabled and at least K selected T1-T5 met that condition on the previous chart bar and the chart-timeframe regime changed from bearish to bullish on the current bar.