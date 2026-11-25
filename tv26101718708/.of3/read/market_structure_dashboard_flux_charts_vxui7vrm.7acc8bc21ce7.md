Calculation: Tn series = EMA, swing, structure, Order Block, Fair Value Gap, and reclaim values calculated on Tn bars and sampled onto chart bars; use the forming Tn bar in real time and the latest completed Tn bar historically; Tn is active when enabled and no shorter than the chart timeframe, for each T1 through T7
Calculation: Swing position = 100 × (chart close − swing low) / max(swing high − swing low, minimum tick); for Tn ranges, use the Tn swing levels with chart close
Calculation: Swing range direction = bearish if swing position < 0; bullish if > 100; otherwise bullish if the swing low has been swept and reclaimed, bearish if the swing high has been swept and reclaimed, otherwise bullish below the range midpoint and bearish at or above it; low-sweep flags reset on a new confirmed swing low and set after low < swing low, with reclaim when close > swing low; high-sweep flags reset on a new confirmed swing high and set after high > swing high, with reclaim when close < swing high
Calculation: Market structure bias = compare each latest confirmed swing high and low with the preceding swing of the same type; each type is +1 if higher and −1 otherwise; override the high type to +1 when close > preceding swing high and the low type to −1 when close < preceding swing low; bias is +1 if both resulting types are +1, −1 if both are −1, otherwise 0
Calculation: Order Block zones = use confirmed swing highs/lows with swing lookback on both sides; on a close crossover above a swing high, form a bullish zone from the low-to-high range of the lowest-low candle after that pivot through the current bar; on a close crossunder below a swing low, form a bearish zone from the high-to-low range of the highest-high candle after that pivot through the current bar; cap the search at the Order Block search limit, exclude same-direction overlapping zones, retain up to the Order Block count, and remove bullish zones when close < zone bottom or bearish zones when close > zone top
Calculation: Fair Value Gap zones = bullish when low one bar ago > high three bars ago, the candle two bars ago has close > open or close > its preceding close, low one bar ago < high two bars ago, and low two bars ago < high three bars ago; set zone bottom to high three bars ago and top to low one bar ago; bearish when high one bar ago < low three bars ago, the candle two bars ago has close < open or close < its preceding close, high one bar ago > low two bars ago, and high two bars ago > low three bars ago; set zone bottom to high one bar ago and top to low three bars ago; retain up to the Fair Value Gap count and remove bullish zones when low < zone bottom or bearish zones when high > zone top
Calculation: Nearest zone direction = for each zone type, compare the absolute distance from close to each bullish zone top and bearish zone bottom; select the closest zone, with ties bearish, and return neutral if no retained unmitigated zone exists
Calculation: Zone-in state = bullish when nearest direction is bullish and bullish distance ≥ 0, bearish when nearest direction is bearish and bearish distance ≤ 0, otherwise neutral
Calculation: Prior-period levels = high and low of the latest completed Tn bar, sampled onto chart bars; reset each period's sweep flags when a new Tn period begins, set the low flag after chart low < prior-period low and reclaim when chart close > that low, and set the high flag after chart high > prior-period high and reclaim when chart close < that high; use T8 through T10
Calculation: Trend-bias percentage = 100 × weighted factor score / maximum weighted score; for each active Tn with positive weight, multiply the sum of enabled structure, nearest Order Block, nearest Fair Value Gap, EMA, and swing factors by that Tn's separate weight; direction factors are +1 bullish, −1 bearish, 0 neutral; swing factor is −1 below the swing low, +1 above the swing high, +1 below the lower swing-position threshold, −1 above the upper threshold, otherwise 0; maximum score is the sum of each included weight times the number of enabled factors; percentage is 0 when maximum score is 0
Calculation: Trend-bias state = bullish above the strong-bias threshold, lean bullish above the lean-bias threshold, lean bearish below the negative lean-bias threshold, bearish below the negative strong-bias threshold, otherwise neutral
Calculation: Volume state = volume percentage is 100 × volume / SMA(volume, volume lookback); state is extreme above the extreme-volume threshold, high above the high-volume threshold, normal above the normal-volume threshold, low above the low-volume threshold, otherwise very low
Calculation: Volatility state = 100 × ATR(ATR period) / SMA(ATR(ATR period), volatility average lookback); state is high above the high-volatility threshold, normal above the normal-volatility threshold, otherwise low
Long: Tn close > EMA(Tn close, EMA lookback) for any active T1 through T7
Short: Tn close ≤ EMA(Tn close, EMA lookback) for any active T1 through T7
Long: Market structure bias = +1 on any active T1 through T7
Short: Market structure bias = −1 on any active T1 through T7
Long: On chart bars, a new confirmed swing high is at least as high as the preceding confirmed swing high or has no preceding swing high; or a new confirmed swing low is at least as high as the preceding confirmed swing low or has no preceding swing low
Short: On chart bars, a new confirmed swing high is lower than the preceding confirmed swing high; or a new confirmed swing low is lower than the preceding confirmed swing low
Long: Swing range direction is bullish on chart bars or for any active T1 through T7
Short: Swing range direction is bearish on chart bars or for any active T1 through T7
Long: The nearest retained unmitigated Order Block direction is bullish on chart bars or on any active T1 through T7
Short: The nearest retained unmitigated Order Block direction is bearish on chart bars or on any active T1 through T7
Long: The nearest retained unmitigated Fair Value Gap direction is bullish on chart bars or on any active T1 through T7
Short: The nearest retained unmitigated Fair Value Gap direction is bearish on chart bars or on any active T1 through T7
Long: Trend-bias state is bullish or lean bullish
Short: Trend-bias state is bearish or lean bearish
Long: The volume state changes from the preceding chart bar to high or extreme
Short: The volume state changes from the preceding chart bar to low or very low
Long: Volatility state is low on chart bars
Short: Volatility state is high on chart bars
Long: Prior-period swing range direction is bullish for T8, T9, or T10
Short: Prior-period swing range direction is bearish for T8, T9, or T10
Long: Chart close crosses above the prior-period high for T8, T9, or T10
Short: Chart close crosses below the prior-period low for T8, T9, or T10
Long: A prior-period low has been swept and reclaimed for T8, T9, or T10
Short: A prior-period high has been swept and reclaimed for T8, T9, or T10