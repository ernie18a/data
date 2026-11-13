Calculation: Z(x) = (x - SMA(x, N)) / stdev(x, N) over one shared lookback N, or 0 if stdev is 0
Calculation: Composite = weighted average of Z(percent rate of change of close over a lookback), Z(RSI of close), Z(volume / SMA(volume)), weights divided by their sum
Calculation: ATRrank = percent rank (0-100) of ATR within a lookback that is longer than the ATR length
Calculation: S = recursive EMA of Composite, seeded with the first Composite value, with alpha = 2/(L+1) and L recomputed every bar as max(round(Lmax - (Lmax - Lmin) * ATRrank/100), 1), where Lmax > Lmin (high volatility rank gives shorter L)
Calculation: Pivot low of S = S at the bar R bars ago is the lowest S over the previous Lb bars and the following R bars (pivot high is the mirror: highest). It is confirmed R bars after the pivot bar. The pivot price is the bar low (pivot low) or bar high (pivot high) at the pivot bar.
Long: S crosses above 0 OR S crosses above a fixed negative threshold (two alternative entry modes)
Long: bullish divergence at the bar where a pivot low of S is confirmed AND pivot price low < previous pivot-low price low AND S at this pivot low > S at the previous pivot low
Short: S crosses below 0 OR S crosses below a fixed positive threshold (two alternative entry modes)
Short: bearish divergence at the bar where a pivot high of S is confirmed AND pivot price high > previous pivot-high price high AND S at this pivot high < S at the previous pivot high
Exit: long, S crosses below a fixed exit level (default the zero line) OR low <= entry price - k * ATR (k is a stop multiplier)
Exit: short, S crosses above a fixed exit level (default the zero line) OR high >= entry price + k * ATR (k is a stop multiplier)