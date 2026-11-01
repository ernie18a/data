Calculation: Heikin Ashi close = (open + high + low + close) / 4; Heikin Ashi open = the average of the previous Heikin Ashi open and close, initialized to (open + close) / 2; Heikin Ashi high and low are the maximum and minimum of high, low, Heikin Ashi open, and Heikin Ashi close; source = (Heikin Ashi high + Heikin Ashi low + Heikin Ashi close) / 3.
Calculation: Oscillator components = EMA-smoothed normalized deviations of the source from its channel EMA, the source from its channel VWMA, and the volume-weighted candle body from zero. Normalize each by its channel EMA of absolute deviation and an ATR-dependent scale. Multiply the candle body by volume and capped square-root relative volume before normalization.
Calculation: Primary wave = the capped weighted average of the three oscillator components plus a weighted EMA of the change in the source-EMA normalized deviation; signal wave = SMA of the primary wave over a shorter smoothing period.
Calculation: Displayed money flow = EMA of a scaled SMA of the volume-body oscillator component.
Long: Primary wave >= signal wave.
Short: Primary wave < signal wave.
Long: Displayed money flow >= 0.
Short: Displayed money flow < 0.
Long: Signal wave <= the extreme oversold threshold.
Short: Signal wave >= the extreme overbought threshold.
Long: All three oscillator components > 0 AND signal wave <= the oversold threshold.
Short: All three oscillator components < 0 AND signal wave >= the overbought threshold.
Long: A newly confirmed signal-wave pivot low has a higher wave value and a lower corresponding price low than the preceding signal-wave pivot low AND pivot spacing is within its minimum and maximum bounds AND wave separation and ATR-scaled price separation meet their minimums.
Short: A newly confirmed signal-wave pivot high has a lower wave value and a higher corresponding price high than the preceding signal-wave pivot high AND pivot spacing is within its minimum and maximum bounds AND wave separation and ATR-scaled price separation meet their minimums.
Long: A newly confirmed signal-wave pivot low has a lower wave value and a higher corresponding price low than the preceding signal-wave pivot low AND pivot spacing is within its minimum and maximum bounds AND wave separation and ATR-scaled price separation meet their minimums.
Short: A newly confirmed signal-wave pivot high has a higher wave value and a lower corresponding price high than the preceding signal-wave pivot high AND pivot spacing is within its minimum and maximum bounds AND wave separation and ATR-scaled price separation meet their minimums.
Calculation: Coverage limitation = This is a partial extraction. The diamond, top/bottom, swing-divergence, dashboard divergence, and signal-sync decisions and their complete dependencies are not specified, so this framework alone cannot reproduce all READ decisions.