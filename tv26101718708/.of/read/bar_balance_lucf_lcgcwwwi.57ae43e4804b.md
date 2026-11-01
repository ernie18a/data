Calculation: Intrabar counts U, D and N = weighted counts of completed lower-timeframe bars within each completed chart bar whose close is respectively greater than, less than, or equal to open. Count each intrabar as one until its index exceeds the ceiling of half the running average number of intrabars per chart bar, then apply the later-intrabar weight. T = U + D + N.
Calculation: Dampener = either 1, (U + D) / T, or an EMA of (U + D) / T using a selected shorter or longer smoothing lookback.
Calculation: Instant balance = (U - D) × dampener. Its bullish and bearish states are U > D and U < D.
Calculation: Average balance = (EMA(U) - EMA(D)) × dampener, using the same longer lookback for both EMAs.
Calculation: Momentum balance = (RSI((EMA(U) - SMA(U)) - (EMA(D) - SMA(D)), shorter momentum lookback) - 50) × dampener. The EMAs use the average-balance lookback; the SMAs use twice that lookback.
Calculation: Combined balance = dampener × (number of bullish instant, average and momentum balance states - number of their bearish states). Average and momentum balance states are bullish above zero and bearish below zero.
Calculation: Selected divergence = selected instant, average, momentum or combined balance is bullish AND close <= open, or is bearish AND close > open. Instant balance uses its separately defined bullish and bearish states; the other balances use greater than or less than zero.
Calculation: First four bullish marker conditions = combined balance = 3 × dampener; U / T > selected ratio AND close > open; previous bar has bullish selected divergence AND close > open AND current bar has no selected divergence; selected average, momentum or combined balance crosses above zero. The bearish conditions are combined balance = -3 × dampener; D / T > selected ratio AND close <= open; previous bar has bearish selected divergence AND close <= open AND current bar has no selected divergence; the selected balance crosses below zero. The divergence and transition selections are independent.
Calculation: Marker bias = rolling sum over the marker-bias lookback of the number of true first four bullish marker conditions minus the number of true first four bearish marker conditions, multiplied by dampener.
Calculation: Selected line = instant balance, average balance, momentum balance, marker bias, combined balance, or EMA(U) × dampener using a separate average lookback.
Calculation: Divergence levels = initialize upper and lower levels to the selected line. A level divergence is a selected divergence using an independent balance selection, optionally also including (U + D) / T < 0.5. On each bar first compare the selected line with the previous upper and lower levels, substituting zero for an unavailable level, and remember whether either level has been breached since the last reset. On a level divergence immediately following another, expand the levels to include the line. Otherwise, if a breach has occurred, reset both levels to the line and clear the breach and current outside states; if no breach has occurred and the line is inside the levels, expand the levels to include it. Outside states are otherwise determined by comparison with the previous levels.
Calculation: Gradient direction = bullish after its source crosses above its center and bearish after it crosses below; retain the previous direction when the source equals the center. The source is instant, average, momentum, marker bias or combined balance with center zero, or the selected line with center equal to the midpoint of the current divergence levels.
Long: U > D.
Short: U <= D.
Long: Average balance > 0 OR momentum balance > 0 OR marker bias > 0 OR combined balance > 0.
Short: Average balance <= 0 OR momentum balance <= 0 OR marker bias <= 0 OR combined balance <= 0.
Long: Gradient direction is bullish.
Short: Gradient direction is bearish.
Long: Any first four bullish marker conditions is true.
Short: Any first four bearish marker conditions is true.
Long: Marker bias crossed above zero on the previous bar.
Short: Marker bias crossed below zero on the previous bar.
Long: Selected line is above the previous upper divergence level AND the previous bar's upper outside state is false AND the current upper outside state is true.
Short: Selected line is below the previous lower divergence level AND the previous bar's lower outside state is false AND the current lower outside state is true.