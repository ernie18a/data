Calculation: FVG = first zone in the chart-bar search window with bounds [high[n], low[n-2]] when high[n] < low[n-2] AND close[n-1] > high[n], or bounds [high[n-2], low[n]] when low[n] > high[n-2] AND close[n-1] < low[n]
Calculation: MSS = bullish when close > high[1] AND close[1] < open[2]; bearish when close < low[1] AND close[1] > open[2]
Calculation: liquidity high = Highest(high, DOL lookback); liquidity low = Lowest(low, DOL lookback)
Calculation: range filter = high - low <= ATR(ATR lookback) * range multiplier
Calculation: protective stop = Lowest(low, stop lookback) - stop buffer for long; Highest(high, stop lookback) + stop buffer for short
Calculation: initial risk = absolute difference between entry price and protective stop
Long: close > moving_average(close, MA lookback, MA method, T1, last completed bar) AND moving_average(close, MA lookback, MA method, T1, last completed bar) > moving_average(close, MA lookback, MA method, T1, forming bar) AND ((Silver Bullet enabled AND time of day >= session start AND time of day < session end AND close < liquidity low AND low[1] <= liquidity low AND bullish MSS AND FVG high > 0 AND FVG low > 0 AND range filter AND close >= FVG low AND close <= FVG high) OR (2022 Model enabled AND no valid Silver Bullet setup AND close > liquidity low AND high[1] >= liquidity low AND bullish MSS AND FVG high > 0 AND FVG low > 0 AND range filter AND close >= FVG low AND close <= FVG high))
Short: close < moving_average(close, MA lookback, MA method, T1, last completed bar) AND moving_average(close, MA lookback, MA method, T1, last completed bar) < moving_average(close, MA lookback, MA method, T1, forming bar) AND ((Silver Bullet enabled AND time of day >= session start AND time of day < session end AND close > liquidity high AND high[1] >= liquidity high AND bearish MSS AND FVG high > 0 AND FVG low > 0 AND range filter AND close >= FVG low AND close <= FVG high) OR (2022 Model enabled AND no valid Silver Bullet setup AND close < liquidity high AND low[1] <= liquidity high AND bearish MSS AND FVG high > 0 AND FVG low > 0 AND range filter AND close >= FVG low AND close <= FVG high))
Exit: long, close <= protective stop
Exit: short, close >= protective stop
Exit: long, close >= entry price + initial risk * first target multiple
Exit: long, close >= entry price + initial risk * second target multiple
Exit: long, close >= entry price + initial risk * third target multiple
Exit: short, close <= entry price - initial risk * first target multiple
Exit: short, close <= entry price - initial risk * second target multiple
Exit: short, close <= entry price - initial risk * third target multiple