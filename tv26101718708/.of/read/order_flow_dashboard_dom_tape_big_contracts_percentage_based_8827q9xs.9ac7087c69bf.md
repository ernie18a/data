Calculation: Close position = (close - low) / (high - low) when high > low; otherwise 0.5.
Calculation: Estimated buy volume = volume × close position; estimated sell volume = volume × (1 - close position). If the optional session filter is enabled, both are zero for bars outside the configured exchange-time session.
Calculation: DOM buy and sell totals = rolling sums of estimated buy and sell volume, respectively, over the DOM lookback. DOM buy percentage = 100 × buy total / (buy total + sell total), or 50 when the denominator is zero; DOM sell percentage = 100 - DOM buy percentage. DOM net delta = DOM buy total - DOM sell total.
Calculation: Aggressive buy volume = volume × 2 × max(close position - 0.5, 0); aggressive sell volume = volume × 2 × max(0.5 - close position, 0). If the optional session filter is enabled, both are zero for bars outside the configured exchange-time session. Aggressive buy and sell totals are their respective rolling sums over the independent tape lookback. Aggressive buy share = 100 × buy total / (buy total + sell total), or 50 when the denominator is zero; aggressive sell share = 100 - aggressive buy share.
Calculation: Cumulative delta = running sum of estimated buy volume minus estimated sell volume, reset to zero on the bar at the configured daily reset time; exclude that reset bar's volume from the sum.
Long: DOM buy percentage > DOM sell percentage.
Short: DOM sell percentage > DOM buy percentage.
Long: Aggressive buy share > aggressive sell share.
Short: Aggressive sell share > aggressive buy share.
Long: DOM buy percentage > DOM alert threshold.
Short: DOM sell percentage > DOM alert threshold.
Long: Aggressive buy share > tape alert threshold.
Short: Aggressive sell share > tape alert threshold.
Long: DOM buy percentage > DOM sell percentage AND aggressive buy share > aggressive sell share.
Short: DOM sell percentage > DOM buy percentage AND aggressive sell share > aggressive buy share.
Long: DOM net delta >= 0.
Short: DOM net delta < 0.
Long: Cumulative delta >= 0.
Short: Cumulative delta < 0.
Long: On the completed chart bar, or on any completed lower-timeframe bar within the completed chart bar, volume >= big-contract volume threshold AND close > open.
Short: On the completed chart bar, or on any completed lower-timeframe bar within the completed chart bar, volume >= big-contract volume threshold AND close < open.