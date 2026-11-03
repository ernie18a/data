Calculation: Last swing high = high from the longer lookback’s midpoint bar when it is the highest high in the centered window; initialize from the longest lookback high.
Calculation: Last swing low = low from the longer lookback’s midpoint bar when it is the lowest low in the centered window; initialize from the longest lookback low.
Calculation: Swing midpoint = (last swing high + last swing low) / 2
Calculation: Bullish order block = previous bar closes below its open AND high three bars ago < low one bar ago AND current close > last swing low AND the lowest low over the liquidity lookback < current low − current close × liquidity tolerance AND current close < swing midpoint; its zone is the previous bar’s low to high.
Calculation: Bearish order block = previous bar closes above its open AND low three bars ago > high one bar ago AND current close < last swing high AND the highest high over the liquidity lookback > current high + current close × liquidity tolerance AND current close > swing midpoint; its zone is the previous bar’s low to high.
Calculation: Active order block = latest qualifying bullish or bearish order block, retained until invalidated by a close below its low (bullish) or above its high (bearish); replace it when a new qualifying order block is detected while flat.
Calculation: Trend EMA = EMA of close on a higher timeframe, using the current higher-timeframe bar (which may still be forming).
Long: Flat AND active order block is bullish AND low ≤ its high + current close × touch buffer AND close > trend EMA
Short: Flat AND active order block is bearish AND high ≥ its low − current close × touch buffer AND close < trend EMA
Exit: Long, low ≤ stop price OR high ≥ target price
Exit: Short, high ≥ stop price OR low ≤ target price