Calculation: 4-hour trend = chart close is above (bullish) or below (bearish) the 4-hour short EMA, with the short EMA above or below the 4-hour long EMA, respectively; use the still-forming 4-hour bar.
Calculation: Daily, weekly, and monthly trend = chart close is above (bullish) or below (bearish) both EMAs for that timeframe; use the still-forming timeframe bar. For each timeframe, the two EMA lengths have a shorter and a longer length.
Calculation: Swing midpoint = midpoint of the highest high and lowest low over the swing lookback, including the current bar. Discount = close below midpoint; premium = close above midpoint. Deep discount/premium = close is below/above the configured lower/upper range-position threshold.
Calculation: Bullish order block = the most recent prior down candle followed by a close above its high, with the current candle body greater than a configured multiple of that prior candle's range. Bearish order block = the inverse. In an order block = current bar's high-low range overlaps that candle's high-low range and the block is within its configured age limit.
Calculation: Sell-side sweep = current low is below the lowest prior low over the liquidity lookback, close is above open, and close is above 60% of the current bar's range measured from its low. Buy-side sweep = current high is above the highest prior high over that lookback, close is below open, and close is below 60% of the range measured from its high. Recent sweep = that sweep occurred within the configured recent-bar window.
Calculation: Bullish FVG = current low is above the high two bars ago by at least the configured minimum gap size. Bearish FVG = current high is below the low two bars ago by at least that size. Near an unfilled FVG = current bar range overlaps the most recently detected gap; clear the gap once fully filled.
Calculation: Bullish BOS = close is above the last confirmed pivot high; bearish BOS = close is below the last confirmed pivot low. Pivots use equal left and right confirmation spans.
Calculation: Daily score = configured weighted sum of 4-hour/daily trend alignment, correctly zoned order block with 4-hour bias, either recent sweep, volume above its rolling average by a configured multiple, optimal session time outside avoid times, either BOS, and either near unfilled FVG.
Calculation: Weekly score = configured weighted sum of weekly/monthly trend alignment, daily/weekly trend alignment, deep zone aligned with weekly trend, either recent sweep, either in-range order block, and either fresh order block.
Calculation: Monthly score = configured weighted sum of monthly/weekly trend alignment, order block in the corresponding deep zone, either recent sweep, daily/weekly/monthly trend alignment, and extreme range position.
Calculation: Optimal session time and avoid time are determined from the chart bar timestamp; avoid the configured lunch interval and first minutes of the configured opening hour.
Long: sell-side sweep.
Short: buy-side sweep.
Long: bullish BOS.
Short: bearish BOS.
Long: bullish FVG.
Short: bearish FVG.
Long: in bullish order block.
Short: in bearish order block.
Long: daily score meets its minimum threshold AND 4-hour trend is bullish AND price is in discount AND (in bullish order block OR recent sell-side sweep OR near an unfilled bullish FVG) AND time is not avoid time.
Short: daily score meets its minimum threshold AND 4-hour trend is bearish AND price is in premium AND (in bearish order block OR recent buy-side sweep OR near an unfilled bearish FVG) AND time is not avoid time.
Long: weekly score meets its minimum threshold AND weekly and daily trends are bullish AND price is in discount AND (in bullish order block OR recent sell-side sweep).
Short: weekly score meets its minimum threshold AND weekly and daily trends are bearish AND price is in premium AND (in bearish order block OR recent buy-side sweep).
Long: monthly score meets its minimum threshold AND monthly and weekly trends are bullish AND price is in deep discount AND price is in a bullish order block.
Short: monthly score meets its minimum threshold AND monthly and weekly trends are bearish AND price is in deep premium AND price is in a bearish order block.
Exit: Long, price <= entry price minus the configured stop distance for the entry timeframe OR price >= entry price plus that stop distance times its configured reward-to-risk ratio.
Exit: Short, price >= entry price plus the configured stop distance for the entry timeframe OR price <= entry price minus that stop distance times its configured reward-to-risk ratio.