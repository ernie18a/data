Calculation: Trigger bar = volume >= volume moving average (longer lookback) × spike multiplier.
Calculation: Trigger weight = size proxy × acceleration factor × recency factor; size proxy is volume or volume × (high − low), acceleration factor increases with volume above its baseline, and recency factor increases for more recent bars.
Calculation: Liquidation projection = trigger bar typical price × (1 − maintenance factor / leverage) for longs, or × (1 + maintenance factor / leverage) for shorts; typical price = (high + low + close) / 3.
Calculation: Wall power = sum of trigger weights for projections in the same price row; candidate walls are local power maxima above a fraction of the strongest row, retaining the strongest rows subject to minimum separation and a maximum count.
Calculation: Wall strength = 10 × wall power / strongest wall power.
Calculation: Strong wall = candidate wall with strength >= strength threshold; nearest strong wall above close is the short-liquidation wall, and nearest strong wall below close is the long-liquidation wall.
Calculation: Proximity distance = close × proximity percentage.
Long: close is within proximity distance of the nearest strong short-liquidation wall above close OR close crosses above that wall.
Short: close is within proximity distance of the nearest strong long-liquidation wall below close OR close crosses below that wall.