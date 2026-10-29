Calculation: Prior-period high/low = high/low of the preceding completed higher-timeframe period
Calculation: Reaction excursion = maximum movement from the touched level in the direction away from it, measured only from bars after the touch bar
Calculation: Breakout excursion = maximum movement from the touched level through it, measured only from bars after the touch bar
Calculation: Retest zone = touched level ± the configured tolerance multiplied by the frozen ATR
Calculation: Retest success rate = completed retests reaching the configured target before invalidation / all completed retests
Long: First touch of a prior-period low, then reaction excursion reaches its configured threshold before breakout excursion reaches its configured threshold, within the configured evaluation horizon
Long: First touch of a prior-period high, then breakout excursion reaches its configured threshold before reaction excursion reaches its configured threshold, within the configured evaluation horizon
Long: For a prior-period high whose completed breakout count exceeds its completed reaction count, a confirmed close above the level is followed within the configured retest window by a touch of the retest zone and a close above the level; require a bullish candle when directional-candle confirmation is enabled
Long: For the selected prior-period high, completed retest count for the applicable volatility regime is at least the configured minimum and its retest success rate is at least the configured minimum
Short: First touch of a prior-period high, then reaction excursion reaches its configured threshold before breakout excursion reaches its configured threshold, within the configured evaluation horizon
Short: First touch of a prior-period low, then breakout excursion reaches its configured threshold before reaction excursion reaches its configured threshold, within the configured evaluation horizon
Short: For a prior-period low whose completed breakout count exceeds its completed reaction count, a confirmed close below the level is followed within the configured retest window by a touch of the retest zone and a close below the level; require a bearish candle when directional-candle confirmation is enabled
Short: For the selected prior-period low, completed retest count for the applicable volatility regime is at least the configured minimum and its retest success rate is at least the configured minimum
Exit: long, after a confirmed bullish retest, high reaches the configured target above the level OR close falls below the configured invalidation boundary below the level
Exit: short, after a confirmed bearish retest, low reaches the configured target below the level OR close rises above the configured invalidation boundary above the level