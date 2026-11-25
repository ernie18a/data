Calculation: Confirmed swing high = high[swing lookback] > highest(high, swing lookback), after a confirmed swing low; confirmed swings alternate, starting with a low
Calculation: Confirmed swing low = low[swing lookback] < lowest(low, swing lookback), after a confirmed swing high or before any swing is recorded
Calculation: Swing range = absolute difference between the most recent confirmed swing high and low, or zero if either is missing
Calculation: Bullish order block zone = bounds of the candle with the lowest low, or lowest body low when body measurement is selected, between the broken swing high and breakout bar, excluding both; limit the scan to the scan maximum; if the anchor is not bearish, use an available immediately adjacent bearish candle with a lower low, choosing the more recent on a tie, or retain the anchor if neither qualifies
Calculation: Bearish order block zone = bounds of the candle with the highest high, or highest body high when body measurement is selected, between the broken swing low and breakout bar, excluding both; limit the scan to the scan maximum; if the anchor is not bullish, use an available immediately adjacent bullish candle with a higher high, choosing the more recent on a tie, or retain the anchor if neither qualifies
Calculation: Bullish FVG = low[0] > high[2] AND low[1] <= high[2] AND high[1] >= low[0]
Calculation: Bearish FVG = high[0] < low[2] AND high[0] >= low[1] AND high[1] >= low[2]
Calculation: Bullish FVG zone = top low[0], bottom high[2]
Calculation: Bearish FVG zone = top low[2], bottom high[0]
Calculation: Bullish implied FVG = high[0] > high[2] AND low[2] < low[0] AND low[0] <= high[2] AND high[2] - max(open[2], close[2]) > (max(open[2], close[2]) - min(open[2], close[2])) / 2 AND min(open[0], close[0]) - low[0] > (max(open[0], close[0]) - min(open[0], close[0])) / 2 AND low[0] > low[1] AND (high[2] + max(open[2], close[2])) / 2 < (min(open[0], close[0]) + low[0]) / 2 AND high[0] > high[1] AND close[1] > open[1]
Calculation: Bearish implied FVG = low[0] < low[2] AND high[2] > high[0] AND high[0] >= low[2] AND min(open[2], close[2]) - low[2] > (max(open[2], close[2]) - min(open[2], close[2])) / 2 AND high[0] - max(open[0], close[0]) > (max(open[0], close[0]) - min(open[0], close[0])) / 2 AND high[0] < high[1] AND (min(open[2], close[2]) + low[2]) / 2 > (high[0] + max(open[0], close[0])) / 2 AND low[0] < low[1] AND close[1] < open[1]
Calculation: Bullish implied FVG zone = top (min(open[0], close[0]) + low[0]) / 2, bottom (high[2] + max(open[2], close[2])) / 2
Calculation: Bearish implied FVG zone = top (min(open[2], close[2]) + low[2]) / 2, bottom (max(open[0], close[0]) + high[0]) / 2
Calculation: Bullish volume imbalance type 1 = open[0] > close[1] AND low[0] <= high[1] AND close[0] > open[0] AND close[1] > open[1]
Calculation: Bearish volume imbalance type 1 = open[0] < close[1] AND high[0] >= low[1] AND close[0] < open[0] AND close[1] < open[1]
Calculation: Bullish volume imbalance type 2 = open[0] < close[1] AND close[0] > open[0] AND close[1] > open[1] AND high[0] >= low[1]
Calculation: Bearish volume imbalance type 2 = open[0] > close[1] AND close[0] < open[0] AND close[1] < open[1] AND low[0] <= high[1]
Calculation: Bullish volume imbalance type 3 = (open[0] > close[1] OR open[0] < close[1]) AND close[0] > open[0] AND close[1] < open[1] AND high[0] >= low[1] AND low[0] <= high[1]
Calculation: Bearish volume imbalance type 3 = (open[0] < close[1] OR open[0] > close[1]) AND close[0] < open[0] AND close[1] > open[1] AND low[0] <= high[1] AND high[0] >= low[1]
Calculation: Bullish volume imbalance zone = type 1 top open[0], bottom close[1]; type 2 top close[1], bottom open[0]; type 3 top max(open[0], close[1]), bottom min(open[0], close[1])
Calculation: Bearish volume imbalance zone = type 1 top close[1], bottom open[0]; type 2 top open[0], bottom close[1]; type 3 top min(open[0], close[1]), bottom max(open[0], close[1])
Calculation: Bullish GAP zone = top low[0], bottom high[1] in true-gap mode; top open[0], bottom close[1] in gap-with-imbalance mode
Calculation: Bearish GAP zone = top low[1], bottom high[0] in true-gap mode; top close[1], bottom open[0] in gap-with-imbalance mode
Long: On a confirmed chart bar, the most recent confirmed swing high is unbroken AND close > swing high + swing range * breakout fraction
Short: On a confirmed chart bar, the most recent confirmed swing low is unbroken AND close < swing low - swing range * breakout fraction
Long: On chart bars when a new order block is published from any enabled T1–T5, the most recent confirmed Tn swing high is unbroken AND Tn close > Tn swing high + Tn swing range * breakout fraction; use the separate higher-timeframe swing lookback and publish one Tn bar after the breakout bar closes when higher-timeframe close confirmation is enabled, otherwise use the forming Tn bar
Short: On chart bars when a new order block is published from any enabled T1–T5, the most recent confirmed Tn swing low is unbroken AND Tn close < Tn swing low - Tn swing range * breakout fraction; use the separate higher-timeframe swing lookback and publish one Tn bar after the breakout bar closes when higher-timeframe close confirmation is enabled, otherwise use the forming Tn bar
Long: On a confirmed chart bar, bullish FVG
Short: On a confirmed chart bar, bearish FVG
Long: On a chart bar at the start of a new T1–T5 bar, low of the last completed Tn bar > high of the third-last completed Tn bar AND low of the second-last completed Tn bar <= high of the third-last completed Tn bar AND high of the second-last completed Tn bar >= low of the last completed Tn bar
Short: On a chart bar at the start of a new T1–T5 bar, high of the last completed Tn bar < low of the third-last completed Tn bar AND high of the last completed Tn bar >= low of the second-last completed Tn bar AND high of the second-last completed Tn bar >= low of the third-last completed Tn bar
Long: On a confirmed chart bar, bullish implied FVG
Short: On a confirmed chart bar, bearish implied FVG
Long: On a confirmed chart bar, (classic volume-imbalance selection AND bullish volume imbalance type 1) OR (advanced volume-imbalance selection AND (bullish volume imbalance type 1 OR type 2 OR type 3))
Short: On a confirmed chart bar, (classic volume-imbalance selection AND bearish volume imbalance type 1) OR (advanced volume-imbalance selection AND (bearish volume imbalance type 1 OR type 2 OR type 3))
Long: On a confirmed chart bar, high[1] < low[0]
Short: On a confirmed chart bar, low[1] > high[0]
Long: In liquidity-void mode, bullish FVG on the current chart bar AND bullish FVG on the prior chart bar AND a bullish FVG zone is already tracked
Short: In liquidity-void mode, bearish FVG on the current chart bar AND bearish FVG on the prior chart bar AND a bearish FVG zone is already tracked
Long: An active, armed chart-timeframe zone created by a bullish FVG intersects the current bar: low <= zone top AND high >= zone bottom
Short: An active, armed chart-timeframe zone created by a bearish FVG intersects the current bar: low <= zone top AND high >= zone bottom
Long: An active, armed chart-timeframe bullish implied FVG zone intersects the current bar: low <= zone top AND high >= zone bottom
Short: An active, armed chart-timeframe bearish implied FVG zone intersects the current bar: low <= zone top AND high >= zone bottom
Long: With inverse FVG enabled, an active armed chart-timeframe bearish FVG zone is crossed end to end by the current bar, with high >= zone top
Short: With inverse FVG enabled, an active armed chart-timeframe bullish FVG zone is crossed end to end by the current bar, with low <= zone bottom
Long: An active armed inverse zone formed from a bearish chart-timeframe FVG intersects the current bar: low <= zone top AND high >= zone bottom
Short: An active armed inverse zone formed from a bullish chart-timeframe FVG intersects the current bar: low <= zone top AND high >= zone bottom
Long: With breaker blocks enabled, an active armed bearish order block from the chart timeframe or T1–T5 is crossed end to end by a chart bar, with high >= zone top
Short: With breaker blocks enabled, an active armed bullish order block from the chart timeframe or T1–T5 is crossed end to end by a chart bar, with low <= zone bottom
Long: A bullish volume imbalance zone is active AND volume-imbalance extension is enabled AND ((mitigation mode is Mitigate AND the chart bar is confirmed AND low <= zone top) OR (mitigation mode is Engulf AND highlighting is enabled AND close >= zone bottom AND low < zone top))
Short: A bearish volume imbalance zone is active AND volume-imbalance extension is enabled AND ((mitigation mode is Mitigate AND the chart bar is confirmed AND high >= zone bottom) OR (mitigation mode is Engulf AND highlighting is enabled AND close <= zone top AND high > zone bottom))
Long: A bullish GAP zone is active AND GAP extension and highlighting are enabled AND ((mitigation mode is Engulf AND close >= zone bottom AND open >= zone bottom AND low < zone top) OR (mitigation mode is Rebalance AND low > zone bottom AND low < zone top))
Short: A bearish GAP zone is active AND GAP extension and highlighting are enabled AND ((mitigation mode is Engulf AND close <= zone top AND open <= zone top AND high > zone bottom) OR (mitigation mode is Rebalance AND high < zone top AND high > zone bottom))