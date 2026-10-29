Calculation: Higher-timeframe high/low = high/low of the latest completed bar aggregated to a timeframe higher than the chart timeframe
Long: close > highest high of the previous lookback window
Long: close > highest high of the previous lookback window AND close[1] < lowest low of the lookback window ending two bars ago
Long: low = lowest low of the lookback window ending on the current bar
Long: low > high[2]
Long: close > highest high of the previous lookback window AND close > higher-timeframe low AND low > high[2]
Short: close < lowest low of the previous lookback window
Short: close < lowest low of the previous lookback window AND close[1] > highest high of the lookback window ending two bars ago
Short: high = highest high of the lookback window ending on the current bar
Short: high < low[2]
Short: close < lowest low of the previous lookback window AND close < higher-timeframe high AND high < low[2]