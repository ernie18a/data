Calculation: Ichimoku lines = short-, medium-, and long-lookback midpoints of the highest high and lowest low; projected span A is the average of the short and medium midpoints, and projected span B is the long midpoint.
Calculation: Current cloud = projected spans A and B from displacement minus one chart bars ago; its upper and lower boundaries are the maximum and minimum of those spans.
Calculation: Price-to-cloud distance = (close minus the nearest cloud boundary) / ATR when close is outside the cloud; otherwise 0.
Calculation: Close momentum = (close minus close from displacement minus one chart bars ago) / ATR.
Long: Short-lookback midpoint crosses above medium-lookback midpoint.
Short: Short-lookback midpoint crosses below medium-lookback midpoint.
Long: Close crosses above the current cloud's upper boundary.
Short: Close crosses below the current cloud's lower boundary.
Long: Short-lookback midpoint crosses above medium-lookback midpoint AND close > open AND absolute price-to-cloud distance > 0 AND close momentum > 0 AND close momentum >= momentum threshold AND (higher-timeframe filter disabled OR last completed higher-timeframe close > last completed higher-timeframe current cloud's upper boundary).
Short: Short-lookback midpoint crosses below medium-lookback midpoint AND close < open AND absolute price-to-cloud distance > 0 AND close momentum < 0 AND absolute close momentum >= momentum threshold AND (higher-timeframe filter disabled OR last completed higher-timeframe close < last completed higher-timeframe current cloud's lower boundary).
Long: Close crosses above the current cloud's upper boundary AND close > open AND absolute price-to-cloud distance >= distance threshold AND close momentum > 0 AND close momentum >= momentum threshold AND (higher-timeframe filter disabled OR last completed higher-timeframe close > last completed higher-timeframe current cloud's upper boundary).
Short: Close crosses below the current cloud's lower boundary AND close < open AND absolute price-to-cloud distance >= distance threshold AND close momentum < 0 AND absolute close momentum >= momentum threshold AND (higher-timeframe filter disabled OR last completed higher-timeframe close < last completed higher-timeframe current cloud's lower boundary).
Long: Projected span A crosses above projected span B.
Short: Projected span A crosses below projected span B.
Long: Projected span A > projected span B.
Short: Projected span A <= projected span B.
Long: Last completed higher-timeframe close > last completed higher-timeframe current cloud's upper boundary.
Short: Last completed higher-timeframe close < last completed higher-timeframe current cloud's lower boundary.