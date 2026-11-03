Calculation: Strong bullish candle = close > open and close − open > (high − max(open, close)) + (min(open, close) − low)
Calculation: Strong bearish candle = close < open and open − close > (high − max(open, close)) + (min(open, close) − low)
Calculation: Bearish structure = a strong bearish candle whose close is below the low of the most recent strong bullish candle; its high and low are the structure high and structure low
Calculation: Structural breakout = close > the most recent bearish structure high, on a bar after that structure formed
Calculation: Bull and bear control feeds = on a strong bullish candle, low + 0.60 × (close − open); on a strong bearish candle, high − 0.60 × (open − close); otherwise carry forward the prior feed, or (high + low) / 2 if unavailable
Calculation: Bull control and bear control = EMA of their respective feeds; use the same lookback
Calculation: Radar compression = abs(bull control − bear control) / ATR
Calculation: Normalized strength = (close − open) / SMA(abs(close − open)); use the same lookback for numerator baseline
Calculation: Acceleration = normalized strength − prior-bar normalized strength
Calculation: Structural range = structure high − structure low
Calculation: Primary targets = structure high + n × structural range, for n = 1, 2, 3
Calculation: Extension targets = extension high + n × (extension high − extension low), for n = 1, 2, 3; extension high and low come from the first qualifying bullish candle closing at or above target 3 after target 3 is reached
Long: Chart-timeframe close > most recent bearish structure high, after that structure formed
Long: Higher-timeframe close > most recent bearish structure high, after that structure formed; use the still-forming higher-timeframe bar
Long: Confirmed chart-timeframe structural breakout event AND an active chart-timeframe structural cycle AND chart-timeframe close >= stored invalidation low AND no active trade-state AND primary target 1 has not already been reached
Long: Confirmed chart-timeframe close crosses above the chart-timeframe structural high AND higher-timeframe structural breakout is active (still-forming bar) AND close > max(bull control, bear control) AND bull control >= prior-bar bull control AND acceleration > 0 AND normalized strength > 0.7
Exit: Long, confirmed chart-timeframe close < stored structural invalidation low
Exit: Long, confirmed chart-timeframe close >= next unreached primary target (targets 1, 2, then 3 in order) OR confirmed chart-timeframe close >= next unreached extension target (targets 1, 2, then 3 in order)