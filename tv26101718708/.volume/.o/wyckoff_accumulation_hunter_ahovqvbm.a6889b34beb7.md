Calculation: Drawdown = (close − highest close over a longer lookback) / highest close over that lookback
Calculation: Average dollar volume = rolling average of close × volume, converted to average daily turnover
Calculation: Edge band = drawdown between the shallow and deep drawdown cutoffs
Calculation: Base maturity = count of new lows over a recent window is no greater than the allowed maximum; a new low is low less than or equal to the prior rolling low over a longer lookback
Calculation: Spring reference = lowest low over a recent window, shifted back by the configured level age
Calculation: Reclaim candle = close > open AND (close − low) / (high − low) is at least the midpoint of the bar’s range
Calculation: Spring = (low < Spring reference AND close > Spring reference) OR (prior low < prior Spring reference AND prior close < prior Spring reference AND close > prior Spring reference) OR (lowest low and lowest close over the spring window shifted back one bar are both below the Spring reference AND close > Spring reference AND prior close ≤ Spring reference); each alternative also requires a Reclaim candle
Calculation: Relative-strength position = position of close / same-timeframe benchmark close within its rolling high-low range
Calculation: Price position = position of close within the rolling range from lowest low to highest high
Calculation: Discount zone = close is below the midpoint of its rolling high-low range
Calculation: Volume z-score = (volume − rolling mean volume) / rolling standard deviation of volume
Calculation: Invalidation level = clamp the recent rolling low reduced by the configured percentage, with lower and upper bounds set as configured percentages below entry price
Long: Drawdown ≤ the configured minimum drawdown AND average dollar volume ≥ the configured liquidity floor AND Edge band AND Base maturity AND Spring AND bar is confirmed AND bars since the prior entry signal ≥ the configured cooldown
Long: Drawdown ≤ the shallow drawdown cutoff AND Drawdown > the deep drawdown cutoff AND close ≤ the recent structural low × the configured floor multiplier AND Base maturity AND Spring AND bar is confirmed AND bars since the prior entry signal ≥ the configured cooldown
Long: Drawdown ≤ the shallow drawdown cutoff AND Drawdown > the deep drawdown cutoff AND close ≤ the recent structural low × the configured floor multiplier AND Base maturity AND Spring AND bar is confirmed AND bars since the prior entry signal ≥ the configured cooldown AND Relative-strength position exceeds Price position by the configured margin while Price position is in its lower range AND Discount zone
Long: Drawdown ≤ the shallow drawdown cutoff AND Drawdown > the deep drawdown cutoff AND close ≤ the recent structural low × the configured floor multiplier AND Base maturity AND Spring AND Relative-strength position exceeds Price position by the configured margin while Price position is in its lower range AND Discount zone AND bar is not confirmed
Exit: Long, close < Invalidation level AND Volume z-score ≥ the configured threshold OR bars since entry > the configured maximum holding bars