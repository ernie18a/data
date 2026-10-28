Calculation: Timeframe KDJ = For each of three selected timeframes, use that timeframe’s current bar (which may still be forming) to calculate RSV = 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback); K = 3-period SMA of RSV, D = 3-period SMA of K, J = 3K − 2D. The lookback is either fixed, or adaptive to that timeframe’s ATR(14)/close, mapping volatility to a shorter or longer lookback; the three timeframes use the same selected method.
Calculation: Smoothed weighted K, D, J = EMA of the weighted average of the corresponding K, D, J values from the three timeframes. The same timeframe weights and EMA length apply to all three.
Calculation: Smoothed total = EMA of the average of weighted K, weighted D, and weighted J.
Long: Smoothed J < 20 AND smoothed K crosses above smoothed D
Long: Smoothed J > 20 AND smoothed J < 40 AND smoothed K crosses above smoothed D
Long: Smoothed K > its previous value AND smoothed D < its previous value AND absolute difference between smoothed K and D < 5 AND smoothed total < 40
Long: Current low < low on the prior bar that confirmed a pivot low (10 bars left and right) AND current smoothed J > smoothed J on the prior bar that confirmed a pivot low
Long: One bar after the bullish divergence condition is true
Short: Smoothed J > 80 AND smoothed K crosses below smoothed D
Short: Smoothed J > 60 AND smoothed J < 80 AND smoothed K crosses below smoothed D
Short: Smoothed K < its previous value AND smoothed D > its previous value AND absolute difference between smoothed K and D < 5 AND smoothed total > 60
Short: Current high > high on the prior bar that confirmed a pivot high (10 bars left and right) AND current smoothed J < smoothed J on the prior bar that confirmed a pivot high
Short: One bar after the bearish divergence condition is true
Exit: Long, (smoothed K < smoothed D crossing OR smoothed K < its previous value AND smoothed D > its previous value AND absolute difference between smoothed K and D < 5 AND smoothed total > 60) AND low reaches the active trailing stop activated at the signal bar’s open
Exit: Short, (smoothed K > smoothed D crossing OR smoothed K > its previous value AND smoothed D < smoothed D’s previous value AND absolute difference between smoothed K and D < 5 AND smoothed total < 40) AND high reaches the active trailing stop activated at the signal bar’s open