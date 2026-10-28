Calculation: Major high = highest high over the configured lookback, excluding the current bar
Calculation: Major low = lowest low over the configured lookback, excluding the current bar
Calculation: Anchored VWAP = volume-weighted average of (high + low + close) / 3 from the configured anchor period, including its forming bar
Calculation: Outer VWAP bands = anchored VWAP plus or minus the configured band basis times the outer-band multiplier; the basis is either VWAP standard deviation or 1% of VWAP, according to the selected mode
Calculation: Volume average = simple moving average of volume over its configured lookback
Long: low < Major low AND close > Major low AND close > open AND (low <= lower outer VWAP band OR previous bar low <= previous bar lower outer VWAP band) AND volume > Volume average × configured volume multiplier
Short: high > Major high AND close < Major high AND close < open AND (high >= upper outer VWAP band OR previous bar high >= previous bar upper outer VWAP band) AND volume > Volume average × configured volume multiplier