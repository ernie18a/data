Calculation: Supertrend direction = Supertrend(hl2, P, M) direction, bullish or bearish
Calculation: Pivot state(Q) = bearish if high[Q] > highest(high, Q), bullish if low[Q] < lowest(low, Q), otherwise unchanged; Q is I or L, where L > I
Calculation: Pivot high level(Q) = high[Q] on each bar where Pivot state(Q) changes from bullish to bearish, otherwise unchanged
Calculation: Pivot low level(Q) = low[Q] on each bar where Pivot state(Q) changes from bearish to bullish, otherwise unchanged
Calculation: Bullish break(Q) = close crosses above Pivot high level(Q) for the first time since that level was set; for Q = I, also Pivot high level(I) != Pivot high level(L)
Calculation: Bearish break(Q) = close crosses below Pivot low level(Q) for the first time since that level was set; for Q = I, also Pivot low level(I) != Pivot low level(L)
Calculation: Bullish structure = Bullish break(L) OR Bullish break(I)
Calculation: Bearish structure = Bearish break(L) OR Bearish break(I)
Calculation: Last break direction(Q) = bullish if the most recent of Bullish break(Q) or Bearish break(Q) is Bullish break(Q), else bearish
Calculation: Active bullish OB(Q) = high and low of the lowest-low bar from the bar whose high equals Pivot high level(Q) through the current bar, added on each Bullish break(Q) and removed on the first bar whose low falls below the OB low
Calculation: Active bearish OB(Q) = high and low of the highest-high bar from the bar whose low equals Pivot low level(Q) through the current bar, added on each Bearish break(Q) and removed on the first bar whose high rises above the OB high
Calculation: Bullish FVG(T1) = on each chart bar where a new T1 bar starts, the forming T1 bar low > high two bars before the forming T1 bar AND last completed T1 bar close > that high AND (close - open) / open of last completed T1 bar > FVG threshold
Calculation: Bearish FVG(T1) = on each chart bar where a new T1 bar starts, the forming T1 bar high < low two bars before the forming T1 bar AND last completed T1 bar close < that low AND -(close - open) / open of last completed T1 bar > FVG threshold
Calculation: FVG threshold = G * (sum of |(close - open) / open| of last completed T1 bar over chart bars where a new T1 bar starts) / number of chart bars so far
Long: Supertrend direction = bullish
Short: Supertrend direction = bearish
Long: Supertrend direction = bullish AND Supertrend direction[1] = bearish
Short: Supertrend direction = bearish AND Supertrend direction[1] = bullish
Long: Bullish structure
Short: Bearish structure
Long: Last break direction(L) = bullish OR Last break direction(I) = bullish
Short: Last break direction(L) = bearish OR Last break direction(I) = bearish
Short: Active bullish OB(I) OR Active bullish OB(L) is removed on this bar
Long: Active bearish OB(I) OR Active bearish OB(L) is removed on this bar
Long: Bullish FVG(T1)
Short: Bearish FVG(T1)
Long: Supertrend direction = bullish AND Supertrend direction[1] = bearish AND (Bullish structure[k] for some k from 0 to W OR current bar range overlaps an Active bullish OB(I) among the K most recent Active OB(I) of either bias OR Bullish FVG(T1))
Short: Supertrend direction = bearish AND Supertrend direction[1] = bullish AND (Bearish structure[k] for some k from 0 to W OR current bar range overlaps an Active bearish OB(I) among the K most recent Active OB(I) of either bias OR Bearish FVG(T1))
Exit: long, close < Supertrend lower band(hl2, P, M)
Exit: short, close > Supertrend upper band(hl2, P, M)