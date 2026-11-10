Calculation: Confirmed pivot high or low = a high or low with the specified number of bars on each side, confirmed only after the right-hand bars have completed; retain pivots in confirmation order.
Calculation: Directional strength = Wilder-smoothed true range and positive and negative directional movement over the same lookback; divide the smoothed directional movements by smoothed true range to obtain directional indices, carrying forward their last non-missing values, then Wilder-smooth their absolute difference divided by the greater of their sum and a denominator floor, scaled as ADX.
Calculation: Bullish score = count of true conditions among: latest confirmed price pivot low > preceding pivot low; close > shorter EMA of close AND shorter EMA > longer EMA; RSI > midpoint; directional strength >= strength threshold; volume >= its SMA multiplied by a spike factor AND close > open.
Calculation: Bearish score = count of true conditions among: latest confirmed price pivot high < preceding pivot high; close < shorter EMA of close AND shorter EMA < longer EMA; RSI < midpoint; directional strength >= strength threshold; volume >= its SMA multiplied by a spike factor AND close < open.
Long: bullish score >= score threshold.
Short: bearish score >= score threshold.
Long: latest confirmed price pivot low > preceding price pivot low.
Short: latest confirmed price pivot high < preceding price pivot high AND latest confirmed price pivot low <= preceding price pivot low, or fewer than two price pivot lows exist.
Long: close > shorter EMA of close AND shorter EMA > longer EMA.
Short: close < shorter EMA of close AND shorter EMA < longer EMA.
Long: RSI > midpoint AND RSI <= upper threshold.
Short: RSI <= midpoint AND RSI >= lower threshold.
Long: RSI < lower threshold.
Short: RSI > upper threshold.
Long: high > low AND lower wick >= body size multiplied by the large-wick factor AND upper wick <= body size multiplied by the small-wick factor.
Short: high > low AND upper wick >= body size multiplied by the large-wick factor AND lower wick <= body size multiplied by the small-wick factor.
Long: price pivot low AND RSI pivot low are confirmed on the current bar using the same divergence lookback AND the new price pivot low < the preceding price pivot low AND the new RSI pivot low > the preceding RSI pivot low; the preceding price and RSI pivots are selected independently.
Short: price pivot high AND RSI pivot high are confirmed on the current bar using the same divergence lookback AND the new price pivot high > the preceding price pivot high AND the new RSI pivot high < the preceding RSI pivot high; the preceding price and RSI pivots are selected independently.